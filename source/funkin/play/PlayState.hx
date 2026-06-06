package funkin.play;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.event.EventData;
import funkin.data.event.EventRegistry;
import funkin.data.notekind.NoteKindRegistry;
import funkin.data.song.SongData.SongNoteData;
import funkin.data.stage.StageRegistry;
import funkin.data.style.StyleRegistry;
import funkin.graphics.FunkinBar;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.character.Character;
import funkin.play.character.HealthIcon;
import funkin.play.components.Countdown;
import funkin.play.components.Popups;
import funkin.play.cutscene.BaseCutscene;
import funkin.play.note.NoteDirection;
import funkin.play.note.NoteSprite;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.play.note.strum.Strumline;
import funkin.play.song.Song;
import funkin.play.song.Voices;
import funkin.play.stage.Stage;
import funkin.ui.FunkinState;
import funkin.ui.freeplay.FreeplaySubState;
import funkin.ui.sticker.StickerSubState;
import funkin.ui.story.StoryMenuSubState;
import funkin.util.MathUtil;
import funkin.util.RhythmUtil;
import funkin.util.SortUtil;

/**
 * A state where the gameplay occurs. Kinda like a "play" state. Hah! I said the thing!
 */
class PlayState extends FunkinState
{
	public static var instance:PlayState;
	public static var difficulty:String;
	public static var song:Song;

	public var songLoaded:Bool;
	public var songStarted:Bool;
	public var songEnded:Bool;
	public var songActive:Bool;

	/**
	 * TODO: Make this changeable ingame
	 */
	public var playbackRate(default, set):Float = 1;

	public var events:Array<EventData>;

	public var voices:Voices;
	public var style:Style;
	public var tallies:Tallies;

	public var score:Float;
	public var health:Float;
	public var healthLerp:Float;
	public var deaths:Int = 0;

	public var defaultZoom:Float;
	public var camZoom:Float;

	public var camFollow:FlxObject;
	public var camHUD:FlxCamera;

	public var cutscene:BaseCutscene;

	public var opponentStrumline:Strumline;
	public var playerStrumline:Strumline;

	public var healthBar:FunkinBar;
	public var healthBorder:FunkinSprite;

	public var opponentIcon:HealthIcon;
	public var playerIcon:HealthIcon;

	public var scoreText:FunkinText;
	public var timeText:FunkinText;

	public var countdown:Countdown;
	public var popups:Popups;

	public var stage:Stage;

	override public function create()
	{
		super.create();

		instance = this;
		style = StyleRegistry.instance.fetch(song.style);

		//
		// CAMERAS
		//

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject();
		camFollow.active = false;
		FlxG.camera.follow(camFollow, LOCKON, 0.035);

		//
		// HUD
		//

		opponentStrumline = new Strumline(style, false);
		opponentStrumline.x = 325;
		opponentStrumline.camera = camHUD;
		opponentStrumline.noteHit.add(opponentNoteHit);
		opponentStrumline.holdNoteHit.add(opponentHoldNoteHit);
		add(opponentStrumline);

		playerStrumline = new Strumline(style, true);
		playerStrumline.x = FlxG.width - opponentStrumline.x;
		playerStrumline.camera = camHUD;
		playerStrumline.noteHit.add(playerNoteHit);
		playerStrumline.noteMiss.add(playerNoteMiss);
		playerStrumline.holdNoteHit.add(playerHoldNoteHit);
		playerStrumline.holdNoteDrop.add(playerHoldNoteDrop);
		add(playerStrumline);

		healthBorder = FunkinSprite.create(0, 0, 'play/bar');
		healthBorder.screenCenter(X);
		healthBorder.active = false;
		healthBorder.camera = camHUD;
		healthBorder.zIndex = 1;
		add(healthBorder);

		healthBar = new FunkinBar(0, 0, Std.int(healthBorder.width - 7), Std.int(healthBorder.height - 10), 0, 1, true);
		healthBar.setColors(Constants.HEALTH_EMPTY_COLOR, Constants.HEALTH_FILL_COLOR);
		healthBar.camera = camHUD;
		add(healthBar);

		timeText = new FunkinText(0, 0, '1:23');
		timeText.setBorderStyle(OUTLINE, 0xFF000000, 3);
		timeText.size = 24;
		timeText.alignment = CENTER;
		timeText.camera = camHUD;
		add(timeText);

		scoreText = new FunkinText(0, 0, '123456');
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 3);
		scoreText.size = 15;
		scoreText.alignment = CENTER;
		scoreText.camera = camHUD;
		scoreText.zIndex = 2;
		add(scoreText);

		countdown = new Countdown(style);
		countdown.camera = camHUD;
		add(countdown);

		//
		// SETUP
		//

		stage = StageRegistry.instance.fetchStage(song.stage);
		add(stage);

		popups = new Popups(style);
		add(popups);

		defaultZoom = stage.zoom;

		loadCharacters();
		resetSong();

		refresh();

		updatePreferences();

		// Runs the create script event
		dispatch(new ScriptEvent(CREATE));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		//
		// SONG
		//

		if (songActive)
		{
			if (songLoaded)
			{
				if (songStarted)
				{
					// Lerping is used to update the conductor time as Lime audio lacks precision
					// One day this will be simplified to how it should be
					final ratio:Float = 1 - Math.exp(-42 * elapsed);

					conductor.time = FlxMath.lerp(conductor.time, FunkinSound.music.time + conductor.offset, ratio);
				}
				else
				{
					conductor.time += elapsed * Constants.MS_PER_SEC;

					if (conductor.time >= Math.max(0, conductor.offset))
						startSong();
				}

				conductor.update();

				voices.checkResync(FunkinSound.music.time);
			}

			opponentStrumline.process();
			playerStrumline.process();

			processEvents();
			processInput();
		}

		//
		// HUD
		//

		health = FlxMath.bound(health, healthBar.min, healthBar.max);
		healthLerp = MathUtil.lerp(healthLerp, health, 0.15);

		healthBar.value = healthLerp;

		if (opponentIcon != null)
		{
			opponentIcon.x = healthBar.fillPosition - opponentIcon.width + 15;
			opponentIcon.isDead = health > 0.8;
		}

		if (playerIcon != null)
		{
			playerIcon.x = healthBar.fillPosition - 15;
			playerIcon.isDead = health < 0.2;
		}

		scoreText.text = 'score: ${Std.int(score)} | misses: ${tallies.misses}';
		scoreText.screenCenter(X);

		if (!songEnded)
		{
			timeText.text = FlxStringUtil.formatTime((FunkinSound.music.length - FunkinSound.music.time) / Constants.MS_PER_SEC);
			timeText.screenCenter(X);
		}

		FlxG.camera.zoom = MathUtil.lerp(FlxG.camera.zoom, camZoom, 0.03);
		camHUD.zoom = MathUtil.lerp(camHUD.zoom, 1, 0.03);

		// Death :(
		if (health <= healthBar.min)
			openSubState(new GameOverSubState());
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		if (subState != null)
			return;

		if (countdown.step < 3)
		{
			var event:CountdownScriptEvent = new CountdownScriptEvent(COUNTDOWN_STEP, countdown.step + 1);
			dispatch(event);

			if (!event.cancelled)
				countdown.advance();
		}

		// Don't bop all this stuff until the song starts
		if (!songStarted)
			return;

		opponentIcon?.bop();
		playerIcon?.bop();

		if (beat % 2 == 0)
		{
			FlxG.camera.zoom = camZoom + 0.05;
			camHUD.zoom = 1.02;
		}
	}

	public function resetSong()
	{
		// Canceling the retry event causes a softlock when dying
		// Putting this before it to stop that from happening
		health = Constants.STARTING_HEALTH;

		if (!songLoaded)
		{
			songLoaded = true;

			healthLerp = health;
			tallies = new Tallies();

			voices = new Voices(song);
			voices.pitch = playbackRate;

			FunkinSound.playMusic(song.instPath, 1, false, false);
			FunkinSound.music.pitch = playbackRate;
			FunkinSound.music.onComplete = endSong;
		}
		else
		{
			var event:ScriptEvent = new ScriptEvent(SONG_RETRY);
			dispatch(event);

			if (event.cancelled)
				return;
		}

		songStarted = false;
		songEnded = false;
		songActive = false;

		score = 0;
		tallies.reset();

		// This is done so that a character is targeted
		// Not all characters exist in a song
		setCameraTarget(stage.gf, true);
		setCameraTarget(stage.opponent, true);
		setCameraTarget(stage.player, true);

		// Reset the camera zoom
		setCameraZoom(null, true);

		// Loads the strumline
		var notes:Array<SongNoteData> = song.getNotes(difficulty);
		var speed:Float = song.getSpeed(difficulty);

		events = song.events.copy();
		events.sort(SortUtil.byEventTime.bind(FlxSort.ASCENDING));

		dispatch(new SongLoadScriptEvent(notes, events));

		opponentStrumline.clean();
		playerStrumline.clean();

		opponentStrumline.load(notes.filter(note -> return note.d >= Constants.NOTE_COUNT), speed);
		playerStrumline.load(notes.filter(note -> return note.d < Constants.NOTE_COUNT), speed);

		// Resets conductor stuff
		conductor.reset(song.bpm);
		conductor.time = -conductor.crotchet * 4 + Math.min(0, conductor.offset);

		FunkinSound.stopAllSounds(true);

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresence('${song.name} - ${difficulty.toUpperCase()}');
		#end

		startCountdown();
	}

	public function startCountdown()
	{
		var event:CountdownScriptEvent = new CountdownScriptEvent(COUNTDOWN_START, -1);
		dispatch(event);

		if (event.cancelled)
			return;

		songActive = true;
		countdown.start();
	}

	public function startCutscene(cutscene:BaseCutscene)
	{
		if (cutscene == null)
			return;

		this.cutscene?.destroy();
		this.cutscene = cutscene;

		cutscene.start();

		add(cutscene);
	}

	public function setCameraTarget(target:Character, instant:Bool = false)
	{
		// Why????
		if (target == null)
			return;

		var pos:FlxPoint = target.getGraphicMidpoint();
		var offset:FlxPoint = MathUtil.arrayToPoint(target.meta.cameraOffset);

		if (target.flipX)
			offset.x = -offset.x;

		PlayState.instance.camFollow.setPosition(pos.x + offset.x, pos.y + offset.y);

		if (instant)
			FlxG.camera.snapToTarget();
	}

	public function setCameraZoom(?zoom:Float, instant:Bool = false)
	{
		// A null zoom means we're resetting the zoom
		// Yeah why not
		camZoom = zoom ?? defaultZoom;

		if (instant)
			FlxG.camera.zoom = camZoom;
	}

	public function pause()
	{
		var event:ScriptEvent = new ScriptEvent(PAUSE);
		dispatch(event);

		if (event.cancelled)
			return;

		openSubState(new PauseSubState());
	}

	public function updatePreferences()
	{
		timeText.y = 35;
		timeText.visible = Preferences.showTimer;

		healthBorder.y = FlxG.height - healthBorder.height - 60;

		if (Preferences.downscroll)
		{
			timeText.y = FlxG.height - timeText.height - timeText.y;
			healthBorder.y = FlxG.height - healthBorder.height - healthBorder.y;
		}

		healthBar.x = healthBorder.x + 3.5;
		healthBar.y = healthBorder.y + 5;

		scoreText.y = healthBorder.y + healthBorder.height + 20;

		if (opponentIcon != null)
			opponentIcon.y = healthBar.y - opponentIcon.height / 2;
		if (playerIcon != null)
			playerIcon.y = healthBar.y - playerIcon.height / 2;

		playerStrumline.isPlayer = !Preferences.botplay;

		opponentStrumline.updateScroll();
		playerStrumline.updateScroll();
	}

	function loadCharacters()
	{
		stage.setPlayer(song.player);
		stage.setOpponent(song.opponent);
		stage.setGF(song.gf);

		// GF opponent
		if (stage.opponent != null && song.opponent == song.gf)
		{
			stage.opponent.setPosition(stage.gf.x, stage.gf.y);
			stage.opponent.zIndex = stage.gf.zIndex;

			stage.gf.destroy();
			stage.gf = null;

			stage.refresh();
		}

		// Sets up character health icons
		opponentIcon = stage.opponent?.buildHealthIcon();
		playerIcon = stage.player?.buildHealthIcon();

		if (opponentIcon != null)
		{
			opponentIcon.camera = camHUD;
			opponentIcon.zIndex = healthBorder.zIndex;
			add(opponentIcon);
		}

		if (playerIcon != null)
		{
			playerIcon.camera = camHUD;
			playerIcon.zIndex = healthBorder.zIndex;
			add(playerIcon);
		}
	}

	function startSong()
	{
		songStarted = true;

		FunkinSound.music.play();
		voices.play();

		dispatch(new ScriptEvent(SONG_START));
	}

	function endSong()
	{
		var event:ScriptEvent = new ScriptEvent(SONG_END);
		dispatch(event);

		songActive = false;
		songEnded = true;

		FunkinSound.stopAllSounds(true);

		if (event.cancelled)
			return;

		// Saves the song score
		final score:Int = Std.int(score);

		song.setScore(score, difficulty, false);

		Playlist.tallies.combine(tallies);
		Playlist.score += score;

		// Exits or switches to the next song
		if (Playlist.next())
			FlxG.resetState();
		else
		{
			if (Playlist.isStory)
				Playlist.level.setScore(Playlist.score, difficulty, false);
			exit();
		}
	}

	function processEvents()
	{
		while (events.length > 0)
		{
			var event:EventData = events[0];

			// Don't handle the event until it's the right time
			if (event.t > conductor.time)
				break;

			// Skip the event if it's one second late
			if (conductor.time - event.t > Constants.MS_PER_SEC)
			{
				events.shift();
				break;
			}

			// Handle the event
			// That's if the script event wasn't cancelled though
			var event:SongEventScriptEvent = new SongEventScriptEvent(event.e, event.v);
			dispatch(event);

			if (event.cancelled)
			{
				events.shift();
				break;
			}

			EventRegistry.instance.handleEvent(event.kind, event.value);

			events.shift();

			trace('Handling event ${event.kind}.');
		}
	}

	function processInput()
	{
		// Player input
		var directionNotes:Array<Array<NoteSprite>> = [[], [], [], []];

		for (note in playerStrumline.getMayHitNotes())
			directionNotes[note.direction].push(note);

		for (i in 0...directionNotes.length)
		{
			var note:NoteSprite = directionNotes[i][0];
			var direction:NoteDirection = NoteDirection.fromInt(i);
			var pressed:Bool = direction.justPressed || Preferences.botplay;

			// Miss if ghost tapping is disabled
			// Don't count the miss if botplay is enabled though
			if (note == null && pressed && !Preferences.ghostTapping && !Preferences.botplay)
				playerGhostMiss(direction);

			// Don't hit the note if nothing's being pressed
			// Especially don't hit the note if it's null
			if (!pressed || note == null)
				continue;

			var event:NoteScriptEvent = new NoteScriptEvent(NOTE_HIT, note);
			dispatch(event);

			if (event.cancelled)
				continue;

			playerStrumline.hitNote(note);
		}

		// Opponent input
		for (note in opponentStrumline.getMayHitNotes())
		{
			var event:NoteScriptEvent = new NoteScriptEvent(NOTE_HIT, note);
			dispatch(event);

			if (event.cancelled)
				continue;

			opponentStrumline.hitNote(note);
		}

		// The misc stuff
		// Pausing, resetting, etc.
		if (controls.PAUSE)
			pause();

		if (controls.RESET)
		{
			health = 0;
			healthLerp = 0;
		}
	}

	function playerNoteHit(note:NoteSprite)
	{
		var judgement:Judgement = RhythmUtil.judgeNote(note);

		score += judgement.score;
		health += Constants.NOTE_HEALTH;

		tallies.hits++;
		tallies.combo++;

		switch (judgement)
		{
			case SICK:
				playerStrumline.playSplash(note.direction);
				tallies.sicks++;
			case GOOD:
				tallies.goods++;
			case BAD:
				tallies.bads++;
			case SHIT:
				tallies.shits++;
		}

		voices.playerVolume = 1;

		popups.popupJudgement(judgement);
		popups.popupCombo(tallies.combo);
	}

	function playerHoldNoteHit(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = new HoldNoteScriptEvent(HOLD_NOTE_HOLD, holdNote);
		dispatch(event);

		if (event.cancelled)
			return;

		score += Constants.HOLD_SCORE_PER_SEC * FlxG.elapsed;
		health += Constants.HOLD_HEALTH_PER_SEC * FlxG.elapsed;

		voices.playerVolume = 1;
	}

	function playerNoteMiss(note:NoteSprite)
	{
		var event:NoteScriptEvent = new NoteScriptEvent(NOTE_MISS, note);
		dispatch(event);

		if (event.cancelled)
			return;

		var missScore:Float = Constants.MISS_SCORE;

		if (note.holdNote != null)
			missScore *= (note.holdNote.length / 500);

		score += missScore;

		tallies.misses++;
		tallies.combo = 0;

		health += Constants.MISS_HEALTH;

		voices.playerVolume = 0;
	}

	function playerGhostMiss(direction:NoteDirection)
	{
		var event:GhostMissScriptEvent = new GhostMissScriptEvent(direction);
		dispatch(event);

		if (event.cancelled)
			return;

		score += Constants.GHOST_MISS_SCORE;
		health += Constants.GHOST_MISS_HEALTH;

		voices.playerVolume = 0;
	}

	function playerHoldNoteDrop(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = new HoldNoteScriptEvent(HOLD_NOTE_DROP, holdNote);
		dispatch(event);

		if (event.cancelled)
			return;

		// Takes away score based on how long the hold note is
		score += Constants.MISS_SCORE * (holdNote.length / 500);
		health += Constants.MISS_HEALTH;

		voices.playerVolume = 0;
	}

	function opponentNoteHit(note:NoteSprite)
	{
		// TODO: Make this do something?
	}

	function opponentHoldNoteHit(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = new HoldNoteScriptEvent(HOLD_NOTE_HOLD, holdNote);
		dispatch(event);
	}

	public function exit()
	{
		if (Playlist.isStory)
			StickerSubState.switchState(() -> StoryMenuSubState.build(), song.stickerpack);
		else
			StickerSubState.switchState(() -> FreeplaySubState.build(), song.stickerpack);
	}

	override function dispatch(event:ScriptEvent)
	{
		super.dispatch(event);

		ScriptEventDispatcher.dispatch(Playlist.level, event);
		ScriptEventDispatcher.dispatch(song, event);

		NoteKindRegistry.instance.dispatch(event);

		ScriptEventDispatcher.dispatch(stage, event);
	}

	override public function openSubState(subState:FlxSubState)
	{
		super.openSubState(subState);

		FlxTimer.globalManager.forEach(timer ->
		{
			if (!timer.active)
				return;
			timer.active = false;
		});

		FlxTween.globalManager.forEach(tween ->
		{
			if (!tween.active)
				return;
			tween.active = false;
		});

		FlxG.sound.defaultMusicGroup.pause();
		FlxG.sound.defaultSoundGroup.pause();

		FlxG.camera.active = false;
	}

	override public function closeSubState()
	{
		super.closeSubState();

		FlxTimer.globalManager.forEach(timer ->
		{
			if (timer.active)
				return;
			timer.active = true;
		});

		FlxTween.globalManager.forEach(tween ->
		{
			if (tween.active)
				return;
			tween.active = true;
		});

		FlxG.sound.defaultMusicGroup.resume();
		FlxG.sound.defaultSoundGroup.resume();

		FlxG.camera.active = true;
	}

	override public function destroy()
	{
		// Runs the destroy script event
		dispatch(new ScriptEvent(DESTROY));

		// Not doing this can cause things to crash
		// Even if it's accessed in a safe way
		instance = null;

		FunkinSound.music.stop();

		super.destroy();
	}

	@:noCompletion
	function set_playbackRate(value:Float):Float
	{
		value = Math.max(0, value);
		playbackRate = value;

		FunkinSound.music.pitch = value;
		voices.pitch = value;

		return value;
	}
}

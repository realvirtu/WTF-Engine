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
import funkin.data.note.kind.NoteKindRegistry;
import funkin.data.note.style.NoteStyleRegistry;
import funkin.data.song.SongData.SongNoteData;
import funkin.data.stage.StageRegistry;
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
import funkin.play.note.NoteStyle;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.play.note.strum.Strumline;
import funkin.play.song.Song;
import funkin.play.song.Voices;
import funkin.play.stage.Stage;
import funkin.save.Save;
import funkin.ui.FunkinState;
import funkin.ui.freeplay.FreeplaySubState;
import funkin.ui.menu.MainMenuState;
import funkin.ui.story.StoryMenuSubState;
import funkin.util.MathUtil;
import funkin.util.RhythmUtil;
import funkin.util.SortUtil;
import funkin.util.WindowUtil;
import funkin.util.plugins.StickerPlugin;
#if HAS_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

/**
 * A structure object containing parameters used for loading `PlayState`.
 */
typedef PlayStateParams =
{
	var song:Song;
	var difficulty:String;
	@:optional
	var instrumental:String;
}

/**
 * A state where the gameplay occurs. Kinda like a "play" state. Hah! I said the thing!
 */
class PlayState extends FunkinState
{
	public static var instance:PlayState;

	static var lastParams:PlayStateParams;

	public var song(get, set):Song;
	public var difficulty(get, set):String;
	public var instrumental(get, set):String;

	public var songLoaded:Bool;
	public var songStarted:Bool;
	public var songEnded:Bool;
	public var songActive:Bool;

	public var isPaused(get, never):Bool;

	/**
	 * TODO: Make this changeable ingame
	 */
	public var playbackRate(default, set):Float = 1;

	public var events:Array<EventData>;
	public var nextEventIndex:Int = -1;

	public var voices:Voices;
	public var style:NoteStyle;
	public var tallies:Tallies;

	public var score:Float;
	public var health:Float;
	public var healthLerp:Float;
	public var deaths:Int = 0;

	public var stageZoom:Float;
	public var camZoom:Float;

	public var camBopMultiplier:Float;
	public var camBopRate:Int;
	public var camBopIntensity:Float;

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

	var criticalError:Bool = false;

	public function new(?params:PlayStateParams)
	{
		super();

		params ??= lastParams;

		if (params == null)
			throw 'PlayState constructed without any parameters.';

		// Force exit to menu instead of crashing the game
		if (params.song == null)
		{
			criticalError = true;

			WindowUtil.alert('PlayState constructed with a null song.');
		}

		lastParams = params;

		song = params.song;
		difficulty = params.difficulty;
		instrumental = params.instrumental;
	}

	override function create()
	{
		super.create();

		if (criticalError)
			return FlxG.switchState(() -> new MainMenuState());

		instance = this;

		style = NoteStyleRegistry.instance.fetch(song.style);

		//
		// CAMERAS
		//

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject();

		camera.follow(camFollow, LOCKON, Constants.CAMERA_FOLLOW_RATE);

		//
		// HUD
		//

		opponentStrumline = new Strumline(style, false);
		opponentStrumline.noteIncoming.add(note -> dispatch(NoteScriptEvent.get(NOTE_INCOMING, note)));
		opponentStrumline.camera = camHUD;
		opponentStrumline.x = 325;
		add(opponentStrumline);

		playerStrumline = new Strumline(style, true);
		playerStrumline.noteIncoming.add(note -> dispatch(NoteScriptEvent.get(NOTE_INCOMING, note)));
		playerStrumline.camera = camHUD;
		playerStrumline.x = FlxG.width - opponentStrumline.x;
		add(playerStrumline);

		healthBorder = FunkinSprite.create(0, 0, 'gameplay/healthbar');
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

		popups = new Popups(style);
		popups.camera = camHUD;
		add(popups);

		countdown = new Countdown(style);
		countdown.camera = camHUD;
		add(countdown);

		//
		// SETUP
		//

		stage = StageRegistry.instance.fetchStage(song.stage);
		stageZoom = stage.zoom;
		add(stage);

		loadCharacters();
		loadSong();

		refresh();
		updatePreferences();

		// Runs the create script event
		dispatch(ScriptEvent.get(CREATE));
	}

	override function update(elapsed:Float)
	{
		if (criticalError)
			return;

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
					final time:Float = FunkinSound.music.time - conductor.offset;
					final diff:Float = Math.round(Math.abs(conductor.time - time));

					// Notes can appear choppy depending on the framerate
					// Blehh
					if (diff <= Constants.CONDUCTOR_DRIFT_THRESHOLD)
						conductor.update(FlxMath.lerp(conductor.time, time, 1 - Math.exp(-(Constants.MUSIC_EASE_RATIO * playbackRate) * elapsed)));
					else
						conductor.update();
				}
				else
				{
					conductor.update(conductor.time + elapsed * Constants.MS_PER_SEC * playbackRate);

					if (conductor.time >= -conductor.offset)
						startSong();
				}

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

		health = health.clamp(healthBar.min, healthBar.max);
		healthLerp = MathUtil.lerp(healthLerp, health, 0.15);

		healthBar.value = healthLerp;

		if (opponentIcon != null)
		{
			opponentIcon.x = healthBar.fillPosition - opponentIcon.width + 15;

			if (health > 0.8)
				opponentIcon.state = LOSING;
			else if (health < 0.2)
				opponentIcon.state = WINNING;
			else
				opponentIcon.state = IDLE;
		}

		if (playerIcon != null)
		{
			playerIcon.x = healthBar.fillPosition - 15;

			if (health > 0.8)
				playerIcon.state = WINNING;
			else if (health < 0.2)
				playerIcon.state = LOSING;
			else
				playerIcon.state = IDLE;
		}

		timeText.text = FlxStringUtil.formatTime((FunkinSound.music.length - FunkinSound.music.time).clamp(0, FunkinSound.music.length) / Constants.MS_PER_SEC);
		timeText.screenCenter(X);

		updateScoreText();

		camBopMultiplier = MathUtil.lerp(camBopMultiplier, 1, 0.03);
		camera.zoom = camZoom * camBopMultiplier;

		// Death :(
		if (health <= healthBar.min)
			openSubState(new GameOverSubState(stage.player));
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		if (subState != null)
			return;

		// Don't bop all this stuff until the song starts
		if (!songStarted)
			return;

		opponentIcon?.bop();
		playerIcon?.bop();

		// Bop the camera
		// This uses step instead of beat for more precision
		final rate:Float = Constants.STEPS_PER_BEAT * Constants.CAMERA_BOP_RATE / camBopRate;
		final intensity:Float = Constants.CAMERA_BOP_INTENSITY * camBopIntensity;

		if (conductor.step % rate == 0)
			camBopMultiplier = intensity;
	}

	public function loadSong()
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
		}
		else
		{
			var event:ScriptEvent = ScriptEvent.get(SONG_RETRY);
			dispatch(event);

			if (event.cancelled)
				return;
		}

		FunkinSound.playMusic(song.getInstrumentalPath(instrumental), 1, false, false);
		FunkinSound.music.pitch = playbackRate;
		FunkinSound.music.onComplete = endSong;

		songStarted = false;
		songEnded = false;
		songActive = false;

		score = 0.0;
		tallies.reset();

		//
		// CAMERA
		//

		setCameraTarget(stage.gf, true);
		setCameraTarget(stage.opponent, true);
		setCameraTarget(stage.player, true);

		setCameraZoom(null, true);

		camera.snapToTarget();

		camBopRate = 1;
		camBopIntensity = 1;

		//
		// STRUMLINE
		//

		var notes:Array<SongNoteData> = song.getNotes(difficulty);
		var speed:Float = song.getSpeed(difficulty);

		events = song.events.copy();
		events.sort(SortUtil.byEventTime.bind(FlxSort.ASCENDING));

		nextEventIndex = 0;

		dispatch(SongLoadScriptEvent.get(notes, events));

		opponentStrumline.clean();
		playerStrumline.clean();

		opponentStrumline.load(notes.filter(note -> return note.d >= Constants.NOTE_COUNT), speed);
		playerStrumline.load(notes.filter(note -> return note.d < Constants.NOTE_COUNT), speed);

		//
		// SETUP
		//

		conductor.reset(song.bpm);
		conductor.time = -conductor.crotchet * 5;

		FunkinSound.stopAllSounds(true);

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresence('${song.name} - ${difficulty.toUpperCase()}');
		#end

		startCountdown();
	}

	public function startCountdown()
	{
		var event:CountdownScriptEvent = CountdownScriptEvent.get(COUNTDOWN_START, 0);
		dispatch(event);

		if (event.cancelled)
			return;

		songActive = true;
		countdown.start(playbackRate);
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

		final pos:FlxPoint = target.getGraphicMidpoint();
		final offset:FlxPoint = MathUtil.arrayToPoint(target.meta.cameraOffset);

		if (target.flipX)
			offset.x = -offset.x;

		PlayState.instance.camFollow.setPosition(pos.x + offset.x, pos.y + offset.y);

		if (instant)
			camera.snapToTarget();

		offset.put();
	}

	public function setCameraZoom(?zoom:Float, instant:Bool = false)
	{
		// A null zoom means we're resetting the zoom
		// Yeah why not
		camZoom = zoom ?? stageZoom;

		// Reset this because it should be 1
		camBopMultiplier = 1;

		if (instant)
			camera.zoom = camZoom;
	}

	public function pause()
	{
		if (isPaused || !songActive)
			return;

		var event:ScriptEvent = ScriptEvent.get(PAUSE);
		dispatch(event);

		if (event.cancelled)
			return;

		openSubState(new PauseSubState());
	}

	public function updatePreferences()
	{
		// I feel like this isn't good enough
		// Is there even a better way to do this?
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

		updateScoreText();
	}

	function updateScoreText()
	{
		if (Preferences.botplay)
			scoreText.text = 'botplay enabled';
		else
			scoreText.text = 'score: ${FlxStringUtil.formatMoney(Std.int(score), false, true)} | misses: ${tallies.misses}';

		scoreText.screenCenter(X);
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

		GameOverSubState.reset();
		PauseSubState.reset();
	}

	function startSong()
	{
		songStarted = true;

		FunkinSound.music.play();
		voices.play();

		dispatch(ScriptEvent.get(SONG_START));
	}

	function endSong()
	{
		var event:ScriptEvent = ScriptEvent.get(SONG_END);
		dispatch(event);

		songActive = false;
		songEnded = true;

		FunkinSound.stopAllSounds(true);

		if (event.cancelled)
			return;

		// Saves the song score
		final score:Int = Std.int(score);

		Save.instance.setSongScore(song.id, difficulty, song.variation, score, false);

		Playlist.tallies.combine(tallies);
		Playlist.score += score;

		// Exits or switches to the next song
		if (!Playlist.next())
		{
			if (Playlist.isStory)
				Save.instance.setLevelScore(Playlist.level.id, difficulty, Playlist.score, false);
			exit();
		}
	}

	function processEvents()
	{
		for (i in nextEventIndex...events.length)
		{
			var event:EventData = events[i];

			// Skip the note if it's null or in the past
			if (event == null || conductor.time - event.t > Constants.MS_PER_SEC)
			{
				nextEventIndex = i + 1;
				continue;
			}

			// Don't handle the event until it's the right time
			if (event.t > conductor.time)
				break;

			// Handle the event
			// That's if the script event wasn't cancelled though
			var event:SongEventScriptEvent = SongEventScriptEvent.get(event.e, event.v);
			dispatch(event);

			if (event.cancelled)
			{
				nextEventIndex = i + 1;
				continue;
			}

			EventRegistry.instance.handleEvent(event.kind, event.value);

			#if debug
			trace('Handling event ${event.kind}.');
			#end

			nextEventIndex = i + 1;
		}
	}

	override function directionDown(direction:NoteDirection)
	{
		super.directionDown(direction);

		if (Preferences.botplay || subState != null)
			return;

		var notes:Array<NoteSprite> = playerStrumline.getMayHitNotes();
		var note:NoteSprite = notes.find(note -> return note.direction == direction);

		if (note == null)
		{
			#if HAS_ANTI_MASH
			if (playerStrumline.getCurrentNotes().length > 0)
				playerGhostMiss(direction);
			#end
			return;
		}

		playerNoteHit(note);
	}

	function processInput()
	{
		//
		// PLAYER
		//

		if (Preferences.botplay)
		{
			for (note in playerStrumline.getMayHitNotes())
				playerNoteHit(note);
		}

		for (holdNote in playerStrumline.getHeldHoldNotes())
		{
			if (holdNote.direction.pressed || Preferences.botplay)
				playerHoldNoteHeld(holdNote);
			else if (holdNote.length > 100)
				playerHoldNoteDrop(holdNote);
		}

		for (note in playerStrumline.getMissedNotes())
			playerNoteMiss(note);

		if (!Preferences.botplay)
		{
			playerStrumline.strums.forEach(strum ->
			{
				if (strum.confirmTime > 0)
					return;
				if (strum.direction.pressed)
					strum.playPress();
				else
					strum.playStatic();
			});
		}

		//
		// OPPONENT
		//

		for (note in opponentStrumline.getMayHitNotes())
			opponentNoteHit(note);
		for (holdNote in opponentStrumline.getHeldHoldNotes())
			opponentHoldNoteHeld(holdNote);

		// The misc stuff
		// Pausing, resetting, etc.
		if (controls.PAUSE)
			pause();

		if (controls.RESET)
		{
			health = healthBar.min;
			healthLerp = health;
		}
	}

	function playerNoteHit(note:NoteSprite)
	{
		final judgement:Judgement = RhythmUtil.judgeNote(note);

		var event:NoteScriptEvent = NoteScriptEvent.get(NOTE_HIT, note, judgement.score, Constants.NOTE_HEALTH, tallies.combo + 1);
		dispatch(event);

		if (event.cancelled)
			return;

		score += event.score;
		health += event.health;

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

		playerStrumline.hitNote(note, judgement != BAD && judgement != SHIT);
	}

	function playerHoldNoteHeld(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = HoldNoteScriptEvent.get(HOLD_NOTE_HOLD, holdNote);
		dispatch(event);

		if (event.cancelled)
			return;

		score += Constants.HOLD_SCORE_PER_SEC * FlxG.elapsed;
		health += Constants.HOLD_HEALTH_PER_SEC * FlxG.elapsed;

		voices.playerVolume = 1;
	}

	function playerNoteMiss(note:NoteSprite)
	{
		playerStrumline.missNote(note);

		var missScore:Float = Constants.MISS_SCORE;

		if (note.holdNote != null)
			missScore *= (note.holdNote.length / 500);

		var event:NoteScriptEvent = NoteScriptEvent.get(NOTE_MISS, note, missScore, Constants.MISS_HEALTH, tallies.combo);
		dispatch(event);

		if (event.cancelled)
			return;

		score += event.score;
		health += event.health;

		tallies.misses++;
		tallies.combo = 0;

		voices.playerVolume = 0;

		FunkinSound.playOnce(Paths.random('gameplay/sounds/miss', 1, 3), 0.5);
	}

	function playerGhostMiss(direction:NoteDirection)
	{
		var event:GhostMissScriptEvent = GhostMissScriptEvent.get(direction);
		dispatch(event);

		if (event.cancelled)
			return;

		score += Constants.GHOST_MISS_SCORE;
		health += Constants.GHOST_MISS_HEALTH;

		voices.playerVolume = 0;

		FunkinSound.playOnce(Paths.random('gameplay/sounds/miss', 1, 3), 0.5);
	}

	function playerHoldNoteDrop(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = HoldNoteScriptEvent.get(HOLD_NOTE_DROP, holdNote);
		dispatch(event);

		if (event.cancelled)
			return;

		holdNote.kill();

		score += Constants.MISS_SCORE * (holdNote.length / 500);
		health += Constants.MISS_HEALTH;

		voices.playerVolume = 0;

		FunkinSound.playOnce(Paths.random('gameplay/sounds/miss', 1, 3), 0.5);
	}

	function opponentNoteHit(note:NoteSprite)
	{
		var event:NoteScriptEvent = NoteScriptEvent.get(NOTE_HIT, note);
		dispatch(event);

		if (event.cancelled)
			return;

		opponentStrumline.hitNote(note);

		if (song.hasLegacyVoices())
			voices.playerVolume = 1;
	}

	function opponentHoldNoteHeld(holdNote:HoldNoteSprite)
	{
		var event:HoldNoteScriptEvent = HoldNoteScriptEvent.get(HOLD_NOTE_HOLD, holdNote);
		dispatch(event);
	}

	public function exit()
	{
		StickerPlugin.instance.switchState(() ->
		{
			if (Playlist.isStory)
				StoryMenuSubState.build();
			else
				FreeplaySubState.build();
		}, song.stickerpack);
	}

	override function dispatch(event:ScriptEvent)
	{
		ScriptEventDispatcher.dispatch(Playlist.level, event);
		ScriptEventDispatcher.dispatch(song, event);

		EventRegistry.instance.dispatch(event);
		NoteKindRegistry.instance.dispatch(event);

		ScriptEventDispatcher.dispatch(stage, event);

		super.dispatch(event);
	}

	override function openSubState(subState:FlxSubState)
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

		FunkinSound.pauseAllSounds();

		camera.active = false;
	}

	override function closeSubState()
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

		FunkinSound.resumeAllSounds();

		camera.active = true;
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		// Pause the game when the game is unfocused
		// Though we only do this if the option is enabled
		if (Preferences.autoPause)
			pause();
	}

	override function destroy()
	{
		// Runs the destroy script event
		dispatch(ScriptEvent.get(DESTROY));

		// Not doing this can cause things to crash
		// Even if it's accessed in a safe way
		instance = null;

		FunkinSound.music.stop();

		super.destroy();
	}

	@:noCompletion
	function get_song():Song
	{
		return lastParams.song;
	}

	@:noCompletion
	function set_song(value:Song):Song
	{
		return lastParams.song = value;
	}

	@:noCompletion
	function get_difficulty():String
	{
		return lastParams.difficulty;
	}

	@:noCompletion
	function set_difficulty(value:String):String
	{
		return lastParams.difficulty = value;
	}

	@:noCompletion
	function get_instrumental():String
	{
		return lastParams.instrumental ?? song.variation;
	}

	@:noCompletion
	function set_instrumental(value:String):String
	{
		return lastParams.instrumental = value;
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

	@:noCompletion
	inline function get_isPaused():Bool
	{
		return subState != null;
	}
}

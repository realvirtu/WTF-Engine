package funkin.ui.freeplay;

import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.song.SongRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.graphics.shader.TextureSwap;
import funkin.modding.event.ScriptEvent;
import funkin.play.PlayState;
import funkin.play.Playlist;
import funkin.play.song.Song;
import funkin.save.Save;
import funkin.ui.freeplay.capsule.CapsuleGroup;
import funkin.ui.freeplay.capsule.CapsuleSprite;
import funkin.ui.freeplay.components.BackcardSprite;
import funkin.ui.freeplay.components.DJSprite;
import funkin.ui.freeplay.components.SortText;
import funkin.ui.menu.MainMenuState;
import funkin.ui.selector.DifficultyText;
import funkin.util.MathUtil;

/**
 * The engine's freeplay sub state.
 * This is the menu where the player can navigate through all the songs.
 */
class FreeplaySubState extends FunkinSubState
{
	static var selectedSong:Int = 1;
	static var selectedDiff:Int = 1;
	static var selectedSort:Int = 0;

	var skipIntro:Bool;
	var exitMovers:ExitMovers;
	var stateMachine:StateMachine;

	var song(get, never):Song;
	var difficulty(get, never):String;

	var lastSong:Song;

	var songScore:Int;
	var lerpScore:Float;

	var backcard:BackcardSprite;
	var backingImage:FunkinSprite;
	var dj:DJSprite;
	var capsules:CapsuleGroup;
	var scoreText:FunkinText;
	var diffText:DifficultyText;
	var sortText:SortText;

	public function new(skipIntro:Bool = false)
	{
		super();

		this.skipIntro = skipIntro;
	}

	override public function create()
	{
		super.create();

		FunkinSound.playMusic('ui/freeplay/music/random', 0);
		FunkinSound.music.fadeIn(1, 0, 0.6);

		exitMovers = new ExitMovers();
		stateMachine = new StateMachine();

		conductor.reset(150);

		backcard = new BackcardSprite();
		add(backcard);

		backingImage = FunkinSprite.create(0, 0, 'ui/freeplay/card/right', 1.5);
		backingImage.shader = new TextureSwap('ui/freeplay/card/image');
		backingImage.active = false;
		backingImage.x = FlxG.width - backingImage.width;
		add(backingImage);

		dj = new DJSprite(30);
		dj.y = FlxG.height - dj.height + 30;
		add(dj);

		capsules = new CapsuleGroup(selectedSong);
		capsules.onChanged.add(changeSong);
		add(capsules);

		var blackbar:FunkinSprite = FunkinSprite.createSolidColor(0, 0, FlxG.width, 50, 0xFF000000);
		blackbar.active = false;
		blackbar.zIndex = 1;
		add(blackbar);

		var freeplayText:FunkinText = new FunkinText(10, 0, 'freeplay');
		freeplayText.size = 24;
		freeplayText.y = (blackbar.height - freeplayText.height) / 2 + 0.5;
		freeplayText.zIndex = blackbar.zIndex;
		add(freeplayText);

		var ostText:FunkinText = new FunkinText(0, freeplayText.y, 'official ost');
		ostText.size = freeplayText.size;
		ostText.x = FlxG.width - ostText.width - freeplayText.x;
		ostText.zIndex = blackbar.zIndex;
		add(ostText);

		scoreText = new FunkinText(0, blackbar.height + 40);
		scoreText.alignment = RIGHT;
		add(scoreText);

		diffText = new DifficultyText(selectedDiff, SongRegistry.instance.getDifficulties());
		diffText.y = scoreText.y;
		diffText.onChanged.add(changeDiff);
		add(diffText);

		sortText = new SortText(selectedSort);
		sortText.screenCenter(X);
		sortText.y = blackbar.height + 30;
		sortText.onChanged.add(changeSort);
		add(sortText);

		exitMovers.add(backcard, -backcard.width);
		exitMovers.add(backingImage, FlxG.width);
		exitMovers.add(dj, -dj.width);
		exitMovers.add(blackbar, null, -blackbar.height);
		exitMovers.add(freeplayText, null, -freeplayText.height);
		exitMovers.add(ostText, null, -ostText.height);
		exitMovers.add(scoreText, null, -scoreText.height);
		exitMovers.add(diffText, null, -diffText.height);
		exitMovers.add(sortText, null, -sortText.height);

		if (!skipIntro)
			stateMachine.transition(TRANSITIONING);

		changeDiff(selectedDiff);
		refresh();

		if (!skipIntro)
			intro();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.time = FunkinSound.music.time;
		conductor.update();

		if (controls.FAVORITE)
			favorite(capsules.capsule);
		if (controls.ACCEPT_P)
			confirm(capsules.capsule);
		if (controls.BACK)
			exit();

		_parentState.persistentDraw = stateMachine.transitioning();

		capsules.lerp = !stateMachine.transitioning();
		capsules.busy = !stateMachine.canInteract();
		diffText.busy = !stateMachine.canInteract();
		sortText.busy = !stateMachine.canInteract();

		lerpScore = MathUtil.lerp(lerpScore, songScore, 0.45);

		scoreText.text = Std.string(Math.round(lerpScore)).leadingZeros(10);
		scoreText.x = FlxG.width - scoreText.width - 50;
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		// Make the DJ bop
		// Without this line, freeplay would be shit
		dj.bop();
	}

	function changeSong(selected:Int)
	{
		selectedSong = selected;

		songScore = Save.instance.getSongScore(song?.id, difficulty);

		// TODO: Song previews
		if (lastSong != song)
		{
			// Song preview logic
		}

		lastSong = song;
	}

	function changeDiff(selected:Int)
	{
		selectedDiff = selected;
		diffText.x = (440 - diffText.width) / 2;

		loadCapsules();
		changeSong(capsules.selected);

		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(INTERACTING);

		FlxTimer.wait(0.1, () -> stateMachine.reset());
	}

	function changeSort(selected:Int)
	{
		selectedSort = selected;
		sortText.screenCenter(X);

		changeDiff(selectedDiff);

		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(INTERACTING);

		FlxTimer.wait(0.1, () -> stateMachine.reset());
	}

	function confirm(capsule:CapsuleSprite)
	{
		if (!stateMachine.canInteract())
			return;

		var event:FreeplaySongScriptEvent = new FreeplaySongScriptEvent(FREEPLAY_SONG_SELECTED, capsule);
		dispatch(event);

		if (event.cancelled)
			return;

		// The capsule's song is null, meaning that it's Random
		if (capsule.song == null)
		{
			var list:Array<CapsuleSprite> = capsules.members.filter(capsule -> capsule.alive && capsule.song != null);
			var random:CapsuleSprite = FlxG.random.getObject(list);

			capsule = random;

			// Can't select a capsule that's null
			if (capsule == null)
			{
				FunkinSound.playOnce('ui/sounds/cancel');
				return;
			}

			capsules.selected = capsule.ID;
		}

		stateMachine.transition(INTERACTING);

		capsule.flicker();
		dj.confirm();

		FunkinSound.playOnce('ui/sounds/confirm');

		FlxTimer.wait(1, () ->
		{
			camera.fade(0xFF000000, 0.25, false, () ->
			{
				Playlist.reset();

				PlayState.song = song;
				PlayState.difficulty = difficulty;

				FlxG.switchState(() -> new PlayState());
			});
		});
	}

	function favorite(capsule:CapsuleSprite)
	{
		var capsule:CapsuleSprite = capsules.capsule;
		var song:Song = capsule.song;

		if (!stateMachine.canInteract() || song == null)
			return;

		var event:FreeplaySongScriptEvent = new FreeplaySongScriptEvent(FREEPLAY_SONG_FAVORITED, capsule);
		dispatch(event);

		if (event.cancelled)
			return;

		stateMachine.transition(INTERACTING);

		if (song != null)
			capsule.favorited = !Save.instance.isSongFavorited(song.id, song.variation);

		FlxTimer.wait(0.1, () -> stateMachine.reset());
	}

	function loadCapsules()
	{
		var songs:Array<String> = SongRegistry.instance.listWithDifficulty(difficulty);

		// Song sorting
		// Either sort by favorites, or sort by levels
		if (selectedSort == sortText.count - 1)
		{
			songs = songs.filter(song ->
			{
				var song:Song = SongRegistry.instance.fetchSong(song, difficulty);

				return Save.instance.isSongFavorited(song.id, song.variation);
			});
		}
		else if (selectedSort > 0)
			songs = songs.filter(song -> return sortText.level.hasSong(song));

		capsules.load(songs, difficulty);
		capsules.forEachAlive(capsule -> exitMovers.add(capsule, FlxG.width + capsule.x));
	}

	function intro()
	{
		// Intro script event
		// Skip the intro if cancelled
		var event:ScriptEvent = new ScriptEvent(FREEPLAY_INTRO);
		dispatch(event);

		if (event.cancelled)
		{
			stateMachine.reset();
			return;
		}

		backcard.hide();
		exitMovers.intro();

		exitMovers.onIntroDone = () ->
		{
			stateMachine.reset();
			backcard.show();

			dispatch(new ScriptEvent(FREEPLAY_INTRO_DONE));
		}
	}

	function exit()
	{
		if (!stateMachine.canInteract())
			return;

		// Exit script event
		// Prevent the player from exiting if cancelled
		var event:ScriptEvent = new ScriptEvent(FREEPLAY_EXIT);
		dispatch(event);

		if (event.cancelled)
			return;

		stateMachine.transition(TRANSITIONING);

		// Outro script event
		// Skip the outro if cancelled
		event = new ScriptEvent(FREEPLAY_OUTRO);
		dispatch(event);

		if (event.cancelled)
		{
			close();
			return;
		}

		backcard.hide();
		exitMovers.outro();

		exitMovers.onOutroDone = () ->
		{
			dispatch(new ScriptEvent(FREEPLAY_OUTRO_DONE));
			close();
		}

		FunkinSound.playOnce('ui/sounds/cancel');
		FunkinSound.music.stop();
	}

	override public function destroy()
	{
		FunkinSound.music.stop();
		@:privateAccess
		if (FlxG.game._nextState == null)
			MainMenuState.playMusic(true);

		super.destroy();
	}

	@:noCompletion
	inline function get_song():Song
	{
		return capsules.song;
	}

	@:noCompletion
	inline function get_difficulty():String
	{
		return diffText.difficulty;
	}

	public static function build(skipIntro:Bool = true):FunkinState
	{
		var menu:MainMenuState = new MainMenuState();
		menu.openSubState(new FreeplaySubState(skipIntro));
		return menu;
	}
}

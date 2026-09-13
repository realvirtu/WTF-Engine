package funkin.ui.freeplay;

import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.data.song.SongRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.graphics.shader.TextureSwap;
import funkin.modding.event.ScriptEvent;
import funkin.play.PlayState;
import funkin.play.Playlist;
import funkin.play.song.Song;
import funkin.save.Save;
import funkin.ui.charselect.CharacterSelectState;
import funkin.ui.freeplay.album.AlbumSprite;
import funkin.ui.freeplay.capsule.CapsuleGroup;
import funkin.ui.freeplay.capsule.CapsuleSprite;
import funkin.ui.freeplay.components.BackcardSprite;
import funkin.ui.freeplay.components.DJSprite;
import funkin.ui.freeplay.components.DifficultySelector;
import funkin.ui.freeplay.components.SortSelector;
import funkin.ui.freeplay.player.Player;
import funkin.ui.menu.MainMenuState;
import funkin.util.MathUtil;

/**
 * The engine's freeplay sub state.
 * This is the menu where the player can navigate through all the songs.
 */
class FreeplaySubState extends FunkinSubState
{
	public static var instance:FreeplaySubState;

	static var selectedSong:Int = 1;
	static var selectedDiff:Int = 1;
	static var selectedSort:Int = 0;

	static var player:Player;

	var skipIntro:Bool;
	var exitMovers:ExitMovers;
	var stateMachine:StateMachine;

	var song(get, never):Song;
	var difficulty(get, never):String;

	var songScore:Int;
	var lerpScore:Float;

	var backcard:BackcardSprite;
	var backingImage:FunkinSprite;
	var dj:DJSprite;
	var capsules:CapsuleGroup;
	var album:AlbumSprite;
	var freeplayText:FunkinText;
	var ostText:FunkinText;
	var scoreText:FunkinText;
	var diffText:DifficultySelector;
	var sortText:SortSelector;

	public function new(skipIntro:Bool = false)
	{
		super();

		this.skipIntro = skipIntro;
	}

	override function create()
	{
		super.create();

		instance = this;

		if (player == null)
			player = PlayerRegistry.instance.fetch('bf');

		FunkinSound.playMusic('ui/freeplay/music', 0);
		FunkinSound.music.fadeIn(1, 0, 0.6);

		exitMovers = new ExitMovers();
		stateMachine = new StateMachine();

		conductor.reset({b: 150});

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

		freeplayText = new FunkinText(10, 0, 'freeplay');
		freeplayText.size = 24;
		freeplayText.y = (blackbar.height - freeplayText.height) / 2 + 0.5;
		freeplayText.zIndex = blackbar.zIndex;
		add(freeplayText);

		ostText = new FunkinText(0, freeplayText.y);
		ostText.size = freeplayText.size;
		ostText.zIndex = blackbar.zIndex;
		add(ostText);

		album = new AlbumSprite();
		album.angle = 2;
		add(album);

		scoreText = new FunkinText(0, blackbar.height + 40);
		scoreText.alignment = RIGHT;
		add(scoreText);

		diffText = new DifficultySelector(selectedDiff, SongRegistry.instance.getDifficulties());
		diffText.onChanged.add(changeDiff);
		diffText.x = 220;
		diffText.y = scoreText.y;
		add(diffText);

		sortText = new SortSelector(selectedSort);
		sortText.x = FlxG.width / 2;
		sortText.y = blackbar.height + 20;
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update();

		if (controls.FAVORITE)
			favorite(capsules.capsule);
		if (controls.ACCEPT_P)
			confirm(capsules.capsule);
		if (controls.CHAR_SELECT)
			enterCharSelect();
		if (controls.BACK)
			exit();

		// Player switching debug
		// Pressing P switches between boyfriend and pico
		if (FlxG.keys.justPressed.P && stateMachine.canInteract())
		{
			var id:String = 'bf';

			if (player.id == id)
				id = 'pico';

			player = PlayerRegistry.instance.fetch(id);

			trace('Changing player to $player'.info());

			changeDiff(selectedDiff);
		}

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

		songScore = Save.instance.getSongScore(song?.id, difficulty, song?.variation);

		album.load(song?.album);
		album.screenCenter(Y);
		album.x = FlxG.width - album.sprite.width - 45;
		album.y += 35;

		ostText.text = album.album?.ost ?? Constants.DEFAULT_OST_NAME;
		ostText.x = FlxG.width - ostText.width - freeplayText.x;

		// Album width is so dumb
		// The exit mover has to be applied like this :omg_bruh:
		exitMovers.add(album, FlxG.width + album.width);
	}

	function changeDiff(selected:Int)
	{
		selectedDiff = selected;

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

		var event:FreeplaySongScriptEvent = FreeplaySongScriptEvent.get(FREEPLAY_SONG_SELECTED, capsule);
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
				FunkinSound.playOnce('general/sounds/cancel');
				return;
			}

			capsules.selected = capsule.ID;
		}

		stateMachine.transition(INTERACTING);

		capsule.flicker();
		dj.confirm();

		FunkinSound.playOnce('general/sounds/confirm');

		FlxTimer.wait(1, () ->
		{
			camera.fade(0xFF000000, 0.25, false, () ->
			{
				Playlist.reset();

				// Yes it has to be done like this
				// Um fuck you Flixel
				final params:PlayStateParams = {song: song, difficulty: difficulty};

				FlxG.switchState(() -> new PlayState(params));
			});
		});
	}

	function favorite(capsule:CapsuleSprite)
	{
		var capsule:CapsuleSprite = capsules.capsule;
		var song:Song = capsule.song;

		if (!stateMachine.canInteract() || song == null)
			return;

		var event:FreeplaySongScriptEvent = FreeplaySongScriptEvent.get(FREEPLAY_SONG_FAVORITED, capsule);
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
		var songs:Array<Song> = SongRegistry.instance.listWithDifficulty(difficulty, player);

		switch (sortText.mode)
		{
			case FAVORITES:
				songs = songs.filter(song -> return Save.instance.isSongFavorited(song.id, song.variation));
			case LEVEL:
				songs = songs.filter(song -> return sortText.level.hasSong(song.id));
			default:
				// Literally nothing
		}

		capsules.load(songs, difficulty);
		capsules.forEachAlive(capsule -> exitMovers.add(capsule, FlxG.width + capsule.x));
	}

	function intro()
	{
		// Intro script event
		// Skip the intro if cancelled
		var event:ScriptEvent = ScriptEvent.get(FREEPLAY_INTRO);
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

			dispatch(ScriptEvent.get(FREEPLAY_INTRO_DONE));
		}
	}

	function enterCharSelect()
	{
		if (!stateMachine.canInteract())
			return;
		FlxG.switchState(() -> new CharacterSelectState());
	}

	function exit()
	{
		if (!stateMachine.canInteract())
			return;

		// Exit script event
		// Prevent the player from exiting if cancelled
		var event:ScriptEvent = ScriptEvent.get(FREEPLAY_EXIT);
		dispatch(event);

		if (event.cancelled)
			return;

		stateMachine.transition(TRANSITIONING);

		// Outro script event
		// Skip the outro if cancelled
		event = ScriptEvent.get(FREEPLAY_OUTRO);
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
			dispatch(ScriptEvent.get(FREEPLAY_OUTRO_DONE));
			close();
		}

		FunkinSound.playOnce('general/sounds/cancel');
		FunkinSound.music.stop();
	}

	override function destroy()
	{
		FunkinSound.music.stop();
		@:privateAccess
		if (FlxG.game._nextState == null)
			MainMenuState.playMusic(true);

		super.destroy();

		instance = null;
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

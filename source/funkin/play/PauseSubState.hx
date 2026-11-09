package funkin.play;

import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.data.character.CharacterRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.modding.event.ScriptEvent;
import funkin.play.song.Song;
import funkin.ui.FunkinSubState;
import funkin.ui.TextMenuList;
import funkin.ui.options.OptionsSubState;
#if FEATURE_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

/**
 * An enum used for determining the entries displayed in the pause menu.
 */
enum PauseMode
{
	DEFAULT;
	DIFFICULTY;
	INSTRUMENTAL;
	CUTSCENE;
}

/**
 * The game's pause menu sub state.
 */
class PauseSubState extends FunkinSubState
{
	public static var instance:PauseSubState;
	public static var musicId:String;

	public var music:FunkinSound;

	public var mode:PauseMode;

	public var bg:FunkinSprite;
	public var songText:FunkinText;
	public var menuList:TextMenuList;

	var song(get, never):Song;
	var difficulty(get, never):String;
	var instrumental(get, never):String;
	var deaths(get, never):Int;

	public function new(mode:PauseMode = DEFAULT)
	{
		super();

		this.mode = mode;
	}

	override function create()
	{
		super.create();

		instance = this;

		_parentState.persistentUpdate = false;

		music = FunkinSound.load(getMusicPath(), 0);
		music.fadeIn(2);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		bg.active = false;
		add(bg);

		songText = new FunkinText(0, 20);
		songText.size = 24;
		songText.alignment = RIGHT;
		add(songText);

		menuList = new TextMenuList();
		add(menuList);

		updateSongText();

		load(mode);

		FlxTween.tween(bg, {alpha: 0.8}, 0.15);

		#if FEATURE_DISCORD_RPC
		DiscordRPC.updatePresence(null, 'Paused');
		#end
	}

	function load(mode:PauseMode = DEFAULT)
	{
		menuList.clearItems();

		switch (mode)
		{
			case DIFFICULTY:
				for (diff in song.getDifficulties(false))
				{
					if (difficulty == diff)
						continue;
					menuList.addItem(diff, changeDifficulty.bind(diff));
				}

				menuList.addItem('back', () -> load());

			case INSTRUMENTAL:
				final instrumentals:Array<String> = song.getInstrumentals();

				instrumentals.push(Constants.DEFAULT_VARIATION);

				for (inst in instrumentals)
				{
					if (instrumental == inst)
						continue;
					menuList.addItem(inst, changeInstrumental.bind(inst));
				}

				menuList.addItem('back', () -> load());

			case CUTSCENE:
				menuList.addItem('resume', resumeSong);

				menuList.addItem('restart cutscene', () ->
				{
					PlayState.instance.conversation?.start();

					resumeSong();
				});

				menuList.addItem('skip cutscene', () ->
				{
					PlayState.instance.conversation?.end();

					resumeSong();
				});

				menuList.addItem('options', openOptions);
				menuList.addItem('exit to menu', exitSong);

			default:
				menuList.addItem('resume', resumeSong);
				menuList.addItem('restart', restartSong);

				if (song.getDifficulties(false).length > 1)
					menuList.addItem('difficulty', () -> load(DIFFICULTY));
				if (song.getInstrumentals().length > 0)
					menuList.addItem('instrumental', () -> load(INSTRUMENTAL));

				menuList.addItem('options', openOptions);
				menuList.addItem('botplay', toggleBotplay);
				menuList.addItem('exit to menu', exitSong);
		}
	}

	function resumeSong()
	{
		var event:ScriptEvent = ScriptEvent.get(RESUME);
		dispatch(event);

		if (event.cancelled)
			return;

		close();
	}

	function restartSong()
	{
		PlayState.instance.loadSong();

		close();
	}

	function openOptions()
	{
		openSubState(new OptionsSubState());
	}

	function toggleBotplay()
	{
		Preferences.botplay = !Preferences.botplay;

		updateSongText();
	}

	function exitSong()
	{
		menuList.busy = true;

		PlayState.instance.exit();
	}

	function changeDifficulty(diff:String)
	{
		PlayState.instance.difficulty = diff;
		PlayState.instance.loadSong();

		close();
	}

	function changeInstrumental(inst:String)
	{
		PlayState.instance.instrumental = inst;
		PlayState.instance.loadSong();

		close();
	}

	function updateSongText()
	{
		// Updates the song text
		// Display some cool info
		songText.text = song.name;
		songText.text += '\ndifficulty: $difficulty';
		songText.text += '\nartist: ${song.artist}';
		songText.text += '\ncharter: ${song.charter}';
		songText.text += '\n$deaths blue ball';

		if (deaths != 1)
			songText.text += 's';
		if (Preferences.botplay)
			songText.text += '\nbotplay';

		songText.x = FlxG.width - songText.width - 20;
	}

	function getMusicPath():String
	{
		return '${CharacterRegistry.instance.path}/$musicId/pause';
	}

	override function close()
	{
		super.close();

		#if FEATURE_DISCORD_RPC
		DiscordRPC.updatePresence();
		#end

		_parentState.persistentUpdate = true;
	}

	override function destroy()
	{
		super.destroy();

		instance = null;

		music.destroy();
	}

	@:noCompletion
	inline function get_song():Song
	{
		return PlayState.instance.song;
	}

	@:noCompletion
	inline function get_difficulty():String
	{
		return PlayState.instance.difficulty;
	}

	@:noCompletion
	inline function get_instrumental():String
	{
		return PlayState.instance.instrumental;
	}

	@:noCompletion
	inline function get_deaths():Int
	{
		return PlayState.instance.deaths;
	}

	public static function reset()
	{
		musicId = PlayState.instance.stage.player?.id;
	}
}

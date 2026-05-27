package funkin.play;

import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.modding.event.ScriptEvent;
import funkin.play.character.Character;
import funkin.play.song.Song;
import funkin.ui.FunkinSubState;
import funkin.ui.MenuList;
import funkin.ui.options.OptionsSubState;

/**
 * The game's pause menu sub state.
 */
class PauseSubState extends FunkinSubState
{
	public static var instance:PauseSubState;

	final DEFAULT_ENTRIES:Array<String> = ['resume', 'restart', 'options', 'botplay', 'exit to menu'];

	var song(get, never):Song;
	var difficulty(get, never):String;
	var deaths(get, never):Int;

	var justOpened:Bool = true;
	var changingDiff:Bool = false;

	var music:FlxSound;

	var bg:FunkinSprite;
	var songText:FunkinText;
	var menuList:MenuList;

	override public function create()
	{
		super.create();

		instance = this;

		if (song.difficulties.length > 1)
			DEFAULT_ENTRIES.insert(2, 'difficulty');

		final player:Character = PlayState.instance.stage.player;
		final musicPath:String = 'play/characters/${player?.meta?.pause ?? player?.id}/pause';

		music = FunkinSound.load(musicPath, 0);
		music.fadeIn(2);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		bg.active = false;
		add(bg);

		songText = new FunkinText(0, 20);
		songText.size = 24;
		songText.alignment = RIGHT;
		add(songText);

		menuList = new MenuList(DEFAULT_ENTRIES);
		menuList.onSelected.add(select);
		add(menuList);

		updateSongText();

		FlxTween.tween(bg, {alpha: 0.8}, 0.15);

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresence(null, 'Paused');
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		justOpened = false;
	}

	function updateSongText()
	{
		// Updates the song text
		// Display some cool info
		songText.text = song.name;
		songText.text += '\ndifficulty: $difficulty';
		songText.text += '\nartist: ${song.artist}';
		songText.text += '\n$deaths blue ball';

		if (deaths != 1)
			songText.text += 's';
		if (Preferences.botplay)
			songText.text += '\nbotplay';

		songText.x = FlxG.width - songText.width - 20;
	}

	function select(item:String)
	{
		if (justOpened)
			return;

		if (changingDiff)
		{
			// Checks if back was pressed
			// I mean, you never know if someone makes a BACK difficulty
			if (menuList.selected == menuList.size - 1)
			{
				menuList.entries = DEFAULT_ENTRIES;
				changingDiff = false;
			}
			else
			{
				PlayState.difficulty = item;
				PlayState.instance.resetSong();
				close();
			}
		}
		else
		{
			switch (item)
			{
				case 'resume':
					var event:ScriptEvent = new ScriptEvent(RESUME);
					dispatch(event);

					if (!event.cancelled)
						close();
				case 'restart':
					PlayState.instance.resetSong();
					close();
				case 'options':
					openSubState(new OptionsSubState());
				case 'exit to menu':
					PlayState.instance.exit();
				case 'difficulty':
					var entries:Array<String> = song.difficulties.copy();

					entries.remove(difficulty);
					entries.push('back');

					menuList.entries = entries;
					changingDiff = true;
				case 'botplay':
					Preferences.botplay = !Preferences.botplay;
					updateSongText();
			}
		}
	}

	override public function close()
	{
		super.close();

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresence();
		#end
	}

	override public function destroy()
	{
		super.destroy();

		instance = null;

		// Destroys the music as it isn't needed anymore
		// If you remove this line, great things will happen
		music.fadeTween.cancel();
		music.destroy();
	}

	@:noCompletion
	inline function get_song():Song
	{
		return PlayState.song;
	}

	@:noCompletion
	inline function get_difficulty():String
	{
		return PlayState.difficulty;
	}

	@:noCompletion
	inline function get_deaths():Int
	{
		return PlayState.instance.deaths;
	}
}

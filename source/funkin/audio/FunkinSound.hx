package funkin.audio;

import flixel.FlxG;
import flixel.sound.FlxSound;

/**
 * A helper class for handling the engine's audio.
 * 
 * TODO: Change `playMusic` to use streamed audio.
 */
class FunkinSound
{
	public static var music(get, never):FlxSound;

	public static inline function load(id:String, volume:Float = 1, looped:Bool = true, autoDestroy:Bool = true, autoPlay:Bool = true):FlxSound
	{
		return FlxG.sound.load(Paths.sound(id), volume, looped, null, autoDestroy, autoPlay);
	}

	public static inline function playOnce(id:String, volume:Float = 1):FlxSound
	{
		return FlxG.sound.play(Paths.sound(id), volume);
	}

	public static function playMusic(id:String, volume:Float = 1, looped:Bool = true, autoPlay:Bool = true, overrideMusic:Bool = true)
	{
		if (music?.playing && !overrideMusic)
			return;

		FlxG.sound.playMusic(Paths.sound(id), volume, looped);

		if (!autoPlay)
			music.stop();
	}

	public static function stopAllSounds(stopMusic:Bool = false)
	{
		if (stopMusic)
			music?.stop();
		FlxG.sound.list.forEachAlive(sound -> sound.stop());
	}

	@:noCompletion
	static inline function get_music():FlxSound
	{
		return FlxG.sound.music;
	}
}

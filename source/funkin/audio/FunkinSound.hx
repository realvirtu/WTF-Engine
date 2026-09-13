package funkin.audio;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;

/**
 * A helper class for handling the engine's audio.
 * 
 * TODO: Change `playMusic` to use streamed audio.
 */
class FunkinSound extends FlxSound
{
	public static var music(get, set):FunkinSound;

	static var pool(default, null) = new FlxTypedGroup<FunkinSound>();

	//
	// FunkinSound
	//

	public static inline function load(id:String, volume:Float = 1, looped:Bool = true, autoDestroy:Bool = true, autoPlay:Bool = true):FunkinSound
	{
		var sound:FunkinSound = pool.recycle(FunkinSound);

		sound.loadEmbedded(Paths.sound(id), looped, autoDestroy);
		sound.volume = volume;

		if (autoPlay)
			sound.play();

		FlxG.sound.defaultSoundGroup.add(sound);
		FlxG.sound.list.add(sound);

		return sound;
	}

	public static inline function playOnce(id:String, volume:Float = 1):FunkinSound
	{
		return load(id, volume, false);
	}

	public static function playMusic(id:String, volume:Float = 1, looped:Bool = true, autoPlay:Bool = true, overrideMusic:Bool = true):FunkinSound
	{
		if (music?.playing && !overrideMusic)
			return music;

		music?.destroy();

		music = load(id, volume, looped, false, autoPlay);

		music.volume = volume;
		music.persist = true;

		FlxG.sound.list.remove(music);

		FlxG.sound.defaultMusicGroup.add(music);
		FlxG.sound.defaultSoundGroup.remove(music);

		return music;
	}

	public static function pauseAllSounds()
	{
		FlxG.sound.defaultSoundGroup.pause();
		FlxG.sound.defaultMusicGroup.pause();
	}

	public static function resumeAllSounds()
	{
		FlxG.sound.defaultSoundGroup.resume();
		FlxG.sound.defaultMusicGroup.resume();
	}

	public static function stopAllSounds(stopMusic:Bool = false)
	{
		if (stopMusic)
			music?.stop();
		FlxG.sound.list.forEachAlive(sound -> sound.stop());
	}

	@:noCompletion
	inline static function get_music():FunkinSound
	{
		return cast FlxG.sound.music;
	}

	@:noCompletion
	inline static function set_music(value:FunkinSound):FunkinSound
	{
		return cast FlxG.sound.music = value;
	}
}

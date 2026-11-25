package funkin.audio;

import flixel.sound.FlxSound;

/**
 * Parameters used for playing sounds.
 */
typedef SoundParams =
{
	@:optional
	var volume:Float;
	@:optional
	var looped:Bool;
	@:optional
	var autoPlay:Bool;
	@:optional
	var autoDestroy:Bool;
}

/**
 * Parameters used for playing music.
 */
typedef MusicParams =
{
	> SoundParams,

	@:optional
	var overrideMusic:Bool;
	@:optional
	var restartTrack:Bool;
}

/**
 * A helper class for handling the engine's audio.
 */
class FunkinSound extends FlxSound
{
	public static var music(default, null):FunkinSound;

	public var id:String;

	//
	// FunkinSound
	//

	public static inline function load(id:String, ?params:SoundParams):FunkinSound
	{
		params ??= {};
		params.volume ??= 1;
		params.looped ??= true;
		params.autoPlay ??= true;
		params.autoDestroy ??= true;

		var sound:FunkinSound = new FunkinSound();

		sound.loadAudio(Paths.sound(id), true, params.looped, params.autoDestroy);

		sound.id = id;
		sound.volume = params.volume;

		FlxG.sound.defaultSoundGroup.add(sound);
		FlxG.sound.list.add(sound);

		if (params.autoPlay)
			sound.play();

		return sound;
	}

	public static inline function playOnce(id:String, volume:Float = 1):FunkinSound
	{
		return load(id, {volume: volume, looped: false});
	}

	public static function playMusic(id:String, ?params:MusicParams):FunkinSound
	{
		params ??= {};
		params.autoDestroy ??= false;
		params.overrideMusic ??= true;
		params.restartTrack ??= true;

		if ((music?.playing && !params.overrideMusic) || (music?.id == id && !params.restartTrack))
			return music;

		music?.destroy();

		music = load(id, params);
		music.persist = true;

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
		FlxG.sound.list.forEachAlive(sound ->
		{
			if (sound == music && !stopMusic)
				return;
			sound.stop();
		});
	}
}

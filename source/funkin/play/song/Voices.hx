package funkin.play.song;

import flixel.sound.FlxSound;
import funkin.audio.FunkinSound;

/**
 * The game's vocal group, containing both the opponent and player's voices.
 */
class Voices
{
	public var opponent:FlxSound;
	public var player:FlxSound;

	public var opponentVolume(get, set):Float;
	public var playerVolume(get, set):Float;

	public var pitch(default, set):Float = 1;

	public function new(song:Song)
	{
		opponent = FunkinSound.load(song.opponentPath, 1, false, false, false);
		player = FunkinSound.load(song.playerPath, 1, false, false, false);
	}

	public function play()
	{
		opponent.play();
		player.play();
	}

	public function pause()
	{
		opponent.pause();
		player.pause();
	}

	public function stop()
	{
		opponent.stop();
		player.stop();
	}

	public function checkResync(time:Float)
	{
		// Opponent vocals resync
		if (Math.abs(time - opponent.time) > Constants.RESYNC_THRESHOLD)
		{
			opponent.pause();
			opponent.time = time;
			opponent.resume();
		}

		// Player vocals resync
		if (Math.abs(time - player.time) > Constants.RESYNC_THRESHOLD)
		{
			player.pause();
			player.time = time;
			player.resume();
		}
	}

	@:noCompletion
	function set_opponentVolume(value:Float):Float
	{
		opponent.volume = value;
		return value;
	}

	@:noCompletion
	function set_playerVolume(value:Float):Float
	{
		player.volume = value;
		return value;
	}

	@:noCompletion
	inline function get_opponentVolume():Float
	{
		return opponent.volume;
	}

	@:noCompletion
	inline function get_playerVolume():Float
	{
		return player.volume;
	}

	@:noCompletion
	inline function set_pitch(value:Float):Float
	{
		pitch = value;

		opponent.pitch = value;
		player.pitch = value;

		return value;
	}
}

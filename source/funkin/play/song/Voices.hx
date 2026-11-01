package funkin.play.song;

import funkin.audio.FunkinSound;

/**
 * The game's vocal group, containing both the opponent and player's voices.
 */
class Voices
{
	public var opponent:FunkinSound;
	public var player:FunkinSound;

	public var opponentVolume(get, set):Float;
	public var playerVolume(get, set):Float;

	public var pitch(default, set):Float = 1;

	public function new(song:Song)
	{
		if (song.hasLegacyVoices())
			player = FunkinSound.load(song.getLegacyVoicePath(), 1, false, false, false);
		else
		{
			if (song.hasVoice(false))
				opponent = FunkinSound.load(song.getVoicePath(false), 1, false, false, false);
			if (song.hasVoice(true))
				player = FunkinSound.load(song.getVoicePath(true), 1, false, false, false);
		}
	}

	public function play()
	{
		opponent?.play();
		player?.play();
	}

	public function pause()
	{
		opponent?.pause();
		player?.pause();
	}

	public function stop()
	{
		opponent?.stop();
		player?.stop();
	}

	@:noCompletion
	function set_opponentVolume(value:Float):Float
	{
		if (opponent != null)
			opponent.volume = value;
		return value;
	}

	@:noCompletion
	function set_playerVolume(value:Float):Float
	{
		if (player != null)
			player.volume = value;
		return value;
	}

	@:noCompletion
	inline function get_opponentVolume():Float
	{
		return opponent?.volume;
	}

	@:noCompletion
	inline function get_playerVolume():Float
	{
		return player?.volume;
	}

	@:noCompletion
	inline function set_pitch(value:Float):Float
	{
		pitch = value;

		if (opponent != null)
			opponent.pitch = pitch;

		if (player != null)
			player.pitch = pitch;

		return value;
	}
}

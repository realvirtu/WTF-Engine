package funkin.play;

import funkin.data.song.SongRegistry;
import funkin.play.PlayState.PlayStateParams;
import funkin.ui.Transition;
import funkin.ui.story.Level;

/**
 * A class for handling the playback of multiple songs.
 */
class Playlist
{
	public static var level:Level;
	public static var difficulty:String;

	public static var isStory(get, never):Bool;

	public static var songs:Array<String>;
	public static var score:Int;
	public static var tallies:Tallies;

	public static function reset(?level:Level, ?difficulty:String)
	{
		Playlist.level = level;
		Playlist.difficulty = difficulty;

		songs = level?.getSongs()?.copy() ?? [];

		score = 0;
		tallies = new Tallies();
	}

	public static function load()
	{
		// Yes it has to be done like this
		// Um fuck you Flixel
		final params:PlayStateParams = {
			song: SongRegistry.instance.fetch(songs[0]),
			difficulty: difficulty
		}

		Transition.switchState(() -> new PlayState(params));
	}

	public static function next():Bool
	{
		songs.shift();

		if (songs.length == 0)
			return false;

		load();

		return true;
	}

	@:noCompletion
	static inline function get_isStory():Bool
	{
		return level != null;
	}
}

package funkin.ui.story;

import funkin.data.song.SongRegistry;
import funkin.data.story.LevelData;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.play.song.Song;
import funkin.save.Save;

/**
 * A class containing the metadata for a level.
 */
class Level implements IPlayStateScriptedClass
{
	public var id:String;
	public var meta:LevelData;

	public var name(get, never):String;
	public var title(get, never):String;

	public var opponent(get, never):String;
	public var player(get, never):String;
	public var gf(get, never):String;

	public var color(get, never):String;

	var songs:Array<String>;
	var songNames:Array<String>;
	var diffs:Array<String>;

	public function new(id:String)
	{
		this.id = id;
	}

	public function getSongs():Array<String>
	{
		// Use a cached array to make it real easy for the engine
		if (songs != null)
			return songs;

		songs = [];

		for (song in meta.songs)
		{
			// Skip duplicate songs
			if (songs.contains(song))
				continue;

			// Push the song if it exists
			// There's no point of keeping null songs
			if (SongRegistry.instance.exists(song))
				songs.push(song);
		}

		return songs;
	}

	public function getSongNames():Array<String>
	{
		// Use a cached array to make it real easy for the engine
		if (songNames != null)
			return songNames;

		songNames = [];

		for (song in getSongs())
		{
			var song:Song = SongRegistry.instance.fetchSong(song);
			var name:String = song.name;

			songNames.push(name);
		}

		return songNames;
	}

	public function hasSong(id:String):Bool
	{
		return getSongs().contains(id);
	}

	public function getDifficulties():Array<String>
	{
		if (diffs != null)
			return diffs;

		diffs = [];

		for (i => song in getSongs())
		{
			final song:Song = SongRegistry.instance.fetchSong(song);

			if (i == 0)
				diffs = song.difficulties.copy();

			for (diff in diffs.copy())
			{
				if (!song.hasDifficulty(diff))
					diffs.remove(diff);
			}
		}

		return diffs;
	}

	public function setScore(score:Int, diff:String, force:Bool = true)
	{
		Save.instance.setScore('level-$id', diff, score, force);
	}

	public function getScore(diff:String):Int
	{
		return Save.instance.getScore('level-$id', diff);
	}

	public function isComplete():Bool
	{
		for (diff in SongRegistry.instance.getDifficulties())
		{
			for (song in getSongs())
			{
				final song:Song = SongRegistry.instance.fetchSong(song, diff);

				if (song.getScore(diff) > 0)
					return true;
			}
		}
		return false;
	}

	@:noCompletion
	function get_name():String
	{
		var name:String = meta.name;
		if (name.isEmpty())
			name = Constants.DEFAULT_NAME;
		return name;
	}

	@:noCompletion
	function get_title():String
	{
		return meta.title ?? id;
	}

	@:noCompletion
	function get_opponent():String
	{
		return meta.opponent;
	}

	@:noCompletion
	function get_player():String
	{
		return meta.player;
	}

	@:noCompletion
	function get_gf():String
	{
		return meta.gf;
	}

	@:noCompletion
	function get_color():String
	{
		return meta.color;
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onHoldNoteHold(event:HoldNoteScriptEvent) {}

	public function onHoldNoteDrop(event:HoldNoteScriptEvent) {}

	public function onGhostMiss(event:GhostMissScriptEvent) {}

	public function onStepHit(event:ConductorScriptEvent) {}

	public function onBeatHit(event:ConductorScriptEvent) {}

	public function onSongLoaded(event:SongLoadScriptEvent) {}

	public function onSongStart(event:ScriptEvent) {}

	public function onSongEnd(event:ScriptEvent) {}

	public function onSongRetry(event:ScriptEvent) {}

	public function onSongEvent(event:SongEventScriptEvent) {}

	public function onCountdownStart(event:CountdownScriptEvent) {}

	public function onCountdownStep(event:CountdownScriptEvent) {}

	public function onPause(event:ScriptEvent) {}

	public function onResume(event:ScriptEvent) {}

	public function onGameOverStart(event:ScriptEvent) {}

	public function onGameOverLoop(event:ScriptEvent) {}

	public function onGameOverRetry(event:ScriptEvent) {}

	public function toString():String
	{
		return name;
	}
}

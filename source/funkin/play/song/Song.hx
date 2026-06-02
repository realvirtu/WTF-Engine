package funkin.play.song;

import funkin.data.event.EventData;
import funkin.data.song.SongData;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.save.Save;
import haxe.ds.StringMap;

/**
 * A class containing meta and chart data for a song.
 */
class Song implements IPlayStateScriptedClass
{
	public var id:String;
	public var meta:SongMetadata;
	public var chart:SongChartData;

	public var variations:StringMap<Song>;
	public var variation:String;

	public var events(get, never):Array<EventData>;

	public var name(get, never):String;
	public var bpm(get, never):Float;
	public var artist(get, never):String;
	public var difficulties(get, never):Array<String>;

	public var album(get, never):String;
	public var style(get, never):String;
	public var stickerpack(get, never):String;

	public var stage(get, never):String;
	public var opponent(get, never):String;
	public var player(get, never):String;
	public var gf(get, never):String;

	public var instPath(get, never):String;
	public var opponentPath(get, never):String;
	public var playerPath(get, never):String;

	var diffs:Array<String>;
	var path(get, never):String;

	public function new(id:String, ?variation:String)
	{
		this.id = id;
		this.variation = variation;

		variations = new StringMap<Song>();
	}

	public function getRating(diff:String):Int
	{
		return meta.rating?.get(diff) ?? 0;
	}

	public function getNotes(diff:String):Array<SongNoteData>
	{
		return chart.notes?.get(diff) ?? [];
	}

	public function getSpeed(diff:String):Float
	{
		return chart.speed?.get(diff) ?? Constants.DEFAULT_SPEED;
	}

	public function getDifficulties():Array<String>
	{
		if (diffs != null)
			return diffs;

		diffs = difficulties.copy();

		for (variation in variations)
			diffs = diffs.concat(variation.difficulties);

		return diffs;
	}

	public function hasDifficulty(diff:String):Bool
	{
		return getDifficulties().contains(diff);
	}

	public function getVariation(id:String):Song
	{
		if (variations.exists(id))
			return variations.get(id);
		return this;
	}

	public function setScore(score:Int, diff:String, force:Bool = true)
	{
		Save.instance.setScore('song-$id', diff, score, force);
	}

	public function getScore(diff:String):Int
	{
		return Save.instance.getScore('song-$id', diff);
	}

	public function setFavorite(favorite:Bool)
	{
		if (isFavorited() == favorite)
			return;

		Save.instance.favorites.set('$id:$variation', favorite);
		Save.instance.flush();
	}

	public function isFavorited():Bool
	{
		return Save.instance.favorites.get('$id:$variation');
	}

	public function isComplete():Bool
	{
		for (diff in difficulties)
		{
			if (getScore(diff) > 0)
				return true;
		}
		return false;
	}

	@:noCompletion
	function get_name():String
	{
		var name:Null<String> = meta.name;
		if (name.isEmpty())
			name = Constants.DEFAULT_NAME;
		return name;
	}

	@:noCompletion
	function get_bpm():Float
	{
		return meta.bpm;
	}

	@:noCompletion
	function get_artist():String
	{
		var artist:Null<String> = meta.artist;
		if (artist == null || artist.trim() == '')
			artist = Constants.DEFAULT_ARTIST;
		return artist;
	}

	@:noCompletion
	function get_difficulties():Array<String>
	{
		return meta.difficulties;
	}

	@:noCompletion
	function get_album():String
	{
		return meta.album;
	}

	@:noCompletion
	function get_style():String
	{
		return meta.style;
	}

	@:noCompletion
	function get_stickerpack():String
	{
		return meta.stickerpack;
	}

	@:noCompletion
	function get_stage():String
	{
		return meta.stage;
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
	function get_events():Array<EventData>
	{
		return chart.events;
	}

	@:noCompletion
	inline function get_instPath():String
	{
		return '$path/inst';
	}

	@:noCompletion
	inline function get_opponentPath():String
	{
		return '$path/opponent';
	}

	@:noCompletion
	inline function get_playerPath():String
	{
		return '$path/player';
	}

	@:noCompletion
	inline function get_path():String
	{
		var path:String = 'play/songs/$id';
		if (variation != Constants.DEFAULT_VARIATION)
			path += '/$variation';
		return path;
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
		return '$id | $name | $bpm';
	}
}

package funkin.play.song;

import funkin.Conductor.ConductorBPM;
import funkin.data.event.EventData;
import funkin.data.song.SongData;
import funkin.data.song.SongRegistry;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import haxe.ds.StringMap;

/**
 * A class containing meta and chart data for a song.
 */
class Song implements IPlayStateScriptedClass
{
	public final id:String;

	public var variation:String;

	public var meta:SongMetadata;
	public var chart:SongChartData;
	public var variations:StringMap<Song>;

	public var events(get, never):Array<EventData>;

	public var name(get, never):String;
	public var bpm(get, never):ConductorBPM;
	public var artist(get, never):String;
	public var charter(get, never):String;

	public var album(get, never):String;

	public var previewStart(get, never):Float;
	public var previewEnd(get, never):Float;

	public var style(get, never):String;
	public var stickerpack(get, never):String;

	public var stage(get, never):String;
	public var opponent(get, never):String;
	public var player(get, never):String;
	public var gf(get, never):String;

	public function new(id:String, ?variation:String)
	{
		this.id = id;
		this.variation = variation;

		variations = new StringMap<Song>();
	}

	public function getNotes(diff:String):Array<SongNoteData>
	{
		return chart.notes?.get(diff)?.copy() ?? [];
	}

	public function getSpeed(diff:String):Float
	{
		return chart.speed?.get(diff) ?? Constants.DEFAULT_SPEED;
	}

	public function getRating(diff:String):Int
	{
		return meta.freeplay?.rating?.get(diff);
	}

	public function getDifficulties(all:Bool = true):Array<String>
	{
		var result:Array<String> = meta.difficulties.copy();

		if (!all)
			return result;

		for (variation in variations)
		{
			for (diff in variation.getDifficulties())
			{
				if (result.contains(diff))
					continue;
				result.push(diff);
			}
		}

		return result;
	}

	public function hasDifficulty(diff:String, all:Bool = true):Bool
	{
		return getDifficulties(all).contains(diff);
	}

	public function getVariation(id:String):Song
	{
		if (variations.exists(id))
			return variations.get(id);
		return this;
	}

	public function getInstrumentals():Array<String>
	{
		return meta.instrumentals.copy();
	}

	public function getInstrumentalPath(?id:String):String
	{
		return getPath('inst', id);
	}

	public function getVoicePath(player:Bool):String
	{
		return getPath(player ? 'player' : 'opponent');
	}

	public function getLegacyVoicePath():String
	{
		return getPath('voices');
	}

	public function hasVoice(player:Bool):Bool
	{
		return Paths.exists(Paths.sound(getVoicePath(player)));
	}

	public function hasLegacyVoices():Bool
	{
		return Paths.exists(Paths.sound(getLegacyVoicePath()));
	}

	public function getPath(id:String, ?variation:String):String
	{
		variation ??= this.variation;

		var path:String = '${SongRegistry.instance.path}/${this.id}';

		if (variation != Constants.DEFAULT_VARIATION)
			path += '/$variation';

		return '$path/$id';
	}

	@:noCompletion
	function get_name():String
	{
		var name:Null<String> = meta.name;
		if (StringTools.isEmpty(name))
			name = Constants.DEFAULT_NAME;
		return name;
	}

	@:noCompletion
	function get_bpm():ConductorBPM
	{
		return meta.bpm;
	}

	@:noCompletion
	function get_artist():String
	{
		var artist:Null<String> = meta.artist;
		if (StringTools.isEmpty(artist))
			artist = Constants.DEFAULT_ARTIST;
		return artist;
	}

	@:noCompletion
	function get_charter():String
	{
		var charter:Null<String> = meta.charter;
		if (StringTools.isEmpty(charter))
			charter = Constants.DEFAULT_CHARTER;
		return charter;
	}

	@:noCompletion
	function get_album():String
	{
		return meta.freeplay?.album;
	}

	@:noCompletion
	function get_previewStart():Float
	{
		return meta.freeplay?.previewStart;
	}

	@:noCompletion
	function get_previewEnd():Float
	{
		return meta.freeplay?.previewEnd;
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

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onNoteIncoming(event:NoteScriptEvent) {}

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
		return id;
	}
}

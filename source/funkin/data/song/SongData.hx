package funkin.data.song;

import funkin.Conductor.ConductorBPM;
import funkin.data.event.EventData;

/**
 * A structure object used for song metadata.
 */
typedef SongMetadata =
{
	var name:String;
	var bpm:ConductorBPM;
	var artist:String;
	var charter:String;
	@:default([])
	var difficulties:Array<String>;
	@:default([])
	var instrumentals:Array<String>;
	var freeplay:SongFreeplayData;
	@:default('funkin')
	var style:String;
	@:optional
	var stickerpack:String;
	var stage:String;
	var opponent:String;
	var player:String;
	var gf:String;
}

/**
 * A structure object used for song freeplay data.
 */
typedef SongFreeplayData =
{
	var rating:Map<String, Int>;
	var album:String;
	var previewStart:Float;
	var previewEnd:Float;
}

/**
 * A structure object used for song chart data.
 */
typedef SongChartData =
{
	var speed:Map<String, Float>;
	var notes:Map<String, Array<SongNoteData>>;
	@:default([])
	var events:Array<EventData>;
}

/**
 * A structure object used for song note data.
 */
typedef SongNoteData =
{
	var t:Float;
	var d:Int;
	var l:Float;
	var k:String;
}

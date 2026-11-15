package funkin.util;

import flixel.FlxBasic;
import flixel.util.FlxSort;
import funkin.data.event.EventData;
import funkin.data.song.SongData.SongNoteData;

/**
 * A utility class for sorting.
 */
class SortUtil
{
	public static inline function byTime(order:Int, a:SongNoteData, b:SongNoteData):Int
	{
		return FlxSort.byValues(order, a.t, b.t);
	}

	public static inline function byEventTime(order:Int, a:EventData, b:EventData):Int
	{
		return FlxSort.byValues(order, a.t, b.t);
	}

	public static function alphabetically(a:String, b:String):Int
	{
		if (a == b)
			return 0;
		return a < b ? -1 : 1;
	}

	public static function defaultsAlphabetically(defaults:Array<String>, a:String, b:String):Int
	{
		if (defaults.contains(a) && defaults.contains(b))
			return defaults.indexOf(a) - defaults.indexOf(b);
		if (defaults.contains(a))
			return -1;
		if (defaults.contains(b))
			return 1;
		return alphabetically(a, b);
	}
}

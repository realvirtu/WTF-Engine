package funkin.util;

import flixel.math.FlxMath;

/**
 * Utility class containing helper functions for strings.
 */
class StringUtil
{
	public static inline function formatBytes(bytes:Float):String
	{
		final units:Array<String> = ['b', 'kb', 'mb', 'gb', 'tb'];

		var memory:Float = bytes;

		while (memory >= 1000 && units.length > 1)
		{
			memory /= 1000;

			units.shift();
		}

		final unit:String = units[0];

		memory = FlxMath.roundDecimal(memory, 2);

		return '$memory$unit';
	}
}

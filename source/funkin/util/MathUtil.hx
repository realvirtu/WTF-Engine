package funkin.util;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;

/**
 * A utility class containing math functions and all that annoying crap.
 */
class MathUtil
{
	/**
	 * A lerp function, but it's actually framerate independent.
	 */
	public static inline function lerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, FlxMath.getElapsedLerp(ratio, FlxG.elapsed));
	}
}

package funkin.util;

/**
 * A utility class for tween easing.
 */
class EaseUtil
{
	public static inline function stepped(steps:Int):Float->Float
	{
		return x -> Math.floor(x * steps) / steps;
	}
}

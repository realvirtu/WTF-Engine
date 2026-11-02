package funkin.util.tools;

/**
 * A tools class for handling strings.
 */
class StringTools
{
	public static inline function isEmpty(s:String):Bool
	{
		return s == null || s.trim() == '';
	}
}

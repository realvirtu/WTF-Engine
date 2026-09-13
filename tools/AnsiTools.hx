package tools;

#if macro
import haxe.macro.Context;
#end

using StringTools;

/**
 * An enum abstract containing string codes for `AnsiTools`.
 */
enum abstract AnsiCode(String) to String from String
{
	var RESET = '\x1b[0m';
	var BOLD = '\x1b[1m';
	var DIM = '\x1b[2m';
	var ITALIC = '\x1b[3m';
	var UNDERLINE = '\x1b[4m';
	var BLINK = '\x1b[5m';
	var INVERSE = '\x1b[7m';
	var HIDDEN = '\x1b[8m';
	var STRIKETHROUGH = '\x1b[9m';

	var BLACK = '\x1b[30m';
	var RED = '\x1b[31m';
	var GREEN = '\x1b[32m';
	var YELLOW = '\x1b[33m';
	var BLUE = '\x1b[34m';
	var MAGENTA = '\x1b[35m';
	var CYAN = '\x1b[36m';
	var WHITE = '\x1b[37m';

	var BG_BLACK = '\x1b[40m';
	var BG_RED = '\x1b[41m';
	var BG_GREEN = '\x1b[42m';
	var BG_YELLOW = '\x1b[43m';
	var BG_BLUE = '\x1b[44m';
	var BG_MAGENTA = '\x1b[45m';
	var BG_CYAN = '\x1b[46m';
	var BG_WHITE = '\x1b[47m';
}

/**
 * A tool class for applying color to strings in the terminal.
 * 
 * Based on Funkin's `AnsiUtil` class.
 */
class AnsiTools
{
	//
	// LOGGING
	//
	public static inline function info(s:String):String
	{
		return bold(magenta(s));
	}

	public static inline function warn(s:String):String
	{
		return bold(yellow(s));
	}

	public static inline function error(s:String):String
	{
		return bold(red(s));
	}

	public static inline function debug(s:String):String
	{
		return bold(green(s));
	}

	//
	// STYLES
	//

	public static inline function bold(s:String):String
	{
		return apply(s, BOLD);
	}

	public static inline function dim(s:String):String
	{
		return apply(s, DIM);
	}

	public static inline function italic(s:String):String
	{
		return apply(s, ITALIC);
	}

	public static inline function underline(s:String):String
	{
		return apply(s, UNDERLINE);
	}

	public static inline function blink(s:String):String
	{
		return apply(s, BLINK);
	}

	public static inline function inverse(s:String):String
	{
		return apply(s, INVERSE);
	}

	public static inline function hidden(s:String):String
	{
		return apply(s, HIDDEN);
	}

	public static inline function strikethrough(s:String):String
	{
		return apply(s, STRIKETHROUGH);
	}

	//
	// COLORS
	//

	public static inline function black(s:String):String
	{
		return apply(s, BLACK);
	}

	public static inline function red(s:String):String
	{
		return apply(s, RED);
	}

	public static inline function green(s:String):String
	{
		return apply(s, GREEN);
	}

	public static inline function yellow(s:String):String
	{
		return apply(s, YELLOW);
	}

	public static inline function blue(s:String):String
	{
		return apply(s, BLUE);
	}

	public static inline function magenta(s:String):String
	{
		return apply(s, MAGENTA);
	}

	public static inline function cyan(s:String):String
	{
		return apply(s, CYAN);
	}

	public static inline function white(s:String):String
	{
		return apply(s, WHITE);
	}

	//
	// BACKGROUND COLORS
	//

	public static inline function bgBlack(s:String):String
	{
		return apply(s, BG_BLACK);
	}

	public static inline function bgRed(s:String):String
	{
		return apply(s, BG_RED);
	}

	public static inline function bgGreen(s:String):String
	{
		return apply(s, BG_GREEN);
	}

	public static inline function bgYellow(s:String):String
	{
		return apply(s, BG_YELLOW);
	}

	public static inline function bgBlue(s:String):String
	{
		return apply(s, BG_BLUE);
	}

	public static inline function bgMagenta(s:String):String
	{
		return apply(s, BG_MAGENTA);
	}

	public static inline function bgCyan(s:String):String
	{
		return apply(s, BG_CYAN);
	}

	public static inline function bgWhite(s:String):String
	{
		return apply(s, BG_WHITE);
	}

	static inline function apply(s:String, code:AnsiCode):String
	{
		if (s.contains(RESET))
			s = s.replace(RESET, '');

		#if macro
		if (Context.defined('message.no-color'))
			return s;
		#end

		return '$code$s$RESET';
	}
}

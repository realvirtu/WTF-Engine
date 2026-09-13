package funkin.util;

import lime.app.Application;

/**
 * A utility class for handling window-related things.
 */
class WindowUtil
{
	public static function exit()
	{
		trace('Exiting the game...'.warn());
		trace('This is NOT a crash.'.warn());

		Sys.exit(0);
	}

	public static function setVSync(vsync:Bool)
	{
		Application.current.window.setVSyncMode(vsync ? ON : OFF);
	}

	public static function alert(message:String)
	{
		Application.current.window.alert(message);
	}
}

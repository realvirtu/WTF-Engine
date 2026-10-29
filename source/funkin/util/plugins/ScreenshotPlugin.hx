package funkin.util.plugins;

#if HAS_SCREENSHOTS
import flixel.FlxBasic;
import funkin.audio.FunkinSound;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import sys.io.File;

/**
 * A plugin that allows the player to take screenshots.
 * This is limited to one screenshot as this plugin is for debugging purposes.
 */
class ScreenshotPlugin extends FlxBasic
{
	var takingScreenshot:Bool = false;
	var takingFrame:Int = 0;

	public static function init()
	{
		FlxG.plugins.addPlugin(new ScreenshotPlugin());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (takingScreenshot)
			takingFrame++;

		// Pressing F3 takes a screenshot of the game
		if (FlxG.keys.justPressed.F3 && !takingScreenshot)
		{
			#if HAS_FPS_COUNTER
			Main.fpsCounter.visible = false;
			#end

			takingScreenshot = true;
		}

		// Takes the screenshot after a few frames
		// Because of the stupid fps counter
		if (takingFrame > 1)
		{
			final data:BitmapData = BitmapData.fromImage(FlxG.stage.window.readPixels());
			final bytes:ByteArray = data.encode(data.rect, new PNGEncoderOptions());

			File.saveBytes('screenshot.${Constants.IMAGE_EXT}', bytes);
			FunkinSound.playOnce('general/sounds/cancel');

			#if HAS_FPS_COUNTER
			Main.fpsCounter.visible = Preferences.showFPS;
			#end

			takingScreenshot = false;
			takingFrame = 0;
		}
	}
}
#end

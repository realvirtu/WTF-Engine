package funkin.util.plugins;

#if HAS_SCREENSHOTS
import flixel.FlxBasic;
import flixel.util.FlxTimer;
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
	var tookScreenshot:Bool = false;

	public static function init()
	{
		FlxG.plugins.addPlugin(new ScreenshotPlugin());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F3 && !tookScreenshot)
		{
			#if HAS_FPS_COUNTER
			Main.fpsCounter.visible = false;
			#end

			tookScreenshot = true;

			// Fuck you
			// Get hit with FlxTimer.wait()
			FlxTimer.wait(0.1, () ->
			{
				var data:BitmapData = BitmapData.fromImage(FlxG.stage.window.readPixels());
				var bytes:ByteArray = data.encode(data.rect, new PNGEncoderOptions());

				File.saveBytes('screenshot.${Constants.IMAGE_EXT}', bytes);
				FunkinSound.playOnce('general/sounds/cancel');

				#if HAS_FPS_COUNTER
				Main.fpsCounter.visible = true;
				#end

				tookScreenshot = false;
			});
		}
	}
}
#end

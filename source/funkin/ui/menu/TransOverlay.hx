package funkin.ui.menu;

#if FEATURE_TRANS_SECRET
import openfl.display.Bitmap;
import openfl.geom.Rectangle;

/**
 * An overlay that displays the transgender flag. Why? Because why the hell not.
 */
class TransOverlay extends Bitmap
{
	public function new()
	{
		super(FlxG.assets.getBitmapData(Paths.image('ui/menu/trans/flag')));

		scrollRect = new Rectangle();
		alpha = 0.5;

		FlxG.signals.gameResized.add((_, _) -> onResize());

		onResize();
	}

	function onResize()
	{
		final width:Float = FlxG.scaleMode.gameSize.x;
		final height:Float = FlxG.scaleMode.gameSize.y;

		scaleX = width;
		scaleY = height / 10;

		__scrollRect.width = width;
		__scrollRect.height = height;
	}
}
#end

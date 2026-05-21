package funkin.ui;

import flixel.system.scaleModes.RatioScaleMode;

/**
 * The engine's scale mode that keeps the game within its aspect ratio when resized.
 * 
 * This is literally an extension of `RatioScaleMode`, but with fixes.
 */
class FunkinScaleMode extends RatioScaleMode
{
	public function new()
	{
		super(false);
	}

	/**
	 * TODO: Fix the evil yucky window scaling.
	 */
	override function updateGameSize(width:Int, height:Int)
	{
		final ratio:Float = FlxG.width / FlxG.height;
		final realRatio:Float = width / height;

		var scaleY:Bool = realRatio < ratio;

		if (scaleY)
		{
			gameSize.x = width;
			gameSize.y = Math.floor(gameSize.x / ratio);
		}
		else
		{
			gameSize.y = height;
			gameSize.x = Math.floor(gameSize.y * ratio);
		}
	}
}

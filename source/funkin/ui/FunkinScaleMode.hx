package funkin.ui;

import flixel.system.scaleModes.BaseScaleMode;

/**
 * The engine's scale mode that keeps the game within its aspect ratio when resized.
 * 
 * This is literally just `RatioScaleMode`, but better.
 */
class FunkinScaleMode extends BaseScaleMode
{
	/**
	 * TODO: Fix the evil yucky window scaling.
	 */
	override function updateGameSize(width:Int, height:Int)
	{
		final ratio:Float = FlxG.width / FlxG.height;
		final realRatio:Float = width / height;

		if (realRatio < ratio)
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

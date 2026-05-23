package funkin.ui;

import flixel.system.scaleModes.RatioScaleMode;

/**
 * The engine's scale mode that keeps the game within its aspect ratio when resized.
 * 
 * This is literally just `RatioScaleMode`, but better.
 */
class FunkinScaleMode extends RatioScaleMode
{
	public function new()
	{
		super(false);
	}
}

package funkin.ui.freeplay.components;

import funkin.graphics.FunkinSprite;

/**
 * The DJ sprite used for the freeplay menu.
 */
class DJSprite extends FunkinSprite
{
	var busy:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadSprite('menu/freeplay/dj', 1.25, 224, 258);

		addAnimation('idle', [0, 1, 2], 10, false);
		addAnimation('confirm', [3, 4, 5], 10, false);

		bop();
	}

	public function bop()
	{
		if (busy)
			return;
		playAnimation('idle', true);
	}

	public function confirm()
	{
		busy = true;
		playAnimation('confirm');
	}
}

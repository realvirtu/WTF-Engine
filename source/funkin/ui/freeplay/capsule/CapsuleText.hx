package funkin.ui.freeplay.capsule;

import funkin.graphics.FunkinText;

/**
 * A `FunkinText` extension used for freeplay song capsules.
 * 
 * This class exists to prevent the repetition of setting the size
 * and color to the same exact thing.
 */
class CapsuleText extends FunkinText
{
	public function new(x:Float = 0, y:Float = 0, text:String = '')
	{
		super(x, y, text);

		color = 0xFF2E2E2E;
		size = 16;
		letterSpacing = 0;
	}
}

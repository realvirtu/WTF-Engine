package funkin.ui.freeplay.player;

import flixel.util.FlxTimer;
import funkin.graphics.FunkinSprite;

/**
 * The DJ sprite used for the freeplay menu.
 */
class DJSprite extends FunkinSprite
{
	var bopTimer:FlxTimer;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadSprite('ui/freeplay/dj', 1.25, 224, 258);

		addAnimation('idle', [0, 1, 2], 10, false);
		addAnimation('confirm', [3, 4, 5], 10, false);

		bop();

		bopTimer = FlxTimer.loop(Conductor.instance.beatLength / Constants.MS_PER_SEC, _ -> bop(), 0);
	}

	public function bop()
	{
		playAnimation('idle', true);
	}

	public function confirm()
	{
		playAnimation('confirm');

		bopTimer.cancel();
	}

	override function destroy()
	{
		super.destroy();

		bopTimer.cancel();
	}
}

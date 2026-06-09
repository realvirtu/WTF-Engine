package funkin.play.components;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;

/**
 * A `FunkinSprite` used for the game's countdown before the song starts.
 */
class Countdown extends FunkinSprite
{
	public var started:Bool = false;
	public var step:Int;

	var style:Style;

	public function new(style:Style)
	{
		super();

		this.style = style;

		visible = false;
		active = false;
	}

	public function start()
	{
		started = true;
		step = -1;

		visible = false;

		FlxTween.cancelTweensOf(this);
	}

	public function advance()
	{
		if (!started)
			return;

		step++;

		switch (step)
		{
			case 0:
				FunkinSound.playOnce(style.getCountdown('sounds/three'));
			case 1:
				FunkinSound.playOnce(style.getCountdown('sounds/two'));
				popup('ready');
			case 2:
				FunkinSound.playOnce(style.getCountdown('sounds/one'));
				popup('set');
			case 3:
				FunkinSound.playOnce(style.getCountdown('sounds/go'));
				popup('go');
		}
	}

	public function popup(id:String)
	{
		loadSprite(style.getCountdown(id), style.scale);
		screenCenter();

		final baseScale:Float = scale.x;

		scale.x = scale.y = baseScale * 2;

		visible = true;
		alpha = 1;

		FlxTween.cancelTweensOf(this);
		FlxTween.cancelTweensOf(scale);

		FlxTween.tween(scale, {x: baseScale, y: baseScale}, 0.5, {
			ease: FlxEase.elasticOut,
			onComplete: _ ->
			{
				FlxTween.tween(this, {alpha: 0}, 0.35, {ease: FlxEase.quadOut, onComplete: _ -> visible = false});
			}
		});
	}
}

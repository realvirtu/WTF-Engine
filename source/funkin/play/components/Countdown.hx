package funkin.play.components;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.modding.event.ScriptEvent;
import funkin.ui.FunkinState;

/**
 * A `FunkinSprite` used for the game's countdown before the song starts.
 */
class Countdown extends FunkinSprite
{
	var timer:FlxTimer;
	var style:Style;

	public function new(style:Style)
	{
		super();

		this.style = style;

		visible = false;
		active = false;
	}

	public function start(rate:Float)
	{
		visible = false;

		timer?.cancel();
		timer = FlxTimer.loop(Conductor.instance.crotchet / Constants.MS_PER_SEC / rate, step, 4);

		FlxTween.cancelTweensOf(this);
		FlxTween.cancelTweensOf(scale);
	}

	public function step(step:Int)
	{
		var event:CountdownScriptEvent = new CountdownScriptEvent(COUNTDOWN_STEP, step);
		dispatch(event);

		if (event.cancelled)
			return;

		switch (step)
		{
			case 1:
				FunkinSound.playOnce(style.getCountdown('sounds/three'));
			case 2:
				FunkinSound.playOnce(style.getCountdown('sounds/two'));
				popup('ready');
			case 3:
				FunkinSound.playOnce(style.getCountdown('sounds/one'));
				popup('set');
			case 4:
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
			onComplete: _ -> FlxTween.tween(this, {alpha: 0}, 0.35, {ease: FlxEase.quadOut, onComplete: _ -> visible = false})
		});
	}

	function dispatch(event:ScriptEvent)
	{
		if (!Std.isOfType(FlxG.state, FunkinState))
			return;

		final state:FunkinState = cast FlxG.state;

		state.dispatch(event);
	}
}

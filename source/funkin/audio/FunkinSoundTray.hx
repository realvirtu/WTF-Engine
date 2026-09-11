package funkin.audio;

import flixel.system.ui.FlxSoundTray;
import funkin.util.MathUtil;
import openfl.display.Bitmap;

/**
 * An extension of `FlxSoundTray`, but with style.
 */
class FunkinSoundTray extends FlxSoundTray
{
	static final SCALE:Float = 1.25;

	var isSilent:Bool;

	var lerpScaleX:Float;
	var lerpScaleY:Float;
	var lerpPos:Float;

	var targetPos:Float;
	var targetAlpha:Float;

	var back:Bitmap;

	public function new()
	{
		super();

		removeChildren();

		back = new Bitmap(FlxG.assets.getBitmapData(Paths.image(getPath('back'))));
		back.x = -back.width / 2;
		back.y = -back.height / 2;
		addChild(back);

		buildBar(10).alpha = 0.3;

		_bars = [];

		for (i in 1...11)
			_bars.push(buildBar(i));
	}

	override function update(elapsed:Float)
	{
		if (!isSilent)
		{
			_timer = Math.min(1, _timer + elapsed / Constants.MS_PER_SEC);

			if (_timer == 1)
			{
				targetPos = -height;
				targetAlpha = 0;

				if (alpha <= 0.05)
					visible = active = false;
			}
		}

		lerpScaleX = MathUtil.lerp(lerpScaleX, SCALE, 0.3);
		lerpScaleY = MathUtil.lerp(lerpScaleY, SCALE, 0.3);

		lerpPos = MathUtil.lerp(lerpPos, targetPos, 0.1);

		alpha = MathUtil.lerp(alpha, targetAlpha, 0.45);

		screenCenter();
	}

	override function screenCenter()
	{
		scaleX = lerpScaleX * FlxG.scaleMode.scale.x;
		scaleY = lerpScaleY * FlxG.scaleMode.scale.y;

		x = FlxG.scaleMode.gameSize.x / 2;
		y = lerpPos * FlxG.scaleMode.scale.y;
	}

	override function showIncrement()
	{
		FunkinSound.playOnce(getPath('sounds/${FlxG.sound.volume == 1 ? 'max' : 'up'}'));

		popup(true);
	}

	override function showDecrement()
	{
		FunkinSound.playOnce(getPath('sounds/down'));

		popup(false);
	}

	function popup(up:Bool)
	{
		final volume:Int = FlxG.sound.muted ? 0 : Math.round(FlxG.sound.logToLinear(FlxG.sound.volume) * 10);

		_timer = 0;

		isSilent = volume == 0;

		lerpScaleX = SCALE * 1.25;
		lerpScaleY = SCALE * 0.75;

		targetPos = 50;
		targetAlpha = 1;

		visible = active = true;

		for (i => bar in _bars)
			bar.visible = i < volume;
	}

	function buildBar(index:Int):Bitmap
	{
		var bar:Bitmap = new Bitmap(FlxG.assets.getBitmapData(Paths.image(getPath('bars/bar$index'))));
		bar.x = -bar.width / 2;
		bar.y = back.y + bar.height / 2 - 3;

		addChild(bar);

		return bar;
	}

	inline function getPath(id:String):String
	{
		return 'general/soundtray/$id';
	}
}

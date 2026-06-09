package funkin.graphics;

import flixel.util.FlxColor;

/**
 * A better version of Flixel's `FlxBar` class because `FlxBar` is dumb and stupid.
 */
class FunkinBar extends FunkinSprite
{
	public var min:Float;
	public var max:Float;
	public var isLeft:Bool;

	public var emptyColor:FlxColor;
	public var fillColor:FlxColor;

	public var value:Float;

	public var percent(get, never):Float;
	public var fillPosition(get, never):Float;

	public function new(x:Float, y:Float, width:Int, height:Int, min:Float = 0, max:Float = 100, isLeft:Bool = false)
	{
		super(x, y);

		this.min = min;
		this.max = max;
		this.isLeft = isLeft;

		makeSolidColor(width, height, 0xFFFFFFFF);
		setColors(0xFF000000, 0xFFFFFFFF);

		active = false;
		value = max;

		offset.x = isLeft ? -width + 1 : 0;
		origin.x = isLeft ? 1 : 0;
	}

	public function setColors(emptyColor:FlxColor, fillColor:FlxColor)
	{
		this.emptyColor = emptyColor;
		this.fillColor = fillColor;
	}

	override public function draw()
	{
		color = emptyColor;

		super.draw();

		scale.x = percent * width;
		color = fillColor;

		super.draw();

		scale.x = width;
	}

	@:noCompletion
	inline function get_percent():Float
	{
		return value / max;
	}

	@:noCompletion
	inline function get_fillPosition():Float
	{
		var pos:Float = percent * width;
		if (isLeft)
			pos = width - pos;
		return x + pos;
	}
}

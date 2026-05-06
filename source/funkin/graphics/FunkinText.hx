package funkin.graphics;

import flixel.math.FlxPoint;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;

/**
 * The engine's text sprite.
 */
class FunkinText extends FlxBitmapText
{
	static final LETTERS:String = '!"#$%&\'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`{|}~\n';
	static final FONT_SIZE:FlxPoint = new FlxPoint(26, 34);

	public var size(default, set):Int = 32;

	public function new(x:Float = 0, y:Float = 0, text:String = '')
	{
		super(x, y, text, FlxBitmapFont.fromMonospace(Paths.image('ui/font'), LETTERS, FONT_SIZE));

		letterSpacing = 2;
		lineSpacing = 4;

		active = false;
	}

	@:noCompletion
	override function set_text(value:String):String
	{
		value = value?.toLowerCase();
		if (this.text == value)
			return value;
		return super.set_text(value);
	}

	@:noCompletion
	inline function set_size(value:Int):Int
	{
		this.size = value;

		// The base font size is 32, so divide size by 32
		scale.x = value / 32;
		scale.y = scale.x;

		updateHitbox();

		return value;
	}
}

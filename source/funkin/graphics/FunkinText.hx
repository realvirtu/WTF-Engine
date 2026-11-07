package funkin.graphics;

import flixel.math.FlxPoint;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;

/**
 * The engine's text sprite.
 */
class FunkinText extends FlxBitmapText
{
	static final LETTERS:String = '!"#$%&\'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`{|}~\n';
	static final FONT_SIZE:FlxPoint = new FlxPoint(26, 34);

	public var size(default, set):Int = 32;

	var typeTimer:FlxTimer;
	var typeText:String;

	public function new(x:Float = 0, y:Float = 0, text:String = '')
	{
		super(x, y, text, FlxBitmapFont.fromMonospace(Paths.image('general/font'), LETTERS, FONT_SIZE));

		letterSpacing = 2;
		lineSpacing = 4;

		active = false;
	}

	public function type(text:String, speed:Float = 0.1, onType:Int->Void)
	{
		this.text = '';

		typeText = text;

		typeTimer?.cancel();
		typeTimer = FlxTimer.loop(speed, loop ->
		{
			this.text = text.substr(0, loop);

			if (onType != null)
				onType(loop);
		}, text.length);
	}

	public function cancelType()
	{
		typeTimer?.cancel();
		typeTimer = null;
		typeText = null;
	}

	public function finishType()
	{
		text = typeText;

		cancelType();
	}

	override function destroy()
	{
		super.destroy();

		cancelType();
	}

	@:noCompletion
	override function set_text(value:String):String
	{
		value = value?.toLowerCase();
		if (text == value)
			return text;
		return super.set_text(value);
	}

	@:noCompletion
	inline function set_size(value:Int):Int
	{
		size = value;

		// The base font size is 32, so divide size by 32
		scale.x = value / 32;
		scale.y = scale.x;

		updateHitbox();

		return size;
	}
}

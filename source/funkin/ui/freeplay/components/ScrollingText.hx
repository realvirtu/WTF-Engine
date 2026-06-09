package funkin.ui.freeplay.components;

import funkin.graphics.FunkinText;

/**
 * An extension of `FunkinText` that scrolls on forever.
 */
class ScrollingText extends FunkinText
{
	public var scrollWidth:Float;
	public var speed:Float;
	public var spacing:Float;

	public var scroll:Float = 0;

	public function new(x:Float = 0, y:Float = 0, text:String = '', speed:Float = 1, spacing:Float = 50)
	{
		super(x, y, text);

		this.speed = speed;
		this.spacing = spacing;

		active = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		scroll += speed * 60 * elapsed;

		if (Math.abs(scroll) > width)
			scroll = 0;
	}

	override public function draw()
	{
		var lastX:Float = x;
		var count:Int = Math.ceil(scrollWidth / width) + 2;

		x -= width + scroll;

		for (i in 0...count)
		{
			super.draw();

			x += width;
		}

		x = lastX;
	}

	@:noCompletion
	override function get_width():Float
	{
		return super.get_width() + spacing * scale.x;
	}
}

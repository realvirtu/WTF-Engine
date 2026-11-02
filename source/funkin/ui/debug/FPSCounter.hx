package funkin.ui.debug;

#if FEATURE_FPS_COUNTER
import flixel.math.FlxMath;
import funkin.util.StringUtil;
import haxe.Timer;
import openfl.display.Shape;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * A simple FPS counter that displays your current FPS, and memory usage.
 * Thank you AnimatingLegend :D
 */
class FPSCounter extends TextField
{
	static final BG_MARGIN:Int = 4;
	static final BG_BORDER:Int = 2;

	public var bg:Shape;

	var fps:Int;
	var times:Array<Float> = [];

	var memory:Float;
	var maxMemory:Float;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = y;

		defaultTextFormat = new TextFormat('_sans', 12, 0xFFFFFFFF, true);

		selectable = false;
		autoSize = LEFT;

		bg = new Shape();
		bg.x = x - BG_MARGIN;
		bg.y = y - BG_MARGIN;
	}

	override function __enterFrame(deltaTime:Float)
	{
		final now:Float = Timer.stamp() * 1000;

		times.push(now);

		while (times[0] < now - 1000)
			times.shift();

		fps = times.length;
		memory = System.totalMemoryNumber;

		if (memory > maxMemory)
			maxMemory = memory;

		updateDisplay();
		redrawBackground();
	}

	function redrawBackground()
	{
		bg.graphics.clear();

		if (!visible)
			return;

		final width:Float = width + BG_MARGIN + 6;
		final height:Float = height + BG_MARGIN + 3;

		bg.graphics.beginFill(0xFFFFFF);
		bg.graphics.drawRect(-BG_BORDER, -BG_BORDER, width + BG_BORDER * 2, height + BG_BORDER * 2);
		bg.graphics.endFill();

		bg.graphics.beginFill(0x202020);
		bg.graphics.drawRect(0, 0, width, height);
		bg.graphics.endFill();
	}

	function updateDisplay()
	{
		text = 'FPS: $fps';
		text += '\nMEM: ${StringUtil.formatBytes(memory)} / ${StringUtil.formatBytes(maxMemory)}';

		textColor = 0xFFFFFFFF;
	}
}
#end

package funkin.input;

import flixel.input.keyboard.FlxKey;
import lime.ui.GamepadButton;
import openfl.Lib;

/**
 * The engine's control action class.
 */
class FunkinAction
{
	var keys:Array<FlxKey> = [];
	var buttons:Array<GamepadButton> = [];

	var pressed:Bool = false;
	var timestamp:Float = -1;

	public function new(keys:Array<FlxKey>, buttons:Array<GamepadButton>)
	{
		this.keys = keys;
		this.buttons = buttons;
	}

	public function press()
	{
		if (pressed)
			return;
		pressed = true;
		timestamp = Lib.getTimer() + 1;
	}

	public function release()
	{
		pressed = false;
	}

	public inline function check():Bool
	{
		return pressed;
	}

	public inline function checkPressed():Bool
	{
		return Lib.getTimer() - timestamp <= FlxG.elapsed;
	}

	public inline function hasKey(key:FlxKey):Bool
	{
		return keys.contains(key);
	}

	public inline function hasButton(button:GamepadButton):Bool
	{
		return buttons.contains(button);
	}
}

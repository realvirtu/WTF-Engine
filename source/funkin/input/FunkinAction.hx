package funkin.input;

import lime.system.System;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;

/**
 * The engine's control action class.
 */
class FunkinAction
{
	public var pressed:Bool = false;
	public var justPressed(get, never):Bool;

	var keys:Array<KeyCode> = [];
	var buttons:Array<GamepadButton> = [];

	var timestamp:Float;

	var lastTime:Float;
	var elapsed:Float;

	public function new(keys:Array<KeyCode>, buttons:Array<GamepadButton>)
	{
		this.keys = keys;
		this.buttons = buttons;

		FlxG.signals.preUpdate.add(update);
	}

	public function update()
	{
		elapsed = System.getTimer() - lastTime;
		lastTime = System.getTimer();
	}

	public function press()
	{
		if (pressed)
			return;
		pressed = true;
		timestamp = System.getTimer();
	}

	public function release()
	{
		pressed = false;
	}

	public inline function hasKey(key:KeyCode):Bool
	{
		return keys.contains(key);
	}

	public inline function hasButton(button:GamepadButton):Bool
	{
		return buttons.contains(button);
	}

	@:noCompletion
	function get_justPressed():Bool
	{
		return System.getTimer() - timestamp <= elapsed;
	}
}

package funkin.input;

import flixel.input.keyboard.FlxKey;
import lime.ui.GamepadButton;

/**
 * The engine's control action class.
 */
class FunkinAction
{
	var keys:Array<FlxKey> = [];
	var buttons:Array<GamepadButton> = [];

	var pressed:Bool = false;

	var timestamp(default, null):Int = -1;

	var spamming:Bool = false;
	var spamTicks:Int = 0;
	var lastTicks:Int = -1;

	public function new(keys:Array<FlxKey>, buttons:Array<GamepadButton>)
	{
		this.keys = keys;
		this.buttons = buttons;
	}

	public function press()
	{
		if (!pressed)
			timestamp = FlxG.game.ticks;
		pressed = true;
	}

	public function release()
		pressed = false;

	public inline function check():Bool
		return pressed;

	public inline function checkPressed():Bool
		return FlxG.game.ticks - timestamp <= FlxG.elapsed * Constants.MS_PER_SEC;

	public inline function checkTurbo():Bool
		return TurboControl.check(this);

	public inline function hasKey(key:FlxKey):Bool
		return keys.contains(key);

	public inline function hasButton(button:GamepadButton):Bool
		return buttons.contains(button);
}

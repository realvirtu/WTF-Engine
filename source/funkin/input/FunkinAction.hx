package funkin.input;

import lime.app.Application;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;

/**
 * The engine's control action class.
 */
class FunkinAction
{
	public final id:Control;

	public var pressed(default, null):Bool;
	public var justPressed(default, null):Bool;
	public var justPressedTurbo(get, never):Bool;

	var wasPressed:Bool;

	var spamTimer:Float = 0;

	var keys:Array<KeyCode> = [];
	var buttons:Array<GamepadButton> = [];

	public function new(id:Control, keys:Array<KeyCode>, buttons:Array<GamepadButton>)
	{
		this.id = id;

		this.keys = keys;
		this.buttons = buttons;

		Application.current.onUpdate.add(update);
	}

	public function press()
	{
		pressed = true;
		justPressed = true;
	}

	public function release()
	{
		pressed = false;
		justPressed = false;

		wasPressed = false;

		spamTimer = 0;
	}

	public function hasKey(key:KeyCode):Bool
	{
		return keys.contains(key);
	}

	public function hasButton(button:GamepadButton):Bool
	{
		return buttons.contains(button);
	}

	function update(elapsed:Float)
	{
		if (!pressed)
			return;

		if (wasPressed)
			justPressed = false;

		wasPressed = true;

		if (spamTimer == 1)
			spamTimer = 0.935;

		spamTimer = Math.min(1, spamTimer + elapsed / Constants.MS_PER_SEC);
	}

	@:noCompletion
	inline function get_justPressedTurbo():Bool
	{
		return justPressed || spamTimer == 1;
	}
}

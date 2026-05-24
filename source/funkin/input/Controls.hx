package funkin.input;

import flixel.FlxG;
import lime.ui.Gamepad;
import openfl.events.KeyboardEvent;

/**
 * The engine's controls class where input is handled.
 */
class Controls
{
	public static var instance:Controls;

	var actions:Map<Control, FunkinAction> = [
		Control.NOTE_LEFT => new FunkinAction([A, LEFT], [DPAD_LEFT, X]),
		Control.NOTE_DOWN => new FunkinAction([S, DOWN], [DPAD_DOWN, A]),
		Control.NOTE_UP => new FunkinAction([W, UP], [DPAD_UP, Y]),
		Control.NOTE_RIGHT => new FunkinAction([D, RIGHT], [DPAD_RIGHT, B]),
		Control.UI_LEFT => new FunkinAction([A, LEFT], [DPAD_LEFT]),
		Control.UI_DOWN => new FunkinAction([S, DOWN], [DPAD_DOWN]),
		Control.UI_UP => new FunkinAction([W, UP], [DPAD_UP]),
		Control.UI_RIGHT => new FunkinAction([D, RIGHT], [DPAD_RIGHT]),
		Control.ACCEPT => new FunkinAction([Z, SPACE, ENTER], [START, A]),
		Control.BACK => new FunkinAction([X, ESCAPE, BACKSPACE], [B]),
		Control.PAUSE => new FunkinAction([P, ENTER, ESCAPE], [START]),
		Control.RESET => new FunkinAction([R], []),
		Control.FAVORITE => new FunkinAction([F], [Y]),
		Control.SORT_LEFT => new FunkinAction([Q], [LEFT_SHOULDER]),
		Control.SORT_RIGHT => new FunkinAction([E], [RIGHT_SHOULDER])
	];

	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_UP(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_UP_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	public var FAVORITE(get, never):Bool;
	public var SORT_LEFT(get, never):Bool;
	public var SORT_RIGHT(get, never):Bool;

	@:noCompletion
	inline function get_NOTE_LEFT():Bool
	{
		return getAction(Control.NOTE_LEFT).check();
	}

	@:noCompletion
	inline function get_NOTE_DOWN():Bool
	{
		return getAction(Control.NOTE_DOWN).check();
	}

	@:noCompletion
	inline function get_NOTE_UP():Bool
	{
		return getAction(Control.NOTE_UP).check();
	}

	@:noCompletion
	inline function get_NOTE_RIGHT():Bool
	{
		return getAction(Control.NOTE_RIGHT).check();
	}

	@:noCompletion
	inline function get_NOTE_LEFT_P():Bool
	{
		return getAction(Control.NOTE_LEFT).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_DOWN_P():Bool
	{
		return getAction(Control.NOTE_DOWN).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_UP_P():Bool
	{
		return getAction(Control.NOTE_UP).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_RIGHT_P():Bool
	{
		return getAction(Control.NOTE_RIGHT).checkPressed();
	}

	@:noCompletion
	inline function get_UI_LEFT():Bool
	{
		return getAction(Control.UI_LEFT).check();
	}

	@:noCompletion
	inline function get_UI_DOWN():Bool
	{
		return getAction(Control.UI_DOWN).check();
	}

	@:noCompletion
	inline function get_UI_UP():Bool
	{
		return getAction(Control.UI_UP).check();
	}

	@:noCompletion
	inline function get_UI_RIGHT():Bool
	{
		return getAction(Control.UI_RIGHT).check();
	}

	@:noCompletion
	inline function get_UI_LEFT_P():Bool
	{
		return getAction(Control.UI_LEFT).checkPressed();
	}

	@:noCompletion
	inline function get_UI_DOWN_P():Bool
	{
		return getAction(Control.UI_DOWN).checkPressed();
	}

	@:noCompletion
	inline function get_UI_UP_P():Bool
	{
		return getAction(Control.UI_UP).checkPressed();
	}

	@:noCompletion
	inline function get_UI_RIGHT_P():Bool
	{
		return getAction(Control.UI_RIGHT).checkPressed();
	}

	@:noCompletion
	inline function get_ACCEPT():Bool
	{
		return getAction(Control.ACCEPT).checkPressed();
	}

	@:noCompletion
	inline function get_BACK():Bool
	{
		return getAction(Control.BACK).checkPressed();
	}

	@:noCompletion
	inline function get_PAUSE():Bool
	{
		return getAction(Control.PAUSE).checkPressed();
	}

	@:noCompletion
	inline function get_RESET():Bool
	{
		return getAction(Control.RESET).checkPressed();
	}

	@:noCompletion
	inline function get_FAVORITE():Bool
	{
		return getAction(Control.FAVORITE).checkPressed();
	}

	@:noCompletion
	inline function get_SORT_LEFT():Bool
	{
		return getAction(Control.SORT_LEFT).checkPressed();
	}

	@:noCompletion
	inline function get_SORT_RIGHT():Bool
	{
		return getAction(Control.SORT_RIGHT).checkPressed();
	}

	var gamepadConnected:Bool = false;

	public function new()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		// Connects any gamepad devices that are already connected
		// This is need so that controllers don't have to be plugged in AFTER the game starts
		// So basically, this makes the game less annoying
		for (device in Gamepad.devices)
			gamepadConnect(device);

		Gamepad.onConnect.add(gamepadConnect);
	}

	inline function getAction(id:Control):FunkinAction
	{
		return actions.get(id);
	}

	function keyDown(event:KeyboardEvent)
	{
		for (action in actions)
		{
			if (action.hasKey(event.keyCode))
				action.press();
		}
	}

	function keyUp(event:KeyboardEvent)
	{
		for (action in actions)
		{
			if (action.hasKey(event.keyCode))
				action.release();
		}
	}

	function gamepadConnect(gamepad:Gamepad)
	{
		// No point of allowing multiple devices
		// Do you even need more than one to play the game??
		if (gamepadConnected)
			return;
		gamepadConnected = true;

		trace('Connected gamepad device.');

		gamepad.onButtonDown.add(button ->
		{
			for (action in actions)
			{
				if (action.hasButton(button))
					action.press();
			}
		});

		gamepad.onButtonUp.add(button ->
		{
			for (action in actions)
			{
				if (action.hasButton(button))
					action.release();
			}
		});

		gamepad.onDisconnect.add(() ->
		{
			trace('Disconnected gamepad device.');

			gamepadConnected = false;
		});
	}
}

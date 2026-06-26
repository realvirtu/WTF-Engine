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
		NoteLeft => new FunkinAction([A, LEFT], [DPAD_LEFT, X]),
		NoteDown => new FunkinAction([S, DOWN], [DPAD_DOWN, A]),
		NoteUp => new FunkinAction([W, UP], [DPAD_UP, Y]),
		NoteRight => new FunkinAction([D, RIGHT], [DPAD_RIGHT, B]),
		UILeft => new FunkinAction([A, LEFT], [DPAD_LEFT]),
		UIDown => new FunkinAction([S, DOWN], [DPAD_DOWN]),
		UIUp => new FunkinAction([W, UP], [DPAD_UP]),
		UIRight => new FunkinAction([D, RIGHT], [DPAD_RIGHT]),
		Accept => new FunkinAction([Z, SPACE, ENTER], [START, A]),
		Back => new FunkinAction([X, ESCAPE, BACKSPACE], [B]),
		Pause => new FunkinAction([P, ENTER, ESCAPE], [START]),
		Reset => new FunkinAction([R], []),
		Favorite => new FunkinAction([F], [Y]),
		SortLeft => new FunkinAction([Q], [LEFT_SHOULDER]),
		SortRight => new FunkinAction([E], [RIGHT_SHOULDER])
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
	public var UI_LEFT_T(get, never):Bool;
	public var UI_DOWN_T(get, never):Bool;
	public var UI_UP_T(get, never):Bool;
	public var UI_RIGHT_T(get, never):Bool;
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
		return getAction(NoteLeft).check();
	}

	@:noCompletion
	inline function get_NOTE_DOWN():Bool
	{
		return getAction(NoteDown).check();
	}

	@:noCompletion
	inline function get_NOTE_UP():Bool
	{
		return getAction(NoteUp).check();
	}

	@:noCompletion
	inline function get_NOTE_RIGHT():Bool
	{
		return getAction(NoteRight).check();
	}

	@:noCompletion
	inline function get_NOTE_LEFT_P():Bool
	{
		return getAction(NoteLeft).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_DOWN_P():Bool
	{
		return getAction(NoteDown).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_UP_P():Bool
	{
		return getAction(NoteUp).checkPressed();
	}

	@:noCompletion
	inline function get_NOTE_RIGHT_P():Bool
	{
		return getAction(NoteRight).checkPressed();
	}

	@:noCompletion
	inline function get_UI_LEFT():Bool
	{
		return getAction(UILeft).check();
	}

	@:noCompletion
	inline function get_UI_DOWN():Bool
	{
		return getAction(UIDown).check();
	}

	@:noCompletion
	inline function get_UI_UP():Bool
	{
		return getAction(UIUp).check();
	}

	@:noCompletion
	inline function get_UI_RIGHT():Bool
	{
		return getAction(UIRight).check();
	}

	@:noCompletion
	inline function get_UI_LEFT_P():Bool
	{
		return getAction(UILeft).checkPressed();
	}

	@:noCompletion
	inline function get_UI_DOWN_P():Bool
	{
		return getAction(UIDown).checkPressed();
	}

	@:noCompletion
	inline function get_UI_UP_P():Bool
	{
		return getAction(UIUp).checkPressed();
	}

	@:noCompletion
	inline function get_UI_RIGHT_P():Bool
	{
		return getAction(UIRight).checkPressed();
	}

	@:noCompletion
	inline function get_UI_LEFT_T():Bool
	{
		return getAction(UILeft).checkTurbo();
	}

	@:noCompletion
	inline function get_UI_DOWN_T():Bool
	{
		return getAction(UIDown).checkTurbo();
	}

	@:noCompletion
	inline function get_UI_UP_T():Bool
	{
		return getAction(UIUp).checkTurbo();
	}

	@:noCompletion
	inline function get_UI_RIGHT_T():Bool
	{
		return getAction(UIRight).checkTurbo();
	}

	@:noCompletion
	inline function get_ACCEPT():Bool
	{
		return getAction(Accept).checkPressed();
	}

	@:noCompletion
	inline function get_BACK():Bool
	{
		return getAction(Back).checkPressed();
	}

	@:noCompletion
	inline function get_PAUSE():Bool
	{
		return getAction(Pause).checkPressed();
	}

	@:noCompletion
	inline function get_RESET():Bool
	{
		return getAction(Reset).checkPressed();
	}

	@:noCompletion
	inline function get_FAVORITE():Bool
	{
		return getAction(Favorite).checkPressed();
	}

	@:noCompletion
	inline function get_SORT_LEFT():Bool
	{
		return getAction(SortLeft).checkPressed();
	}

	@:noCompletion
	inline function get_SORT_RIGHT():Bool
	{
		return getAction(SortRight).checkPressed();
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

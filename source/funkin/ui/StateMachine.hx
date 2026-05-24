package funkin.ui;

/**
 * An enum of the different possible UI states.
 */
enum State
{
	IDLE;
	TRANSITIONING;
	INTERACTING;
}

/**
 * The engine's UI state machine class.
 */
class StateMachine
{
	var currentState(default, null):State = IDLE;
	var previousState(default, null):State = IDLE;

	public function new() {}

	public function transition(state:State):Bool
	{
		// Can't transition if the state isn't IDLE
		if (!canInteract())
			return false;

		previousState = currentState;
		currentState = state;

		// This message is a little annoying
		// Why not make it debug exclusive?
		#if debug
		trace('Transitioned from $previousState to $currentState.');
		#end

		return true;
	}

	public function reset()
	{
		previousState = currentState;
		currentState = IDLE;
	}

	public function is(state:State):Bool
	{
		return currentState == state;
	}

	public function canInteract():Bool
	{
		return currentState == IDLE;
	}

	public function transitioning():Bool
	{
		return currentState == TRANSITIONING;
	}

	public function toString():String
	{
		return Std.string(currentState);
	}
}

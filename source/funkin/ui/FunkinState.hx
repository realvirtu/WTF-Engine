package funkin.ui;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.Transition;
import funkin.input.Controls;
import funkin.modding.event.ScriptEvent;
import funkin.modding.module.ModuleHandler;
import funkin.play.note.NoteDirection;

/**
 * A class used as the base for all the game's states.
 */
class FunkinState extends FlxTransitionableState
{
	var conductor(get, never):Conductor;
	var controls(get, never):Controls;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		conductor.stepHit.add(stepHit);
		conductor.beatHit.add(beatHit);

		controls.directionDown.add(directionDown);
		controls.directionUp.add(directionUp);

		dispatch(StateScriptEvent.get(STATE_CREATE, this));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		dispatch(UpdateScriptEvent.get(elapsed));
	}

	override function transitionIn()
	{
		if (transIn == null || transIn.type == NONE)
			return;

		if (FlxTransitionableState.skipNextTransIn)
		{
			FlxTransitionableState.skipNextTransIn = false;

			if (finishTransIn != null)
				finishTransIn();

			return;
		}

		final state:FlxState = getTopmostState();
		final trans:Transition = createTransition(transIn);

		if (trans != null)
		{
			state.openSubState(trans);

			trans.finishCallback = finishTransIn;

			trans.setStatus(FULL);
			trans.start(OUT);
		}
	}

	override function transitionOut(?onExit:() -> Void)
	{
		_onExit = onExit;

		if (hasTransOut)
		{
			final state:FlxState = getTopmostState();
			final trans:Transition = createTransition(transOut);

			state.openSubState(trans);

			trans.finishCallback = finishTransOut;

			trans.setStatus(EMPTY);
			trans.start(IN);
		}
		else
			_onExit();
	}

	public function dispatch(event:ScriptEvent)
	{
		// Don't run the create, update, or destroy events for modules
		// Modules handle these events on their own
		if (event.type != CREATE && event.type != UPDATE && event.type != DESTROY)
			ModuleHandler.dispatch(event);

		event.put();
	}

	public function getTopmostState():FlxState
	{
		var result:FlxState = this;

		while (true)
		{
			@:privateAccess
			final state:FlxState = result._requestedSubState ?? result.subState;

			if (state == null || state is Transition)
				break;

			result = state;
		}

		return result;
	}

	function stepHit(step:Int)
	{
		dispatch(ConductorScriptEvent.get(STEP_HIT, step, conductor.beat));
	}

	function beatHit(beat:Int)
	{
		dispatch(ConductorScriptEvent.get(BEAT_HIT, conductor.step, beat));
	}

	function directionDown(direction:NoteDirection) {}

	function directionUp(direction:NoteDirection) {}

	override function destroy()
	{
		super.destroy();

		conductor.stepHit.remove(stepHit);
		conductor.beatHit.remove(beatHit);

		controls.directionDown.remove(directionDown);
		controls.directionUp.remove(directionUp);
	}

	@:noCompletion
	inline function get_conductor():Conductor
	{
		return Conductor.instance;
	}

	@:noCompletion
	inline function get_controls():Controls
	{
		return Controls.instance;
	}
}

package funkin.ui;

import flixel.FlxState;
import funkin.input.Controls;
import funkin.modding.event.ScriptEvent;
import funkin.modding.module.ModuleHandler;

/**
 * A class used as the base for all the game's states.
 */
class FunkinState extends FlxState
{
	var conductor(get, never):Conductor;
	var controls(get, never):Controls;

	public function new()
	{
		super();

		// Adds conductor callbacks
		conductor.stepHit.add(stepHit);
		conductor.beatHit.add(beatHit);
	}

	override public function create()
	{
		super.create();

		dispatch(new StateScriptEvent(STATE_CREATE, this));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		dispatch(new UpdateScriptEvent(elapsed));
	}

	public function dispatch(event:ScriptEvent)
	{
		// Don't run the create, update, or destroy events for modules
		// Modules handle these events on their own
		if (event.type == CREATE || event.type == UPDATE || event.type == DESTROY)
			return;

		ModuleHandler.dispatch(event);
	}

	function stepHit(step:Int)
	{
		dispatch(new ConductorScriptEvent(STEP_HIT, step, conductor.beat));
	}

	function beatHit(beat:Int)
	{
		dispatch(new ConductorScriptEvent(BEAT_HIT, conductor.step, beat));
	}

	override public function destroy()
	{
		super.destroy();

		// Removes conductor callbacks
		conductor.stepHit.remove(stepHit);
		conductor.beatHit.remove(beatHit);

		// Clears the asset cache
		// This is pretty good ngl
		FunkinMemory.clearCache();
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

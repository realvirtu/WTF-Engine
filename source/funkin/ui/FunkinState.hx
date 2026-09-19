package funkin.ui;

import flixel.FlxState;
import funkin.assets.FunkinCache;
import funkin.input.Controls;
import funkin.modding.event.ScriptEvent;
import funkin.modding.module.ModuleHandler;
import funkin.play.note.NoteDirection;

/**
 * A class used as the base for all the game's states.
 */
class FunkinState extends FlxState
{
	var conductor(get, never):Conductor;
	var controls(get, never):Controls;

	override function create()
	{
		super.create();

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

	public function dispatch(event:ScriptEvent)
	{
		// Don't run the create, update, or destroy events for modules
		// Modules handle these events on their own
		if (event.type != CREATE && event.type != UPDATE && event.type != DESTROY)
			ModuleHandler.dispatch(event);

		event.put();
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

		// Clears the asset cache
		// This is pretty good ngl
		FunkinCache.clearCache();
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

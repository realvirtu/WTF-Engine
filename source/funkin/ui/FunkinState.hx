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

	var lostFocusVolume:Float;
	var lostFocus:Bool;

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

	override function onFocusLost()
	{
		super.onFocusLost();

		// Lower the volume when focus is lost
		if (Preferences.autoPause)
			return;

		lostFocusVolume = FlxG.sound.volume;
		lostFocus = true;

		FlxG.sound.volume *= 0.25;
	}

	override function onFocus()
	{
		super.onFocus();

		// Restore the volume when the window has focus again
		// It'd suck if the game stayed quiet
		if (Preferences.autoPause || !lostFocus)
			return;

		lostFocus = false;

		FlxG.sound.volume = lostFocusVolume;
	}

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

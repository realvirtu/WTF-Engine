package funkin.ui;

import flixel.FlxCamera;
import flixel.FlxSubState;
import funkin.input.Controls;
import funkin.modding.event.ScriptEvent;

/**
 * A class used as the base for all the game's sub states.
 */
class FunkinSubState extends FlxSubState
{
	var conductor(get, never):Conductor;
	var controls(get, never):Controls;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		camera = new FlxCamera();
		camera.bgColor = 0x0;
		FlxG.cameras.add(camera, false);

		conductor.stepHit.add(stepHit);
		conductor.beatHit.add(beatHit);

		dispatch(SubStateScriptEvent.get(SUBSTATE_OPEN, subState));
	}

	override function close()
	{
		super.close();

		dispatch(SubStateScriptEvent.get(SUBSTATE_CLOSE, this));
	}

	override function destroy()
	{
		if (camera != null && camera != FlxG.camera)
			FlxG.cameras.remove(camera);

		// Removes conductor callbacks
		conductor.stepHit.remove(stepHit);
		conductor.beatHit.remove(beatHit);

		super.destroy();
	}

	public function dispatch(event:ScriptEvent)
	{
		// Script events only work if the parent state is a FunkinState
		// Why wouldn't you use FunkinState anyways?
		if (!(_parentState is FunkinState))
		{
			event.put();
			return;
		}

		var state:FunkinState = cast _parentState;

		state.dispatch(event);
	}

	function stepHit(step:Int) {}

	function beatHit(beat:Int) {}

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

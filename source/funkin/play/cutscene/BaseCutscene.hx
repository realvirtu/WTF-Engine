package funkin.play.cutscene;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import funkin.input.Controls;

/**
 * The base class used for gameplay cutscenes.
 */
class BaseCutscene extends FlxGroup
{
	public final id:String;

	var hideHUD:Bool;
	var callback:() -> Void;

	var controls(get, never):Controls;

	public function new(id:String, hideHUD:Bool = true, ?callback:() -> Void)
	{
		super();

		this.id = id;
		this.hideHUD = hideHUD;
		this.callback = callback;

		camera = new FlxCamera();
		camera.bgColor = 0x0;
		FlxG.cameras.add(camera, false);
	}

	public function start()
	{
		PlayState.instance.camHUD.visible = !hideHUD;

		trace('Started cutscene $id.'.info());
	}

	public function close()
	{
		PlayState.instance.camHUD.visible = true;

		if (callback != null)
			callback();

		// The cutscene's no longer needed, so destroy it
		destroy();

		trace('Ended cutscene $id.'.info());
	}

	override function destroy()
	{
		if (FlxG.cameras.list.contains(camera))
			FlxG.cameras.remove(camera);

		PlayState.instance?.remove(this, true);

		super.destroy();
	}

	@:noCompletion
	inline function get_controls():Controls
	{
		return Controls.instance;
	}
}

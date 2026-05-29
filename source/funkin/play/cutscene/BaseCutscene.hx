package funkin.play.cutscene;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import funkin.input.Controls;

/**
 * The base class used for gameplay cutscenes.
 */
class BaseCutscene extends FlxGroup
{
	public var id:String;

	var hideHUD:Bool;
	var callback:Void->Void;

	var controls(get, never):Controls;

	public function new(id:String, hideHUD:Bool = true, ?callback:Void->Void)
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
		PlayState.instance.songActive = false;
		PlayState.instance.camHUD.visible = !hideHUD;

		trace('Started cutscene $id.');
	}

	public function close()
	{
		PlayState.instance.camHUD.visible = true;

		if (callback != null)
			callback();

		// The cutscene's no longer needed, so destroy it
		destroy();

		trace('Ended cutscene $id.');
	}

	override public function destroy()
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

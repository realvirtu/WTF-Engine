package funkin.util.plugins;

import flixel.FlxBasic;
import funkin.modding.ModHandler;
import funkin.ui.Transition;
import funkin.ui.menu.MainMenuState;
import funkin.util.plugins.StickerPlugin;

/**
 * A plugin that allows the player to hot-reload the engine.
 */
class ReloadPlugin extends FlxBasic
{
	public static var instance:ReloadPlugin;

	public static function init()
	{
		FlxG.plugins.addPlugin(new ReloadPlugin());
	}

	public function new()
	{
		super();

		instance = this;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Hot reloads after pressing F5
		// You can also press F4 to eject into the main menu :D
		if (FlxG.keys.justPressed.F5)
		{
			ModHandler.reload();
			Transition.resetState();
		}
		else if (FlxG.keys.justPressed.F4)
		{
			Transition.switchState(() -> new MainMenuState(), NONE);
			StickerPlugin.instance.clear();
		}
	}
}

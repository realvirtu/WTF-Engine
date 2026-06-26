package funkin.modding.module;

import funkin.modding.ScriptBases.ScriptedModule;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import haxe.ds.StringMap;

/**
 * A class for handling the engine's modules.
 */
class ModuleHandler
{
	static var modules(default, null) = new StringMap<Module>();

	public static function load()
	{
		clear();

		// Loads the modules
		final scripts:Array<String> = ScriptedModule.listScriptClasses();

		for (script in scripts)
		{
			try
			{
				var module:Module = ScriptedModule.scriptInit(script, '');
				modules.set(module.id, module);
			}
			catch (e)
				trace('Failed to load script $script.');
		}

		// Runs onCreate() for all modules
		dispatch(new ScriptEvent(CREATE));

		// Adds a callback for when the game updates
		// This allows modules to update, even when the game isn't paused
		FlxG.signals.postUpdate.add(update);

		trace('Done loading modules.');
	}

	public static inline function getModule(id:String):Module
	{
		return modules.get(id);
	}

	public static function setModuleActive(id:String, active:Bool)
	{
		final module:Module = getModule(id);

		if (module != null)
			module.active = active;
	}

	public static function dispatch(event:ScriptEvent)
	{
		for (module in modules)
		{
			// Skip the module if it's inactive
			if (!module.active)
				continue;

			ScriptEventDispatcher.dispatch(module, event);
		}
	}

	static function update()
	{
		for (module in modules)
		{
			if (!module.active)
				continue;

			// Checks whether the module can actually update
			if (FlxG.state.subState != null && !module.alwaysUpdate)
				continue;

			ScriptEventDispatcher.dispatch(module, new UpdateScriptEvent(FlxG.elapsed));
		}
	}

	static function clear()
	{
		// The dispatch function checks for if a module is active
		// We want to dispatch the onDestroy() event no matter what
		for (module in modules)
		{
			var event:ScriptEvent = new ScriptEvent(DESTROY);
			ScriptEventDispatcher.dispatch(module, event);
		}

		modules.clear();

		// Remove the update callback
		FlxG.signals.postUpdate.remove(update);
	}
}

package funkin.modding.module;

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
		final scripts:Array<String> = Module.listScriptClasses();

		for (script in scripts)
		{
			try
			{
				var module:Module = Module.scriptInit(script, '');
				modules.set(module.id, module);
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}

		create();

		// Adds a callback for when the game updates
		// This allows modules to update, even when the game isn't paused
		FlxG.signals.postUpdate.add(update);

		trace('Done loading modules.'.info());
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

	static function create()
	{
		var event:ScriptEvent = ScriptEvent.get(CREATE);

		for (module in modules)
			ScriptEventDispatcher.dispatch(module, event);

		event.put();
	}

	static function update()
	{
		var event:UpdateScriptEvent = UpdateScriptEvent.get(FlxG.elapsed);

		for (module in modules)
		{
			if (!module.active)
				continue;

			// Checks whether the module can actually update
			if (FlxG.state.subState != null && !module.alwaysUpdate)
				continue;

			ScriptEventDispatcher.dispatch(module, event);
		}

		event.put();
	}

	static function clear()
	{
		var event:ScriptEvent = ScriptEvent.get(DESTROY);

		for (module in modules)
			ScriptEventDispatcher.dispatch(module, event);

		modules.clear();
		event.put();

		// Remove the update callback
		FlxG.signals.postUpdate.remove(update);
	}
}

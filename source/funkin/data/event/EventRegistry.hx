package funkin.data.event;

import funkin.modding.ScriptBases.ScriptedSongEvent;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.song.SongEvent;

/**
 * A registry class for loading song events.
 */
class EventRegistry extends BaseRegistry<SongEvent>
{
	public static var instance:EventRegistry;

	public function new()
	{
		super('events');
	}

	override public function load()
	{
		super.load();

		// Song events are loaded just like how scripted stuff is loaded in registries
		// Song events are literally just code, so yeah
		final scripts:Array<String> = ScriptedSongEvent.listScriptClasses();

		trace('Loading ${scripts.length} scripted song event(s)...');

		for (script in scripts)
		{
			try
			{
				var event:SongEvent = ScriptedSongEvent.scriptInit(script, '');
				entries.set(event.id, event);
			}
			catch (e)
				trace('Failed to load script $script.');
		}
	}

	public function dispatch(event:ScriptEvent)
	{
		for (songEvent in entries)
			ScriptEventDispatcher.dispatch(songEvent, event);
	}

	public function handleEvent(event:String, value:Dynamic)
	{
		if (!exists(event))
			return;
		fetch(event).handle(value);
	}
}

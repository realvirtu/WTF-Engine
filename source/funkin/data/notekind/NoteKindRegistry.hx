package funkin.data.notekind;

import funkin.modding.ScriptBases.ScriptedNoteKind;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.note.NoteKind;

/**
 * A registry class for loading note kinds.
 */
class NoteKindRegistry extends BaseRegistry<NoteKind>
{
	public static var instance:NoteKindRegistry;

	// Doing it like this to make it a tad bit easier for the engine
	// Because it doesn't have to create a new note kind for every single note
	static var defaultKind(default, null) = new NoteKind('');

	public function new()
	{
		super('notekinds');
	}

	override public function load()
	{
		super.load();

		// Loading note kinds just like scripts because it's literally just code
		final scripts:Array<String> = ScriptedNoteKind.listScriptClasses();

		trace('Loading ${scripts.length} scripted notekind(s)...');

		for (script in scripts)
		{
			try
			{
				var kind:NoteKind = ScriptedNoteKind.scriptInit(script, '');
				entries.set(kind.id, kind);
			}
			catch (e)
				trace('Failed to load script $script.');
		}
	}

	public function dispatch(event:ScriptEvent)
	{
		// Handle note script events
		if (Std.isOfType(event, NoteScriptEvent))
		{
			var event:NoteScriptEvent = cast event;

			ScriptEventDispatcher.dispatch(fetch(event.note.kind), event);
		}
		else if (Std.isOfType(event, HoldNoteScriptEvent))
		{
			var event:HoldNoteScriptEvent = cast event;

			ScriptEventDispatcher.dispatch(fetch(event.holdNote.kind), event);
		}
		else
		{
			// Loop through all notekinds if the event isn't a note script event
			// Because those are the only two events that can access a note kind
			for (kind in entries)
				ScriptEventDispatcher.dispatch(kind, event);
		}
	}

	override public function fetch(id:String):NoteKind
	{
		if (!exists(id))
			return defaultKind;
		return super.fetch(id);
	}
}

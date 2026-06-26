package funkin.modding.event;

import flixel.FlxState;
import flixel.FlxSubState;
import funkin.data.event.EventData;
import funkin.data.song.SongData.SongNoteData;
import funkin.play.note.NoteDirection;
import funkin.play.note.NoteSprite;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.play.song.Song;
import funkin.ui.freeplay.capsule.CapsuleSprite;

/**
 * The base class for all the engine's script events.
 */
class ScriptEvent
{
	public var type(default, null):ScriptEventType;
	public var cancelled(default, null):Bool = false;

	public function new(type:ScriptEventType)
	{
		this.type = type;
	}

	public function cancel()
	{
		cancelled = true;
	}
}

/**
 * A script event that runs for every game update.
 */
class UpdateScriptEvent extends ScriptEvent
{
	public var elapsed(default, null):Float;

	public function new(elapsed:Float)
	{
		super(UPDATE);

		this.elapsed = elapsed;
	}
}

/**
 * A script event that runs for states.
 */
class StateScriptEvent extends ScriptEvent
{
	public var state(default, null):FlxState;

	public function new(type:ScriptEventType, state:FlxState)
	{
		super(type);

		this.state = state;
	}
}

/**
 * A script event that runs for substates.
 */
class SubStateScriptEvent extends ScriptEvent
{
	public var state(default, null):FlxSubState;

	public function new(type:ScriptEventType, state:FlxSubState)
	{
		super(type);

		this.state = state;
	}
}

/**
 * A script event that runs for the conductor.
 */
class ConductorScriptEvent extends ScriptEvent
{
	public var step(default, null):Int;
	public var beat(default, null):Int;

	public function new(type:ScriptEventType, step:Int, beat:Int)
	{
		super(type);

		this.step = step;
		this.beat = beat;
	}
}

/**
 * A script event that runs when the song is loaded.
 */
class SongLoadScriptEvent extends ScriptEvent
{
	public var notes:Array<SongNoteData>;
	public var events:Array<EventData>;

	public function new(notes:Array<SongNoteData>, events:Array<EventData>)
	{
		super(SONG_LOAD);

		this.notes = notes;
		this.events = events;
	}
}

/**
 * The base script event that runs for regular notes.
 * 
 * This event is cancelable.
 */
class NoteScriptEvent extends ScriptEvent
{
	public var note(default, null):NoteSprite;

	public var playAnimation:Bool = true;
	public var suffix:String = '';

	public function new(type:ScriptEventType, note:NoteSprite)
	{
		super(type);

		this.note = note;
	}
}

/**
 * The base script event that runs for hold notes.
 * 
 * This event is cancelable.
 */
class HoldNoteScriptEvent extends ScriptEvent
{
	public var holdNote(default, null):HoldNoteSprite;

	public var playAnimation:Bool = true;
	public var suffix:String = '';

	public function new(type:ScriptEventType, holdNote:HoldNoteSprite)
	{
		super(type);

		this.holdNote = holdNote;
	}
}

/**
 * A script event that runs when a song event occurs.
 * 
 * This event is cancelable.
 */
class SongEventScriptEvent extends ScriptEvent
{
	public var kind:String;
	public var value:Dynamic;

	public function new(kind:String, value:Dynamic)
	{
		super(SONG_EVENT);

		this.kind = kind;
		this.value = value;
	}
}

/**
 * A script event that runs when a ghost miss occurs.
 * 
 * This event is cancelable.
 */
class GhostMissScriptEvent extends ScriptEvent
{
	public var direction(default, null):NoteDirection;

	public var playAnimation:Bool = true;
	public var suffix:String = '';

	public function new(direction:NoteDirection)
	{
		super(GHOST_MISS);

		this.direction = direction;
	}
}

/**
 * A script event that runs for the countdown.
 * 
 * This event is cancelable.
 */
class CountdownScriptEvent extends ScriptEvent
{
	public var step(default, null):Int;

	public function new(type:ScriptEventType, step:Int)
	{
		super(type);

		this.step = step;
	}
}

/**
 * A script event that runs for freeplay songs.
 * 
 * This event is cancelable.
 */
class FreeplaySongScriptEvent extends ScriptEvent
{
	public var capsule(default, null):CapsuleSprite;
	public var song:Song;

	public function new(type:ScriptEventType, capsule:CapsuleSprite)
	{
		super(type);

		this.capsule = capsule;
		this.song = capsule.song;
	}
}

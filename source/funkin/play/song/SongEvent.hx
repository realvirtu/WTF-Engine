package funkin.play.song;

import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.play.character.Character;

/**
 * The base class for the engine's song events.
 */
class SongEvent implements IPlayStateScriptedClass
{
	public var id:String;

	var value:Dynamic;

	public function new(id:String)
	{
		this.id = id;
	}

	public function handle(value:Dynamic)
	{
		this.value = value;

		// Override type shit
	}

	function getInt(id:String):Int
	{
		return Std.int(getValue(id));
	}

	function getFloat(id:String):Float
	{
		return getValue(id);
	}

	function getBool(id:String):Bool
	{
		return getValue(id);
	}

	function getString(id:String):String
	{
		return Std.string(getValue(id));
	}

	function getCharacter(id:String):Character
	{
		return switch (getInt(id))
		{
			case 0:
				PlayState.instance.stage.opponent;
			case 1:
				PlayState.instance.stage.player;
			case 2:
				PlayState.instance.stage.gf;
			default:
				null;
		}
	}

	function getValue(id:String):Dynamic
	{
		return Reflect.field(value, id);
	}

	inline function hasValue(id:String):Bool
	{
		return Reflect.hasField(value, id);
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onHoldNoteHold(event:HoldNoteScriptEvent) {}

	public function onHoldNoteDrop(event:HoldNoteScriptEvent) {}

	public function onGhostMiss(event:GhostMissScriptEvent) {}

	public function onStepHit(event:ConductorScriptEvent) {}

	public function onBeatHit(event:ConductorScriptEvent) {}

	public function onSongLoaded(event:SongLoadScriptEvent) {}

	public function onSongStart(event:ScriptEvent) {}

	public function onSongEnd(event:ScriptEvent) {}

	public function onSongRetry(event:ScriptEvent) {}

	public function onSongEvent(event:SongEventScriptEvent) {}

	public function onCountdownStart(event:CountdownScriptEvent) {}

	public function onCountdownStep(event:CountdownScriptEvent) {}

	public function onPause(event:ScriptEvent) {}

	public function onResume(event:ScriptEvent) {}

	public function onGameOverStart(event:ScriptEvent) {}

	public function onGameOverLoop(event:ScriptEvent) {}

	public function onGameOverRetry(event:ScriptEvent) {}

	public function toString():String
	{
		return id;
	}
}

package funkin.modding.module;

import funkin.modding.IScriptedClass;
import funkin.modding.event.ScriptEvent;

/**
 * A class that serves as an advanced script class for mods.
 * Unlike any scripted class, this runs globally.
 */
class Module implements IStateScriptedClass implements IPlayStateScriptedClass implements IFreeplayScriptedClass
{
	public final id:String;

	public var active:Bool = true;

	/**
	 * Disabling this means that only updates when the game isn't paused.
	 * Disable this if you want it to pause with the current state.
	 */
	public var alwaysUpdate:Bool = true;

	public function new(id:String)
	{
		this.id = id;
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onStateCreate(event:StateScriptEvent) {}

	public function onSubStateOpen(event:SubStateScriptEvent) {}

	public function onSubStateClose(event:SubStateScriptEvent) {}

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

	public function onFreeplayEnter(event:ScriptEvent) {}

	public function onFreeplayExit(event:ScriptEvent) {}

	public function onFreeplayIntro(event:ScriptEvent) {}

	public function onFreeplayOutro(event:ScriptEvent) {}

	public function onFreeplayIntroDone(event:ScriptEvent) {}

	public function onFreeplayOutroDone(event:ScriptEvent) {}

	public function onFreeplaySongSelected(event:FreeplaySongScriptEvent) {}

	public function onFreeplaySongFavorited(event:FreeplaySongScriptEvent) {}

	public function toString():String
	{
		return '$id | $active';
	}
}

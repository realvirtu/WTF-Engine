package funkin.modding;

import funkin.modding.event.ScriptEvent;

/**
 * The base interface class for basic scripted classes.
 */
interface IScriptedClass
{
	public function onCreate(event:ScriptEvent):Void;
	public function onUpdate(event:UpdateScriptEvent):Void;
	public function onDestroy(event:ScriptEvent):Void;
	public function onScriptEvent(event:ScriptEvent):Void;
}

/**
 * An interface for scripted classes that follow different states.
 */
interface IStateScriptedClass extends IScriptedClass
{
	public function onStateCreate(event:StateScriptEvent):Void;
	public function onSubStateOpen(event:SubStateScriptEvent):Void;
	public function onSubStateClose(event:SubStateScriptEvent):Void;
}

/**
 * A interface for scripted classes that require note events.
 */
interface INoteScriptedClass extends IScriptedClass
{
	public function onNoteHit(event:NoteScriptEvent):Void;
	public function onNoteMiss(event:NoteScriptEvent):Void;
	public function onHoldNoteHold(event:HoldNoteScriptEvent):Void;
	public function onHoldNoteDrop(event:HoldNoteScriptEvent):Void;
	public function onGhostMiss(event:GhostMissScriptEvent):Void;
}

/**
 * An interface for scripted classes that require conductor events.
 */
interface IConductorScriptedClass extends IScriptedClass
{
	public function onStepHit(event:ConductorScriptEvent):Void;
	public function onBeatHit(event:ConductorScriptEvent):Void;
}

/**
 * An interface for scripted classes that require PlayState events.
 */
interface IPlayStateScriptedClass extends IConductorScriptedClass extends INoteScriptedClass
{
	public function onSongLoaded(event:SongLoadScriptEvent):Void;
	public function onSongStart(event:ScriptEvent):Void;
	public function onSongEnd(event:ScriptEvent):Void;
	public function onSongRetry(event:ScriptEvent):Void;
	public function onSongEvent(event:SongEventScriptEvent):Void;
	public function onCountdownStart(event:CountdownScriptEvent):Void;
	public function onCountdownStep(event:CountdownScriptEvent):Void;
	public function onPause(event:ScriptEvent):Void;
	public function onResume(event:ScriptEvent):Void;
	public function onGameOverStart(event:ScriptEvent):Void;
	public function onGameOverLoop(event:ScriptEvent):Void;
	public function onGameOverRetry(event:ScriptEvent):Void;
}

/**
 * An interface for scripted classes that require FreeplaySubState events.
 */
interface IFreeplayScriptedClass extends IConductorScriptedClass
{
	public function onFreeplayEnter(event:ScriptEvent):Void;
	public function onFreeplayExit(event:ScriptEvent):Void;
	public function onFreeplayIntro(event:ScriptEvent):Void;
	public function onFreeplayOutro(event:ScriptEvent):Void;
	public function onFreeplayIntroDone(event:ScriptEvent):Void;
	public function onFreeplayOutroDone(event:ScriptEvent):Void;
	public function onFreeplaySongSelected(event:FreeplaySongScriptEvent):Void;
	public function onFreeplaySongFavorited(event:FreeplaySongScriptEvent):Void;
}

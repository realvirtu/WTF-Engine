package funkin.modding.event;

import funkin.modding.IScriptedClass;
import funkin.ui.FunkinState;

/**
 * A class for dispatching script events.
 */
class ScriptEventDispatcher
{
	public static function dispatch(target:Null<IScriptedClass>, event:ScriptEvent)
	{
		// Can't dispatch an event when the target's null
		// Especially when the event itself is null
		if (target == null || event == null)
			return;

		//
		// BASIC
		//

		switch (event.type)
		{
			case CREATE:
				target.onCreate(event);
			case UPDATE:
				target.onUpdate(cast event);
			case DESTROY:
				target.onDestroy(event);
			default:
				// Does literally nothing
		}

		//
		// STATE
		//

		if (target is IStateScriptedClass)
		{
			var target:IStateScriptedClass = cast target;

			switch (event.type)
			{
				case STATE_CREATE:
					target.onStateCreate(cast event);
				case SUBSTATE_OPEN:
					target.onSubStateOpen(cast event);
				case SUBSTATE_CLOSE:
					target.onSubStateClose(cast event);
				default:
					// Does literally nothing
			}
		}

		//
		// NOTE
		//

		if (target is INoteScriptedClass)
		{
			var target:INoteScriptedClass = cast target;

			switch (event.type)
			{
				case NOTE_HIT:
					target.onNoteHit(cast event);
				case NOTE_MISS:
					target.onNoteMiss(cast event);
				case NOTE_INCOMING:
					target.onNoteIncoming(cast event);
				case HOLD_NOTE_HOLD:
					target.onHoldNoteHold(cast event);
				case HOLD_NOTE_DROP:
					target.onHoldNoteDrop(cast event);
				case GHOST_MISS:
					target.onGhostMiss(cast event);
				default:
					// Does literally nothing
			}
		}

		//
		// CONDUCTOR
		//

		if (target is IConductorScriptedClass)
		{
			var target:IConductorScriptedClass = cast target;

			switch (event.type)
			{
				case STEP_HIT:
					target.onStepHit(cast event);
				case BEAT_HIT:
					target.onBeatHit(cast event);
				default:
					// Does literally nothing
			}
		}

		//
		// PLAYSTATE
		//

		if (target is IPlayStateScriptedClass)
		{
			var target:IPlayStateScriptedClass = cast target;

			switch (event.type)
			{
				case SONG_LOAD:
					target.onSongLoaded(cast event);
				case SONG_START:
					target.onSongStart(event);
				case SONG_END:
					target.onSongEnd(event);
				case SONG_RETRY:
					target.onSongRetry(event);
				case SONG_EVENT:
					target.onSongEvent(cast event);
				case COUNTDOWN_START:
					target.onCountdownStart(cast event);
				case COUNTDOWN_STEP:
					target.onCountdownStep(cast event);
				case PAUSE:
					target.onPause(event);
				case RESUME:
					target.onResume(event);
				case GAMEOVER_START:
					target.onGameOverStart(event);
				case GAMEOVER_LOOP:
					target.onGameOverLoop(event);
				case GAMEOVER_RETRY:
					target.onGameOverRetry(event);
				default:
					// Does literally nothing
			}
		}

		//
		// DIALOGUE
		//

		if (target is IDialogueScriptedClass)
		{
			var target:IDialogueScriptedClass = cast target;

			switch (event.type)
			{
				case DIALOGUE_START:
					target.onDialogueStart(cast event);
				case DIALOGUE_LINE:
					target.onDialogueLine(cast event);
				case DIALOGUE_COMPLETE_LINE:
					target.onDialogueCompleteLine(cast event);
				case DIALOGUE_END:
					target.onDialogueEnd(cast event);
				default:
					// Does literally nothing
			}
		}

		//
		// FREEPLAY
		//

		if (target is IFreeplayScriptedClass)
		{
			var target:IFreeplayScriptedClass = cast target;

			switch (event.type)
			{
				case FREEPLAY_ENTER:
					target.onFreeplayEnter(event);
				case FREEPLAY_EXIT:
					target.onFreeplayExit(event);
				case FREEPLAY_INTRO:
					target.onFreeplayIntro(event);
				case FREEPLAY_OUTRO:
					target.onFreeplayOutro(event);
				case FREEPLAY_INTRO_DONE:
					target.onFreeplayIntroDone(event);
				case FREEPLAY_OUTRO_DONE:
					target.onFreeplayOutroDone(event);
				case FREEPLAY_SONG_SELECTED:
					target.onFreeplaySongSelected(cast event);
				case FREEPLAY_SONG_FAVORITED:
					target.onFreeplaySongFavorited(cast event);
				default:
					// Does literally nothing
			}
		}

		// Runs the onScriptEvent() script event
		// This isn't actually a real event type
		target.onScriptEvent(event);
	}

	public static function dispatchToState(event:ScriptEvent)
	{
		if (!(FlxG.state is FunkinState))
		{
			// Might be a good idea to put the event to prevent any leaks
			// There's a chance the current state cannot dispatch the event
			event.put();

			return;
		}

		final state:FunkinState = cast FlxG.state;

		state.dispatch(event);
	}
}

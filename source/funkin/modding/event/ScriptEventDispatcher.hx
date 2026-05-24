package funkin.modding.event;

import funkin.modding.IScriptedClass;

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
		// NOTE
		//

		if (Std.isOfType(target, INoteScriptedClass))
		{
			var target:INoteScriptedClass = cast target;

			switch (event.type)
			{
				case NOTE_HIT:
					target.onNoteHit(cast event);
				case NOTE_MISS:
					target.onNoteMiss(cast event);
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

		if (Std.isOfType(target, IConductorScriptedClass))
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

		if (Std.isOfType(target, IPlayStateScriptedClass))
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
		// FREEPLAY
		//

		if (Std.isOfType(target, IFreeplayScriptedClass))
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
}

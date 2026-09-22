package funkin.util;

import funkin.play.note.NoteSprite;

/**
 * An enum abstract of the possible judgements.
 */
enum abstract Judgement(String) to String from String
{
	var SICK = 'sick';
	var GOOD = 'good';
	var BAD = 'bad';
	var SHIT = 'shit';

	public var score(get, never):Int;

	@:noCompletion
	function get_score():Int
	{
		return switch (abstract)
		{
			case SICK: Constants.SICK_SCORE;
			case GOOD: Constants.GOOD_SCORE;
			case BAD: Constants.BAD_SCORE;
			case SHIT: Constants.SHIT_SCORE;
		}
	}
}

/**
 * A utility class for handling rhythm game stuff.
 */
class RhythmUtil
{
	public static function processHitWindow(note:NoteSprite, isPlayer:Bool)
	{
		var songTime:Float = Conductor.instance.time;
		var hitStart:Float = note.time;
		var hitEnd:Float = note.time + Constants.HIT_WINDOW_MS;

		// Give the player some extra time to hit the note
		// Not having this line will create something known as FNF EXTREME DIFFICULTY
		if (isPlayer)
			hitStart -= Constants.HIT_WINDOW_MS;

		note.mayHit = false;
		note.willMiss = false;

		if (songTime >= hitEnd)
			note.willMiss = true;
		if (songTime >= hitStart)
			note.mayHit = true;
	}

	public static function judgeNote(note:NoteSprite):Judgement
	{
		var timing:Float = Math.abs(Std.int(note.time - Conductor.instance.time));
		var judgement:Judgement = SHIT;

		if (timing <= Constants.SICK_WINDOW_MS)
			judgement = SICK;
		else if (timing <= Constants.GOOD_WINDOW_MS)
			judgement = GOOD;
		else if (timing <= Constants.BAD_WINDOW_MS)
			judgement = BAD;

		return judgement;
	}

	public static inline function getDistance(time:Float, speed:Float):Float
	{
		return (time - Conductor.instance.time) * Constants.PIXELS_PER_MS * speed;
	}

	public static inline function getNoteY(strumY:Float, time:Float, speed:Float, downscroll:Bool):Float
	{
		return strumY + getDistance(time, speed) * (downscroll ? -1 : 1);
	}
}

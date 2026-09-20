package funkin;

import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;

/**
 * A structure object used for setting the BPM of a `Conductor`.
 */
typedef ConductorBPM =
{
	var b:Float;
	@:optional
	var n:Int;
	@:optional
	var d:Int;
}

/**
 * The conductor class for the game. This is what handles steps and beats and all that crap.
 */
class Conductor
{
	public static var instance:Conductor;

	public var time:Float;
	public var bpm(default, null):ConductorBPM;

	public var step(default, null):Int;
	public var beat(default, null):Int;
	public var measure(default, null):Int;

	public var stepLength(get, never):Float;
	public var beatLength(get, never):Float;

	/**
	 * TODO: Make this changeable ingame.
	 */
	public var offset:Float = 0;

	public var stepHit(default, null) = new FlxTypedSignal<Int->Void>();
	public var beatHit(default, null) = new FlxTypedSignal<Int->Void>();
	public var measureHit(default, null) = new FlxTypedSignal<Int->Void>();

	var changeStep:Int;
	var changeBeat:Int;
	var changeMeasure:Int;
	var changeTimestamp:Float;

	public function new() {}

	public function update(?time:Float)
	{
		final lastStep:Int = step;
		final lastBeat:Int = beat;
		final lastMeasure:Int = measure;

		this.time = time ??= FunkinSound.music?.time;

		step = changeStep + Math.floor((time - changeTimestamp) / stepLength);
		beat = Math.floor(step / Constants.STEPS_PER_BEAT);
		measure = changeMeasure + Math.floor((beat - changeBeat) / bpm.n);

		if (lastStep != step)
			stepHit.dispatch(step);
		if (lastBeat != beat)
			beatHit.dispatch(beat);
		if (lastMeasure != measure)
			measureHit.dispatch(measure);

		// Debug watching (for debugging purposes)
		FlxG.watch.addQuick('time', time);
		FlxG.watch.addQuick('bpm', bpm);
		FlxG.watch.addQuick('step', step);
		FlxG.watch.addQuick('beat', beat);
		FlxG.watch.addQuick('measure', measure);
	}

	/**
	 * Resets everything, including time, BPM, and steps.
	 * You're going to want to run this whenever music is changed.
	 */
	public function reset(bpm:ConductorBPM)
	{
		time = 0;

		step = 0;
		beat = 0;
		measure = 0;

		setBPM(bpm);
	}

	public function setBPM(bpm:ConductorBPM)
	{
		this.bpm = bpm ??= {b: 0};

		bpm.n ??= Constants.DEFAULT_SIGNATURE_NUM;
		bpm.d ??= Constants.DEFAULT_SIGNATURE_DEN;

		changeStep = step;
		changeBeat = beat;
		changeMeasure = measure;
		changeTimestamp = time;
	}

	@:noCompletion
	inline function get_stepLength():Float
	{
		return Constants.SECS_PER_MIN / bpm.b / bpm.d * Constants.MS_PER_SEC;
	}

	@:noCompletion
	inline function get_beatLength():Float
	{
		return stepLength * Constants.STEPS_PER_BEAT;
	}
}

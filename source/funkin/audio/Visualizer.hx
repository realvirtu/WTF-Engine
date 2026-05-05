package funkin.audio;

import flixel.sound.FlxSound;
import funkin.vis.dsp.SpectralAnalyzer;

class Visualizer
{
	public var sound:FlxSound;
	public var barCount:Int;

	public var analyzer:SpectralAnalyzer;

	var _levels:Array<Bar> = [];

	public function new(sound:FlxSound, barCount:Int)
	{
		this.barCount;

		for (i in 0...barCount)
			_levels.push({value: 0, peak: 0});

		load(sound);
	}

	public function load(sound:FlxSound)
	{
		if (sound == null)
			return;

		this.sound = sound;

		@:privateAccess
		analyzer = new SpectralAnalyzer(sound._channel.__audioSource, barCount, 0.1, 40);
		analyzer.minDb = -65;
		analyzer.maxDb = -25;
		analyzer.maxFreq = 22000;
		analyzer.minFreq = 10;
		analyzer.fftN = 256;
	}

	public function dump()
	{
		sound = null;
		analyzer = null;
	}

	public function getLevels():Array<Bar>
	{
		return _levels = analyzer.getLevels(_levels);
	}
}

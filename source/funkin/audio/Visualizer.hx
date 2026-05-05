package funkin.audio;

import flixel.sound.FlxSound;
import funkin.vis.dsp.SpectralAnalyzer;

class Visualizer
{
	public var sound:FlxSound;
	public var barCount:Int;

	public var analyzer:SpectralAnalyzer;

	public function new(sound:FlxSound, barCount:Int)
	{
		this.barCount;

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
}

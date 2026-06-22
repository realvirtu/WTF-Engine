package;

import flixel.FlxGame;
import flixel.util.typeLimit.NextState.InitialState;
import funkin.InitState;
import funkin.audio.FunkinSoundTray;
#if HAS_FPS_COUNTER
import funkin.FPSCounter;
#end

/**
 * The engine's main class where the game is initialized.
 */
class Main extends FlxGame
{
	#if HAS_FPS_COUNTER
	public static var fpsCounter:FPSCounter;
	#end

	public function new()
	{
		final width:Int = 0;
		final height:Int = 0;
		final state:InitialState = InitState;
		final framerate:Int = 60;
		final skipSplash:Bool = true;
		final startFullscreen:Bool = false;

		// The FPS counter has to be initialized here
		// Because the FPS counter is problematic media
		#if HAS_FPS_COUNTER
		fpsCounter = new FPSCounter(15, 15);
		#end

		super(width, height, state, framerate, framerate, skipSplash, startFullscreen);
	}

	override function create(_)
	{
		_customSoundTray = FunkinSoundTray;

		super.create(_);

		// Adds the FPS counter
		// Only if it's enabled though
		#if HAS_FPS_COUNTER
		addChild(fpsCounter.bg);
		addChild(fpsCounter);
		#end
	}
}

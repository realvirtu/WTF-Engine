package funkin.ui.title;

import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.menu.MainMenuState;
import funkin.util.MathUtil;
import funkin.util.WindowUtil;

/**
 * The engine's title screen state.
 * This is the very first state the player sees.
 */
class TitleState extends FunkinState
{
	static var seenIntro:Bool = false;

	#if HAS_TITLE_SCARE
	final SCARE_TIME:Float = 40;

	// Typing 1987 results in a jumpscare
	// Only if HAS_TITLE_SCARE is defined though
	var scareKeys:Array<FlxKey> = [ONE, NINE, EIGHT, SEVEN];
	var scared:Bool = false;
	var scareTimer:FlxTimer;

	var gfSpooky:FunkinSprite;
	var gfScare:FunkinSprite;
	#end

	var started:Bool = false;
	var logoScale:Float;

	var gf:FunkinSprite;
	var logo:FunkinSprite;
	var startText:FunkinText;

	override public function create()
	{
		super.create();

		conductor.reset(100);

		gf = FunkinSprite.create(0, 0, 'ui/title/gf', 1.5, 268, 290);
		gf.x = FlxG.width - gf.width - 30;
		gf.y = FlxG.height - gf.height - 30;
		gf.visible = false;
		gf.addAnimation('idle', [0, 1, 2], 10, false);
		add(gf);

		logo = FunkinSprite.create(60, 60, 'ui/title/logo', 1.75);
		logo.active = false;
		logo.visible = false;
		add(logo);

		startText = new FunkinText(0, 0, 'press accept to begin');
		startText.size = 30;
		startText.screenCenter(X);
		startText.y = FlxG.height - startText.height - 80;
		startText.visible = false;
		add(startText);

		#if HAS_TITLE_SCARE
		gfSpooky = FunkinSprite.create(0, 0, 'ui/title/gf-spooky');
		gfSpooky.screenCenter();
		gfSpooky.active = false;
		gfSpooky.y += 50;
		add(gfSpooky);

		gfScare = FunkinSprite.create(0, 0, 'ui/title/scare/scare');
		gfScare.screenCenter();
		gfScare.active = false;
		gfScare.visible = false;
		gfScare.y -= 50;
		add(gfScare);
		#end

		logoScale = logo.scale.x;

		#if HAS_TITLE_SCARE
		scareTimer = FlxTimer.wait(SCARE_TIME, jumpscare);

		if (seenIntro)
			skipIntro();
		else
			FunkinSound.playMusic('ui/music/title-loop');
		#else
		skipIntro();
		#end

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresenceMenu();
		#end
	}

	function skipIntro()
	{
		#if HAS_TITLE_SCARE
		if (scared)
			return;
		if (!seenIntro)
			FunkinSound.music?.stop();

		seenIntro = true;

		scareTimer.cancel();
		gfSpooky.destroy();
		#end

		gf.visible = true;
		logo.visible = true;
		startText.visible = true;

		MainMenuState.playMusic();
		FlxG.camera.flash();
	}

	#if HAS_TITLE_SCARE
	function jumpscare()
	{
		if (scared)
			return;
		scared = true;

		gfSpooky.destroy();
		gfScare.visible = true;

		FunkinSound.playOnce('ui/title/scare/scare');
		FunkinSound.music.stop();

		FlxTimer.wait(0.5, WindowUtil.exit);
	}
	#end

	function start()
	{
		if (started)
			return exitToMenu();

		started = true;

		FunkinSound.playOnce('ui/sounds/confirm');
		FlxFlicker.flicker(startText, 1, 0.04, true, true, _ -> exitToMenu());
	}

	function exitToMenu()
	{
		FlxG.switchState(() -> new MainMenuState());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.time = FunkinSound.music.time;
		conductor.update();

		logo.scale.x = MathUtil.lerp(logo.scale.x, logoScale, 0.15);
		logo.scale.y = logo.scale.x;

		#if HAS_TITLE_SCARE
		if (scared)
		{
			gfScare.scale.x += 20 * elapsed;
			gfScare.scale.y = gfScare.scale.x;
		}

		if (scareKeys.length == 0)
			jumpscare();
		else
		{
			if (FlxG.keys.anyJustPressed([scareKeys[0]]))
				scareKeys.shift();
		}
		#end

		if (controls.BACK)
			WindowUtil.exit();

		if (controls.ACCEPT_P)
		{
			#if HAS_TITLE_SCARE
			if (seenIntro)
				start();
			else
				skipIntro();
			#else
			start();
			#end
		}
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		gf.playAnimation('idle', true);

		// Logo bop
		logo.scale.x = logo.scale.y = logoScale + 0.15;
	}

	override public function destroy()
	{
		super.destroy();

		// This is in case the player pressed F4
		#if HAS_TITLE_SCARE
		if (!seenIntro)
		{
			seenIntro = true;
			FunkinSound.music.stop();
		}
		#end
	}
}

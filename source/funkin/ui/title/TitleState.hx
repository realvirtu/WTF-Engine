package funkin.ui.title;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.menu.MainMenuState;
import funkin.util.MathUtil;
import funkin.util.WindowUtil;
#if FEATURE_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

/**
 * The engine's title screen state.
 * This is the very first state the player sees.
 */
class TitleState extends FunkinState
{
	final GRID_SIZE:Int = 64;
	final GRID_COLOR:FlxColor = 0x10FFFFFF;
	final GRID_SPEED:Float = 30;

	var started:Bool = false;
	var logoScale:Float;

	var gf:FunkinSprite;
	var logo:FunkinSprite;
	var startText:FunkinText;

	override function create()
	{
		super.create();

		conductor.reset({b: 100});

		var bg:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 2, GRID_SIZE * 2, true, GRID_COLOR, 0x0));
		bg.velocity.set(GRID_SPEED, GRID_SPEED);
		bg.moves = true;
		add(bg);

		gf = FunkinSprite.create(0, 0, 'ui/title/gf', 1.5, 268, 290);
		gf.x = FlxG.width - gf.width - 30;
		gf.y = FlxG.height - gf.height - 30;
		gf.addAnimation('idle', [0, 1, 2], 10, false);
		add(gf);

		logo = FunkinSprite.create(60, 60, 'ui/title/logo', 1.75);
		logo.active = false;
		add(logo);

		startText = new FunkinText(0, 0, 'press accept to begin');
		startText.size = 30;
		startText.screenCenter(X);
		startText.y = FlxG.height - startText.height - 80;
		add(startText);

		logoScale = logo.scale.x;

		MainMenuState.playMusic();

		#if FEATURE_DISCORD_RPC
		DiscordRPC.updatePresenceMenu();
		#end
	}

	function start()
	{
		if (started)
			return exitToMenu();

		started = true;

		FunkinSound.playOnce('general/sounds/confirm');
		FlxFlicker.flicker(startText, 1, 0.04, true, true, _ -> exitToMenu());
	}

	function exitToMenu()
	{
		Transition.switchState(() -> new MainMenuState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update();

		logo.scale.x = MathUtil.lerp(logo.scale.x, logoScale, 0.15);
		logo.scale.y = logo.scale.x;

		if (controls.BACK)
			WindowUtil.exit();
		if (controls.ACCEPT_P)
			start();
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		gf.playAnimation('idle', true);

		// Logo bop
		logo.scale.x = logo.scale.y = logoScale + 0.15;
	}
}

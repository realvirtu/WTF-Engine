package funkin.ui.options;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

/**
 * The sub state where the player is able to customize their settings and preferences.
 */
class OptionsSubState extends FunkinSubState
{
	static var selected:Int = 0;

	var stateMachine:StateMachine;
	var exitMovers:ExitMovers;

	var bg:FunkinSprite;
	var options:OptionList;

	override public function create()
	{
		super.create();

		stateMachine = new StateMachine();
		exitMovers = new ExitMovers();

		bg = FunkinSprite.create(0, 0, 'ui/menu/bg', 1.5);
		bg.color = 0xFFD400FF;
		bg.active = false;
		add(bg);

		options = new OptionList(selected);
		options.onChanged.add(index -> selected = index);
		add(options);

		var topText:FunkinText = new FunkinText(0, 50, 'options');
		topText.screenCenter(X);
		add(topText);

		exitMovers.add(topText, null, -topText.height);

		loadOptions();
		intro();
	}

	override public function update(elapsed:Float)
	{
		_parentState.persistentDraw = stateMachine.transitioning();

		options.lerp = !stateMachine.transitioning();
		options.busy = !stateMachine.canInteract();

		if (controls.BACK)
			exit();

		super.update(elapsed);
	}

	function loadOptions()
	{
		options.addOption('downscroll');
		options.addOption('ghostTapping', 'ghost tapping');
		options.addOption('showTimer', 'show timer');

		#if HAS_FPS_COUNTER
		options.addOption('showFPS', 'show fps');
		options.addOption('fpsBGOpacity', 'fps background', 10, 0, 100);
		#end
		options.addOption('fpsCap', 'fps cap', 10, 60, 500);

		#if HAS_DISCORD_RPC
		options.addOption('discordRPC', 'discord rpc');
		#end

		options.forEach(option -> exitMovers.add(option, FlxG.width));
	}

	function intro()
	{
		final bgScale:Float = bg.scale.x;

		stateMachine.transition(TRANSITIONING);

		bg.scale.x = bg.scale.y = 0;

		exitMovers.intro();
		exitMovers.onIntroDone = stateMachine.reset;

		FlxTween.tween(bg.scale, {x: bgScale, y: bgScale}, 0.75, {ease: FlxEase.quintOut});
	}

	function exit()
	{
		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(TRANSITIONING);

		exitMovers.outro();
		exitMovers.onOutroDone = close;

		FlxTween.tween(bg.scale, {x: 0, y: 0}, 0.75, {ease: FlxEase.quintOut});
		FunkinSound.playOnce('ui/sounds/cancel');
	}
}

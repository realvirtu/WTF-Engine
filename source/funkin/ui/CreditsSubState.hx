package funkin.ui;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.menu.MainMenuState;
import funkin.util.macro.GitMacro;

/**
 * A `FunkinSubState` that contains the engine's credits.
 */
class CreditsSubState extends FunkinSubState
{
	final LINE_SPACING:Float = 20;
	final SCROLL_SPEED:Float = 50;

	var lineY:Float = 0;

	var exitMovers:ExitMovers;
	var stateMachine:StateMachine;

	var camFollow:FlxObject;

	var bg:FunkinSprite;
	var credits:FlxTypedGroup<FunkinText>;

	override public function create()
	{
		super.create();

		FunkinSound.playMusic('ui/freeplay/music/random', 0);
		FunkinSound.music.fadeIn(0.75);

		exitMovers = new ExitMovers();
		stateMachine = new StateMachine();

		camFollow = new FlxObject();
		camFollow.screenCenter();
		camFollow.active = false;

		camera.follow(camFollow);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.active = false;
		add(bg);

		var logo:FunkinSprite = FunkinSprite.create(0, 100, 'ui/title/logo', 1.25);
		logo.screenCenter(X);
		logo.active = false;
		add(logo);

		credits = new FlxTypedGroup<FunkinText>();
		credits.active = false;
		add(credits);

		lineY = logo.y + logo.height + 30;

		exitMovers.add(logo, FlxG.width);

		buildCredits();
		intro();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		camFollow.y += SCROLL_SPEED * (controls.ACCEPT ? 5 : 1) * elapsed;

		// Exit to the main menu
		if (controls.BACK || camera.viewTop > lineY)
			exit();
	}

	function buildCredits()
	{
		// WTF Engine authors
		// Only me lmao
		addLine('WTF Engine', true);
		addLine('VirtuGuy');

		// GitHub contributors
		addLine('Contributors', true);

		for (contributor in GitMacro.getContributors())
		{
			final total:Int = GitMacro.getContributions();
			final percent:Int = Std.int(contributor.contributions / total * 100);

			addLine('${contributor.name} - $percent%');
		}

		// Special thanks
		// Don't be offended if you aren't on here
		addLine('Special Thanks', true);
		addLine('The Funkin\' Crew Inc.');
		addLine('The Funkin\' Contributors');
		addLine('TechnikTil');
		addLine('AnimatingLegend');
		addLine('MightyTheArmiddilo');
		addLine('CharlesIsCoffer');
		addLine('CrusherNotDrip');
		addLine('ADA Funni');
		addLine('PurSnake');
		addLine('Requazar');
		addLine('Maki');
		addLine('ACrazyTown');
		addLine('Rodney');
		addLine('minimehan');
		addLine('Ahmed7P');
		addLine('Blake');
	}

	function addLine(name:String, section:Bool = false)
	{
		if (section)
			lineY += LINE_SPACING;

		var line:FunkinText = new FunkinText(0, lineY, name);

		line.size = section ? 28 : 20;
		line.alpha = section ? 0.6 : 1;
		line.screenCenter(X);

		lineY += line.height + LINE_SPACING;

		exitMovers.add(line, -line.width);

		credits.add(line);
	}

	function intro()
	{
		stateMachine.transition(TRANSITIONING);

		exitMovers.intro();
		exitMovers.onIntroDone = stateMachine.reset;

		bg.scale.x = bg.scale.y = 0;

		FlxTween.tween(bg.scale, {x: FlxG.width, y: FlxG.height}, 0.75, {ease: FlxEase.quintOut});
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
		FunkinSound.music.stop();
	}

	override public function destroy()
	{
		FunkinSound.music.stop();
		@:privateAccess
		if (FlxG.game._nextState == null)
			MainMenuState.playMusic(true);

		super.destroy();
	}
}

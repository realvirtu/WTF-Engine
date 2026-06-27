package funkin.ui;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.data.credits.CreditsData;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.menu.MainMenuState;
import funkin.util.FileUtil;
import funkin.util.macro.GitMacro;
import json2object.JsonParser;

/**
 * A `FunkinSubState` that contains the engine's credits.
 */
class CreditsSubState extends FunkinSubState
{
	static final LINE_SPACING:Float = 20;
	static final SCROLL_SPEED:Float = 50;

	static var parser(default, null) = new JsonParser<Array<CreditsData>>();

	var lineY:Float = 0;

	var exitMovers:ExitMovers;
	var stateMachine:StateMachine;

	var camFollow:FlxObject;

	var bg:FunkinSprite;
	var credits:FlxTypedGroup<FunkinText>;

	override public function create()
	{
		super.create();

		FunkinSound.playMusic('menu/freeplay/music', 0);
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

		var logo:FunkinSprite = FunkinSprite.create(0, 100, 'menu/title/logo', 1.25);
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

		_parentState.persistentDraw = stateMachine.transitioning();

		camFollow.y += SCROLL_SPEED * (controls.ACCEPT ? 5 : 1) * elapsed;

		// Exit to the main menu
		if (controls.BACK || camera.viewTop > lineY)
			exit();
	}

	function buildCredits()
	{
		final path:String = Paths.json('general/credits');
		final data:Array<CreditsData> = parser.fromJson(FileUtil.getText(path));

		for (section in data)
		{
			if (section == null)
				continue;

			final header:String = section.header;
			final body:Array<CreditsBodyData> = section.body;

			if (!header.isEmpty())
				buildLine(header, '', true);

			switch (header.toLowerCase())
			{
				case 'contributors':
					buildContributors();
				default:
					for (item in body)
						buildLine(item.name, item.role);
			}
		}
	}

	function buildContributors()
	{
		if (GitMacro.getContributors().length > 0)
		{
			for (contributor in GitMacro.getContributors())
			{
				final total:Int = GitMacro.getContributions();
				final percent:Int = Std.int(contributor.contributions / total * 100);

				buildLine('${contributor.name} [$percent%]');
			}
		}
		else
			buildLine('lmao yeah there is none');
	}

	function buildLine(name:String, role:String = '', section:Bool = false)
	{
		if (section)
			lineY += LINE_SPACING;

		var text:String = name;

		if (!role.isEmpty())
			text += ': $role';

		var line:FunkinText = new FunkinText(0, lineY, text);

		line.size = section ? 28 : 20;
		line.alpha = section ? 0.6 : 1;
		line.screenCenter(X);

		lineY += line.height + LINE_SPACING;

		exitMovers.add(line, -line.x - line.width / 2);
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

		FunkinSound.playOnce('general/sounds/cancel');
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

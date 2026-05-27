package funkin.ui;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.menu.MainMenuState;
import funkin.util.macro.GitMacro;

/**
 * A `FunkinState` that contains the engine's credits.
 */
class CreditsState extends FunkinState
{
	final LINE_SPACING:Float = 20;
	final SCROLL_SPEED:Float = 50;

	var lineY:Float = 0;

	var camFollow:FlxObject;
	var credits:FlxTypedGroup<FunkinText>;

	override public function create()
	{
		super.create();

		FunkinSound.playMusic('ui/freeplay/music/random');

		camFollow = new FlxObject();
		camFollow.screenCenter();
		FlxG.camera.follow(camFollow);

		var logo:FunkinSprite = FunkinSprite.create(0, 100, 'ui/title/logo', 1.25);
		logo.screenCenter(X);
		logo.active = false;
		add(logo);

		credits = new FlxTypedGroup<FunkinText>();
		add(credits);

		lineY = logo.y + logo.height + 50;

		buildCredits();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		camFollow.y += SCROLL_SPEED * (controls.ACCEPT ? 5 : 1) * elapsed;

		// Exit to the main menu
		if (controls.BACK || FlxG.camera.viewTop > lineY)
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
			addLine(contributor.name);
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

		credits.add(line);
	}

	function exit()
	{
		FlxG.switchState(() -> new MainMenuState());
	}

	override public function destroy()
	{
		super.destroy();

		FunkinSound.music.stop();
	}
}

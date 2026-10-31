package funkin.ui.charselect;

import flixel.FlxObject;
import funkin.audio.FunkinSound;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.ui.charselect.icon.IconGroup;
import funkin.ui.freeplay.FreeplaySubState;
import funkin.ui.freeplay.player.Player;

/**
 * A menu where the player is able to select a character to play as.
 */
class CharacterSelectState extends FunkinState
{
	public static var instance:CharacterSelectState;

	static final PATH:String = 'ui/character-select';

	static var selected:Int = 4;

	var available(default, null) = new Map<Int, Player>();

	var camFollow:FlxObject;
	var crowd:FunkinSprite;

	var bar:FunkinSprite;
	var icons:IconGroup;
	var cursor:CursorSprite;
	var nameText:FunkinText;

	var player(get, never):Player;

	override function create()
	{
		super.create();

		instance = this;

		FunkinSound.playMusic('$PATH/music');

		conductor.reset({b: 90});

		camFollow = new FlxObject();
		camera.follow(camFollow, null, 0.015);

		loadAvailable();

		//
		// PROPS
		//

		var back:FunkinSprite = FunkinSprite.create(0, -5, '$PATH/props/back', 1.5);
		back.scrollFactor.set(0.06, 0.06);
		back.active = false;
		back.screenCenter(X);
		add(back);

		crowd = FunkinSprite.create(0, 0, '$PATH/props/crowd', 1.5, 594, 129);
		crowd.scrollFactor.set(0.05, 0.05);
		crowd.y = FlxG.height - crowd.height * 2;
		crowd.addAnimation('idle', [0, 1, 2], 10, false);
		crowd.screenCenter(X);
		add(crowd);

		var floor:FunkinSprite = FunkinSprite.create(0, 0, '$PATH/props/floor', 1.5);
		floor.scrollFactor.set(0.04, 0.04);
		floor.active = false;
		floor.y = FlxG.height - floor.height + 5;
		floor.screenCenter(X);
		add(floor);

		var curtain1:FunkinSprite = FunkinSprite.create(-5, -5, '$PATH/props/curtain', 1.5);
		curtain1.scrollFactor.set(0.03, 0.03);
		curtain1.active = false;
		add(curtain1);

		var curtain2:FunkinSprite = curtain1.clone();
		curtain2.flipX = true;
		curtain2.x = FlxG.width - curtain2.width - curtain1.x;
		curtain2.y = curtain1.y;
		add(curtain2);

		var front1:FunkinSprite = FunkinSprite.create(-5, 0, '$PATH/props/front', 1.5);
		front1.scrollFactor.set(0.02, 0.02);
		front1.active = false;
		front1.y = FlxG.height - front1.height + 5;
		add(front1);

		var front2:FunkinSprite = front1.clone();
		front2.flipX = true;
		front2.x = FlxG.width - front2.width - front1.x;
		front2.y = front1.y;
		add(front2);

		//
		// HUD
		//

		bar = FunkinSprite.createSolidColor(0, 20, FlxG.width, 90, 0xFF070C21);
		bar.scrollFactor.set();
		bar.active = false;
		bar.alpha = 0.8;
		add(bar);

		var hud:FunkinSprite = FunkinSprite.create(0, 0, '$PATH/hud', 1.5);
		hud.scrollFactor.copyFrom(floor.scrollFactor);
		hud.active = false;
		hud.screenCenter(X);
		add(hud);

		icons = new IconGroup(available, selected);
		icons.scrollFactor.set(0.03, 0.03);
		icons.x = (FlxG.width - icons.width) / 2;
		icons.y = 135;
		icons.onChanged.add(change);
		add(icons);

		cursor = new CursorSprite();
		cursor.scrollFactor.copyFrom(icons.scrollFactor);
		add(cursor);

		nameText = new FunkinText();
		nameText.scrollFactor.set();
		nameText.alignment = CENTER;
		nameText.size = 40;
		add(nameText);

		// Doing this so that everything can snap into place
		change(selected);

		camera.snapToTarget();

		cursor.snap();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update();

		if (controls.BACK)
			exit();
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		// Make the crowd bop
		// :whatthehappy:
		crowd.playAnimation('idle', true);
	}

	function loadAvailable()
	{
		// Instead of overriding slots, we add to the slot index until it works
		// Of course, we prioritize vanilla characters
		for (id in PlayerRegistry.instance.listSorted())
		{
			final player:Player = PlayerRegistry.instance.fetch(id);

			var position:Int = player.position;

			while (available.exists(position))
				position++;

			available.set(position, player);
		}
	}

	function change(index:Int)
	{
		selected = index;

		camFollow.setPosition(icons.icon.x, icons.icon.y);
		cursor.target = icons.icon;

		nameText.text = player?.name;
		nameText.x = FlxG.width - nameText.width / 2 - 220;
		nameText.y = bar.y + (bar.height - nameText.height) / 2;
	}

	function exit()
	{
		Transition.switchState(() -> FreeplaySubState.build(), NONE);
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	@:noCompletion
	inline function get_player():Player
	{
		return available.get(selected);
	}
}

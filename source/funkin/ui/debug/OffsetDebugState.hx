package funkin.ui.debug;

import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxColor;
import funkin.data.character.CharacterRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.play.character.Character;
import funkin.util.SortUtil;

/**
 * A state for debugging character offsets to ensure that all characters properly align.
 */
class OffsetDebugState extends FunkinState
{
	final GRID_SIZE:Int = 64;
	final GRID_COLOR:FlxColor = 0x10FFFFFF;
	final GRID_SPEED:Float = 30;

	var characters:Array<String>;

	var camHUD:FlxCamera;

	var characterText:FunkinText;
	var offsetText:FunkinText;

	var middleLine:FunkinSprite;
	var floorLine:FunkinSprite;

	var character:Character;
	var onionSkin:Character;

	override function create()
	{
		super.create();

		characters = CharacterRegistry.instance.list();
		characters.sort(SortUtil.alphabetically);

		//
		// HUD
		//

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		characterText = new FunkinText(20, 20);
		characterText.size = 20;
		characterText.camera = camHUD;
		add(characterText);

		offsetText = new FunkinText(20, 0);
		offsetText.size = 24;
		offsetText.y = FlxG.height - offsetText.height - 20;
		offsetText.camera = camHUD;
		add(offsetText);

		//
		// SETUP
		//

		var bg:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 2, GRID_SIZE * 2, true, GRID_COLOR, 0x0));
		bg.velocity.set(GRID_SPEED, GRID_SPEED);
		bg.moves = true;
		add(bg);

		middleLine = FunkinSprite.createSolidColor(0, 0, 2, Std.int(FlxG.height - 150), 0xFF0000FF);
		middleLine.screenCenter(X);
		middleLine.active = false;
		add(middleLine);

		floorLine = FunkinSprite.createSolidColor(0, middleLine.height, FlxG.width, 2, 0xFFFF00FF);
		floorLine.active = false;
		add(floorLine);

		loadCharacter(characters[0]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update();

		//
		// CHARACTER
		//

		final prev:Bool = FlxG.keys.justPressed.Q;
		final next:Bool = FlxG.keys.justPressed.E;

		if (FlxG.keys.justPressed.F)
			character.flipX = !character.flipX;
		if (FlxG.keys.justPressed.O)
			buildOnionSkin();

		if (prev || next)
		{
			var index:Int = characters.indexOf(character.id);

			index += prev ? -1 : 1;

			if (index >= characters.length)
				index = 0;
			else if (index < 0)
				index = characters.length - 1;

			loadCharacter(characters[index]);
		}

		//
		// OFFSETS
		//

		final left:Bool = FlxG.keys.justPressed.A;
		final right:Bool = FlxG.keys.justPressed.D;
		final up:Bool = FlxG.keys.justPressed.W;
		final down:Bool = FlxG.keys.justPressed.S;

		var add:Int = 10;

		add = FlxG.keys.pressed.SHIFT ? 100 : add;
		add = FlxG.keys.pressed.CONTROL ? 1 : add;

		if (left || right)
			character.offset.x -= (left ? -add : add);
		if (up || down)
			character.offset.y -= (up ? -add : add);

		var offsetX:Float = -character.offset.x;
		var offsetY:Float = -character.offset.y;

		offsetX = offsetX == -0 ? 0 : offsetX;
		offsetY = offsetY == -0 ? 0 : offsetY;

		offsetText.text = '($offsetX, $offsetY)';
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		character.bop();
		onionSkin?.bop();
	}

	function loadCharacter(id:String)
	{
		character?.destroy();

		character = CharacterRegistry.instance.fetchCharacter(id);
		character.setPosition(middleLine.x, floorLine.y);
		add(character);

		final id:String = character.id;
		final index:Int = characters.indexOf(id) + 1;
		final count:Int = characters.length;

		characterText.text = '$id ($index/$count)';
	}

	function buildOnionSkin()
	{
		if (onionSkin?.id != character.id)
		{
			onionSkin?.destroy();

			onionSkin = CharacterRegistry.instance.fetchCharacter(character.id);
			onionSkin.setPosition(character.x, character.y);
			onionSkin.alpha = 0.5;
			onionSkin.zIndex = -1;

			add(onionSkin);
			refresh();
		}

		onionSkin.offset.copyFrom(character.offset);
		onionSkin.flipX = character.flipX;
	}
}

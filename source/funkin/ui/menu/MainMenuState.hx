package funkin.ui.menu;

import flixel.FlxObject;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.modding.event.ScriptEvent;
import funkin.ui.debug.OffsetDebugState;
import funkin.ui.freeplay.FreeplaySubState;
import funkin.ui.options.OptionsSubState;
import funkin.ui.story.StoryMenuSubState;
import funkin.ui.title.TitleState;
import funkin.util.plugins.StickerPlugin;
#if HAS_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

/**
 * The engine's main menu state.
 * This is the menu where the player can access the story and freeplay menu.
 */
class MainMenuState extends FunkinState
{
	#if HAS_TRANS_SECRET
	static var transOverlay:TransOverlay;
	#end

	static var selectedItem:Int = 0;

	var stateMachine:StateMachine;

	var camFollow:FlxObject;
	var items:MenuItemGroup;

	override function create()
	{
		super.create();

		playMusic();

		#if HAS_TRANS_SECRET
		// 1/1000 chance of the game becoming trans
		if (FlxG.random.bool(0.1))
			buildTransOverlay();
		#end

		stateMachine = new StateMachine();

		camFollow = new FlxObject();
		camFollow.screenCenter();

		camera.follow(camFollow, LOCKON, 0.06);

		var bg:FunkinSprite = FunkinSprite.create(0, 0, 'ui/menu/bg', 1.5);
		bg.scale.add(0.15, 0.15);
		bg.color = 0xFFFFC82F;
		bg.active = false;
		bg.scrollFactor.set(0, 0.1);
		add(bg);

		var version:FunkinText = new FunkinText(10, 0, '${Constants.TITLE} ${Constants.VERSION}');
		version.size = 15;
		version.y = FlxG.height - version.height - 10;
		version.scrollFactor.set();
		add(version);

		items = new MenuItemGroup(selectedItem);
		items.onChanged.add(change);
		items.addItem('story', openStoryMenu);
		items.addItem('freeplay', openFreeplayMenu);
		items.addItem('options', openOptionsMenu);
		items.addItem('merch', openMerch);
		items.addItem('credits', openCreditsMenu);
		add(items);

		change(selectedItem);

		camera.snapToTarget();

		#if HAS_DISCORD_RPC
		DiscordRPC.updatePresenceMenu();
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		stateMachine.active = !StickerPlugin.instance.active;

		if (controls.BACK)
			exit();
		if (controls.ACCEPT_P)
			confirm();

		// Debugg controls
		// Press 7 to access offset debug
		// Press 8 to test sticker transition
		if (FlxG.keys.justPressed.SEVEN && stateMachine.canInteract())
			FlxG.switchState(() -> new OffsetDebugState());
		if (FlxG.keys.justPressed.EIGHT && stateMachine.canInteract())
			StickerPlugin.instance.switchState(null);

		items.busy = !stateMachine.canInteract();
	}

	function change(selected:Int)
	{
		selectedItem = selected;

		// Positions the camera
		camFollow.y = items.item.y;
	}

	function confirm()
	{
		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(INTERACTING);

		items.flicker();

		FunkinSound.playOnce('general/sounds/confirm');
		FlxTimer.wait(1, stateMachine.reset);
	}

	function openStoryMenu()
	{
		// Quite literally opens the story menu
		openSubState(new StoryMenuSubState());
	}

	function openFreeplayMenu()
	{
		var event:ScriptEvent = ScriptEvent.get(FREEPLAY_ENTER);
		dispatch(event);

		if (event.cancelled)
			return;

		openSubState(new FreeplaySubState());
	}

	function openOptionsMenu()
	{
		openSubState(new OptionsSubState());
	}

	function openMerch()
	{
		// Hell yeah!
		// Support Funkin' today!
		FlxG.openURL('https://needlejuicerecords.com/collections/friday-night-funkin');
	}

	function openCreditsMenu()
	{
		openSubState(new CreditsSubState());
	}

	function exit()
	{
		if (!stateMachine.canInteract())
			return;
		FlxG.switchState(() -> new TitleState());
	}

	#if HAS_TRANS_SECRET
	function buildTransOverlay()
	{
		if (transOverlay != null)
			return;

		transOverlay = new TransOverlay();

		FlxG.addChildBelowMouse(transOverlay, 1);
		FunkinSound.playOnce('ui/menu/trans/cheer');
	}
	#end

	public static function playMusic(fadeIn:Bool = false)
	{
		FunkinSound.playMusic('ui/music', fadeIn ? 0 : 1, true, true, false);
		FunkinSound.music.fadeIn(0.75, FunkinSound.music.volume);
	}
}

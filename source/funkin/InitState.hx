package funkin;

import flixel.FlxObject;
import flixel.FlxState;
import funkin.Conductor;
import funkin.DiscordRPC;
import funkin.data.character.CharacterRegistry;
import funkin.data.event.EventRegistry;
import funkin.data.notekind.NoteKindRegistry;
import funkin.data.song.SongRegistry;
import funkin.data.stage.StageRegistry;
import funkin.data.sticker.StickerRegistry;
import funkin.data.story.LevelRegistry;
import funkin.data.style.StyleRegistry;
import funkin.input.Controls;
import funkin.modding.ModHandler;
import funkin.modding.module.ModuleHandler;
import funkin.save.Save;
import funkin.ui.FunkinScaleMode;
import funkin.ui.title.TitleState;
import funkin.util.plugins.ReloadPlugin;
#if HAS_SCREENSHOTS
import funkin.util.plugins.ScreenshotPlugin;
#end

/**
 * An `FlxState` for initializing the game.
 * This is what sets up all the save and initializing stuff.
 */
class InitState extends FlxState
{
	override public function create()
	{
		super.create();

		// Flixel
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 30;
		FlxG.inputs.resetOnStateSwitch = false;
		FlxG.mouse.visible = false;
		FlxG.scaleMode = new FunkinScaleMode();
		FlxObject.defaultMoves = false;

		@:privateAccess
		FlxG.mouse._visibleWhenFocusLost = false;

		#if HAS_DISCORD_RPC
		DiscordRPC.init();
		#end

		Save.instance = new Save();

		ModHandler.init();

		// Plugins
		ReloadPlugin.init();
		#if HAS_SCREENSHOTS
		ScreenshotPlugin.init();
		#end

		// Instances
		Conductor.instance = new Conductor();
		Controls.instance = new Controls();

		// Registries
		CharacterRegistry.instance = new CharacterRegistry();
		StageRegistry.instance = new StageRegistry();
		SongRegistry.instance = new SongRegistry();
		LevelRegistry.instance = new LevelRegistry();
		EventRegistry.instance = new EventRegistry();
		NoteKindRegistry.instance = new NoteKindRegistry();
		StyleRegistry.instance = new StyleRegistry();
		StickerRegistry.instance = new StickerRegistry();

		ModuleHandler.load();

		// Starts the game
		FlxG.switchState(() -> new TitleState());
	}
}

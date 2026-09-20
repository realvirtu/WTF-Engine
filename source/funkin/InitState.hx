package funkin;

import flixel.FlxObject;
import flixel.FlxState;
import funkin.data.character.CharacterRegistry;
import funkin.data.event.EventRegistry;
import funkin.data.freeplay.album.AlbumRegistry;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.data.note.kind.NoteKindRegistry;
import funkin.data.note.style.NoteStyleRegistry;
import funkin.data.song.SongRegistry;
import funkin.data.stage.StageRegistry;
import funkin.data.sticker.StickerRegistry;
import funkin.data.story.LevelRegistry;
import funkin.input.Controls;
import funkin.modding.ModHandler;
import funkin.modding.module.ModuleHandler;
import funkin.save.Save;
import funkin.ui.title.TitleState;
import funkin.util.plugins.ReloadPlugin;
import funkin.util.plugins.StickerPlugin;
#if HAS_DISCORD_RPC
import funkin.api.DiscordRPC;
#end
#if HAS_SCREENSHOTS
import funkin.util.plugins.ScreenshotPlugin;
#end

/**
 * An `FlxState` for initializing the game.
 * This is what sets up all the save and initializing stuff.
 */
class InitState extends FlxState
{
	#if HAS_FOCUS_LOST_VOLUME
	var lastFocusVolume:Null<Float>;
	#end

	override function create()
	{
		super.create();

		// Flixel
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 30;
		FlxG.inputs.resetOnStateSwitch = false;
		FlxG.mouse.visible = false;
		FlxObject.defaultMoves = false;

		@:privateAccess
		FlxG.mouse._visibleWhenFocusLost = false;

		#if HAS_FOCUS_LOST_VOLUME
		FlxG.signals.focusLost.add(onLoseFocus);
		FlxG.signals.focusGained.add(onGainFocus);
		#end

		#if HAS_DISCORD_RPC
		DiscordRPC.init();
		#end

		Save.instance = new Save();
		Save.instance.load();

		ModHandler.init();

		// Plugins
		StickerPlugin.init();
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
		PlayerRegistry.instance = new PlayerRegistry();
		EventRegistry.instance = new EventRegistry();
		NoteKindRegistry.instance = new NoteKindRegistry();
		NoteStyleRegistry.instance = new NoteStyleRegistry();
		StickerRegistry.instance = new StickerRegistry();
		AlbumRegistry.instance = new AlbumRegistry();

		loadRegistries();

		// Starts the game
		FlxG.switchState(() -> new TitleState());
	}

	#if HAS_FOCUS_LOST_VOLUME
	function onLoseFocus()
	{
		if (Preferences.autoPause)
			return;

		lastFocusVolume = FlxG.sound.volume;

		FlxG.sound.volume *= 0.25;
	}

	function onGainFocus()
	{
		if (Preferences.autoPause || lastFocusVolume == null)
			return;

		FlxG.sound.volume = lastFocusVolume;
	}
	#end

	public static function loadRegistries()
	{
		// Loads registries
		CharacterRegistry.instance.load();
		StageRegistry.instance.load();
		SongRegistry.instance.load();
		LevelRegistry.instance.load();
		PlayerRegistry.instance.load();
		EventRegistry.instance.load();
		NoteKindRegistry.instance.load();
		NoteStyleRegistry.instance.load();
		StickerRegistry.instance.load();
		AlbumRegistry.instance.load();

		// Loads modules
		ModuleHandler.load();
	}
}

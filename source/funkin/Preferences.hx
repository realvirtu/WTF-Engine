package funkin;

import funkin.play.PlayState;
import funkin.save.Save;
import funkin.util.WindowUtil;
#if HAS_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

/**
 * A class containing the player's preferences.
 * 
 * These preferences can be changed ingame through the options menu.
 */
class Preferences
{
	public static var downscroll(get, set):Bool;
	public static var cameraBops(get, set):Bool;
	public static var strumBGOpacity(get, set):Int;
	public static var showTimer(get, set):Bool;

	#if HAS_FPS_COUNTER
	public static var showFPS(get, set):Bool;
	public static var fpsBGOpacity(get, set):Int;
	#end

	public static var fpsCap(get, set):Int;
	public static var vsync(get, set):Bool;
	public static var unlockedFPS(get, set):Bool;
	public static var autoPause(get, set):Bool;

	#if HAS_DISCORD_RPC
	public static var discordRPC(get, set):Bool;
	#end

	@:noCompletion
	static inline function set_downscroll(value:Bool):Bool
	{
		Save.instance.options.set('downscroll', value);
		Save.instance.flush();

		PlayState.instance?.updatePreferences();

		return value;
	}

	@:noCompletion
	static inline function get_downscroll():Bool
	{
		return Save.instance.options.get('downscroll') ?? false;
	}

	@:noCompletion
	static inline function set_cameraBops(value:Bool):Bool
	{
		Save.instance.options.set('cameraBops', value);
		Save.instance.flush();

		return value;
	}

	@:noCompletion
	static inline function get_cameraBops():Bool
	{
		return Save.instance.options.get('cameraBops') ?? true;
	}

	@:noCompletion
	static inline function set_strumBGOpacity(value:Int):Int
	{
		Save.instance.options.set('strumBGOpacity', value);
		Save.instance.flush();

		PlayState.instance?.updatePreferences();

		return value;
	}

	@:noCompletion
	static inline function get_strumBGOpacity():Int
	{
		return Save.instance.options.get('strumBGOpacity') ?? 0;
	}

	@:noCompletion
	static inline function set_showTimer(value:Bool):Bool
	{
		Save.instance.options.set('showTimer', value);
		Save.instance.flush();

		PlayState.instance?.updatePreferences();

		return value;
	}

	@:noCompletion
	static inline function get_showTimer():Bool
	{
		return Save.instance.options.get('showTimer') ?? true;
	}

	#if HAS_FPS_COUNTER
	@:noCompletion
	static inline function set_showFPS(value:Bool):Bool
	{
		Save.instance.options.set('showFPS', value);
		Save.instance.flush();

		Main.fpsCounter.visible = value;

		return value;
	}

	@:noCompletion
	static inline function get_showFPS():Bool
	{
		return Save.instance.options.get('showFPS') ?? true;
	}

	@:noCompletion
	static inline function set_fpsBGOpacity(value:Int):Int
	{
		Save.instance.options.set('fpsBGOpacity', value);
		Save.instance.flush();

		Main.fpsCounter.bg.alpha = value / 100;

		return value;
	}

	@:noCompletion
	static inline function get_fpsBGOpacity():Int
	{
		return Save.instance.options.get('fpsBGOpacity') ?? 50;
	}
	#end

	@:noCompletion
	static inline function set_fpsCap(value:Int):Int
	{
		Save.instance.options.set('fpsCap', value);
		Save.instance.flush();

		FlxG.drawFramerate = FlxG.updateFramerate = unlockedFPS ? 0 : value;

		return value;
	}

	@:noCompletion
	static inline function get_fpsCap():Int
	{
		return Save.instance.options.get('fpsCap') ?? 200;
	}

	@:noCompletion
	static inline function set_vsync(value:Bool):Bool
	{
		Save.instance.options.set('vsync', value);
		Save.instance.flush();

		WindowUtil.setVSync(value);

		return value;
	}

	@:noCompletion
	static inline function get_vsync():Bool
	{
		return Save.instance.options.get('vsync') ?? false;
	}

	@:noCompletion
	static inline function set_unlockedFPS(value:Bool):Bool
	{
		Save.instance.options.set('unlockedFPS', value);
		Save.instance.flush();

		FlxG.drawFramerate = FlxG.updateFramerate = value ? 0 : fpsCap;

		return value;
	}

	@:noCompletion
	static inline function get_unlockedFPS():Bool
	{
		return Save.instance.options.get('unlockedFPS') ?? false;
	}

	@:noCompletion
	static inline function set_autoPause(value:Bool):Bool
	{
		Save.instance.options.set('autoPause', value);
		Save.instance.flush();

		FlxG.autoPause = value;

		return value;
	}

	@:noCompletion
	static inline function get_autoPause():Bool
	{
		return Save.instance.options.get('autoPause') ?? true;
	}

	#if HAS_DISCORD_RPC
	@:noCompletion
	static inline function set_discordRPC(value:Bool):Bool
	{
		Save.instance.options.set('discordRPC', value);
		Save.instance.flush();

		if (value)
			DiscordRPC.start();
		else
			DiscordRPC.shutdown(0);

		return value;
	}

	@:noCompletion
	static inline function get_discordRPC():Bool
	{
		return Save.instance.options.get('discordRPC') ?? true;
	}
	#end

	//
	// DEBUG
	//
	public static var botplay(default, set):Bool = false;

	@:noCompletion
	static inline function set_botplay(value:Bool):Bool
	{
		botplay = value;
		PlayState.instance?.updatePreferences();
		return value;
	}
}

package funkin;

import funkin.play.PlayState;
import funkin.save.Save;

/**
 * A class containing the player's preferences.
 * 
 * These preferences can be changed ingame through the options menu.
 */
class Preferences
{
	public static var downscroll(get, set):Bool;
	public static var ghostTapping(get, set):Bool;
	public static var showTimer(get, set):Bool;

	#if HAS_FPS_COUNTER
	public static var showFPS(get, set):Bool;
	public static var fpsBGOpacity(get, set):Int;
	#end

	public static var fpsCap(get, set):Int;

	#if HAS_DISCORD_RPC
	public static var discordRPC(get, set):Bool;
	#end

	@:noCompletion
	static inline function set_downscroll(value:Bool):Bool
	{
		Save.instance.options.downscroll = value;
		Save.instance.flush();

		PlayState.instance?.updatePreferences();

		return value;
	}

	@:noCompletion
	static inline function get_downscroll():Bool
	{
		return Save.instance.options.downscroll;
	}

	@:noCompletion
	static inline function set_ghostTapping(value:Bool):Bool
	{
		Save.instance.options.ghostTapping = value;
		Save.instance.flush();

		return value;
	}

	@:noCompletion
	static inline function get_ghostTapping():Bool
	{
		return Save.instance.options.ghostTapping;
	}

	@:noCompletion
	static inline function set_showTimer(value:Bool):Bool
	{
		Save.instance.options.showTimer = value;
		Save.instance.flush();

		PlayState.instance?.updatePreferences();

		return value;
	}

	@:noCompletion
	static inline function get_showTimer():Bool
	{
		return Save.instance.options.showTimer;
	}

	#if HAS_FPS_COUNTER
	@:noCompletion
	static inline function set_showFPS(value:Bool):Bool
	{
		Save.instance.options.showFPS = value;
		Save.instance.flush();

		Main.fpsCounter.visible = value;

		return value;
	}

	@:noCompletion
	static inline function get_showFPS():Bool
	{
		return Save.instance.options.showFPS;
	}

	@:noCompletion
	static inline function set_fpsBGOpacity(value:Int):Int
	{
		Save.instance.options.fpsBGOpacity = value;
		Save.instance.flush();

		Main.fpsCounter.bg.alpha = value / 100;

		return value;
	}

	@:noCompletion
	static inline function get_fpsBGOpacity():Int
	{
		return Save.instance.options.fpsBGOpacity;
	}
	#end

	@:noCompletion
	static inline function set_fpsCap(value:Int):Int
	{
		Save.instance.options.fpsCap = value;
		Save.instance.flush();

		FlxG.updateFramerate = value;
		FlxG.drawFramerate = value;

		return value;
	}

	@:noCompletion
	static inline function get_fpsCap():Int
	{
		return Save.instance.options.fpsCap;
	}

	#if HAS_DISCORD_RPC
	@:noCompletion
	static inline function set_discordRPC(value:Bool):Bool
	{
		Save.instance.options.discordRPC = value;
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
		return Save.instance.options.discordRPC;
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

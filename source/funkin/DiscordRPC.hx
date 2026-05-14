package funkin;

#if HAS_DISCORD_RPC
import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordEventHandlers;
import hxdiscord_rpc.Types.DiscordRichPresence;
import hxdiscord_rpc.Types.DiscordUser;
import openfl.Lib;
import sys.thread.Thread;

/**
 * A class for handling the Discord Rich Presence.
 */
class DiscordRPC
{
	static final APP_ID:String = '1494506209036992636';

	static var handlers:DiscordEventHandlers;
	static var presence:DiscordRichPresence;

	static var presenceState:String;

	public static function init()
	{
		handlers = new DiscordEventHandlers();
		handlers.ready = Function.fromStaticFunction(ready);
		handlers.errored = Function.fromStaticFunction(error);
		handlers.disconnected = Function.fromStaticFunction(disconnect);

		// Creates the daemon thread
		// This allows Discord to update and run its stuff
		Thread.create(() ->
		{
			while (true)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				Sys.sleep(2);
			}
		});

		// Shutdown Discord RPC once the game is closed
		// Can't keep it active forever
		Lib.application.onExit.add(shutdown);
	}

	public static function start()
	{
		trace('Initializing Discord RPC...');

		Discord.Initialize(APP_ID, RawPointer.addressOf(handlers), false, null);
	}

	public static function updatePresence(?state:String, details:String = '')
	{
		presence = new DiscordRichPresence();
		presence.type = DiscordActivityType_Playing;

		// 10% chance of replacing the image icon with :whatthefuck:
		if (FlxG.random.bool(10))
			presence.largeImageKey = Paths.random('icon', 1, 2);
		else
			presence.largeImageKey = '';

		presence.state = state ?? presenceState;
		presence.details = details;

		if (state != null)
			presenceState = state;

		Discord.UpdatePresence(RawPointer.addressOf(presence));
	}

	/**
	 * Updates the presence to show main menu status.
	 */
	public static function updatePresenceMenu()
	{
		updatePresence('In the menus...');
	}

	public static function shutdown(code:Int)
	{
		trace('Shutting down Discord RPC...');

		Discord.Shutdown();
	}

	static function ready(request:RawConstPointer<DiscordUser>)
	{
		trace('Done initializing Discord RPC.');
		trace('Haiii!! ${request[0].username}!');

		Discord.UpdatePresence(RawPointer.addressOf(presence));
	}

	static function error(code:Int, message:ConstCharStar)
	{
		trace('Error ($code:$message).');
	}

	static function disconnect(code:Int, message:ConstCharStar)
	{
		trace('Disconnected ($code:$message).');
	}
}
#end

package funkin.modding;

import funkin.data.song.SongRegistry;
import funkin.data.story.LevelRegistry;
import funkin.play.PlayState;
import funkin.play.Playlist;
import funkin.util.WindowUtil;
import polymod.Polymod;
import sys.FileSystem;

/**
 * A class for handling the engine's mod support.
 */
class ModHandler
{
	static final MOD_FOLDER:String = 'mods';
	static final API_VERSION_RULE:String = '>=0.1.0';

	public static function init()
	{
		// Creates the mod folder
		if (!FileSystem.exists(MOD_FOLDER))
			FileSystem.createDirectory(MOD_FOLDER);

		buildImports();
		loadMods();
	}

	public static function reload()
	{
		Polymod.clearCache();
		Polymod.clearScripts();

		loadMods();

		InitState.loadRegistries();

		// Reload the current song and level
		// This is so dumb
		if (PlayState.instance?.song != null)
			PlayState.instance.song = SongRegistry.instance.fetch(PlayState.instance.song.id)?.getVariation(PlayState.instance.song.variation);
		if (Playlist.level != null)
			Playlist.level = LevelRegistry.instance.fetch(Playlist.level.id);
	}

	static function loadMods()
	{
		Polymod.init({
			modRoot: MOD_FOLDER,
			framework: OPENFL,
			errorCallback: onError,
			apiVersionRule: API_VERSION_RULE,
			skipDependencyErrors: true,
			useScriptedClasses: true
		});

		#if HAS_MODDING
		// TODO: Make this only load enabled mods
		// Well uh after a mod menu gets added
		for (meta in Polymod.scan())
			Polymod.loadMod(meta.dirName);
		#end
	}

	static function buildImports()
	{
		// Imports classes
		// Just whatever is used in import.hx
		Polymod.addDefaultImport(Constants);
		Polymod.addDefaultImport(Conductor);
		Polymod.addDefaultImport(Paths);
		Polymod.addDefaultImport(Preferences);
		Polymod.addDefaultImport(FlxG);

		// Blacklists classes
		// Blacklisting is important for security
		// PRs for this is heavily appreciated
		Polymod.blacklistImport('Sys');
		Polymod.blacklistImport('Reflect');
		Polymod.blacklistImport('Type');
		Polymod.blacklistImport('cpp.Lib');
		Polymod.blacklistImport('lime.utils.AssetLibrary');
		Polymod.blacklistImport('lime.system.CFFI');
		Polymod.blacklistImport('lime.system.JNI');
		Polymod.blacklistImport('lime.system.System');
		Polymod.blacklistImport('lime.utils.Assets');
		Polymod.blacklistImport('openfl.utils.Assets');
		Polymod.blacklistImport('openfl.Lib');
		Polymod.blacklistImport('openfl.system.ApplicationDomain');
		Polymod.blacklistImport('openfl.net.SharedObject');
		Polymod.blacklistImport('openfl.desktop.NativeProcess');

		Polymod.blacklistStaticFields(flixel.util.FlxSave, ['resolveFlixelClasses']);

		Polymod.blacklistStaticFields(haxe.Unserializer, ['run']);
		Polymod.blacklistInstanceFields(haxe.Unserializer, ['unserialize']);

		// TODO: Blacklist the entire Polymod package
		// Chances are I probably missed something
		Polymod.blacklistImport('polymod.Polymod');
		Polymod.blacklistImport('polymod.hscript._internal.PolymodScriptClass');
	}

	static function onError(e:PolymodError)
	{
		// Trace the message because why the hell not
		// Only the good errors though
		// No one cares about framework and missing icons
		if (e.code == FRAMEWORK_INIT || e.code == MOD_MISSING_ICON || e.code == MOD_MISSING_ID)
			return;

		switch (e.severity)
		{
			case ERROR:
				trace(e.message.error());
			case WARNING:
				trace(e.message.warn());
			case DEBUG:
				trace(e.message.debug());
			case INFO:
				trace(e.message.info());
		}

		// Only alert the player of errors because no one cares about the other stuff
		// Though the player should be aware of dependency problems as well
		if (e.severity == ERROR || e.code == MOD_DEPENDENCY_UNMET)
			WindowUtil.alert(e.message);
	}
}

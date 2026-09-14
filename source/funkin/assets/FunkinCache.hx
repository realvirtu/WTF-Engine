package funkin.assets;

import cpp.vm.Gc;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFlAssets;

/**
 * A class for handling sound and image cache.
 * 
 * For now, its main purpose is clearing the cache.
 */
class FunkinCache
{
	public static function clearCache()
	{
		clear();

		// Runs garbage collector
		// Pffff I don't know what major means
		Gc.run(true);

		trace('Done clearing cache.'.yellow());
	}

	public static function clearStickers()
	{
		clear('sticker/');

		trace('Done clearing sticker cache.'.yellow());
	}

	static function clear(?prefix:String)
	{
		LimeAssets.cache.clear(prefix);
		OpenFlAssets.cache.clear(prefix);
	}
}

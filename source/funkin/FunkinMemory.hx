package funkin;

import openfl.system.System;
import openfl.utils.Assets;
import polymod.Polymod;

/**
 * A class for handling sound and image cache.
 * 
 * For now, its main purpose is clearing the cache.
 */
class FunkinMemory
{
	public static function clearCache()
	{
		// Clears the polymore cache
		// Yes that's right
		// Clearing the polymore cache
		Polymod.clearCache();

		Assets.cache.clear();

		// Run the garbage collector
		System.gc();

		trace('Done clearing cache.');
	}
}

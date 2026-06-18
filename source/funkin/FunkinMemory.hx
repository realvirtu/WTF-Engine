package funkin;

#if cpp
import cpp.vm.Gc;
#end
#if hl
import hl.Gc;
#end
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFlAssets;
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

		LimeAssets.cache.clear();
		OpenFlAssets.cache.clear();

		// Runs garbage collector
		// Hashlink uses a separate one :serious_car:
		#if cpp
		Gc.compact();
		#end
		#if hl
		Gc.major();
		#end

		trace('Done clearing cache.');
	}
}

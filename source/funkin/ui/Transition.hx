package funkin.ui;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.typeLimit.NextState;
import funkin.assets.FunkinCache;
import funkin.util.plugins.StickerPlugin;

/**
 * The different transition types.
 */
enum TransitionType
{
	NONE;
	FADE;
	STICKER(?id:String);
}

/**
 * A class for transitioning between states.
 */
class Transition
{
	public static function init()
	{
		final tile:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		final tileData:TransitionTileData = {asset: tile, width: 32, height: 32};
		final region:FlxRect = FlxRect.get(0, 0, FlxG.width, FlxG.height);

		tile.persist = true;
		tile.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 0.35, FlxPoint.get(0, -1), tileData, region, NEW);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.35, FlxPoint.get(0, 1), tileData, region, NEW);
	}

	public static function switchState(nextState:NextState, type:TransitionType = FADE)
	{
		if (nextState == null)
			return;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		FlxG.signals.preStateSwitch.addOnce(FunkinCache.clearCache);

		switch (type)
		{
			case FADE:
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;

				FlxG.switchState(nextState);
			case STICKER(id):
				StickerPlugin.instance.start(id, () ->
				{
					FlxG.signals.preStateCreate.addOnce(_ -> StickerPlugin.instance.popup());
					FlxG.switchState(nextState);
				});
			default:
				FlxG.switchState(nextState);
		}
	}

	public static function resetState()
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		FlxG.signals.preStateSwitch.addOnce(FunkinCache.clearCache);
		FlxG.resetState();

		StickerPlugin.instance.clear();
	}
}

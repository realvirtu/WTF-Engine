package funkin.util.plugins;

import flixel.FlxBasic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;
import funkin.assets.FunkinCache;
import funkin.audio.FunkinSound;
import funkin.data.sticker.StickerRegistry;
import funkin.ui.sticker.StickerPack;
import funkin.ui.sticker.StickerSprite;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * A plugin for playing a sticker transition when exiting a song.
 */
@:access(openfl.display.Sprite)
class StickerPlugin extends FlxBasic
{
	public static var instance:StickerPlugin;

	final START_OFFSET:Int = -100;
	final STICKER_TIME:Float = 0.015;

	var sprite:Sprite;

	public static function init()
	{
		FlxG.plugins.addPlugin(new StickerPlugin());
	}

	public function new()
	{
		super();

		instance = this;
		active = false;

		sprite = new Sprite();
		sprite.scrollRect = new Rectangle();

		FlxG.addChildBelowMouse(sprite, 1);
		FlxG.signals.gameResized.add((_, _) -> onResize());

		onResize();
	}

	public function switchState(nextState:NextState, ?id:String)
	{
		start(id, () ->
		{
			if (nextState == null)
				return popup();

			FlxG.switchState(nextState);
			FlxG.signals.preStateCreate.addOnce(_ -> popup(FunkinCache.clearStickers));
		});
	}

	public function clear()
	{
		sprite.removeChildren();
		active = false;
	}

	function start(?id:String, ?callback:() -> Void)
	{
		if (sprite.numChildren > 0)
			return;

		if (!StickerRegistry.instance.exists(id))
			id = Constants.DEFAULT_STICKER_PACK;

		final pack:StickerPack = StickerRegistry.instance.fetch(id);

		// Don't bother generating stickers if there is none
		if (pack.images.length == 0)
		{
			if (callback != null)
				callback();
			return;
		}

		active = true;

		var x:Float = START_OFFSET;
		var y:Float = START_OFFSET;

		while (x < FlxG.width)
		{
			var sticker:StickerSprite = new StickerSprite(pack, pack.pickRandom());

			sticker.x = x;
			sticker.y = y;

			sprite.addChild(sticker);

			x += sticker.width / 2;

			if (x >= FlxG.width && y < FlxG.height)
			{
				x = START_OFFSET;
				y += FlxG.random.int(50, 100);
			}
		}

		// I love random :D
		FlxG.random.shuffle(sprite.__children);

		popup(callback);
	}

	function popup(?callback:() -> Void)
	{
		for (i => sticker in sprite.__children)
		{
			FlxTimer.wait(STICKER_TIME * (i + 1), () ->
			{
				sticker.visible = !sticker.visible;

				if (sticker.visible)
				{
					final x:Float = sticker.x;
					final y:Float = sticker.y;

					FlxTween.tween(sticker, {scaleX: sticker.scaleX}, 0.05, {
						ease: FlxEase.backOut,
						onUpdate: _ ->
						{
							sticker.scaleY = sticker.scaleX;

							// Yes this HAS to be done like this
							// :obese_cat:
							sticker.x = x + (sticker.width / sticker.scaleX - sticker.width) / 2;
							sticker.y = y + (sticker.height / sticker.scaleY - sticker.height) / 2;
						}
					});

					sticker.scaleX = sticker.scaleY *= 1.35;
				}

				if (i == sprite.__children.length - 1)
				{
					FlxTimer.wait(0.05, () ->
					{
						if (!sticker.visible)
							clear();
						if (callback != null)
							callback();
					});
				}

				FunkinSound.playOnce(Paths.random('general/sticker/sounds/sticker', 1, 4));
			});
		}
	}

	function onResize()
	{
		sprite.scaleX = FlxG.scaleMode.scale.x;
		sprite.scaleY = FlxG.scaleMode.scale.y;

		sprite.__scrollRect.width = Math.max(FlxG.width, FlxG.scaleMode.gameSize.x);
		sprite.__scrollRect.height = Math.max(FlxG.height, FlxG.scaleMode.gameSize.y);
	}
}

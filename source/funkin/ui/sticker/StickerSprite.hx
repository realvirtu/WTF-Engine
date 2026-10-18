package funkin.ui.sticker;

import openfl.display.Bitmap;

/**
 * A sprite mainly used for the sticker transition. Well isn't it obvious?
 */
class StickerSprite extends Bitmap
{
	public final pack:StickerPack;
	public final id:String;

	public function new(pack:StickerPack, id:String)
	{
		super(FlxG.assets.getBitmapData(Paths.image('${pack.path}/$id')));

		this.pack = pack;
		this.id = id;

		scaleX = scaleY = Constants.ZOOM * 3.25;
		rotation = FlxG.random.float(-10, 10);

		visible = false;
	}
}

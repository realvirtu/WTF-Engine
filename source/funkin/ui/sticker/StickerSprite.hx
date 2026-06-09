package funkin.ui.sticker;

import funkin.graphics.FunkinSprite;

/**
 * A `FunkinSprite` mainly used to help cover the screen for the `StickerSubState` class.
 */
class StickerSprite extends FunkinSprite
{
	public var pack:StickerPack;
	public var id:String;

	public function new(pack:StickerPack, id:String)
	{
		super();

		this.pack = pack;
		this.id = id;

		loadSprite('${pack.path}/$id', 2.65);

		angle = FlxG.random.float(-10, 10);

		visible = false;
		active = false;
	}
}

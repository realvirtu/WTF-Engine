package funkin.ui.sticker;

import funkin.data.sticker.StickerData;

/**
 * The engine's stickerpack class used for the sticker transition.
 */
class StickerPack
{
	public var id:String;
	public var meta:StickerData;

	public var name(get, never):String;
	public var artist(get, never):String;
	public var images(get, never):Array<String>;

	public var path(get, never):String;

	var _images:Array<String>;

	public function new(id:String)
	{
		this.id = id;
	}

	public function buildSticker(id:String):StickerSprite
	{
		return new StickerSprite(this, id);
	}

	public function pickRandom():String
	{
		return FlxG.random.getObject(images);
	}

	@:noCompletion
	function get_name():String
	{
		var name:String = meta.name;
		if (name.isEmpty())
			name = Constants.DEFAULT_NAME;
		return name;
	}

	@:noCompletion
	function get_artist():String
	{
		var artist:String = meta.artist;
		if (artist.isEmpty())
			artist = Constants.DEFAULT_ARTIST;
		return artist;
	}

	@:noCompletion
	function get_images():Array<String>
	{
		if (_images != null)
			return _images;

		_images = [];

		for (image in meta.images)
		{
			if (!Paths.exists(Paths.image('$path/$image')))
				continue;
			_images.push(image);
		}

		return _images;
	}

	@:noCompletion
	inline function get_path():String
	{
		return 'general/sticker/packs/$id';
	}

	public function toString():String
	{
		return '$id | $name';
	}
}

package funkin.ui.freeplay.album;

import funkin.data.album.AlbumData;

/**
 * The engine's freeplay album class.
 */
class Album
{
	public var id:String;
	public var meta:AlbumData;

	public var name(get, never):String;
	public var artist(get, never):String;
	public var ost(get, never):String;

	public var image(get, never):String;

	var path(get, never):String;

	public function new(id:String)
	{
		this.id = id;
	}

	@:noCompletion
	function get_name():String
	{
		return meta.name;
	}

	@:noCompletion
	function get_artist():String
	{
		return meta.artist;
	}

	@:noCompletion
	function get_ost():String
	{
		return meta.ost;
	}

	@:noCompletion
	function get_image():String
	{
		return '$path/image';
	}

	@:noCompletion
	inline function get_path():String
	{
		return 'menu/freeplay/albums/$id';
	}

	public function toString():String
	{
		return '$id | $name';
	}
}

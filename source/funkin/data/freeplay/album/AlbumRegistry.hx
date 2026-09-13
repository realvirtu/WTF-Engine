package funkin.data.freeplay.album;

import funkin.ui.freeplay.album.Album;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A registry for loading albums used for the freeplay menu.
 */
class AlbumRegistry extends BaseRegistry<Album>
{
	public static var instance:AlbumRegistry;

	var parser(default, null) = new JsonParser<AlbumData>();

	public function new()
	{
		super('albums', 'ui/freeplay/albums');
	}

	override function load()
	{
		super.load();

		//
		// VANILLA
		//

		for (id in FileUtil.listFolders(path))
		{
			final metaPath:String = Paths.json('$path/$id/meta');

			// Skip the album if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			var album:Album = new Album(id);
			album.meta = parser.fromJson(FileUtil.getText(metaPath));

			register(id, album);
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = Album.listScriptClasses();

		trace('Loading ${scripts.length} scripted album(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var album:Album = Album.scriptInit(script, '');
				var ogAlbum:Album = fetch(album.id);

				if (ogAlbum == null)
					continue;

				album.meta = ogAlbum.meta;

				entries.set(album.id, album);
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}
}

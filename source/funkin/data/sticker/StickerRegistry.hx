package funkin.data.sticker;

import funkin.modding.ScriptBases.ScriptedStickerPack;
import funkin.ui.sticker.StickerPack;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A registry class for loading stickerpacks.
 */
class StickerRegistry extends BaseRegistry<StickerPack>
{
	public static var instance:StickerRegistry;

	var parser(default, null) = new JsonParser<StickerData>();

	public function new()
	{
		super('stickers', 'general/sticker/packs');
	}

	override public function load()
	{
		super.load();

		//
		// VANILLA
		//

		for (id in FileUtil.listFolders(path))
		{
			final metaPath:String = Paths.json('$path/$id/meta');

			// Skip the stickerpack if it doesn't exist
			if (!Paths.exists(metaPath))
				continue;

			var pack:StickerPack = new StickerPack(id);
			pack.meta = parser.fromJson(FileUtil.getText(metaPath));

			register(id, pack);
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = ScriptedStickerPack.listScriptClasses();

		trace('Loading ${scripts.length} scripted stickerpack(s)...');

		for (script in scripts)
		{
			try
			{
				var pack:StickerPack = ScriptedStickerPack.scriptInit(script, '');
				var ogPack:StickerPack = fetch(pack.id);

				pack.meta = ogPack.meta;

				entries.set(pack.id, pack);
			}
			catch (e)
				trace('Failed to load script $script.');
		}
	}
}

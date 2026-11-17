package funkin.util;

/**
 * A utility class for file handling.
 */
class FileUtil
{
	static var assets:Array<String>;

	public static function getText(id:String):String
	{
		return try
		{
			FlxG.assets.getText(id);
		}
		catch (e)
			'';
	}

	public static function listFolders(id:String):Array<String>
	{
		id = Paths.path(id);

		assets ??= FlxG.assets.list();

		var list:Array<String> = [];
		var items:Array<String> = assets.filter(item -> return item.startsWith(id));

		for (item in items)
		{
			item = item.substr(0, item.lastIndexOf('/'));
			item = item.substr(item.lastIndexOf('/') + 1);

			if (list.contains(item))
				continue;

			list.push(item);
		}

		return list;
	}
}

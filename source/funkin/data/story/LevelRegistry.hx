package funkin.data.story;

import funkin.ui.story.Level;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A registry class for loading levels.
 */
class LevelRegistry extends BaseRegistry<Level>
{
	public static var instance:LevelRegistry;

	var parser(default, null) = new JsonParser<LevelData>();

	public function new()
	{
		super('levels', 'ui/story/levels');
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

			// Skip the level if it doesn't have a metadata file
			if (!Paths.exists(metaPath))
				continue;

			var level:Level = new Level(id);

			level.meta = parser.fromJson(FileUtil.getText(metaPath));

			register(id, level);
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = Level.listScriptClasses();

		trace('Loading ${scripts.length} scripted level(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var level:Level = Level.scriptInit(script, '');
				var ogLevel:Level = fetch(level.id);

				if (ogLevel == null)
					continue;

				level.meta = ogLevel.meta;

				entries.set(level.id, level);
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	override function listDefaults():Array<String>
	{
		return [
			'tutorial',
			'week1',
			'week2',
			'week3',
			'week4',
			'week5',
			'week6',
			'week7',
			'weekend1'
		];
	}
}

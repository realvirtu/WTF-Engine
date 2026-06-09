package funkin.data.style;

import funkin.modding.ScriptBases.ScriptedStyle;
import funkin.play.Style;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A registry class for loading styles.
 */
class StyleRegistry extends BaseRegistry<Style>
{
	public static var instance:StyleRegistry;

	var parser(default, null) = new JsonParser<StyleData>();

	public function new()
	{
		super('styles', 'gameplay/styles');
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

			// Skip the style if it doesn't exist
			if (!Paths.exists(metaPath))
				continue;

			var style:Style = new Style(id);
			style.meta = parser.fromJson(FileUtil.getText(metaPath));

			register(id, style);
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = ScriptedStyle.listScriptClasses();

		trace('Loading ${scripts.length} scripted style(s)...');

		for (script in scripts)
		{
			try
			{
				var style:Style = ScriptedStyle.scriptInit(script, '');
				var ogStyle:Style = fetch(style.id);

				style.meta = ogStyle.meta;

				entries.set(style.id, style);
			}
			catch (e)
				trace('Failed to load script $script.');
		}
	}
}

package funkin.data.note.style;

import funkin.play.note.NoteStyle;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A registry class for loading note styles.
 */
class NoteStyleRegistry extends BaseRegistry<NoteStyle>
{
	public static var instance:NoteStyleRegistry;

	var parser(default, null) = new JsonParser<NoteStyleData>();

	public function new()
	{
		super('notestyles', 'gameplay/notestyles');
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

			// Skip the style if it doesn't exist
			if (!Paths.exists(metaPath))
				continue;

			var style:NoteStyle = new NoteStyle(id);
			style.meta = parser.fromJson(FileUtil.getText(metaPath));

			register(id, style);
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = NoteStyle.listScriptClasses();

		trace('Loading ${scripts.length} scripted style(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var style:NoteStyle = NoteStyle.scriptInit(script, '');
				var ogStyle:NoteStyle = fetch(style.id);

				if (ogStyle == null)
					continue;

				style.meta = ogStyle.meta;

				entries.set(style.id, style);
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}
}

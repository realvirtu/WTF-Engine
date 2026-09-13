package funkin.data.stage;

import funkin.play.stage.Stage;
import funkin.util.FileUtil;
import haxe.ds.StringMap;
import json2object.JsonParser;

/**
 * A registry class for loading stages.
 */
class StageRegistry extends BaseRegistry<StageData>
{
	public static var instance:StageRegistry;

	var parser(default, null) = new JsonParser<StageData>();
	var scripted(default, null) = new StringMap<String>();

	public function new()
	{
		super('stages', 'gameplay/stages');
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

			// Skip the stage if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			register(id, parser.fromJson(FileUtil.getText(metaPath)));
		}

		//
		// SCRIPTED
		//

		scripted.clear();

		final scripts:Array<String> = Stage.listScriptClasses();

		trace('Loading ${scripts.length} scripted stage(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var stage:Stage = Stage.scriptInit(script, '');

				scripted.set(stage.id, script);
				stage.destroy();
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function fetchStage(id:String):Stage
	{
		var stage:Stage = null;

		if (scripted.exists(id))
			stage = Stage.scriptInit(scripted.get(id), id);
		else
			stage = new Stage(id);

		stage.meta = fetch(id);
		stage.buildProps();

		return stage;
	}
}

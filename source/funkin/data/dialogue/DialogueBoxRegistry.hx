package funkin.data.dialogue;

import funkin.play.dialogue.DialogueBox;
import funkin.util.FileUtil;
import haxe.ds.StringMap;
import json2object.JsonParser;

/**
 * A registry class for loading dialogue boxes.
 */
class DialogueBoxRegistry extends BaseRegistry<DialogueBoxData>
{
	public static var instance:DialogueBoxRegistry;

	var parser(default, null) = new JsonParser<DialogueBoxData>();
	var scripted(default, null) = new StringMap<String>();

	public function new()
	{
		super('dialogue-box', 'gameplay/dialogue/boxes');
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

			// Skip the dialogue box if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			register(id, parser.fromJson(FileUtil.getText(metaPath)));
		}

		//
		// SCRIPTED
		//

		scripted.clear();

		final scripts:Array<String> = DialogueBox.listScriptClasses();

		trace('Loading ${scripts.length} scripted dialogue box(es)...'.info());

		for (script in scripts)
		{
			try
			{
				var box:DialogueBox = DialogueBox.scriptInit(script, '');

				scripted.set(box.id, script);
				box.destroy();
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function fetchDialogueBox(id:String):DialogueBox
	{
		var box:DialogueBox = null;

		if (scripted.exists(id))
			box = DialogueBox.scriptInit(scripted.get(id), id);
		else
			box = new DialogueBox(id);

		box.meta = fetch(id);
		box.buildSprite();

		return box;
	}
}

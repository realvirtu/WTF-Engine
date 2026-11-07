package funkin.data.dialogue;

import funkin.play.dialogue.DialogueSpeaker;
import funkin.util.FileUtil;
import haxe.ds.StringMap;
import json2object.JsonParser;

/**
 * A registry class for loading dialogue speakers.
 */
class SpeakerRegistry extends BaseRegistry<SpeakerData>
{
	public static var instance:SpeakerRegistry;

	var parser(default, null) = new JsonParser<SpeakerData>();
	var scripted(default, null) = new StringMap<String>();

	public function new()
	{
		super('speaker', 'gameplay/dialogue/speakers');
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

			// Skip the dialogue speaker if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			register(id, parser.fromJson(FileUtil.getText(metaPath)));
		}

		//
		// SCRIPTED
		//

		scripted.clear();

		final scripts:Array<String> = DialogueSpeaker.listScriptClasses();

		trace('Loading ${scripts.length} scripted dialogue speaker(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var speaker:DialogueSpeaker = DialogueSpeaker.scriptInit(script, '');

				scripted.set(speaker.id, script);
				speaker.destroy();
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function fetchSpeaker(id:String):DialogueSpeaker
	{
		if (!exists(id))
			return null;

		var speaker:DialogueSpeaker = null;

		if (scripted.exists(id))
			speaker = DialogueSpeaker.scriptInit(scripted.get(id), id);
		else
			speaker = new DialogueSpeaker(id);

		speaker.meta = fetch(id);
		speaker.buildSprite();

		return speaker;
	}
}

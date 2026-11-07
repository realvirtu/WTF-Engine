package funkin.data.dialogue;

import funkin.play.dialogue.Conversation;
import funkin.util.FileUtil;
import haxe.ds.StringMap;
import json2object.JsonParser;

/**
 * A registry class for loading dialogue conversations.
 */
class ConversationRegistry extends BaseRegistry<ConversationData>
{
	public static var instance:ConversationRegistry;

	var parser(default, null) = new JsonParser<ConversationData>();
	var scripted(default, null) = new StringMap<String>();

	public function new()
	{
		super('conversations', 'gameplay/dialogue/conversations');
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

			// Skip the conversation if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			register(id, parser.fromJson(FileUtil.getText(metaPath)));
		}

		//
		// SCRIPTED
		//

		scripted.clear();

		final scripts:Array<String> = Conversation.listScriptClasses();

		trace('Loading ${scripts.length} scripted conversation(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var conversation:Conversation = Conversation.scriptInit(script, '');

				scripted.set(conversation.id, script);
				conversation.destroy();
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function fetchConversation(id:String):Conversation
	{
		if (!exists(id))
			return null;

		var conversation:Conversation = null;

		if (scripted.exists(id))
			conversation = Conversation.scriptInit(scripted.get(id), id);
		else
			conversation = new Conversation(id);

		conversation.meta = fetch(id);

		return conversation;
	}
}

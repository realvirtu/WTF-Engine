package funkin.data.character;

import funkin.play.character.Character;
import funkin.play.character.CharacterType;
import funkin.util.FileUtil;
import haxe.ds.StringMap;
import json2object.JsonParser;

/**
 * A registry class for loading characters.
 */
class CharacterRegistry extends BaseRegistry<CharacterData>
{
	public static var instance:CharacterRegistry;

	var parser(default, null) = new JsonParser<CharacterData>();
	var scripted(default, null) = new StringMap<String>();

	public function new()
	{
		super('characters', 'gameplay/characters');
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

			// Skip the character if it doesn't have metadata
			if (!Paths.exists(metaPath))
				continue;

			register(id, parser.fromJson(FileUtil.getText(metaPath)));
		}

		//
		// SCRIPTED
		//

		scripted.clear();

		final scripts:Array<String> = Character.listScriptClasses();

		trace('Loading ${scripts.length} scripted character(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var character:Character = Character.scriptInit(script, '');

				scripted.set(character.id, script);
				character.destroy();
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function fetchCharacter(id:String, type:CharacterType = OTHER):Character
	{
		if (!exists(id))
			return null;

		var character:Character = null;

		if (scripted.exists(id))
			character = Character.scriptInit(scripted.get(id), id);
		else
			character = new Character(id);

		character.meta = fetch(id);
		character.type = type;
		character.buildSprite();

		return character;
	}
}

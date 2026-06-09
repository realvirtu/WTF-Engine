package funkin.play.cutscene.dialogue;

import flixel.math.FlxPoint;
import funkin.data.dialogue.DialogueBoxData;
import funkin.graphics.FunkinSprite;
import funkin.util.FileUtil;
import funkin.util.MathUtil;
import json2object.JsonParser;

/**
 * The box sprite used for the `DialogueCutscene` class.
 */
class DialogueBox extends FunkinSprite
{
	static var parser(default, null) = new JsonParser<DialogueBoxData>();

	public var meta:DialogueBoxData;

	public function new(id:String)
	{
		super();

		final path:String = 'gameplay/dialogue/boxes/$id';
		final metaPath:String = Paths.json('$path/meta');

		// Can't load the metadata if it doesn't exist
		if (!Paths.exists(metaPath))
			return;

		meta = parser.fromJson(FileUtil.getText(metaPath));

		loadSprite('$path/image', meta.scale);
		centerOffsets();

		final off:FlxPoint = MathUtil.arrayToPoint(meta.offset);

		offset.add(off);
		off.put();
	}
}

package funkin.play.cutscene.dialogue;

import flixel.math.FlxPoint;
import funkin.data.dialogue.DialogueSpeakerData;
import funkin.graphics.FunkinSprite;
import funkin.util.FileUtil;
import funkin.util.MathUtil;
import json2object.JsonParser;

/**
 * A `FunkinSprite` used as the speaker for the `DialogueCutscene` class.
 */
class DialogueSpeaker extends FunkinSprite
{
	static var parser(default, null) = new JsonParser<DialogueSpeakerData>();

	public var meta:DialogueSpeakerData;

	public function new()
	{
		super();

		active = false;
	}

	public function load(id:String)
	{
		final path:String = 'play/dialogue/speakers/$id';
		final metaPath:String = Paths.json('$path/meta');

		// Hide the speaker if it doesn't exist
		// This would be good for narration
		if (!Paths.exists(metaPath))
		{
			visible = false;
			return;
		}

		meta = parser.fromJson(FileUtil.getText(metaPath));
		visible = true;

		loadSprite('$path/image', meta.scale);
		centerOffsets();

		final off:FlxPoint = MathUtil.arrayToPoint(meta.offset);

		offset.add(off);
		off.put();
	}
}

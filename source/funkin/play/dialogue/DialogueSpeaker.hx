package funkin.play.dialogue;

import funkin.data.dialogue.SpeakerData;
import funkin.data.dialogue.SpeakerRegistry;
import funkin.graphics.FunkinSprite;

/**
 * Dialogue speaker sprite used for conversations.
 */
class DialogueSpeaker extends FunkinSprite
{
	public final id:String;

	public var meta:SpeakerData;

	var speakerPath(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		loadSprite('$speakerPath/image', meta.scale);

		offset.subtract(meta.offset[0], meta.offset[1]);
	}

	@:noCompletion
	inline function get_speakerPath():String
	{
		return '${SpeakerRegistry.instance.path}/$id';
	}
}

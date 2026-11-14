package funkin.play.dialogue;

import funkin.data.dialogue.SpeakerData;
import funkin.data.dialogue.SpeakerRegistry;
import funkin.graphics.FunkinSprite;
import funkin.modding.IScriptedClass.IDialogueScriptedClass;
import funkin.modding.event.ScriptEvent;

/**
 * Dialogue speaker sprite used for conversations.
 */
class Speaker extends FunkinSprite implements IDialogueScriptedClass
{
	public final id:String;

	public var meta:SpeakerData;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		loadSprite(getPath('image'), meta.scale);

		active = false;

		offset.subtract(meta.offset[0], meta.offset[1]);
	}

	public function getPath(id:String):String
	{
		return '${SpeakerRegistry.instance.path}/${this.id}/$id';
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onDialogueStart(event:DialogueScriptEvent) {}

	public function onDialogueLine(event:DialogueScriptEvent) {}

	public function onDialogueCompleteLine(event:DialogueScriptEvent) {}

	public function onDialogueEnd(event:DialogueScriptEvent) {}

	override function toString():String
	{
		return id;
	}
}

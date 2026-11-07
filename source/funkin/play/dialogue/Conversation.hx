package funkin.play.dialogue;

import flixel.group.FlxGroup;
import funkin.audio.FunkinSound;
import funkin.data.dialogue.ConversationData;
import funkin.data.dialogue.DialogueBoxRegistry;

/**
 * A class for playing dialogue between characters.
 */
class Conversation extends FlxGroup
{
	public final id:String;

	public var meta:ConversationData;

	public var music:FunkinSound;
	public var box:DialogueBox;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function start()
	{
		music = FunkinSound.load('gameplay/dialogue/music/${meta.music}', 1, true, false);
		music.fadeIn(1);

		box = DialogueBoxRegistry.instance.fetchDialogueBox(meta.box);
		box.screenCenter(X);
		box.x += box.getBoxOffset()[0];
		box.y = FlxG.height - box.height + box.getBoxOffset()[1];
		add(box);
	}

	override function destroy()
	{
		super.destroy();

		music?.destroy();
	}
}

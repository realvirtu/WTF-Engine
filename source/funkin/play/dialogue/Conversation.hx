package funkin.play.dialogue;

import flixel.group.FlxGroup;
import funkin.audio.FunkinSound;
import funkin.data.dialogue.ConversationData;

/**
 * A class for playing dialogue between characters.
 */
class Conversation extends FlxGroup
{
	public final id:String;

	public var meta:ConversationData;

	public var music:FunkinSound;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function start()
	{
		music = FunkinSound.load('gameplay/dialogue/music/${meta.music}', 1, true, false);
		music.fadeIn(1);
	}

	override function destroy()
	{
		super.destroy();

		music?.destroy();
	}
}

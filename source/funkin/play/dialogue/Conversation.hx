package funkin.play.dialogue;

import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.data.dialogue.ConversationData;
import funkin.data.dialogue.ConversationRegistry;
import funkin.data.dialogue.DialogueBoxRegistry;
import funkin.data.dialogue.SpeakerRegistry;
import funkin.graphics.FunkinSprite;
import funkin.input.Controls;

/**
 * A class for playing dialogue between characters.
 */
class Conversation extends FlxGroup
{
	public final id:String;

	public var meta:ConversationData;

	public var music:FunkinSound;

	public var bg:FunkinSprite;
	public var box:DialogueBox;
	public var speaker:DialogueSpeaker;

	var path(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function start()
	{
		music = FunkinSound.load('$path/music', 1, true, false);
		music.fadeIn(1);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.alpha = 0;
		bg.active = false;
		add(bg);

		box = DialogueBoxRegistry.instance.fetchDialogueBox(meta.box);
		box.screenCenter(X);
		box.x += box.globalOffset[0];
		box.y = FlxG.height - box.height + box.globalOffset[1];
		box.zIndex = 1;
		add(box);

		speaker = SpeakerRegistry.instance.fetchSpeaker('senpai');
		speaker.x = box.x + box.speakerOffset[0];
		speaker.y = box.y - speaker.height + box.speakerOffset[1];
		add(speaker);

		refresh();

		FlxTween.tween(bg, {alpha: 0.5}, 2, {ease: x -> return Math.floor(x * 8) / 8});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.instance.ACCEPT_P)
			box.confirm();
	}

	override function destroy()
	{
		super.destroy();

		music?.destroy();
	}

	@:noCompletion
	inline function get_path():String
	{
		return '${ConversationRegistry.instance.path}/$id';
	}
}

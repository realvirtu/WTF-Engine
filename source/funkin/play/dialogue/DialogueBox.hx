package funkin.play.dialogue;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.data.dialogue.DialogueBoxData;
import funkin.data.dialogue.DialogueBoxRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

/**
 * Dialogue box object used for conversations.
 */
class DialogueBox extends FlxSpriteGroup
{
	public final id:String;

	public var meta:DialogueBoxData;

	public var globalOffset(get, never):Array<Float>;
	public var speakerOffset(get, never):Array<Float>;

	public var box:FunkinSprite;
	public var hand:FunkinSprite;
	public var text:FunkinText;

	var boxTimer:FlxTimer;

	var boxPath(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		final handData:DialogueBoxHandData = meta?.hand;
		final textData:DialogueBoxTextData = meta?.text;

		box = FunkinSprite.create(0, 0, '$boxPath/image', meta?.scale ?? 1);
		box.active = false;
		add(box);

		if (handData != null)
		{
			hand = FunkinSprite.create(0, 0, '$boxPath/hand', handData.scale, handData.width, handData.height);
			hand.addAnimation('anim', [1, 2, 0], 10, false);
			hand.x = box.width - hand.width + handData.offset[0];
			hand.y = box.height - hand.height + handData.offset[1];
			add(hand);
		}

		text = new FunkinText();
		text.autoSize = false;
		text.fieldWidth = Std.int(box.width);
		add(text);

		if (textData != null)
		{
			text.x += textData.offset[0];
			text.y += textData.offset[1];

			text.fieldWidth -= Std.int(textData.offset[0]);

			text.color = FlxColor.fromString(textData.textColor);
			text.borderColor = FlxColor.fromString(textData.borderColor);
			text.borderStyle = SHADOW;
			text.size = textData.textSize;
			text.borderSize = textData.borderSize;
		}
	}

	public function confirm()
	{
		if (box != null)
		{
			boxTimer?.cancel();
			boxTimer = FlxTimer.wait(0.05, () -> box.y = y);

			box.y = y - 10;
		}

		hand?.playAnimation('anim', true);
	}

	@:noCompletion
	inline function get_globalOffset():Array<Float>
	{
		return meta?.globalOffset ?? [];
	}

	@:noCompletion
	inline function get_speakerOffset():Array<Float>
	{
		return meta?.speakerOffset ?? [];
	}

	@:noCompletion
	inline function get_boxPath():String
	{
		return '${DialogueBoxRegistry.instance.path}/$id';
	}
}

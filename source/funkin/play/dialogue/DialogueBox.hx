package funkin.play.dialogue;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.dialogue.DialogueBoxData;
import funkin.data.dialogue.DialogueBoxRegistry;
import funkin.graphics.FunkinSprite;

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

	var boxTimer:FlxTimer;

	var boxPath(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		if (meta == null)
			return;

		box = FunkinSprite.create(0, 0, '$boxPath/image', meta.scale);
		box.active = false;
		add(box);

		// Creates the hand sprite
		// Though only do so if there's data for the hand
		final handPath:String = '$boxPath/hand';
		final handData:DialogueBoxHandData = meta.hand;

		if (meta.hand != null && Paths.exists(Paths.image(handPath)))
		{
			hand = FunkinSprite.create(0, 0, handPath, handData.scale, handData.width, handData.height);
			hand.addAnimation('anim', [1, 2, 0], 10, false);
			hand.x = box.width - hand.width + handData.offset[0];
			hand.y = box.height - hand.height + handData.offset[1];
			add(hand);
		}
	}

	public function confirm()
	{
		box.y = y - 10;

		boxTimer?.cancel();
		boxTimer = FlxTimer.wait(0.05, () -> box.y = y);

		hand?.playAnimation('anim', true);

		FunkinSound.playOnce('gameplay/dialogue/sounds/next');
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

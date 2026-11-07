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

		final path:String = '$boxPath/hand';

		if (meta.hand != null && Paths.exists(Paths.image(path)))
		{
			hand = FunkinSprite.create(0, 0, path, meta.hand.scale, meta.hand.width, meta.hand.height);
			hand.addAnimation('anim', [1, 2, 0], 10, false);
			hand.x = box.width - hand.width + getHandOffset()[0];
			hand.y = box.height - hand.height + getHandOffset()[1];
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

	public function getBoxOffset():Array<Float>
	{
		return meta?.offset?.copy() ?? [];
	}

	public function getHandOffset():Array<Float>
	{
		return meta?.hand?.offset?.copy() ?? [];
	}

	@:noCompletion
	inline function get_boxPath():String
	{
		return '${DialogueBoxRegistry.instance.path}/$id';
	}
}

package funkin.play.dialogue;

import flixel.group.FlxSpriteGroup;
import funkin.data.dialogue.DialogueBoxData;
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

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		if (meta == null)
			return;

		box = FunkinSprite.create(0, 0, 'gameplay/dialogue/boxes/$id/image', meta.scale);
		add(box);

		if (meta.hand != null)
		{
			hand = FunkinSprite.create(0, 0, 'gameplay/dialogue/boxes/$id/hand', meta.hand.scale, meta.hand.width, meta.hand.height);
			hand.addAnimation('anim', [1, 2, 0], 10, false);
			hand.x = box.width - hand.width + getHandOffset()[0];
			hand.y = box.height - hand.height + getHandOffset()[1];
			add(hand);
		}
	}

	public function getBoxOffset():Array<Float>
	{
		return meta?.offset?.copy() ?? [];
	}

	public function getHandOffset():Array<Float>
	{
		return meta?.hand?.offset?.copy() ?? [];
	}
}

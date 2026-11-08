package funkin.play.dialogue;

import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.data.dialogue.DialogueBoxData;
import funkin.data.dialogue.DialogueBoxRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.modding.IScriptedClass.IDialogueScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.util.EaseUtil;
import funkin.util.SortUtil;

/**
 * Dialogue box object used for conversations.
 */
class DialogueBox extends FlxSpriteGroup implements IDialogueScriptedClass
{
	public final id:String;

	public var meta:DialogueBoxData;

	public var globalOffset(get, never):Array<Float>;
	public var speakerOffset(get, never):Array<Float>;

	public var box:FunkinSprite;
	public var hand:FunkinSprite;
	public var text:FunkinText;

	var boxPath(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildSprite()
	{
		text = new FunkinText();
		text.autoSize = false;
		text.zIndex = 1;
		add(text);

		if (meta == null)
			return;

		box = FunkinSprite.create(0, 0, '$boxPath/image', meta.scale, meta.width, meta.height);
		add(box);

		for (anim in meta.animations)
		{
			if (anim == null)
				continue;
			box.addAnimation(anim.name, anim.frames, anim.framerate, anim.looped);
		}

		box.playAnimation('idle');

		box.animation.onFinish.add(name ->
		{
			if (name == 'open')
				box.playAnimation('idle');
		});

		if (meta.text != null)
		{
			final offset:Array<Float> = meta.text.offset;

			text.x += offset[0];
			text.y += offset[1];

			text.fieldWidth = Std.int(box.width - offset[0]);

			text.color = FlxColor.fromString(meta.text.textColor);
			text.borderColor = FlxColor.fromString(meta.text.borderColor);
			text.borderStyle = SHADOW;
			text.size = meta.text.textSize;
			text.borderSize = meta.text.borderSize;
		}

		if (meta.hand != null)
		{
			final offset:Array<Float> = meta.hand.offset;

			hand = FunkinSprite.create(0, 0, '$boxPath/hand', meta.hand.scale, meta.hand.width, meta.hand.height);
			hand.x = box.width - hand.width + offset[0];
			hand.y = box.height - hand.height + offset[1];

			hand.addAnimation('press', [1, 2, 0], 10, false);

			add(hand);
		}

		sort(SortUtil.byZIndex.bind());
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onDialogueStart(event:DialogueScriptEvent)
	{
		if (box == null)
			return;

		box.playAnimation('open');
		box.alpha = 0;

		FlxTween.tween(box, {alpha: 1}, 0.5, {ease: EaseUtil.stepped(8)});
	}

	public function onDialogueLine(event:DialogueScriptEvent)
	{
		box?.playAnimation('idle');
		hand?.playAnimation('press', true);
	}

	public function onDialogueCompleteLine(event:DialogueScriptEvent)
	{
		hand?.playAnimation('press', true);
	}

	public function onDialogueEnd(event:DialogueScriptEvent)
	{
		if (box == null)
			return;

		text?.destroy();
		text = null;

		hand?.destroy();
		hand = null;

		box.playAnimation('close');

		FlxTween.tween(box, {alpha: 0}, 0.5, {ease: EaseUtil.stepped(8)});
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

	override function toString():String
	{
		return id;
	}
}

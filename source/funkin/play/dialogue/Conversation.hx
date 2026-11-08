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
import funkin.modding.IScriptedClass.IDialogueScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.ui.FunkinState;
import funkin.util.EaseUtil;

/**
 * The different states for dialogue conversations.
 */
enum ConversationState
{
	START;
	SPEAKING;
	IDLE;
	ENDING;
}

/**
 * A class for playing dialogue between characters.
 */
class Conversation extends FlxGroup implements IDialogueScriptedClass
{
	public final id:String;

	public var meta:ConversationData;
	public var state:ConversationState;

	public var music:FunkinSound;

	public var lineNumber:Int = -1;
	public var lineCount(get, never):Int;

	public var line(get, never):ConversationLineData;
	public var lineText(get, never):String;

	public var onComplete:() -> Void;

	public var bg:FunkinSprite;
	public var box:DialogueBox;
	public var speaker:Speaker;

	var path(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function start()
	{
		ScriptEventDispatcher.dispatchToState(new DialogueScriptEvent(DIALOGUE_START, this));
	}

	public function end()
	{
		ScriptEventDispatcher.dispatchToState(new DialogueScriptEvent(DIALOGUE_END, this));
	}

	public function advance()
	{
		switch (state)
		{
			case START | IDLE:
				ScriptEventDispatcher.dispatchToState(new DialogueScriptEvent(DIALOGUE_LINE, this));
			case SPEAKING:
				ScriptEventDispatcher.dispatchToState(new DialogueScriptEvent(DIALOGUE_COMPLETE_LINE, this));
			default:
				// Does literally nothing
		}
	}

	function showSpeaker()
	{
		speaker?.destroy();
		speaker = SpeakerRegistry.instance.fetchSpeaker(line.speaker);

		if (speaker == null)
			return;

		speaker.x = box.x + box.speakerOffset[0];
		speaker.y = box.y - speaker.height + box.speakerOffset[1];

		add(speaker);
		refresh();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.instance.ACCEPT_P)
			advance();
	}

	override function destroy()
	{
		super.destroy();

		music?.destroy();
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent)
	{
		ScriptEventDispatcher.dispatch(box, event);
		ScriptEventDispatcher.dispatch(speaker, event);
	}

	public function onDialogueStart(event:DialogueScriptEvent)
	{
		state = START;

		music = FunkinSound.load('$path/music', 1, true, false);
		music.fadeIn(1);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.alpha = 0;
		bg.active = false;
		add(bg);

		box = DialogueBoxRegistry.instance.fetchDialogueBox(meta.box);
		box.x = (FlxG.width - box.box.width) / 2 + box.globalOffset[0];
		box.y = FlxG.height - box.height + box.globalOffset[1];
		box.zIndex = 1;
		add(box);

		advance();

		FlxTween.tween(bg, {alpha: 0.5}, 2, {ease: EaseUtil.stepped(8)});
	}

	public function onDialogueLine(event:DialogueScriptEvent)
	{
		state = SPEAKING;

		lineNumber++;

		if (lineNumber > 0)
			FunkinSound.playOnce('gameplay/dialogue/sounds/advance');

		if (lineNumber >= lineCount)
			end();
		else
		{
			box.text.type(lineText, 0.06, () ->
			{
				@:privateAccess
				var click:String = '${speaker?.speakerPath}/click';

				if (!Paths.exists(Paths.sound(click)))
					click = 'gameplay/dialogue/sounds/click';

				FunkinSound.playOnce(click);
			}, () -> state = IDLE);

			showSpeaker();
		}
	}

	public function onDialogueCompleteLine(event:DialogueScriptEvent)
	{
		state = IDLE;

		box.text.finishType();

		FunkinSound.playOnce('gameplay/dialogue/sounds/advance');
	}

	public function onDialogueEnd(event:DialogueScriptEvent)
	{
		state = ENDING;

		music.fadeOut(1);
		speaker?.destroy();

		FlxTween.cancelTweensOf(bg);
		FlxTween.tween(bg, {alpha: 0}, 1, {
			ease: EaseUtil.stepped(8),
			onComplete: _ ->
			{
				if (onComplete != null)
					onComplete();
				destroy();
			}
		});
	}

	@:noCompletion
	inline function get_lineCount():Int
	{
		return meta.lines.length;
	}

	@:noCompletion
	inline function get_line():ConversationLineData
	{
		return meta.lines[lineNumber];
	}

	@:noCompletion
	inline function get_lineText():String
	{
		return line?.text ?? '';
	}

	@:noCompletion
	inline function get_path():String
	{
		return '${ConversationRegistry.instance.path}/$id';
	}

	override function toString():String
	{
		return id;
	}
}

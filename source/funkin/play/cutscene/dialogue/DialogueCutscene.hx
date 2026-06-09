package funkin.play.cutscene.dialogue;

import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.dialogue.DialogueData;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.util.FileUtil;
import json2object.JsonParser;

/**
 * A `Cutscene` class for playing dialogue. This is specifically used for Week 6.
 */
class DialogueCutscene extends BaseCutscene
{
	static var parser(default, null) = new JsonParser<DialogueData>();

	final TEXT_POSITION:Float = 50;
	final TYPE_SPEED:Float = 0.03;
	final FADE_SPEED:Float = 1;

	var data:DialogueData;
	var lines:Array<DialogueLineData>;
	var line:DialogueLineData;

	var typeTimer:FlxTimer;
	var music:FlxSound;

	var bg:FunkinSprite;
	var speaker:DialogueSpeaker;
	var box:DialogueBox;
	var text:FunkinText;

	var lineText(get, never):String;
	var lineFinished(get, never):Bool;

	public function new(id:String, ?callback:Void->Void)
	{
		super(id, false, callback);

		final path:String = Paths.json('play/dialogue/$id');

		// Don't run the dialogue if it doesn't exist
		// Come on.. that's WAY too dangerous
		if (!Paths.exists(path))
			return close();

		data = parser.fromJson(FileUtil.getText(path));
		lines = data.lines.copy();

		music = FunkinSound.load('play/dialogue/music/${data.music}', 0);
		music.fadeIn();

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.active = false;
		bg.alpha = 0.5;
		add(bg);

		speaker = new DialogueSpeaker();
		add(speaker);

		box = new DialogueBox(data.box);
		box.screenCenter(X);
		box.y = FlxG.height - box.height - 50;
		add(box);

		text = new FunkinText(box.x + TEXT_POSITION, box.y + TEXT_POSITION);
		text.fieldWidth = Std.int(box.width - TEXT_POSITION * 2);
		text.size = 30;
		text.wrap = CHAR;
		text.borderColor = 0xFF000000;
		text.borderSize = 4;
		text.borderStyle = SHADOW;
		add(text);
	}

	override public function start()
	{
		super.start();

		nextLine();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT_P)
			finishLine();
	}

	function finishLine()
	{
		typeTimer?.cancel();

		if (lineFinished)
			nextLine();
		else
			text.text = lineText;

		FunkinSound.playOnce('play/dialogue/sounds/next');
	}

	function nextLine()
	{
		typeTimer?.cancel();

		// Dialogue is done, so end it
		if (lines.length == 0)
			return end();

		line = lines.shift();

		// Skip the line if it's null
		// Null lines can exist methinks
		if (line == null)
			return nextLine();

		text.text = '';

		speaker.load(line.speaker);
		speaker.x = box.x;
		speaker.y = box.y - speaker.height;

		typeText();
	}

	function typeText()
	{
		typeTimer?.cancel();
		typeTimer = FlxTimer.wait(TYPE_SPEED, () ->
		{
			text.text = lineText.substr(0, text.text.length + 1);

			if (!lineFinished)
				typeText();

			FunkinSound.playOnce('play/dialogue/sounds/type', 0.35);
		});
	}

	function end()
	{
		active = false;

		speaker.visible = false;
		box.visible = false;
		text.visible = false;

		music.fadeOut();

		// Does a neat background fade out
		// Literally the coolest thing ever
		// Of course, the cutscene ends after the fade
		FlxTween.tween(bg, {alpha: 0}, FADE_SPEED, {onComplete: _ -> close()});
	}

	override public function destroy()
	{
		super.destroy();

		music.stop();
	}

	@:noCompletion
	inline function get_lineText():String
	{
		return line.text;
	}

	@:noCompletion
	inline function get_lineFinished():Bool
	{
		return text.text == lineText;
	}
}

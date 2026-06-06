package funkin.ui.selector;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

/**
 * A sprite group that's literally just text with arrows on the sides.
 */
class SelectorText extends FlxSpriteGroup
{
	final ARROW_SPACING:Float = 10;

	public var selected:Int;
	public var busy:Bool = false;

	public var size(default, set):Int = 32;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	var text:FunkinText;
	var arrowLeft:FunkinSprite;
	var arrowRight:FunkinSprite;

	var selectTimer:FlxTimer;

	public function new(selected:Int, arrowImage:String)
	{
		super();

		this.selected = selected;

		text = new FunkinText();
		add(text);

		arrowLeft = FunkinSprite.create(0, 0, arrowImage);
		arrowLeft.active = false;
		add(arrowLeft);

		arrowRight = arrowLeft.clone();
		arrowRight.flipX = true;
		add(arrowRight);

		change();
	}

	function change(change:Int = 0)
	{
		if (busy)
			return;

		final lastSelected:Int = selected;

		selected += change;

		updateSelected();
		updateText();

		if (lastSelected != selected && change != 0)
		{
			FunkinSound.playOnce('ui/sounds/scroll');

			text.y -= 5;

			selectTimer?.cancel();
			selectTimer = FlxTimer.wait(0.05, () -> text.y += 5);

			onChanged.dispatch(selected);
		}
	}

	function updateSelected()
	{
		// You stupid bitch
		// You need to override this
	}

	function updateText()
	{
		text.x = arrowLeft.x + arrowLeft.width + ARROW_SPACING;

		arrowRight.x = text.x + text.width + ARROW_SPACING;
		arrowLeft.y = text.y + (text.height - arrowLeft.height) / 2;
		arrowRight.y = arrowLeft.y;
	}

	@:noCompletion
	function set_size(value:Int):Int
	{
		if (text.size == value)
			return value;
		text.size = value;

		updateText();

		return value;
	}
}

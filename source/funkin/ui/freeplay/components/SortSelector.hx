package funkin.ui.freeplay.components;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.data.story.LevelRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.input.Controls;
import funkin.ui.story.Level;
import funkin.util.MathUtil;

/**
 * A selector for sorting songs in the freeplay menu.
 */
class SortSelector extends FlxSpriteGroup
{
	public var selected:Int;

	public var busy:Bool = false;

	public var text:FunkinText;
	public var arrowLeft:FunkinSprite;
	public var arrowRight:FunkinSprite;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	public var count(get, never):Int;
	public var mode(get, never):SortMode;
	public var level(get, never):Level;

	var textTimer:Float = 0;
	var off:Float = 0;

	public function new(selected:Int = 0)
	{
		super();

		this.selected = selected;

		text = new FunkinText();
		text.size = 32;
		add(text);

		arrowLeft = FunkinSprite.create(0, 0, 'ui/freeplay/selector/sort');
		arrowLeft.y = y + (text.height - arrowLeft.height) / 2;
		add(arrowLeft);

		arrowRight = arrowLeft.clone();
		arrowRight.y = arrowLeft.y;
		arrowRight.flipX = true;
		add(arrowRight);

		updateText();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		textTimer += elapsed * 5;
		off = MathUtil.lerp(off, 0, 0.5);

		updateText();

		if (busy)
			return;

		final left:Bool = Controls.instance.FREEPLAY_SORT_LEFT;
		final right:Bool = Controls.instance.FREEPLAY_SORT_RIGHT;

		if (left || right)
			change(left ? -1 : 1);
	}

	function updateText()
	{
		text.text = switch (mode)
		{
			case FAVORITES:
				'favorites';
			case LEVEL:
				level.title;
			default:
				'all';
		}

		final x:Float = x - text.width / 2;

		text.x = x - off;
		text.y = y - Math.cos(textTimer) * 2;

		arrowLeft.x = x - arrowLeft.width - 10;
		arrowRight.x = x + text.width + 10;
	}

	function change(change:Int)
	{
		selected += change;

		if (selected >= count)
			selected = 0;
		else if (selected < 0)
			selected = count - 1;

		onChanged.dispatch(selected);

		off = 50 * change;

		FunkinSound.playOnce('general/sounds/scroll');
	}

	@:noCompletion
	function get_mode():SortMode
	{
		if (selected == count - 1)
			return FAVORITES;
		else if (selected > 0)
			return LEVEL;
		return ALL;
	}

	@:noCompletion
	function get_level():Level
	{
		return LevelRegistry.instance.fetch(LevelRegistry.instance.listSorted()[selected - 1]);
	}

	@:noCompletion
	inline function get_count():Int
	{
		return LevelRegistry.instance.list().length + 2;
	}
}

/**
 * An enum for the different sorting modes displayed for `SortSelector`.
 */
enum SortMode
{
	ALL;
	LEVEL;
	FAVORITES;
}

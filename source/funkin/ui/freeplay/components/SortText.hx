package funkin.ui.freeplay.components;

import funkin.data.story.LevelRegistry;
import funkin.input.Controls;
import funkin.ui.selector.SelectorText;
import funkin.ui.story.Level;

/**
 * Text that displays how freeplay songs are currently being sorted.
 */
class SortText extends SelectorText
{
	public var count(get, never):Int;
	public var level(get, never):Level;

	public function new(selected:Int = 0)
	{
		super(selected, 'menu/arrow/small');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var left:Bool = Controls.instance.SORT_LEFT;
		var right:Bool = Controls.instance.SORT_RIGHT;

		if (left || right)
			change(left ? -1 : 1);
	}

	override function updateSelected()
	{
		if (selected < 0)
			selected = count - 1;
		else if (selected >= count)
			selected = 0;
	}

	override function updateText()
	{
		var sortText:String = 'all';

		if (selected == count - 1)
			sortText = 'favorites';
		else if (selected > 0)
			sortText = level.title;

		text.text = sortText;

		super.updateText();
	}

	@:noCompletion
	inline function get_count():Int
	{
		return 2 + LevelRegistry.instance.list().length;
	}

	@:noCompletion
	inline function get_level():Level
	{
		// Gets the level id
		// Holy moly :O
		final id:String = LevelRegistry.instance.listSorted()[selected - 1];

		return LevelRegistry.instance.fetch(id);
	}
}

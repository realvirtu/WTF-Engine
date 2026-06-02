package funkin.ui.selector;

import funkin.input.Controls;

/**
 * Text that displays the current difficulty in the freeplay menu.
 */
class DifficultyText extends SelectorText
{
	public var difficulties(default, set):Array<String>;
	public var difficulty(get, never):String;

	public function new(selected:Int = 0, difficulties:Array<String>)
	{
		// This HAS to be set before
		// Setting this after the super will CRASH
		this.difficulties = difficulties;

		super(selected, 'ui/arrow');

		size = 48;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var left:Bool = Controls.instance.UI_LEFT_P;
		var right:Bool = Controls.instance.UI_RIGHT_P;

		if (left || right)
			change(left ? -1 : 1);
	}

	override function updateSelected()
	{
		if (selected < 0)
			selected = difficulties.length - 1;
		else if (selected >= difficulties.length)
			selected = 0;
	}

	override function updateText()
	{
		text.text = difficulty;

		// Nightmare is too lengthy of a name
		// TODO: Find a way to make this softcoded
		if (difficulty == 'nightmare')
			text.text = 'night';

		super.updateText();
	}

	@:noCompletion
	inline function set_difficulties(value:Array<String>):Array<String>
	{
		this.difficulties = value;

		if (selected >= value.length)
			selected = value.length - 1;

		if (text != null)
			updateText();

		return value;
	}

	@:noCompletion
	inline function get_difficulty():String
	{
		return difficulties[selected];
	}
}

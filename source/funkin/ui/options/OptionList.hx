package funkin.ui.options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.input.Controls;
import funkin.util.MathUtil;

/**
 * A class similar to `MenuList`, but specifically for the `Option` class.
 */
class OptionList extends FlxTypedGroup<Option>
{
	public var selected:Int;

	public var busy:Bool = false;
	public var lerp:Bool = true;

	public var option(get, never):Option;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	var controls(get, never):Controls;

	public function new(selected:Int = 0)
	{
		super();

		this.selected = selected;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		final up:Bool = controls.UI_UP_T;
		final down:Bool = controls.UI_DOWN_T;
		final left:Bool = controls.UI_LEFT_T;
		final right:Bool = controls.UI_RIGHT_T;
		final accept:Bool = controls.ACCEPT;

		if (up || down)
			change(up ? -1 : 1);
		if (left || right)
			changeValue(left ? -1 : 1);
		if (accept)
			select();

		forEach(option ->
		{
			option.alpha = selected == option.ID ? 1 : 0.6;

			if (lerp)
			{
				option.x = MathUtil.lerp(option.x, getOptionX(option), 0.15);
				option.y = MathUtil.lerp(option.y, getOptionY(option), 0.15);
			}
		});
	}

	public function addOption(id:String, ?name:String, step:Int = 5, min:Int = 0, max:Int = 1):Option
	{
		var option:Option = new Option(id, name ?? id, step, min, max);
		add(option);

		option.ID = length - 1;

		option.x = getOptionX(option);
		option.y = getOptionY(option);

		return option;
	}

	function change(change:Int)
	{
		if (busy)
			return;

		selected += change;

		if (selected < 0)
			selected = length - 1;
		else if (selected >= length)
			selected = 0;

		onChanged.dispatch(selected);

		FunkinSound.playOnce('ui/sounds/scroll');
	}

	function changeValue(change:Int)
	{
		if (busy || option.type != Numeric)
			return;

		final lastValue:Float = option.value;

		option.value += option.step * change;

		if (lastValue != option.value)
		{
			option.x += 10 * (change > 0 ? 1 : -1);

			FunkinSound.playOnce('ui/sounds/scroll');
		}
	}

	function select()
	{
		// Only checkboxes can be selected
		if (busy || option.type != Checkbox)
			return;

		option.value = !option.value;
		option.y += 10 * (option.value ? 1 : -1);

		FunkinSound.playOnce('ui/sounds/scroll');
	}

	function getOptionX(option:Option):Float
	{
		var x:Float = 100;
		if (option.ID == selected)
			x += 10;
		return x;
	}

	function getOptionY(option:Option):Float
	{
		// Couldn't use option.height because of some stupid fucking problems
		// LITERALLY WHATTHESHIT
		return 300 + 100 * (option.ID - selected);
	}

	@:noCompletion
	inline function get_option():Option
	{
		return members[selected];
	}

	@:noCompletion
	inline function get_controls():Controls
	{
		return Controls.instance;
	}
}

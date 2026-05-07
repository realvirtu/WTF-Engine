package funkin.ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinText;
import funkin.input.Controls;
import funkin.util.MathUtil;

/**
 * A list of `FunkinText` objects that the player can scroll through.
 */
class MenuList extends FlxTypedGroup< #if hl Dynamic #else FunkinText #end>
{
	public var entries(default, set):Array<String>;
	public var size(get, never):Int;

	public var selected:Int = 0;
	public var onSelected(default, null) = new FlxTypedSignal<String->Void>();

	var controls(get, never):Controls;

	public function new(entries:Array<String>)
	{
		super();

		this.entries = entries;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P || controls.UI_DOWN_P)
			change(controls.UI_UP_P ? -1 : 1);
		if (controls.ACCEPT)
			onSelected.dispatch(entries[selected]);

		// Updates the items to be in the correct position
		forEachAlive(item ->
		{
			item.alpha = item.ID == selected ? 1 : 0.6;
			item.x = MathUtil.lerp(item.x, getItemX(#if hl cast #end item), 0.15);
			item.y = MathUtil.lerp(item.y, getItemY(#if hl cast #end item), 0.15);
		});
	}

	public function change(change:Int)
	{
		FunkinSound.playOnce('ui/sounds/scroll');

		selected += change;

		if (selected < 0)
			selected = size - 1;
		if (selected >= size)
			selected = 0;
	}

	inline function getItemX(item:FunkinText):Float
	{
		return 80 + (item.ID - selected) * 20;
	}

	inline function getItemY(item:FunkinText):Float
	{
		return FlxG.height / 2 + (item.ID - selected - 0.5) * (item.height + 50);
	}

	@:noCompletion
	function set_entries(value:Array<String>):Array<String>
	{
		if (this.entries == value)
			return value;
		this.entries = value;

		selected = 0;

		killMembers();

		for (i => item in value)
		{
			var text:FunkinText = #if hl cast #end
			recycle(FunkinText);
			text.text = item;
			text.size = 56;
			text.ID = i;
			text.setPosition(getItemX(text) - 500, getItemY(text));
		}

		return value;
	}

	@:noCompletion
	inline function get_size():Int
	{
		return countLiving();
	}

	@:noCompletion
	inline function get_controls():Controls
	{
		return Controls.instance;
	}
}

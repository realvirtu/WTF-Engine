package funkin.ui.menu;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.input.Controls;

/**
 * A group of `MenuItem` sprites used for the main menu.
 */
class MenuItemGroup extends FlxTypedGroup<MenuItem>
{
	final SPACING:Float = 20;

	public var selected:Int;
	public var busy:Bool = false;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	public var item(get, never):MenuItem;

	public function new(selected:Int = 0)
	{
		super();

		this.selected = selected;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Controls
		var up:Bool = Controls.instance.UI_UP_P;
		var down:Bool = Controls.instance.UI_DOWN_P;

		if ((up || down) && !busy)
			change(up ? -1 : 1);
	}

	public function addItem(id:String, callback:Void->Void)
	{
		var item:MenuItem = new MenuItem(id);

		item.ID = length;

		item.screenCenter(X);
		item.selected = item.ID == selected;
		item.onSelected = callback;

		add(item);

		// Adjusts the position of all the items
		forEach(item ->
		{
			item.y = FlxG.height / 2 + (item.ID - length / 2) * (item.height + SPACING);
			item.y += SPACING / 2;
		});
	}

	public function flicker()
	{
		FlxFlicker.flicker(item, 1, 0.04, true, true, _ ->
		{
			// onSelected can be null, so we're being real careful
			if (item.onSelected != null)
				item.onSelected();
		});
	}

	function change(change:Int)
	{
		FunkinSound.playOnce('general/sounds/scroll');

		selected += change;

		if (selected < 0)
			selected = length - 1;
		else if (selected >= length)
			selected = 0;

		forEach(item -> item.selected = item.ID == selected);

		onChanged.dispatch(selected);
	}

	@:noCompletion
	inline function get_item():MenuItem
	{
		return members[selected];
	}
}

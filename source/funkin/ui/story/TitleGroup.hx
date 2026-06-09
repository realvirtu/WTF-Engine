package funkin.ui.story;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.data.story.LevelRegistry;
import funkin.input.Controls;
import funkin.ui.story.Level;
import funkin.util.MathUtil;

/**
 * A group of `TitleText`s that display different level titles.
 */
class TitleGroup extends FlxTypedGroup<TitleText>
{
	final SPACING:Float = 30;

	public var selected:Int;
	public var y:Float;
	public var levels:Array<String>;

	public var busy:Bool = false;
	public var lerp:Bool = true;

	public var title(get, never):TitleText;
	public var level(get, never):Level;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	public function new(selected:Int = 0, y:Float, levels:Array<String>)
	{
		super();

		this.selected = selected;
		this.y = y;
		this.levels = levels;

		// Loads the level titles
		for (i => level in levels)
		{
			var level:Level = LevelRegistry.instance.fetch(level);
			var text:TitleText = new TitleText(0, 0, level.title);

			text.ID = i;

			text.size = 64;
			text.screenCenter(X);
			text.y = getIntendedY(text);

			add(text);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.instance.UI_UP_P;
		var down:Bool = Controls.instance.UI_DOWN_P;

		if ((up || down) && !busy)
			change(up ? -1 : 1);

		forEach(text ->
		{
			if (lerp)
				text.y = MathUtil.lerp(text.y, getIntendedY(text), 0.15);
			text.alpha = text.ID == selected ? 1 : 0.6;
		});
	}

	public function change(change:Int)
	{
		final lastSelected:Int = selected;

		selected += change;

		if (selected < 0)
			selected = length - 1;
		else if (selected >= length)
			selected = 0;

		if (lastSelected != selected && change != 0)
		{
			FunkinSound.playOnce('general/sounds/scroll');

			onChanged.dispatch(selected);
		}
	}

	function getIntendedY(text:TitleText):Float
	{
		return y + (text.ID - selected) * (text.height + SPACING);
	}

	@:noCompletion
	inline function get_title():TitleText
	{
		return members[selected];
	}

	@:noCompletion
	inline function get_level():Level
	{
		return LevelRegistry.instance.fetch(levels[selected]);
	}
}

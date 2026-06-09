package funkin.ui.options;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

/**
 * An extension of `FunkinText` used for the options menu.
 */
class Option extends FlxSpriteGroup
{
	public var id:String;
	public var name:String;
	public var step:Int;
	public var min:Int;
	public var max:Int;

	public var value(get, set):Dynamic;
	public var type(get, never):OptionType;

	var text:FunkinText;
	var checkbox:FunkinSprite;

	var arrowLeft:FunkinSprite;
	var arrowRight:FunkinSprite;
	var valueText:FunkinText;

	public function new(id:String, name:String, step:Int, min:Int, max:Int)
	{
		super();

		this.id = id;
		this.name = name;
		this.step = step;
		this.min = min;
		this.max = max;

		active = false;

		text = new FunkinText(0, 0, name);
		text.size = 56;
		add(text);

		switch (type)
		{
			case CHECKBOX:
				checkbox = FunkinSprite.create(text.width + 10, 0, 'menu/option/checkbox', 1.25, 72, 61);
				checkbox.y = (text.height - checkbox.height) / 2;
				checkbox.active = false;
				checkbox.addAnimation('checkbox', [0, 1], 0);
				checkbox.playAnimation('checkbox');
				add(checkbox);
			case NUMERIC:
				arrowLeft = FunkinSprite.create(text.width + 10, 0, 'menu/arrow/default');
				arrowLeft.active = false;
				arrowLeft.y = (text.height - arrowLeft.height) / 2;
				add(arrowLeft);

				arrowRight = arrowLeft.clone();
				arrowRight.flipX = true;
				arrowRight.y = arrowLeft.y;
				add(arrowRight);

				valueText = new FunkinText(arrowLeft.x + arrowLeft.width + 10, 0, 'wawa');
				valueText.size = 48;
				valueText.y = (text.height - valueText.height) / 2;
				add(valueText);
			default:
				// Does literally nothing
		}

		updateValue();
	}

	function updateValue()
	{
		// Updates the checkbox
		if (checkbox != null)
			checkbox.animation.frameIndex = value ? 1 : 0;

		// Updates the value text
		if (valueText != null)
		{
			valueText.text = Std.string(value);
			arrowRight.x = valueText.x + valueText.width + 10;
		}
	}

	@:noCompletion
	inline function set_value(value:Dynamic):Dynamic
	{
		value = FlxMath.bound(value, min, max);

		if (this.value == value)
			return value;

		// Reflect.setProperty() is a huge life saver
		// Reflect.setField CANNOT do setters :(
		Reflect.setProperty(Preferences, id, value);

		updateValue();

		return value;
	}

	@:noCompletion
	inline function get_value():Dynamic
	{
		return Reflect.getProperty(Preferences, id);
	}

	@:noCompletion
	function get_type():OptionType
	{
		return switch (Type.typeof(value))
		{
			case TBool:
				return CHECKBOX;
			case TInt:
				return NUMERIC;
			default:
				return NONE;
		}
	}
}

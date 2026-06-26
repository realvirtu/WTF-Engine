package funkin.play.note.strum;

import funkin.graphics.FunkinSprite;

/**
 * A `FunkinSprite` used as the recepter for a `Strumline`.
 */
class StrumSprite extends FunkinSprite
{
	public var direction:NoteDirection;
	public var confirmTime:Float = 0;

	public var middle(get, never):Float;

	public function new(direction:NoteDirection)
	{
		super();

		this.direction = direction;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		confirmTime = Math.max(0, confirmTime - elapsed * 10);
	}

	public function buildSprite(style:Style)
	{
		loadSprite(style.getNote('image'), style.note.scale, style.note.width, style.note.height);

		addAnimation('static', [direction]);
		addAnimation('press', [direction + Constants.NOTE_COUNT]);
		addAnimation('confirm', [direction + Constants.NOTE_COUNT * 2]);

		playStatic();
	}

	public function playStatic()
	{
		playAnimation('static');
	}

	public function playPress()
	{
		playAnimation('press');
	}

	public function playConfirm()
	{
		playAnimation('confirm');
		confirmTime = 1;
	}

	@:noCompletion
	inline function get_middle():Float
	{
		return y + height / 2;
	}
}

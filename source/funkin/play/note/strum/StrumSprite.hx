package funkin.play.note.strum;

import funkin.graphics.FunkinSprite;

/**
 * A `FunkinSprite` used as the recepter for a `Strumline`.
 */
class StrumSprite extends FunkinSprite
{
	public final direction:NoteDirection;
	public final isPlayer:Bool;

	public var confirmTime:Float = 0;

	public var middle(get, never):Float;

	public function new(direction:NoteDirection, isPlayer:Bool)
	{
		super();

		this.direction = direction;
		this.isPlayer = isPlayer;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (confirmTime > 0)
		{
			confirmTime = Math.max(0, confirmTime - elapsed * 10);

			if (confirmTime == 0)
				playStatic();
		}
	}

	public function buildSprite(style:NoteStyle)
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

		// Slightly longer time for the opponent
		// Gives the opponent strums a snapped look
		confirmTime = isPlayer ? 1 : 1.85;
	}

	@:noCompletion
	inline function get_middle():Float
	{
		return y + height / 2;
	}
}

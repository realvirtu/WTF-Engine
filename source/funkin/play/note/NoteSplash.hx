package funkin.play.note;

import funkin.graphics.FunkinSprite;
import funkin.play.note.strum.StrumSprite;

/**
 * A `FunkinSprite` used as a note splash that appears when hitting a note perfectly.
 */
class NoteSplash extends FunkinSprite
{
	public var strum:StrumSprite;

	public function buildSprite(style:Style)
	{
		loadSprite(style.getNote('splashes'), style.noteSplash.scale, style.noteSplash.width, style.noteSplash.height);

		for (i in 0...Constants.NOTE_COUNT)
		{
			var direction:NoteDirection = NoteDirection.fromInt(i);
			var frames:Array<Int> = style.getNoteFrames(style.noteSplash.animations, direction);
			var framerate:Int = Std.int(Math.max(1, style.noteSplash.framerate));

			addAnimation(direction.name, frames, framerate, false);
		}

		animation.onFinish.add(_ -> kill());
	}

	public function play(strum:StrumSprite)
	{
		this.strum = strum;

		if (graphic == null)
			kill();

		playAnimation(strum.direction.name);
	}

	override public function draw()
	{
		if (strum != null)
		{
			x = strum.x + (strum.width - width) / 2;
			y = strum.y + (strum.height - height) / 2;
		}

		super.draw();
	}

	override public function revive()
	{
		super.revive();

		strum = null;
	}
}

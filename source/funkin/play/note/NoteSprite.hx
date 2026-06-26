package funkin.play.note;

import funkin.data.song.SongData.SongNoteData;
import funkin.graphics.FunkinSprite;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.play.note.strum.StrumSprite;
import funkin.util.RhythmUtil;

/**
 * A `FunkinSprite` used as a note for a `Strumline`.
 */
class NoteSprite extends FunkinSprite
{
	public var time:Float;
	public var direction(default, set):NoteDirection;
	public var kind:String;

	public var mayHit:Bool;
	public var willMiss:Bool;
	public var wasMissed:Bool;

	public var holdNote:HoldNoteSprite;
	public var strum:StrumSprite;

	public var data:SongNoteData;
	public var speed:Float;

	public var isPlayer(get, never):Bool;
	public var distance(get, never):Float;

	public function buildSprite(style:Style)
	{
		loadSprite(style.getNote('image'), style.note.scale, style.note.width, style.note.height);

		for (i in 0...Constants.NOTE_COUNT)
		{
			var direction:NoteDirection = NoteDirection.fromInt(i);
			var frame:Int = direction + Constants.NOTE_COUNT * 3;

			addAnimation(direction.name, [frame]);
		}

		this.direction = direction;
		this.active = false;
	}

	override public function draw()
	{
		if (strum != null)
		{
			x = strum.x;
			y = strum.y + distance * (Preferences.downscroll ? -1 : 1);
		}

		super.draw();
	}

	override public function revive()
	{
		super.revive();

		time = 0;
		direction = LEFT;
		kind = '';

		mayHit = false;
		willMiss = false;
		wasMissed = false;

		holdNote = null;
		strum = null;

		data = null;
	}

	@:noCompletion
	inline function set_direction(value:NoteDirection):NoteDirection
	{
		value %= Constants.NOTE_COUNT;

		this.direction = value;

		playAnimation(value.name);

		return value;
	}

	@:noCompletion
	inline function get_isPlayer():Bool
	{
		return data.d < Constants.NOTE_COUNT;
	}

	@:noCompletion
	inline function get_distance():Float
	{
		return RhythmUtil.getDistance(time, speed);
	}
}

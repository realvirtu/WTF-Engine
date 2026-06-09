package funkin.play.note.hold;

import flixel.FlxStrip;
import funkin.data.song.SongData.SongNoteData;

/**
 * A sprite used as a sustain note that the player must hold.
 */
class HoldNoteSprite extends FlxStrip
{
	final HOLD_HEIGHT:Int = 1;

	public var time:Float;
	public var direction(default, set):NoteDirection;
	public var kind:String;
	public var length(default, set):Float;
	public var speed(default, set):Float;

	public var fullLength:Float;
	public var wasHit:Bool;

	public var data:SongNoteData;

	public var isPlayer(get, never):Bool;

	var holdHeight:Float;
	var endHeight:Float;

	var graphicWidth:Float;
	var graphicHeight:Float;

	public function new()
	{
		super();

		active = false;

		// Sets the indices
		// This doesn't need to be changed at all
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 1;
		indices[4] = 3;
		indices[5] = 2;
		indices[6] = 4;
		indices[7] = 5;
		indices[8] = 6;
		indices[9] = 5;
		indices[10] = 7;
		indices[11] = 6;
	}

	public function buildSprite(style:Style)
	{
		loadGraphic(Paths.image(style.getNote('hold/image')));
		setGraphicSize(Std.int(width * Constants.ZOOM * style.note.scale));
		updateHitbox();

		graphicWidth = graphic?.width;
		graphicHeight = graphic?.height;
	}

	public function redraw()
	{
		holdHeight = length * Constants.PIXELS_PER_MS * speed;
		endHeight = (graphicHeight - HOLD_HEIGHT) * scale.y;

		var endClip:Float = Math.min(0, holdHeight - endHeight);
		var flipOff:Float = flipY ? holdHeight : 0;
		var flip:Int = flipY ? -1 : 1;

		// Order:
		// Top left, top right, bottom left, bottom right

		// Hold
		vertices[0] = 0;
		vertices[1] = flipOff;
		vertices[2] = graphicWidth * scale.x / Constants.NOTE_COUNT;
		vertices[3] = vertices[1];
		vertices[4] = vertices[0];
		vertices[5] = Math.max(0, holdHeight - endHeight) * flip + flipOff;
		vertices[6] = vertices[2];
		vertices[7] = vertices[5];

		uvtData[0] = direction / Constants.NOTE_COUNT;
		uvtData[1] = 0;
		uvtData[2] = (direction + 1) / Constants.NOTE_COUNT;
		uvtData[3] = uvtData[1];
		uvtData[4] = uvtData[0];
		uvtData[5] = HOLD_HEIGHT / graphicHeight;
		uvtData[6] = uvtData[2];
		uvtData[7] = uvtData[5];

		// End
		vertices[8] = vertices[4];
		vertices[9] = vertices[5];
		vertices[10] = vertices[6];
		vertices[11] = vertices[9];
		vertices[12] = vertices[8];
		vertices[13] = vertices[9] + (endHeight + endClip) * flip;
		vertices[14] = vertices[10];
		vertices[15] = vertices[13];

		uvtData[8] = uvtData[0];
		uvtData[9] = uvtData[5] - endClip / scale.y / graphicHeight;
		uvtData[10] = uvtData[2];
		uvtData[11] = uvtData[9];
		uvtData[12] = uvtData[8];
		uvtData[13] = 0.99;
		uvtData[14] = uvtData[10];
		uvtData[15] = uvtData[13];

		updateHitbox();
	}

	override public function updateHitbox()
	{
		width = graphicWidth * scale.x / Constants.NOTE_COUNT;
		height = holdHeight;
		offset.set(0, flipY ? height : 0);
		origin.set();
	}

	override public function revive()
	{
		super.revive();

		time = 0;
		direction = LEFT;
		kind = '';
		length = 0;
		speed = 0;

		fullLength = 0;
		wasHit = false;

		data = null;

		holdHeight = 0;
		endHeight = 0;
	}

	@:noCompletion
	function set_direction(value:NoteDirection):NoteDirection
	{
		value %= Constants.NOTE_COUNT;

		if (this.direction == value)
			return value;
		this.direction = value;

		redraw();

		return value;
	}

	@:noCompletion
	function set_length(value:Float):Float
	{
		value = Math.max(0, value);

		if (this.length == value)
			return value;
		this.length = value;

		redraw();

		return value;
	}

	@:noCompletion
	function set_speed(value:Float):Float
	{
		if (this.speed == value)
			return value;
		this.speed = value;

		redraw();

		return value;
	}

	@:noCompletion
	override function set_flipY(value:Bool):Bool
	{
		if (this.flipY == value)
			return super.set_flipY(value);
		this.flipY = super.set_flipY(value);

		redraw();

		return value;
	}

	@:noCompletion
	inline function get_isPlayer():Bool
	{
		return data.d < Constants.NOTE_COUNT;
	}
}

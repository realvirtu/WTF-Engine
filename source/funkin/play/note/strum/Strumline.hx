package funkin.play.note.strum;

import flixel.group.FlxGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import funkin.data.song.SongData;
import funkin.play.note.hold.HoldNoteCover;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.util.RhythmUtil;
import funkin.util.SortUtil;

/**
 * An `FlxGroup` containing strums and notes.
 */
class Strumline extends FlxGroup
{
	public var isPlayer:Bool;

	public var data:Array<SongNoteData> = [];
	public var speed(default, set):Float;

	public var x(default, set):Float;

	public var strums:FlxTypedGroup<StrumSprite>;
	public var notes:FlxTypedGroup<NoteSprite>;
	public var holdNotes:FlxTypedGroup<HoldNoteSprite>;
	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	public var holdCovers:FlxTypedGroup<HoldNoteCover>;

	public var noteMiss(default, null) = new FlxTypedSignal<NoteSprite->Void>();
	public var holdNoteHit(default, null) = new FlxTypedSignal<HoldNoteSprite->Void>();
	public var holdNoteDrop(default, null) = new FlxTypedSignal<HoldNoteSprite->Void>();

	var dirty:Bool = false;
	var style:Style;

	public function new(style:Style, isPlayer:Bool)
	{
		super();

		this.style = style;
		this.isPlayer = isPlayer;

		strums = new FlxTypedGroup<StrumSprite>();
		add(strums);

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		add(noteSplashes);

		holdNotes = new FlxTypedGroup<HoldNoteSprite>();
		add(holdNotes);

		holdCovers = new FlxTypedGroup<HoldNoteCover>();
		add(holdCovers);

		notes = new FlxTypedGroup<NoteSprite>();
		add(notes);

		// Builds the strums
		for (direction in 0...Constants.NOTE_COUNT)
		{
			var strum:StrumSprite = new StrumSprite(direction);
			strum.buildSprite(style);
			strums.add(strum);
		}

		refresh();
	}

	public function process()
	{
		// Spawns the notes
		while (data[0] != null)
		{
			var noteData:SongNoteData = data[0];
			var time:Float = noteData.t;
			var direction:NoteDirection = NoteDirection.fromInt(noteData.d);
			var kind:String = noteData.k;
			var length:Float = noteData.l;

			if (RhythmUtil.getDistance(time, speed) > FlxG.height)
				break;

			// Skip the note if it's in the past
			if (RhythmUtil.getDistance(time, speed) < 0)
			{
				data.shift();
				break;
			}

			// Creates a note
			var note:NoteSprite = notes.recycle(NoteSprite);

			if (note.graphic == null)
				note.buildSprite(style);

			note.y = -9999;

			note.time = time;
			note.direction = direction;
			note.kind = kind;
			note.data = noteData;

			// Creates a hold note
			// However, its length has to be lengthy enough to be considered length
			if (length > 25)
			{
				var holdNote:HoldNoteSprite = holdNotes.recycle(HoldNoteSprite);

				if (holdNote.graphic == null)
					holdNote.buildSprite(style);

				holdNote.y = -9999;

				holdNote.time = time;
				holdNote.direction = direction;
				holdNote.kind = kind;
				holdNote.length = length;
				holdNote.fullLength = length;

				holdNote.flipY = Preferences.downscroll;
				holdNote.data = noteData;
				holdNote.speed = speed;

				note.holdNote = holdNote;
			}

			// Sorts the notes
			// Not doing this will mess up the input
			notes.sort((i, a, b) -> return SortUtil.byTime(FlxSort.ASCENDING, a.data, b.data));
			holdNotes.sort((i, a, b) -> return SortUtil.byTime(FlxSort.ASCENDING, a.data, b.data));

			data.shift();
		}

		// Note processing
		notes.forEachAlive(note ->
		{
			var strum:StrumSprite = getStrum(note.direction);
			var distance:Float = RhythmUtil.getDistance(note.time, speed);

			// Positions the note
			note.x = strum.x;
			note.y = strum.y + distance * (Preferences.downscroll ? -1 : 1);

			if (distance <= -strum.y - note.height && note.wasMissed)
				note.kill();

			RhythmUtil.processHitWindow(note, isPlayer);

			// Miss the note if the note misses
			// No shit lol
			if (note.willMiss && !note.wasMissed)
			{
				note.wasMissed = true;
				noteMiss.dispatch(note);
			}
		});

		// Hold note processing
		holdNotes.forEachAlive(holdNote ->
		{
			var strum:StrumSprite = getStrum(holdNote.direction);
			var distance:Float = RhythmUtil.getDistance(holdNote.time, speed);
			var y:Float = strum.y + strum.height / 2;

			// Positions the hold note
			holdNote.x = strum.x + (strum.width - holdNote.width) / 2;
			holdNote.y = y + distance * (Preferences.downscroll ? -1 : 1);

			if (distance <= -y - holdNote.height && !holdNote.wasHit)
				holdNote.kill();

			// Hold note input
			if (holdNote.wasHit)
			{
				// Drops the hold note
				if (!holdNote.direction.pressed && isPlayer && holdNote.length > 100 && !dirty)
				{
					holdNote.kill();
					holdNoteDrop.dispatch(holdNote);
					return;
				}

				getStrum(holdNote.direction).playConfirm();

				holdNote.length = holdNote.time - Conductor.instance.time + holdNote.fullLength;
				holdNote.y = y;

				holdNoteHit.dispatch(holdNote);

				// Kill the hold note if it's short enough
				if (holdNote.length <= 10)
					holdNote.kill();
			}
		});

		// Strum processing
		strums.forEach(strum ->
		{
			final pressed:Bool = strum.direction.pressed;

			if (strum.confirmTime > 0 || dirty)
				return;

			if (pressed && isPlayer)
				strum.playPress();
			else
				strum.playStatic();
		});
	}

	public function updateScroll()
	{
		dirty = true;

		strums.forEach(strum ->
		{
			strum.y = 60;

			if (Preferences.downscroll)
				strum.y = FlxG.height - strum.height - strum.y;
		});

		holdNotes.forEachAlive(holdNote -> holdNote.flipY = Preferences.downscroll);

		noteSplashes.forEachAlive(splash -> splash.updatePosition());
		holdCovers.forEachAlive(cover -> cover.updatePosition());

		process();

		dirty = false;
	}

	public function load(notes:Array<SongNoteData>, speed:Float)
	{
		// Notes NEED to be sorted
		notes.sort(SortUtil.byTime.bind(FlxSort.ASCENDING));

		this.data = notes;
		this.speed = speed;
	}

	public function hitNote(note:NoteSprite)
	{
		getStrum(note.direction).playConfirm();

		if (note.holdNote != null)
		{
			note.holdNote.wasHit = true;

			// Plays the hold cover here because this runs once
			playHoldCover(note.holdNote);
		}

		note.kill();
	}

	public function playSplash(direction:NoteDirection)
	{
		var splash:NoteSplash = noteSplashes.recycle(NoteSplash);
		var strum:StrumSprite = getStrum(direction);

		if (splash.graphic == null)
			splash.buildSprite(style);

		splash.play(strum);
	}

	public function playHoldCover(holdNote:HoldNoteSprite)
	{
		var cover:HoldNoteCover = holdCovers.recycle(HoldNoteCover);
		var strum:StrumSprite = getStrum(holdNote.direction);

		if (cover.graphic == null)
			cover.buildSprite(style);

		cover.play(holdNote, strum);
	}

	public function clean()
	{
		// Kill instead of destroy because of recycling
		notes.killMembers();
		holdNotes.killMembers();
		noteSplashes.killMembers();
		holdCovers.killMembers();

		// Clears the note data because we're cleaning, aren't we?
		data = [];
		speed = 0;
	}

	public function getMayHitNotes():Array<NoteSprite>
	{
		return notes.members.filter(note -> return note.alive && note.mayHit && !note.willMiss);
	}

	public function getStrum(direction:NoteDirection):StrumSprite
	{
		return strums.members[direction];
	}

	@:noCompletion
	function set_speed(value:Float):Float
	{
		value = Math.max(0, value);

		if (this.speed == value)
			return value;
		this.speed = value;

		holdNotes.forEachAlive(holdNote -> holdNote.speed = value);

		return value;
	}

	@:noCompletion
	inline function set_x(value:Float):Float
	{
		this.x = value;

		strums.forEach(strum ->
		{
			var off:Float = (strum.direction - Constants.NOTE_COUNT / 2);
			var spacing:Float = 2;

			strum.x = value + off * (strum.width + spacing);
			strum.x += spacing / 2;
		});

		return value;
	}
}

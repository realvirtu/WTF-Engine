package funkin.play.note.strum;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import funkin.data.song.SongData;
import funkin.graphics.FunkinSprite;
import funkin.play.note.hold.HoldNoteCover;
import funkin.play.note.hold.HoldNoteSprite;
import funkin.util.RhythmUtil;
import funkin.util.SortUtil;

/**
 * An `FlxGroup` containing strums and notes.
 */
class Strumline extends FlxGroup
{
	public var style(default, set):NoteStyle;
	public var isPlayer:Bool;

	public var data:Array<SongNoteData> = [];
	public var speed:Float;

	public var x(get, set):Float;

	public var bg:FunkinSprite;
	public var strums:FlxTypedSpriteGroup<StrumSprite>;
	public var notes:FlxTypedGroup<NoteSprite>;
	public var holdNotes:FlxTypedGroup<HoldNoteSprite>;
	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	public var holdCovers:FlxTypedGroup<HoldNoteCover>;

	public var noteIncoming(default, null) = new FlxTypedSignal<NoteSprite->Void>();

	var nextNoteIndex:Int;

	public function new(style:NoteStyle, isPlayer:Bool)
	{
		super();

		bg = FunkinSprite.createSolidColor(0, 0, 1, 1, 0xFF000000);
		bg.alpha = 0;
		add(bg);

		strums = new FlxTypedSpriteGroup<StrumSprite>();
		add(strums);

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		add(noteSplashes);

		holdNotes = new FlxTypedGroup<HoldNoteSprite>();
		add(holdNotes);

		holdCovers = new FlxTypedGroup<HoldNoteCover>();
		add(holdCovers);

		notes = new FlxTypedGroup<NoteSprite>();
		add(notes);

		for (direction in 0...Constants.NOTE_COUNT)
			strums.add(new StrumSprite(direction, isPlayer));

		this.style = style;
		this.isPlayer = isPlayer;
	}

	public function process()
	{
		// Spawns the notes
		for (i in nextNoteIndex...data.length)
		{
			final noteData:SongNoteData = data[i];
			final distance:Float = RhythmUtil.getDistance(noteData?.t, speed);

			// Skip the note if it's null
			if (noteData == null || distance < 0)
			{
				nextNoteIndex = i + 1;
				continue;
			}

			// The note is too far away to spawn
			if (distance > FlxG.height)
				break;

			var note:NoteSprite = buildNote(noteData);

			if (noteData.l > 25)
				note.holdNote = buildHoldNote(noteData);

			nextNoteIndex = i + 1;
			noteIncoming.dispatch(note);
		}

		// Note processing
		notes.forEachAlive(note ->
		{
			final strum:StrumSprite = getStrum(note.direction);
			final distance:Float = RhythmUtil.getDistance(note.time, speed);

			note.x = strum.x;
			note.y = strum.y + distance * (Preferences.downscroll ? -1 : 1);

			final isOffscreen:Bool = Preferences.downscroll ? note.y > FlxG.height : note.y < -note.height;

			if (isOffscreen && (note.wasMissed || note.wasHit))
				note.kill();

			RhythmUtil.processHitWindow(note, isPlayer);
		});

		// Hold note processing
		holdNotes.forEachAlive(holdNote ->
		{
			final strum:StrumSprite = getStrum(holdNote.direction);
			final distance:Float = RhythmUtil.getDistance(holdNote.time, speed);

			holdNote.x = strum.x + (strum.width - holdNote.width) / 2;
			holdNote.y = strum.middle + distance * (Preferences.downscroll ? -1 : 1);

			holdNote.flipY = Preferences.downscroll;
			holdNote.speed = speed;

			if (holdNote.wasHit)
			{
				holdNote.y = strum.middle;
				holdNote.length = holdNote.time - Conductor.instance.time + holdNote.fullLength;

				getStrum(holdNote.direction).playConfirm();

				if (holdNote.length <= 10)
					holdNote.kill();
			}

			final isOffscreen:Bool = Preferences.downscroll ? holdNote.y > FlxG.height + holdNote.height : holdNote.y < -holdNote.height;

			if (isOffscreen && (holdNote.wasMissed || holdNote.wasHit))
				holdNote.kill();
		});
	}

	public function updateScroll()
	{
		strums.y = 50;

		if (Preferences.downscroll)
			strums.y = FlxG.height - strums.height - strums.y;

		bg.alpha = Preferences.strumBGOpacity / 100;

		process();
	}

	public function load(notes:Array<SongNoteData>, speed:Float)
	{
		// Notes NEED to be sorted
		notes.sort(SortUtil.byTime.bind(FlxSort.ASCENDING));

		nextNoteIndex = 0;

		this.data = notes;
		this.speed = speed;
	}

	public function hitNote(note:NoteSprite, removeNote:Bool = true)
	{
		getStrum(note.direction).playConfirm();

		note.wasHit = true;

		if (removeNote)
			note.kill();
		else
			note.alpha = 0.5;

		if (note.holdNote != null)
		{
			note.holdNote.wasHit = true;

			// Plays the hold cover here because this runs once
			playHoldCover(note.holdNote);
		}
	}

	public function missNote(note:NoteSprite)
	{
		note.wasMissed = true;

		if (note.holdNote != null)
			note.holdNote.wasMissed = true;
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

		nextNoteIndex = -1;

		// Resets the strum animations
		// No more unwanted strum glow :3
		strums.forEach(strum ->
		{
			strum.confirmTime = 0;
			strum.playStatic();
		});
	}

	public function getCurrentNotes():Array<NoteSprite>
	{
		return notes.members.filter(note -> return note.alive);
	}

	public function getCurrentHoldNotes():Array<HoldNoteSprite>
	{
		return holdNotes.members.filter(holdNote -> return holdNote.alive);
	}

	public function getMayHitNotes():Array<NoteSprite>
	{
		return getCurrentNotes().filter(note -> return note.mayHit && !note.wasHit && !note.willMiss);
	}

	public function getMissedNotes():Array<NoteSprite>
	{
		return getCurrentNotes().filter(note -> return !note.wasHit && note.willMiss && !note.wasMissed);
	}

	public function getHeldHoldNotes():Array<HoldNoteSprite>
	{
		return getCurrentHoldNotes().filter(holdNote -> return holdNote.wasHit);
	}

	public function getStrum(direction:NoteDirection):StrumSprite
	{
		return strums.members[direction];
	}

	function buildNote(data:SongNoteData):NoteSprite
	{
		var note:NoteSprite = notes.recycle(NoteSprite);

		if (note.graphic == null)
			note.buildSprite(style);

		note.y = 9999;
		note.alpha = 1;
		note.data = data;

		notes.sort((i, a, b) -> return SortUtil.byTime(FlxSort.ASCENDING, a.data, b.data));

		return note;
	}

	function buildHoldNote(data:SongNoteData):HoldNoteSprite
	{
		var holdNote:HoldNoteSprite = holdNotes.recycle(HoldNoteSprite);

		if (holdNote.graphic == null)
			holdNote.buildSprite(style);

		holdNote.y = 9999;
		holdNote.data = data;
		holdNote.speed = speed;

		holdNotes.sort((i, a, b) -> return SortUtil.byTime(FlxSort.ASCENDING, a.data, b.data));

		return holdNote;
	}

	@:noCompletion
	inline function set_style(value:NoteStyle):NoteStyle
	{
		if (style == value)
			return style;

		style = value;

		strums.forEach(strum ->
		{
			strum.buildSprite(style);
			strum.x = strums.x + (strum.direction - Constants.NOTE_COUNT / 2) * strum.width;
		});

		notes.forEach(note -> note.buildSprite(style));
		holdNotes.forEach(holdNote -> holdNote.buildSprite(style));

		noteSplashes.forEach(splash -> splash.buildSprite(style));
		holdCovers.forEach(cover -> cover.buildSprite(style));

		bg.setGraphicSize(strums.width + 20, FlxG.height);
		bg.updateHitbox();

		return style;
	}

	@:noCompletion
	inline function set_x(value:Float):Float
	{
		strums.x = value;
		bg.x = strums.x - bg.width / 2;

		return strums.x;
	}

	@:noCompletion
	inline function get_x():Float
	{
		return strums.x;
	}
}

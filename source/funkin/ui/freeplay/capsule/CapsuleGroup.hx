package funkin.ui.freeplay.capsule;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.audio.FunkinSound;
import funkin.data.song.SongRegistry;
import funkin.input.Controls;
import funkin.play.song.Song;
import funkin.util.MathUtil;

/**
 * A group of song capsules used for the freeplay menu.
 */
class CapsuleGroup extends FlxTypedGroup<CapsuleSprite>
{
	public var selected:Int;

	public var capsule(get, never):CapsuleSprite;
	public var song(get, never):Song;
	public var size(get, never):Int;

	public var busy:Bool = false;
	public var lerp:Bool = true;

	public var onChanged(default, null) = new FlxTypedSignal<Int->Void>();

	var justLoaded:Bool = true;

	public function new(selected:Int = 1)
	{
		super();

		this.selected = selected;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var up:Bool = Controls.instance.UI_UP_P;
		var down:Bool = Controls.instance.UI_DOWN_P;

		if ((up || down) && !busy)
			change(up ? -1 : 1);

		forEachAlive(capsule ->
		{
			if (lerp)
			{
				capsule.x = MathUtil.lerp(capsule.x, getCapsuleX(capsule), 0.2);
				capsule.y = MathUtil.lerp(capsule.y, getCapsuleY(capsule), 0.2);
			}
			capsule.selected = capsule.ID == selected;
		});
	}

	public function change(change:Int)
	{
		final lastSelected:Int = selected;

		selected += change;

		if (selected < 0)
			selected = size - 1;
		else if (selected >= size)
			selected = 0;

		if (selected != lastSelected && change != 0)
		{
			FunkinSound.playOnce('general/sounds/scroll');

			onChanged.dispatch(selected);
		}
	}

	public function load(songs:Array<String>, diff:String)
	{
		killMembers();

		// Builds the Random capsule
		buildCapsuleSprite(null, diff, 0);

		var prevSong:Song = song;

		if (selected > songs.length)
			selected = songs.length;

		for (i => song in songs)
		{
			var song:Song = SongRegistry.instance.fetchSong(song, diff);
			var id:Int = i + 1;

			if (prevSong?.id == song.id)
				selected = id;

			buildCapsuleSprite(song, diff, id);
		}

		// Snaps the capsules into place
		// Because ew yucky lerp
		forEachAlive(capsule ->
		{
			capsule.x = getCapsuleX(capsule);
			capsule.y = getCapsuleY(capsule);

			if (!justLoaded)
				capsule.x += 200;
		});

		justLoaded = false;
	}

	function buildCapsuleSprite(song:Song, diff:String, index:Int):CapsuleSprite
	{
		var capsule:CapsuleSprite = recycle(CapsuleSprite);

		capsule.ID = index;

		capsule.song = song;
		capsule.difficulty = diff;

		return capsule;
	}

	function getCapsuleX(capsule:CapsuleSprite):Float
	{
		return FlxG.width / 2 - 200 + Math.sin(capsule.ID - selected) * 50;
	}

	function getCapsuleY(capsule:CapsuleSprite):Float
	{
		return 200 + (capsule.height + 10) * (capsule.ID - selected);
	}

	@:noCompletion
	inline function get_capsule():CapsuleSprite
	{
		return members[selected];
	}

	@:noCompletion
	function get_song():Song
	{
		return capsule?.song;
	}

	@:noCompletion
	inline function get_size():Int
	{
		return countLiving();
	}
}

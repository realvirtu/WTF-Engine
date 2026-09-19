package funkin.play.character;

import flixel.math.FlxPoint;
import funkin.data.character.CharacterData;
import funkin.data.character.CharacterRegistry;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.play.note.NoteDirection;
import funkin.play.stage.StageProp;
import haxe.ds.StringMap;

/**
 * A `StageProp` that sings and bops and all that.
 */
class Character extends StageProp implements IPlayStateScriptedClass
{
	static final MAX_SING_TIME:Float = 1;

	public var meta:CharacterData;
	public var type:CharacterType;

	public var singDuration:Float;
	public var singTimer:Float;

	public var isBopping(get, never):Bool;
	public var isSinging(get, never):Bool;
	public var isMissing(get, never):Bool;

	public var animOffsets(default, null) = new StringMap<Array<Float>>();
	public var globalOffset(get, never):Array<Float>;

	var dropAnimCounts:Array<Int> = [];

	var charPath(get, never):String;

	public function buildSprite()
	{
		if (meta == null)
			return;

		loadSprite('$charPath/image', meta.scale, meta.width, meta.height);

		buildAnimations();
		updateOffset();

		flipX = meta.flipX != (type == PLAYER);
		flipY = meta.flipY;

		bopEvery = meta.bopEvery;

		singDuration = meta.singDuration;
		singTimer = MAX_SING_TIME;

		bop(true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		final singSeconds:Float = MAX_SING_TIME / (Conductor.instance.quaver / Constants.MS_PER_SEC * singDuration);

		singTimer = Math.min(MAX_SING_TIME, singTimer + elapsed * singSeconds);
	}

	override function bop(force:Bool = false)
	{
		if (singTimer < MAX_SING_TIME && !force)
			return;

		// Recreates that cool ass sing hold thing that the player can do
		if (type == PLAYER && NoteDirection.anyPressed() && isSinging)
			return;

		super.bop(force);
	}

	public function sing(direction:NoteDirection, suffix:String = '')
	{
		if (flipX && direction.horizontal)
			direction = direction.inverse;
		playAnimation('${direction.name}$suffix', true);
	}

	public function miss(direction:NoteDirection, suffix:String = '')
	{
		if (flipX && direction.horizontal)
			direction = direction.inverse;
		playAnimation('${direction.name}-miss$suffix', true);
	}

	public function combo(combo:Int)
	{
		playAnimation('combo$combo', true);
	}

	public function drop(combo:Int)
	{
		var count:Int = 0;

		for (num in dropAnimCounts)
		{
			if (combo >= num && num > count)
				count = num;
		}

		playAnimation('drop$count');
	}

	public function updateOffset()
	{
		final animOffset:Array<Float> = animOffsets.get(getCurrentAnimation()) ?? [0, 0];

		offset.set(-globalOffset[0], -globalOffset[1]);
		offset.subtract(animOffset[0], animOffset[1]);
	}

	public function getCameraPosition():Array<Float>
	{
		final pos:FlxPoint = getGraphicMidpoint();
		final offset:Array<Float> = meta.cameraOffset ?? [0, 0];

		if (flipX)
			offset[0] = -offset[0];

		return [pos.x + offset[0], pos.y + offset[1]];
	}

	function buildAnimations()
	{
		if (frames == null)
			return;

		// Loads the sprites
		var numFrames:Array<Int> = [];

		for (image in meta.images)
		{
			final name:String = image.name;
			final path:String = '$charPath/images/$name';

			numFrames.push(frames.numFrames);

			loadFrames(path, image.width, image.height, name);
		}

		// Adds the actual animations
		for (anim in meta.animations)
		{
			if (anim == null)
				continue;

			final name:String = anim.name;
			final index:Int = numFrames[images.indexOf(anim.image)];

			addAnimation(name, [for (frame in anim.frames) frame + index], anim.framerate, anim.looped);

			animOffsets.set(name, anim.offset);

			// This is mainly for the GF character
			// Because GF plays a drop animation when you lose your combo
			if (name.startsWith('drop'))
				dropAnimCounts.push(Std.parseInt(name.substr('drop'.length)));
		}
	}

	override function playAnimation(name:String, force:Bool = false)
	{
		if (!hasAnimation(name))
			return;

		super.playAnimation(name, force);

		updateOffset();

		if (!isBopping)
			singTimer = 0;
	}

	override function onNoteHit(event:NoteScriptEvent)
	{
		super.onNoteHit(event);

		if (event.cancelled)
			return;

		switch (type)
		{
			case OPPONENT | PLAYER:
				if (type == PLAYER == event.note.isPlayer && event.playAnimation)
					sing(event.note.direction, event.suffix);
			case GF:
				combo(event.combo);
			default:
				// Does literally nothing
		}
	}

	override function onNoteMiss(event:NoteScriptEvent)
	{
		super.onNoteMiss(event);

		if (event.cancelled)
			return;

		switch (type)
		{
			case PLAYER:
				if (event.playAnimation)
					miss(event.note.direction, event.suffix);
			case GF:
				drop(event.combo);
			default:
				// Does literally nothing
		}
	}

	override function onHoldNoteHold(event:HoldNoteScriptEvent)
	{
		super.onHoldNoteHold(event);

		if (event.cancelled)
			return;

		switch (type)
		{
			case OPPONENT | PLAYER:
				if (type == PLAYER == event.holdNote.isPlayer && event.playAnimation && !isBopping)
					singTimer = 0;
			default:
				// Does literally nothing
		}
	}

	override function onHoldNoteDrop(event:HoldNoteScriptEvent)
	{
		super.onHoldNoteDrop(event);

		if (event.cancelled || !event.playAnimation || type != PLAYER)
			return;

		miss(event.holdNote.direction, event.suffix);
	}

	override function onGhostMiss(event:GhostMissScriptEvent)
	{
		super.onGhostMiss(event);

		if (event.cancelled || !event.playAnimation || type != PLAYER)
			return;

		miss(event.direction, event.suffix);
	}

	override function onSongRetry(event:ScriptEvent)
	{
		super.onSongRetry(event);

		singTimer = MAX_SING_TIME;

		// Force the bopping animation
		// This is honestly better than staying in a singing animation
		bop(true);
	}

	@:noCompletion
	inline function get_isBopping():Bool
	{
		return getCurrentAnimation() == 'idle';
	}

	@:noCompletion
	inline function get_isSinging():Bool
	{
		final name:String = getCurrentAnimation();

		return (name.startsWith(NoteDirection.LEFT.name)
			|| name.startsWith(NoteDirection.DOWN.name)
			|| name.startsWith(NoteDirection.UP.name)
			|| name.startsWith(NoteDirection.RIGHT.name))
			&& !name.endsWith('-miss');
	}

	@:noCompletion
	inline function get_isMissing():Bool
	{
		return getCurrentAnimation().endsWith('-miss');
	}

	@:noCompletion
	inline function get_globalOffset():Array<Float>
	{
		return meta.globalOffset;
	}

	@:noCompletion
	inline function get_charPath():String
	{
		return '${CharacterRegistry.instance.path}/$id';
	}
}

package funkin.play.character;

import funkin.data.character.CharacterData;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.play.note.NoteDirection;
import funkin.play.stage.StageProp;

/**
 * A `StageProp` that sings and bops and all that.
 */
class Character extends StageProp implements IPlayStateScriptedClass
{
	final MAX_SING_TIME:Float = 1;

	public var meta:CharacterData;
	public var type:CharacterType;

	public var bopping(get, never):Bool;
	public var singing(get, never):Bool;
	public var missing(get, never):Bool;

	// Flixel is so fucking stupid
	// Why does path HAVE to be an already existing variable?!
	public var charPath(get, never):String;

	var singTimer:Float;

	public function buildSprite()
	{
		if (meta == null)
			return;

		// Loads the image
		loadSprite('$charPath/image', meta.scale, meta.width, meta.height);
		loadAnimations(meta.animations);

		bopEvery = meta.bopEvery;

		flipX = meta.flipX != (type == Player);
		flipY = meta.flipY;

		offset.set(-meta.globalOffset[0] ?? 0, -meta.globalOffset[1] ?? 0);

		singTimer = MAX_SING_TIME;

		bop();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		singTimer = Math.min(MAX_SING_TIME, singTimer + elapsed * (Conductor.instance.quaver / 5 / meta.singDuration));
	}

	override public function bop(force:Bool = false)
	{
		if (singTimer < MAX_SING_TIME && !force)
			return;

		// Recreates that cool ass sing hold thing that the player can do
		if (type == Player && NoteDirection.anyPressed() && singing)
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

	public function resetSingTimer()
	{
		if (getCurrentAnimation() == 'idle')
			return;
		singTimer = 0;
	}

	public function buildHealthIcon():HealthIcon
	{
		// Return null if icon data is lacking
		// The god damn errors this would give >:(
		if (meta.icon == null)
			return null;
		return new HealthIcon(id, meta.icon, type == Player);
	}

	override public function playAnimation(name:String, force:Bool = false)
	{
		super.playAnimation(name, force);

		// Resets the sing timer
		resetSingTimer();
	}

	@:noCompletion
	inline function get_charPath():String
	{
		return 'play/characters/$id';
	}

	@:noCompletion
	inline function get_bopping():Bool
	{
		return getCurrentAnimation() == 'idle';
	}

	@:noCompletion
	inline function get_singing():Bool
	{
		return [
			NoteDirection.LEFT.name,
			NoteDirection.DOWN.name,
			NoteDirection.UP.name,
			NoteDirection.RIGHT.name
		].contains(getCurrentAnimation());
	}

	@:noCompletion
	inline function get_missing():Bool
	{
		return getCurrentAnimation().endsWith('-miss');
	}

	override public function onNoteHit(event:NoteScriptEvent)
	{
		super.onNoteHit(event);

		if (event.cancelled || !event.playAnimation || type == Player != event.note.isPlayer || type == Other)
			return;

		sing(event.note.direction, event.suffix);
	}

	override public function onNoteMiss(event:NoteScriptEvent)
	{
		super.onNoteMiss(event);

		if (event.cancelled || !event.playAnimation || type != Player)
			return;

		miss(event.note.direction, event.suffix);
	}

	override public function onHoldNoteHold(event:HoldNoteScriptEvent)
	{
		super.onHoldNoteHold(event);

		if (event.cancelled || !event.playAnimation || type == Player != event.holdNote.isPlayer || type == Other)
			return;

		resetSingTimer();
	}

	override public function onHoldNoteDrop(event:HoldNoteScriptEvent)
	{
		super.onHoldNoteDrop(event);

		if (event.cancelled || !event.playAnimation || type != Player)
			return;

		miss(event.holdNote.direction, event.suffix);
	}

	override public function onGhostMiss(event:GhostMissScriptEvent)
	{
		super.onGhostMiss(event);

		if (event.cancelled || !event.playAnimation || type != Player)
			return;

		miss(event.direction, event.suffix);
	}

	override public function onSongRetry(event:ScriptEvent)
	{
		super.onSongRetry(event);

		singTimer = MAX_SING_TIME;

		// Force the bopping animation
		// This is honestly better than staying in a singing animation
		bop();
	}
}

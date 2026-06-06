package funkin.ui.freeplay.capsule;

import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.play.song.Song;
import funkin.save.Save;

/**
 * The song capsule sprite used for the freeplay menu.
 */
class CapsuleSprite extends FlxSpriteGroup
{
	public var song(default, set):Song;
	public var difficulty(default, set):String;

	public var selected(default, set):Bool = true;
	public var favorited(default, set):Bool = false;

	var clipWidth(get, never):Float;
	var canMoveText(get, never):Bool;

	var justLoaded:Bool;
	var moveTween:FlxTween;

	var capsule:FunkinSprite;
	var songText:FunkinText;
	var bpmText:CapsuleText;
	var diffText:CapsuleText;
	var ratingText:CapsuleText;
	var heart:FunkinSprite;

	override public function new()
	{
		super();

		capsule = FunkinSprite.create(0, 0, 'ui/freeplay/capsule/capsule');
		capsule.active = false;
		add(capsule);

		songText = new FunkinText(33, 36.5, 'what the song');
		songText.autoBounds = false;
		songText.size = 20;
		songText.clipRect = new FlxRect(0, 0, 0, songText.frameHeight);
		add(songText);

		bpmText = new CapsuleText(35, 0, '100');
		bpmText.y = capsule.height - bpmText.height - 15;
		add(bpmText);

		diffText = new CapsuleText(0, bpmText.y, 'diff');
		diffText.x = capsule.width - diffText.width - 20;
		add(diffText);

		ratingText = new CapsuleText(0, songText.y - 6, '00');
		ratingText.size = 30;
		ratingText.x = capsule.width - ratingText.width - 17;
		add(ratingText);

		heart = FunkinSprite.create(0, songText.y - 2, 'ui/freeplay/capsule/heart');
		heart.x = capsule.width - heart.width - 85;
		heart.active = false;
		heart.visible = false;
		add(heart);
	}

	public function flicker()
	{
		FlxFlicker.flicker(songText);

		resetMovement();
	}

	function resetMovement()
	{
		moveTween?.cancel();

		songText.offset.x = 0;
		songText.origin.x = 0;

		updateClip();

		if (!canMoveText)
			return;

		moveTween = FlxTween.tween(songText.offset, {x: songText.width - clipWidth}, 2, {
			ease: FlxEase.sineInOut,
			type: PINGPONG,
			startDelay: 0.6,
			loopDelay: 0.3,
			onUpdate: _ -> updateClip()
		});
	}

	function updateClip()
	{
		songText.clipRect.x = songText.offset.x / songText.scale.x;
		songText.clipRect.width = clipWidth / songText.scale.x;

		// This is stupid
		@:privateAccess
		songText.pendingTextBitmapChange = true;
	}

	override public function revive()
	{
		super.revive();

		song = null;
		difficulty = '';

		selected = false;
		favorited = false;

		justLoaded = false;
		moveTween = null;
	}

	override public function destroy()
	{
		super.destroy();

		moveTween?.cancel();
	}

	@:noCompletion
	function set_song(value:Song):Song
	{
		justLoaded = true;

		this.song = value;
		this.difficulty = difficulty;
		this.favorited = Save.instance.isSongFavorited(value?.id, value?.variation);

		songText.text = value?.name ?? 'Random';
		songText.updateHitbox();

		bpmText.text = Std.string(value?.bpm).leadingZeros(3);
		bpmText.visible = diffText.visible;

		justLoaded = false;

		resetMovement();

		return value;
	}

	@:noCompletion
	function set_difficulty(value:String):String
	{
		this.difficulty = value;

		ratingText.text = Std.string(song?.getRating(value)).leadingZeros(2);

		diffText.visible = song != null;
		ratingText.visible = diffText.visible;

		return value;
	}

	@:noCompletion
	function set_selected(value:Bool):Bool
	{
		if (this.selected == value)
			return value;
		this.selected = value;

		songText.alpha = value ? 1 : 0.6;

		resetMovement();

		return value;
	}

	@:noCompletion
	function set_favorited(value:Bool):Bool
	{
		if (this.favorited == value)
			return value;
		this.favorited = value;

		if (!justLoaded)
		{
			FunkinSound.playOnce('ui/freeplay/sounds/${value ? 'favorite' : 'unfavorite'}');
			Save.instance.setFavorite(song.id, song.variation, value);

			y += value ? -20 : 20;
		}

		heart.visible = value;

		resetMovement();

		return value;
	}

	@:noCompletion
	inline function get_clipWidth():Float
	{
		var clip:Float = 305;
		if (favorited)
			clip -= heart.width + 10;
		return clip;
	}

	@:noCompletion
	inline function get_canMoveText():Bool
	{
		return songText.width > clipWidth && selected && !FlxFlicker.isFlickering(songText);
	}
}

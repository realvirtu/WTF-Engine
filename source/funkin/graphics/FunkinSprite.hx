package funkin.graphics;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * The base class for all of the engine's sprites.
 */
class FunkinSprite extends FlxSprite
{
	var images:Array<String> = [];

	public function loadSprite(id:String, scale:Float = 1, width:Int = 0, height:Int = 0):FunkinSprite
	{
		frames = null;
		images = [];

		loadFrames(id, width, height);

		if (graphic != null)
		{
			setGraphicSize(Std.int(frameWidth * Constants.ZOOM * scale));
			updateHitbox();
		}

		return this;
	}

	public function loadFrames(id:String, ?width:Int, ?height:Int, ?key:String):FunkinSprite
	{
		key ??= id;

		if (images.contains(key))
			return this;

		var graphic:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image(id));

		if (graphic == null)
			return this;

		// Frame size checking
		// Use the image frame if the frame size matches the graphic size
		width = width <= 0 ? graphic.width : Std.int(width.clamp(0, graphic.width));
		height = height <= 0 ? graphic.height : Std.int(height.clamp(0, graphic.height));

		if (frames == null && width == graphic.width && height == graphic.height)
		{
			frames = graphic.imageFrame;

			frameWidth = graphic.width;
			frameHeight = graphic.height;

			return this;
		}

		// Loads the frames
		// Initialize frames if it's null
		var tiles:FlxTileFrames = FlxTileFrames.fromGraphic(graphic, FlxPoint.weak(width, height));

		if (frames == null)
		{
			frames = tiles;

			frameWidth = width;
			frameHeight = height;

			return this;
		}

		for (frame in tiles.frames)
			frames.pushFrame(frame);

		images.push(key);

		return this;
	}

	public function makeSolidColor(width:Int, height:Int, color:FlxColor):FunkinSprite
	{
		makeGraphic(1, 1, color, false, 'solid${color.toHexString(true, false)}');

		scale.set(width, height);
		updateHitbox();

		return this;
	}

	public function addAnimation(name:String, frames:Array<Int>, framerate:Int = 10, looped:Bool = true)
	{
		animation.add(name, frames, framerate, looped);
	}

	public function removeAnimation(name:String)
	{
		animation.remove(name);
	}

	public function playAnimation(name:String, force:Bool = false)
	{
		if (!hasAnimation(name))
			return;
		animation.play(name, force);
	}

	public function hasAnimation(name:String):Bool
	{
		return animation.exists(name);
	}

	public function getCurrentAnimation():String
	{
		return animation.curAnim?.name ?? '';
	}

	override function clone():FunkinSprite
	{
		var sprite:FunkinSprite = new FunkinSprite();

		sprite.loadGraphicFromSprite(this);
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();

		sprite.animation.copyFrom(animation);
		sprite.scrollFactor.copyFrom(scrollFactor);
		sprite.offset.copyFrom(offset);
		sprite.origin.copyFrom(origin);

		sprite.angle = angle;
		sprite.flipX = flipX;
		sprite.flipY = flipY;

		sprite.visible = visible;
		sprite.active = active;

		sprite.zIndex = zIndex;

		return sprite;
	}

	override function destroy()
	{
		super.destroy();

		FlxTween.cancelTweensOf(this);
	}

	public static function create(x:Float, y:Float, id:String, scale:Float = 1, width:Int = 0, height:Int = 0):FunkinSprite
	{
		return new FunkinSprite(x, y).loadSprite(id, scale, width, height);
	}

	public static function createSolidColor(x:Float, y:Float, width:Int, height:Int, color:FlxColor):FunkinSprite
	{
		return new FunkinSprite(x, y).makeSolidColor(width, height, color);
	}
}

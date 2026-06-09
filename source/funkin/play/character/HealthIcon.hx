package funkin.play.character;

import funkin.data.character.CharacterData.CharacterIconData;
import funkin.graphics.FunkinSprite;
import funkin.util.MathUtil;

/**
 * A `FunkinSprite` that helps indicate whoever is winning or losing.
 */
class HealthIcon extends FunkinSprite
{
	public var id:String;
	public var meta:CharacterIconData;
	public var isPlayer:Bool;

	public var isDead(default, set):Bool;

	var baseScale:Float;

	public function new(id:String, meta:CharacterIconData, isPlayer:Bool = false)
	{
		super();

		this.id = id;
		this.meta = meta;
		this.isPlayer = isPlayer;

		final image:String = meta.id ?? id;
		final path:String = 'gameplay/characters/$image/icon';

		// The sprite needs to be loaded in order to get the size
		loadSprite(path);
		loadSprite(path, meta.scale, graphic?.height, graphic?.height);

		addAnimation('icon', [0, 1], 0);
		playAnimation('icon');

		flipX = meta.flipX != isPlayer;
		flipY = meta.flipY;

		baseScale = scale.x;

		isDead = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Cool ass lerping >:D
		scale.x = scale.y = MathUtil.lerp(scale.x, baseScale, 0.15);
		angle = MathUtil.lerp(angle, 0, 0.15);
	}

	public function bop()
	{
		// Don't bop the icon if it's not the right beat
		if (Conductor.instance.beat % meta.bopEvery != 0)
			return;

		scale.x = scale.y = baseScale * 1.25;

		if (meta.bopAngle != null)
			angle = meta.bopAngle;
	}

	@:noCompletion
	function set_isDead(value:Bool):Bool
	{
		if (this.isDead == value)
			return value;
		this.isDead = value;

		animation.frameIndex = value ? 1 : 0;

		return value;
	}
}

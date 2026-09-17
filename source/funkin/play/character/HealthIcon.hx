package funkin.play.character;

import funkin.data.character.CharacterData.CharacterIconData;
import funkin.data.character.CharacterRegistry;
import funkin.graphics.FunkinSprite;
import funkin.util.MathUtil;

/**
 * A `FunkinSprite` that helps indicate whoever is winning or losing.
 */
class HealthIcon extends FunkinSprite
{
	static final BOP_SCALE:Float = 1.265;
	static final LERP_SPEED:Float = 0.165;

	public final isPlayer:Bool;

	public var meta(default, null):CharacterIconData;

	public var bopEvery:Float;
	public var bopAngle:Float;

	public var state(default, set):HealthIconState = IDLE;

	var isOld:Bool = false;

	var _meta:CharacterIconData;
	var _scale:Float;

	public function new(meta:CharacterIconData, isPlayer:Bool)
	{
		super();

		this.isPlayer = isPlayer;

		load(meta);
	}

	public function load(meta:CharacterIconData)
	{
		this.meta = meta ??= {
			id: '',
			scale: 1,
			flipX: true,
			flipY: false,
			bopEvery: 1,
			bopAngle: 0
		}

		// Loads the icon sprite
		// Uses the default icon if the icon doesn't exist
		var image:String = '${CharacterRegistry.instance.path}/${meta.id}/icon';

		if (!Paths.exists(Paths.image(image)))
			image = 'gameplay/icon';

		loadSprite(image);
		loadSprite(image, meta.scale, frameHeight, frameHeight);

		addAnimation('icon', [0, 1, 2], 0);
		playAnimation('icon');

		updateState();

		flipX = meta.flipX != isPlayer;
		flipY = meta.flipY;

		bopEvery = meta.bopEvery;
		bopAngle = meta.bopAngle;

		_scale = scale.x;
	}

	public function toggleOldIcon()
	{
		isOld = !isOld;

		if (isOld)
		{
			_meta = meta;

			load({
				id: 'bf-old',
				scale: 1,
				flipX: true,
				flipY: false,
				bopEvery: 1
			});
		}
		else
			load(_meta);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Cool ass lerping >:D
		scale.x = scale.y = MathUtil.lerp(scale.x, _scale, LERP_SPEED);
		angle = MathUtil.lerp(angle, 0, LERP_SPEED);
	}

	public function bop()
	{
		// Don't bop the icon if it's not the right beat
		// Using steps for more precision
		if (Conductor.instance.step * Constants.STEPS_PER_BEAT % bopEvery != 0)
			return;

		scale.x = scale.y = _scale * BOP_SCALE;
		angle = bopAngle;
	}

	function updateState()
	{
		animation.frameIndex = switch (state)
		{
			case LOSING:
				1;
			case WINNING:
				2;
			default:
				0;
		}
	}

	@:noCompletion
	inline function set_state(value:HealthIconState):HealthIconState
	{
		state = value;

		updateState();

		return state;
	}
}

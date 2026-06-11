package funkin.ui.sticker;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;
import funkin.audio.FunkinSound;
import funkin.data.sticker.StickerRegistry;

/**
 * The sub state where the screen is filled with stickers.
 * This is used to make a clean transition from one state to the other.
 */
class StickerSubState extends FunkinSubState
{
	final START_OFFSET:Int = -100;
	final STICKER_TIME:Float = 0.01;

	static var stickers:FlxTypedGroup<StickerSprite>;

	public var nextState:NextState;
	public var pack:String;

	var persist:Bool = false;

	public function new(?nextState:NextState, ?pack:String)
	{
		super();

		// Fallback in case the specified pack doesn't exist
		// The default one should ALWAYS exist
		if (!StickerRegistry.instance.exists(pack))
			pack = Constants.DEFAULT_STICKER_PACK;

		this.nextState = nextState;
		this.pack = pack;
	}

	override public function create()
	{
		super.create();

		stickers ??= new FlxTypedGroup<StickerSprite>();
		add(stickers);

		// Generates the stickers
		if (stickers.length == 0)
		{
			var x:Float = START_OFFSET;
			var y:Float = START_OFFSET;

			final pack:StickerPack = StickerRegistry.instance.fetch(pack);

			while (x < FlxG.width)
			{
				if (pack.images.length == 0)
					break;

				var sticker:StickerSprite = pack.buildSticker(pack.pickRandom());
				sticker.setPosition(x, y);
				stickers.add(sticker);

				x += sticker.width / 2;

				if (x >= FlxG.width && y < FlxG.height)
				{
					x = START_OFFSET;
					y += FlxG.random.int(50, 100);
				}
			}

			// Shuffles the stickers to be in a more unique order
			// I LOVE random!! :ivebeenabadbrother:
			FlxG.random.shuffle(stickers.members);
		}

		for (i => sticker in stickers)
		{
			FlxTimer.wait(STICKER_TIME * (i + 1), () ->
			{
				sticker.visible = !sticker.visible;

				// Plays a cool sticker sound :)
				FunkinSound.playOnce(Paths.random('general/sticker/sounds/sticker', 1, 5));

				if (i == stickers.length - 1)
					transition();
			});
		}

		// Immediately transition if there are no stickers
		if (stickers.length == 0)
			transition();
	}

	function transition()
	{
		if (nextState != null)
		{
			persist = true;

			FlxG.switchState(nextState);
			FlxG.signals.preStateCreate.addOnce(state ->
			{
				var stickers:StickerSubState = new StickerSubState(null, pack);

				// This is so dumb :whattheangry:
				@:privateAccess
				if (state._requestedSubState != null)
					state._requestedSubState.openSubState(stickers);
				else
					state.openSubState(stickers);
			});
		}
		else
			close();
	}

	override public function destroy()
	{
		// The stickers are removed so that they aren't destroyed
		if (persist)
			remove(stickers);
		else
		{
			stickers.destroy();
			stickers = null;

			trace('Destroyed stickers.');
		}

		super.destroy();
	}

	public static function switchState(nextState:NextState, ?pack:String)
	{
		var stickers:StickerSubState = new StickerSubState(nextState, pack);

		if (FlxG.state.subState != null)
			FlxG.state.subState.openSubState(stickers);
		else
			FlxG.state.openSubState(stickers);
	}
}

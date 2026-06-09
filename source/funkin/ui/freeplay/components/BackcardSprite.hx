package funkin.ui.freeplay.components;

import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.graphics.FunkinSprite;

/**
 * The backing card sprite used for the freeplay menu.
 */
class BackcardSprite extends FlxSpriteGroup
{
	var cardColor:FlxColor = 0xFFFFCB2F;
	var flashTween:FlxTween;

	var card:FunkinSprite;
	var cardFlash:FunkinSprite;

	var text1:ScrollingText;
	var text2:ScrollingText;
	var text3:ScrollingText;

	public function new()
	{
		super();

		card = FunkinSprite.create(0, 0, 'menu/freeplay/card/left', 1.5);
		card.color = cardColor;
		card.active = false;
		add(card);

		text1 = new ScrollingText(0, 180, 'coolswag', -5);
		text1.scrollWidth = card.width;
		add(text1);

		text2 = new ScrollingText(0, 330, 'warmer than blood', 3);
		text2.scrollWidth = card.width;
		add(text2);

		text3 = new ScrollingText(0, 480, 'coolswag', -5);
		text3.scrollWidth = card.width;
		add(text3);

		cardFlash = card.clone();
		cardFlash.visible = false;
		add(cardFlash);
	}

	public function hide()
	{
		// Sets the card color to black
		// That way, the flash looks good
		card.color = 0xFF000000;

		text1.visible = false;
		text2.visible = false;
		text3.visible = false;

		cardFlash.visible = false;

		flashTween?.cancel();
	}

	public function show()
	{
		text1.visible = true;
		text2.visible = true;
		text3.visible = true;

		cardFlash.visible = true;
		card.color = cardColor;

		// Cool flashbang
		// Yes.. flashbang the player
		flashTween = FlxTween.tween(cardFlash, {alpha: 0}, 0.65, {onComplete: _ -> cardFlash.visible = false});
	}
}

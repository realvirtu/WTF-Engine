package funkin.ui.freeplay.player;

import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.graphics.FunkinSprite;
import funkin.ui.freeplay.components.ScrollingText;

/**
 * The backing card sprite used for the freeplay menu.
 */
class BackcardSprite extends FlxSpriteGroup
{
	static final cardColor:FlxColor = 0xFFFFCB2F;

	public var card:FunkinSprite;
	public var cardFlash:FunkinSprite;

	public var text1:ScrollingText;
	public var text2:ScrollingText;
	public var text3:ScrollingText;
	public var text4:ScrollingText;
	public var text5:ScrollingText;
	public var text6:ScrollingText;

	var flashTween:FlxTween;

	public function new()
	{
		super();

		card = FunkinSprite.create(0, 0, 'ui/freeplay/card/left', 1.5);
		card.color = cardColor;
		card.active = false;
		add(card);

		text1 = new ScrollingText(0, 170, 'warm blooded in more ways than one', 7);
		text1.scrollWidth = card.width;
		text1.size = 30;
		text1.color = 0xFFFFE8B5;
		add(text1);

		text2 = new ScrollingText(0, text1.y + text1.height + 20, 'boyfriend', -4);
		text2.scrollWidth = card.width;
		text2.color = 0xFFFFAC2F;
		text2.size = 40;
		add(text2);

		text3 = new ScrollingText(0, text2.y + text2.height + 20, 'protect yo nuts', 4);
		text3.scrollWidth = card.width;
		text3.size = text1.size;
		add(text3);

		text4 = new ScrollingText(0, text3.y + text3.height + 20, text2.text, text2.speed);
		text4.scrollWidth = card.width;
		text4.color = text2.color;
		text4.size = text2.size;
		add(text4);

		text5 = new ScrollingText(0, text4.y + text4.height + 20, text1.text, text1.speed);
		text5.scrollWidth = card.width;
		text5.color = text1.color;
		text5.size = text1.size;
		add(text5);

		text6 = new ScrollingText(0, text5.y + text5.height + 30, text2.text, text2.speed);
		text6.scrollWidth = card.width;
		text6.color = text2.color;
		text6.size = text2.size;
		add(text6);

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
		text4.visible = false;
		text5.visible = false;
		text6.visible = false;

		cardFlash.visible = false;

		flashTween?.cancel();
	}

	public function show()
	{
		text1.visible = true;
		text2.visible = true;
		text3.visible = true;
		text4.visible = true;
		text5.visible = true;
		text6.visible = true;

		cardFlash.visible = true;
		card.color = cardColor;

		// Cool flashbang
		// Yes.. flashbang the player
		flashTween = FlxTween.tween(cardFlash, {alpha: 0}, 0.65, {onComplete: _ -> cardFlash.visible = false});
	}
}

package funkin.ui.freeplay.album;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.util.FlxTimer;
import funkin.data.album.AlbumRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;

/**
 * The actual album sprite used for the freeplay menu.
 */
class AlbumSprite extends FlxSpriteGroup
{
	public var id:String;
	public var album:Album;

	public var sprite:FunkinSprite;
	public var title:FunkinText;

	public function new()
	{
		super();

		active = false;

		sprite = new FunkinSprite();
		sprite.active = false;
		add(sprite);

		title = new FunkinText();
		title.alignment = CENTER;
		title.size = 35;
		title.borderColor = 0xFF000000;
		title.borderSize = 3;
		title.borderStyle = OUTLINE;
		add(title);
	}

	public function load(id:String)
	{
		if (!AlbumRegistry.instance.exists(id))
		{
			album = null;
			visible = false;

			return;
		}

		album = AlbumRegistry.instance.fetch(id);
		visible = true;

		if (this.id == id)
			return;
		this.id = id;

		sprite.loadSprite(album.image, 1.75);

		title.text = album.name;
		title.x = sprite.x + ((sprite.width - title.width) / 2) * Math.sin(FlxAngle.asRadians(angle));
		title.y = sprite.y + sprite.height - 10;

		final off:Float = 10;

		sprite.offset.y += off;
		title.offset.y += off;

		FlxTimer.wait(0.05, () ->
		{
			sprite.offset.y -= off;
			title.offset.y -= off;
		});
	}
}

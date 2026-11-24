package funkin.ui.freeplay.components;

import funkin.graphics.FunkinSprite;

/**
 * An icon sprite used for freeplay capsules.
 */
class FreeplayIcon extends FunkinSprite
{
	static final PATH:String = 'ui/freeplay/icons';

	public function new()
	{
		super();

		active = false;
	}

	public function load(id:String)
	{
		var path:String = '$PATH/$id';

		// Shorten icons if they need to be shortened
		// Otherwise "monster-christmas" or "senpai-angry" isn't gonna work
		while (!Paths.exists(Paths.image(path)) && id.contains('-'))
		{
			id = id.substr(0, id.lastIndexOf('-'));
			path = '$PATH/$id';
		}

		// Hide the icon if it doesn't exist
		if (!Paths.exists(Paths.image(path)))
		{
			visible = false;
			return;
		}

		loadSprite(path, 0.7);

		visible = true;
	}
}

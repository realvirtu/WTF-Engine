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

		loadSprite(path, 0.8);

		// Only show the icon if it's visible
		visible = graphic != null;
	}
}

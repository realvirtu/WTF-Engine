package funkin.graphics.shader;

import flixel.addons.display.FlxRuntimeShader;
import funkin.util.FileUtil;
import openfl.utils.Assets;

/**
 * A shader for swapping a texture with another texture.
 */
class TextureSwap extends FlxRuntimeShader
{
	public function new(id:String)
	{
		super(FileUtil.getText(Paths.frag('general/shaders/texture-swap')));

		load(id);
	}

	public function load(id:String)
	{
		setBitmapData('texture', Assets.getBitmapData(Paths.image(id)));
	}
}

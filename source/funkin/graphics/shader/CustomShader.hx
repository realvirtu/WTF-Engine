package funkin.graphics.shader;

import flixel.addons.display.FlxRuntimeShader;
import funkin.util.WindowUtil;
import lime.utils.Assets;

class CustomShader extends FlxRuntimeShader
{
	public function new(name:String)
	{
		var fragPath:String = Paths.frag(name);
		var vertPath:String = Paths.vert(name);

		var fragCode:String = null;
		var vertCode:String = null;

		if (Paths.exists(fragPath))
			fragCode = Assets.getText(fragPath);

		if (Paths.exists(vertPath))
			vertCode = Assets.getText(vertPath);

		if (fragCode == null && vertCode == null)
			WindowUtil.alert('Shader "$name" couldn\'t be found.');

		super(fragCode, vertCode);
	}
}

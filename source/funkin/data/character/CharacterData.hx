package funkin.data.character;

import funkin.data.stage.StageData.PropAnimData;

/**
 * A structure object used for... you guessed it... character data!
 */
typedef CharacterData =
{
	var name:String;
	var width:Int;
	var height:Int;
	var icon:CharacterIconData;
	var globalOffset:Array<Float>;
	var cameraOffset:Array<Float>;
	@:default(1)
	var scale:Float;
	var flipX:Bool;
	var flipY:Bool;
	@:default(2)
	var bopEvery:Int;
	@:default(8)
	var singDuration:Float;
	@:default([])
	var images:Array<CharacterImageData>;
	@:default([])
	var animations:Array<CharacterAnimData>;
}

/**
 * A structure object used for the health icon data of characters.
 */
typedef CharacterIconData =
{
	var id:String;
	@:default(1)
	var scale:Float;
	var flipX:Bool;
	var flipY:Bool;
	@:default(1)
	var bopEvery:Int;
	@:optional
	var bopAngle:Float;
}

/**
 * A structure object used for the animation data of characters.
 */
typedef CharacterAnimData = PropAnimData &
{
	@:optional
	var image:String;
	var offset:Array<Float>;
}

/**
 * A structure object used for the image data of characters.
 */
typedef CharacterImageData =
{
	var name:String;
	@:optional
	var width:Int;
	@:optional
	var height:Int;
}

package funkin.data.dialogue;

/**
 * A structure object used for dialogue box data.
 */
typedef DialogueBoxData =
{
	var name:String;
	@:default(1)
	var scale:Float;
	@:default([])
	var offset:Array<Float>;
}

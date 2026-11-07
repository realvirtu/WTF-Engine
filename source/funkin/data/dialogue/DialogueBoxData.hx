package funkin.data.dialogue;

/**
 * Structure object used for the data of dialogue boxes.
 */
typedef DialogueBoxData =
{
	var name:String;
	@:default(1)
	var scale:Float;
	var hand:DialogueBoxHandData;
	@:default([])
	var offset:Array<Float>;
}

/**
 * The data for the hands of dialogue boxes.
 */
typedef DialogueBoxHandData =
{
	var width:Int;
	var height:Int;
	@:default(1)
	var scale:Float;
	@:default([])
	var offset:Array<Float>;
}

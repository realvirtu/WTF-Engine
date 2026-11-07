package funkin.data.dialogue;

/**
 * Structure object used for the data of dialogue boxes.
 */
typedef DialogueBoxData =
{
	var name:String;
	var scale:Float;
	var hand:DialogueBoxHandData;
	var text:DialogueBoxTextData;
	var globalOffset:Array<Float>;
	var speakerOffset:Array<Float>;
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

/**
 * The data for the dialogue box text.
 */
typedef DialogueBoxTextData =
{
	var textColor:String;
	var borderColor:String;
	@:default(32)
	var textSize:Int;
	var borderSize:Int;
	@:default([])
	var offset:Array<Float>;
}

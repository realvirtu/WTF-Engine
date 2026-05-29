package funkin.data.dialogue;

/**
 * A structure object used for dialogue speakers.
 */
typedef DialogueSpeakerData =
{
	var name:String;
	@:default(1)
	var scale:Float;
	var offset:Array<Float>;
}

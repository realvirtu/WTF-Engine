package funkin.data.dialogue;

/**
 * Structure object of the data for dialogue speakers/portraits.
 */
typedef SpeakerData =
{
	var name:String;
	@:default(1)
	var scale:Float;
	@:default([])
	var offset:Array<Float>;
}

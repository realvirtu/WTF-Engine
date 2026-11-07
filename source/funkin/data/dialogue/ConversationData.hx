package funkin.data.dialogue;

/**
 * Structure object used for the data of dialogue conversations.
 */
typedef ConversationData =
{
	var name:String;
	var box:String;
	@:default([])
	var lines:Array<ConversationLineData>;
}

/**
 * The data for the dialogue lines of conversations.
 */
typedef ConversationLineData =
{
	var text:String;
	@:optional
	var speaker:String;
}

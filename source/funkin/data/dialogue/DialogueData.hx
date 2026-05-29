package funkin.data.dialogue;

/**
 * A structure object used for the game's dialogue system.
 */
typedef DialogueData =
{
	var name:String;
	var box:String;
	@:optional
	var music:String;
	@:default([])
	var lines:Array<DialogueLineData>;
}

/**
 * A structure object used for the lines of dialogue.
 */
typedef DialogueLineData =
{
	var speaker:String;
	var text:String;
}

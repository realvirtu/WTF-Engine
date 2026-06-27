package funkin.data.credits;

/**
 * A structure object for the engine's credits.
 */
typedef CreditsData =
{
	var header:String;
	@:default([])
	var body:Array<CreditsBodyData>;
}

/**
 * A structure object used for the body of `CreditsData`.
 */
typedef CreditsBodyData =
{
	var name:String;
	var role:String;
}

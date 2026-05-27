package funkin.util.macro;

#if macro
import haxe.Http;
import haxe.Json;
import haxe.macro.Expr;
#end

/**
 * A structure object used when listing the engine's GitHub contributors.
 */
typedef ContributorData =
{
	var name:String;
	var contributions:Int;
}

/**
 * A macro class for handling git stuff.
 */
class GitMacro
{
	@:persistent
	public static macro function getContributors():ExprOf<Array<ContributorData>>
	{
		#if !display
		var result:Array<ContributorData> = [];
		var http:Http = new Http('https://api.github.com/repos/VirtuGuy/WTF-Engine/contributors');

		http.setHeader('User-Agent', 'WTFEngine');
		http.request();

		var data:Array<Dynamic> = try Json.parse(http?.responseData) catch (e) [];

		if (data.length == 0)
			trace('Failed to fetch contributors.');

		for (contributor in data)
		{
			result.push({
				name: contributor.login,
				contributions: contributor.contributions
			});
		}

		return macro $v{result};
		#else
		return macro $v{[]};
		#end
	}
}

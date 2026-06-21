package funkin.util.macro;

#if macro
import haxe.Http;
import haxe.Json;
import haxe.macro.Context;
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
	static var _contributors:Array<ContributorData>;
	@:persistent
	static var _contributions:Int = 0;

	public static macro function getContributors():ExprOf<Array<ContributorData>>
	{
		if (Context.defined('display'))
			return macro $v{[]};

		if (_contributors != null)
		{
			trace('Using cached GitHub contributors list.');

			return macro $v{_contributors};
		}

		var result:Array<ContributorData> = [];

		try
		{
			final http:Http = new Http('https://api.github.com/repos/realvirtu/WTF-Engine/contributors');

			http.setHeader('User-Agent', 'WTFEngine');
			http.request();

			final data:Array<Dynamic> = Json.parse(http?.responseData);

			for (contributor in data)
			{
				final name:String = contributor.login;
				final contributions:Int = contributor.contributions;

				// Lol don't include me
				// I'm the creator of the engine, not a contributor
				if (name == 'realvirtu')
					continue;

				result.push({
					name: name,
					contributions: contributions
				});

				_contributions += contributions;
			}
		}
		catch (e)
			trace('Failed to fetch GitHub contributors.');

		_contributors = result;

		trace('Done fetching GitHub contributors.');

		return macro $v{result};
	}

	public static macro function getContributions():ExprOf<Int>
	{
		return macro $v{_contributions};
	}
}

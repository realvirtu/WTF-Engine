package funkin.util.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * A macro class for implementing z-ordering features.
 */
class ZIndexMacro
{
	public static macro function buildFlxGroup():Array<Field>
	{
		if (Context.defined('display'))
			return [];

		var fields = Context.getBuildFields();
		var has:Bool = false;

		for (field in fields)
		{
			if (field.name != 'refresh')
				continue;
			has = true;
		}

		if (!has)
		{
			fields.push({
				name: 'refresh',
				access: [APublic],
				kind: FieldType.FFun({
					args: [],
					expr: macro
					{sort(funkin.util.SortUtil.byZIndex);}
				}),
				pos: Context.currentPos()
			});
		}

		return fields;
	}
}
#end

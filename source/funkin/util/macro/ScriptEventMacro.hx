package funkin.util.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;
using thx.Arrays;

/**
 * A macro class for building the pooling system for the `ScriptEvent` class.
 * 
 * Stolen evilly from Funkin' PR #7238.
 */
class ScriptEventMacro
{
	static final PROCESSED_META:String = ':builtPool';

	public static macro function build():Array<Field>
	{
		if (Context.defined('display'))
			return [];

		var fields:Array<Field> = Context.getBuildFields();
		var cls:ClassType = Context.getLocalClass().get();
		var pos:Position = Context.currentPos();

		if (cls.meta.has(PROCESSED_META))
			return fields;

		cls.meta.add(PROCESSED_META, [], pos);

		var clsType:ComplexType = Context.getType('${cls.module}.${cls.name}').toComplexType();
		var constructor:Field = fields.find(field -> return field.name == 'new');

		switch (constructor?.kind)
		{
			case FFun(f):
				var name:String = cls.pack.copy().concat([cls.name]).join('.');
				var args:Array<Expr> = [for (arg in f.args) macro $i{arg.name}];

				//
				// RESET
				//

				var resetExpr:Expr = {expr: f.expr.expr, pos: pos};
				var resetFunc:String = 'reset_${cls.name}';

				if (cls.superClass != null)
				{
					switch (resetExpr.expr)
					{
						case EBlock(exprs):
							var exprs:Array<Expr> = exprs.copy();
							var resetFunc:String = 'reset_${cls.superClass.t.get().name}';

							for (i => e in exprs)
							{
								switch (e.expr)
								{
									case ECall(e, params) if (Type.enumEq(e.expr, EConst(CIdent('super')))):
										exprs[i] = {
											expr: ECall({
												expr: EConst(CIdent(resetFunc)),
												pos: pos
											}, params),
											pos: pos
										};
										break;
									default:
										// Does literally nothing
								}
							}

							resetExpr.expr = EBlock(exprs);
						default:
							// Does literally nothing
					}
				}

				fields.push({
					name: resetFunc,
					kind: FFun({
						args: f.args,
						expr: resetExpr
					}),
					access: [APrivate],
					pos: pos
				});

				//
				// POOLING
				//

				fields.push({
					name: 'pool',
					kind: FVar(macro :Array<$clsType>, macro []),
					access: [APublic, AStatic],
					pos: pos
				});

				fields.push({
					name: 'get',
					kind: FFun({
						args: f.args,
						ret: clsType,
						expr: macro
						{
							var event:$clsType = pool.find(event -> return event.handled);

							// Check if the pool has 50 or more events
							// You never know when I decide to fuck up
							if (pool.length > 50)
								trace(tools.AnsiTools.warn($v{cls.name} + ' pool has more than 50 events. Is there a leak?'));

							if (event == null)
							{
								event = Type.createInstance(Type.resolveClass($v{name}), $a{args});
								pool.push(event);

								return event;
							}

							event.$resetFunc($a{args});

							return event;
						}
					}),
					access: [APublic, AStatic],
					pos: pos
				});
			default:
				Context.warning('No proper constructor was found.', pos);
		}

		return fields;
	}
}
#end

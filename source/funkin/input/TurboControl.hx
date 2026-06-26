package funkin.input;

@:access(funkin.input.FunkinAction)
class TurboControl
{
	static var registry:Map<FunkinAction, TurboControl> = new Map<FunkinAction, TurboControl>();

	public static function check(action:FunkinAction):Bool
	{
		var TurboControl:Null<TurboControl> = registry.get(action);

		if (TurboControl == null)
		{
			TurboControl = new TurboControl(action);
			registry.set(action, TurboControl);
		}

		return TurboControl?.active ?? false;
	}

	public var active:Bool = false;

	var action:FunkinAction;

	var spamming:Bool = false;
	var spamTimer:Float = 0;

	public function new(action:FunkinAction)
	{
		this.action = action;
		FlxG.signals.preUpdate.add(() -> update(FlxG.elapsed));
	}

	function update(elapsed:Float):Void
	{
		active = false;

		if (action.check())
		{
			if (spamming && spamTimer >= 0.07)
			{
				spamTimer = 0;
				active = true;
			}
			else if (!spamming && spamTimer >= 0.5)
				spamming = true;
			else if (spamTimer <= 0)
				active = true;

			spamTimer += elapsed;
		}
		else
		{
			spamming = false;
			spamTimer = 0;
		}
	}
}

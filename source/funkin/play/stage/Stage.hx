package funkin.play.stage;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import funkin.data.character.CharacterRegistry;
import funkin.data.stage.StageData;
import funkin.modding.IScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.character.Character;
import funkin.util.MathUtil;
import haxe.ds.StringMap;

/**
 * A group containing stage props and characters.
 */
class Stage extends FlxGroup implements IPlayStateScriptedClass
{
	public var id:String;
	public var meta:StageData;

	public var props(default, null) = new StringMap<StageProp>();
	public var propData(default, null) = new StringMap<StagePropData>();

	public var zoom(get, never):Float;

	public var player:Character;
	public var opponent:Character;
	public var gf:Character;

	var path(get, never):String;

	public function new(id:String)
	{
		super();

		this.id = id;
	}

	public function buildProps()
	{
		if (meta?.props == null)
			return;

		for (prop in meta.props)
		{
			if (prop == null)
				continue;

			var data:StagePropData = propData.get(prop.prop) ?? prop;
			var sprite:StageProp = new StageProp(data.id);

			final image:String = '$path/props/${data.image}';
			final position:FlxPoint = MathUtil.arrayToPoint(prop.position);
			final scroll:FlxPoint = MathUtil.arrayToPoint(data.scroll, 1);

			sprite.loadSprite(image, data.scale, data.width, data.height);
			sprite.loadAnimations(data.animations);

			sprite.scrollFactor.copyFrom(scroll);

			sprite.flipX = data.flipX;
			sprite.flipY = data.flipY;
			sprite.zIndex = data.zIndex;

			sprite.active = data.animations.length > 0;

			sprite.setPosition(position.x, position.y);

			// We're done with the points
			position.put();
			scroll.put();

			if (prop.id != null)
			{
				props.set(prop.id, sprite);
				propData.set(prop.id, data);
			}

			add(sprite);
		}

		// Refreshes to properly sort props
		refresh();
	}

	public function getProp(id:String):StageProp
	{
		return props.get(id);
	}

	public function setPlayer(id:String):Character
	{
		var position:FlxPoint = MathUtil.arrayToPoint(meta?.player?.position);
		var scroll:FlxPoint = MathUtil.arrayToPoint(meta?.player?.scroll, 1);

		player?.destroy();
		player = CharacterRegistry.instance.fetchCharacter(id, PLAYER);

		if (player != null)
		{
			player.setPosition(position.x, position.y);
			player.scrollFactor.copyFrom(scroll);
			player.zIndex = meta?.player?.zIndex ?? 2;

			add(player);
			refresh();
		}

		position.put();
		scroll.put();

		return player;
	}

	public function setOpponent(id:String)
	{
		var position:FlxPoint = MathUtil.arrayToPoint(meta?.opponent?.position);
		var scroll:FlxPoint = MathUtil.arrayToPoint(meta?.opponent?.scroll, 1);

		opponent?.destroy();
		opponent = CharacterRegistry.instance.fetchCharacter(id, OPPONENT);

		if (opponent != null)
		{
			opponent.setPosition(position.x, position.y);
			opponent.scrollFactor.copyFrom(scroll);
			opponent.zIndex = meta?.opponent?.zIndex ?? 2;

			add(opponent);
			refresh();
		}

		position.put();
		scroll.put();
	}

	public function setGF(id:String)
	{
		var position:FlxPoint = MathUtil.arrayToPoint(meta?.gf?.position);
		var scroll:FlxPoint = MathUtil.arrayToPoint(meta?.gf?.scroll, 1);

		gf?.destroy();
		gf = CharacterRegistry.instance.fetchCharacter(id);

		if (gf != null)
		{
			gf.setPosition(position.x, position.y);
			gf.scrollFactor.copyFrom(scroll);
			gf.zIndex = meta?.gf?.zIndex ?? 1;

			add(gf);
			refresh();
		}

		position.put();
		scroll.put();
	}

	@:noCompletion
	function get_zoom():Float
	{
		return meta?.zoom ?? Constants.DEFAULT_CAMERA_ZOOM;
	}

	@:noCompletion
	inline function get_path():String
	{
		return 'play/stages/$id';
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent)
	{
		// Thank you Hyper :whatthehappy:
		// It's done like this because for Spirit, he runs refresh on the stage
		// Running a refresh means it iterates through Spirit over and over again
		// Spirit creates an FlxTrail as well, so the loop just never ends
		var props:Array<FlxBasic> = members.copy().filter(prop -> prop?.exists && return Std.isOfType(prop, IScriptedClass));

		for (prop in props)
			ScriptEventDispatcher.dispatch(cast prop, event);
	}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onHoldNoteHold(event:HoldNoteScriptEvent) {}

	public function onHoldNoteDrop(event:HoldNoteScriptEvent) {}

	public function onGhostMiss(event:GhostMissScriptEvent) {}

	public function onStepHit(event:ConductorScriptEvent) {}

	public function onBeatHit(event:ConductorScriptEvent) {}

	public function onSongLoaded(event:SongLoadScriptEvent) {}

	public function onSongStart(event:ScriptEvent) {}

	public function onSongEnd(event:ScriptEvent) {}

	public function onSongRetry(event:ScriptEvent) {}

	public function onSongEvent(event:SongEventScriptEvent) {}

	public function onCountdownStart(event:CountdownScriptEvent) {}

	public function onCountdownStep(event:CountdownScriptEvent) {}

	public function onPause(event:ScriptEvent) {}

	public function onResume(event:ScriptEvent) {}

	public function onGameOverStart(event:ScriptEvent) {}

	public function onGameOverLoop(event:ScriptEvent) {}

	public function onGameOverRetry(event:ScriptEvent) {}
}

package funkin.play.stage;

import flixel.group.FlxGroup;
import funkin.data.character.CharacterRegistry;
import funkin.data.stage.StageData;
import funkin.data.stage.StageRegistry;
import funkin.modding.IScriptedClass;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.character.Character;
import haxe.ds.StringMap;

/**
 * A group containing stage props and characters.
 */
class Stage extends FlxGroup implements IPlayStateScriptedClass
{
	public final id:String;

	public var meta:StageData;

	public var props(default, null) = new StringMap<StageProp>();

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

			final position:Array<Float> = prop.position ?? [0, 0];
			final scroll:Array<Float> = prop.scroll ?? [1, 1];

			var sprite:StageProp = new StageProp(prop.id);

			sprite.loadSprite('$path/props/${prop.image}', prop.scale, prop.width, prop.height);
			sprite.loadAnimations(prop.animations);

			sprite.setPosition(position[0], position[1]);

			sprite.scrollFactor.set(scroll[0], scroll[1]);
			sprite.active = prop.animations.length > 0;

			sprite.flipX = prop.flipX;
			sprite.flipY = prop.flipY;
			sprite.zIndex = prop.zIndex;

			if (prop.id != null)
				props.set(prop.id, sprite);

			add(sprite);
		}

		refresh();
	}

	public function getProp(id:String):StageProp
	{
		return props.get(id);
	}

	public function setPlayer(id:String)
	{
		player?.destroy();
		player = CharacterRegistry.instance.fetchCharacter(id, PLAYER);

		if (player != null)
		{
			final scroll:Array<Float> = meta?.player?.scroll ?? [1, 1];
			final zIndex:Int = meta?.player?.zIndex ?? 2;

			player.setPosition(getPlayerPosition()[0], getPlayerPosition()[1]);

			player.scrollFactor.set(scroll[0], scroll[1]);
			player.zIndex = zIndex;

			add(player);
			refresh();
		}
	}

	public function setOpponent(id:String)
	{
		opponent?.destroy();
		opponent = CharacterRegistry.instance.fetchCharacter(id, OPPONENT);

		if (opponent != null)
		{
			final scroll:Array<Float> = meta?.opponent?.scroll ?? [1, 1];
			final zIndex:Int = meta?.opponent?.zIndex ?? 2;

			opponent.setPosition(getOpponentPosition()[0], getOpponentPosition()[1]);

			opponent.scrollFactor.set(scroll[0], scroll[1]);
			opponent.zIndex = zIndex;

			add(opponent);
			refresh();
		}
	}

	public function setGF(id:String)
	{
		gf?.destroy();
		gf = CharacterRegistry.instance.fetchCharacter(id, GF);

		if (gf != null)
		{
			final scroll:Array<Float> = meta?.gf?.scroll ?? [1, 1];
			final zIndex:Int = meta?.gf?.zIndex ?? 1;

			gf.setPosition(getGFPosition()[0], getGFPosition()[1]);

			gf.scrollFactor.set(scroll[0], scroll[1]);
			gf.zIndex = zIndex;

			add(gf);
			refresh();
		}
	}

	public function getPlayerPosition():Array<Float>
	{
		return meta?.player?.position ?? [0, 0];
	}

	public function getOpponentPosition():Array<Float>
	{
		return meta?.opponent?.position ?? [0, 0];
	}

	public function getGFPosition():Array<Float>
	{
		return meta?.gf?.position ?? [0, 0];
	}

	public function onCreate(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onScriptEvent(event:ScriptEvent)
	{
		for (prop in members.copy().filter(prop -> return prop is IScriptedClass))
			ScriptEventDispatcher.dispatch(cast prop, event);
	}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onNoteIncoming(event:NoteScriptEvent) {}

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

	@:noCompletion
	function get_zoom():Float
	{
		return meta?.zoom ?? Constants.DEFAULT_CAMERA_ZOOM;
	}

	@:noCompletion
	inline function get_path():String
	{
		return '${StageRegistry.instance.path}/$id';
	}
}

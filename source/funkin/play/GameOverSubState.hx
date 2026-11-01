package funkin.play;

import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.character.CharacterRegistry;
import funkin.modding.event.ScriptEvent;
import funkin.modding.event.ScriptEventDispatcher;
import funkin.play.character.Character;
import funkin.ui.FunkinSubState;

/**
 * The game over sub state that appears when the player dies.
 */
class GameOverSubState extends FunkinSubState
{
	public static var instance:GameOverSubState;

	public static var deathId:String;
	public static var deathMusic:String;
	public static var deathSFX:String;

	public var retrying:Bool = false;
	public var exiting:Bool = false;

	public var music:FunkinSound;
	public var character:Character;

	var _conductor:Conductor;

	var retryTimer:FlxTimer;
	var player:Character;

	public function new(player:Character)
	{
		super();

		this.player = player;
	}

	override function create()
	{
		super.create();

		instance = this;

		_parentState.persistentDraw = false;
		_parentState.persistentUpdate = false;

		// This doesn't need a unique camera
		// This should use the game's camera actually
		FlxG.cameras.remove(camera);

		camera = FlxG.camera;
		camera.active = true;

		_conductor = new Conductor();
		_conductor.beatHit.add(beatHit);
		_conductor.reset({b: 100});

		music = FunkinSound.load(getPath('music', deathMusic), 1, true, true, false);

		FunkinSound.load(getPath('sounds/start', deathSFX), 1, false).onComplete = startLoop;

		buildCharacter();

		PlayState.instance.setCameraTarget(character);
		PlayState.instance.deaths++;

		var event:ScriptEvent = ScriptEvent.get(GAMEOVER_START);
		dispatch(event);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_conductor.update(music?.time);

		if (controls.ACCEPT_P)
			retry();
		if (controls.BACK)
			exit();
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		if (retrying)
			return;

		character?.playAnimation('loop');
	}

	function startLoop()
	{
		var event:ScriptEvent = ScriptEvent.get(GAMEOVER_LOOP);
		dispatch(event);

		if (event.cancelled)
			return;

		music.play();
	}

	function retry()
	{
		if (exiting)
			return;

		// Faster gameover mashing hehe
		if (retrying)
			return close();

		var event:ScriptEvent = ScriptEvent.get(GAMEOVER_RETRY);
		dispatch(event);

		if (event.cancelled)
			return;

		retrying = true;
		retryTimer = FlxTimer.wait(1, () ->
		{
			camera.fade(0xFF000000, 2, false, close);
			exiting = true;
		});

		character?.playAnimation('end');

		FunkinSound.stopAllSounds();
		FunkinSound.playOnce(getPath('sounds/end', deathSFX));
	}

	function exit()
	{
		if (exiting || retrying)
			return;

		exiting = true;

		PlayState.instance.exit();
	}

	function buildCharacter()
	{
		if (player == null)
			return;

		character = CharacterRegistry.instance.fetchCharacter('$deathId-death');

		if (character == null)
			return;

		character.scrollFactor.copyFrom(player.scrollFactor);
		character.setPosition(player.x, player.y);
		character.playAnimation('start');

		if (character != null)
			add(character);
	}

	function getPath(id:String, ?character:String):String
	{
		character ??= deathId;
		character += '-death';

		return '${CharacterRegistry.instance.path}/$character/$id';
	}

	override function dispatch(event:ScriptEvent)
	{
		ScriptEventDispatcher.dispatch(character, event);

		super.dispatch(event);
	}

	override function close()
	{
		super.close();

		_parentState.persistentDraw = true;
		_parentState.persistentUpdate = true;

		camera.fade(0xFF000000, 1, true);

		PlayState.instance.loadSong();
	}

	override function destroy()
	{
		super.destroy();

		instance = null;

		retryTimer?.cancel();
	}

	public static function reset()
	{
		deathId = PlayState.instance.stage.player?.id;
		deathMusic = deathId;
		deathSFX = deathId;
	}
}

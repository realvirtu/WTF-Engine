package funkin.play;

import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.character.CharacterRegistry;
import funkin.modding.event.ScriptEvent;
import funkin.play.character.Character;
import funkin.ui.FunkinSubState;

/**
 * The game over sub state that appears when the player dies.
 * 
 * TODO: Possibly rework how character gameover stuff is handled.
 */
class GameOverSubState extends FunkinSubState
{
	public static var instance:GameOverSubState;

	var retrying:Bool = false;

	var menuConductor:Conductor;

	var music:FlxSound;
	var startSound:FlxSound;

	var player:Character;
	var character:Character;
	var id:String;

	override public function create()
	{
		super.create();

		instance = this;

		var event:ScriptEvent = new ScriptEvent(GAMEOVER_START);
		dispatch(event);

		if (event.cancelled)
			return close();

		PlayState.instance.deaths++;

		_parentState.persistentDraw = false;

		// This doesn't need a unique camera
		// This should use the game's camera actually
		FlxG.cameras.remove(camera);

		camera = FlxG.camera;

		menuConductor = new Conductor();
		menuConductor.beatHit.add(beatHit);
		menuConductor.reset(100);

		player = PlayState.instance.stage.player;

		music = FunkinSound.load(getDeathMusic(), 1, true, true, false);

		startSound = FunkinSound.load(getDeathSound('start'), 1, false);
		startSound.onComplete = startLoop;

		buildCharacter();

		if (character != null)
		{
			PlayState.instance.setCameraTarget(character);
			FlxG.camera.active = true;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Updates the conductor
		menuConductor.time = music?.time;
		menuConductor.update();

		if (controls.ACCEPT_P)
			retry();
		if (controls.BACK)
			PlayState.instance.exit();
	}

	function startLoop()
	{
		var event:ScriptEvent = new ScriptEvent(GAMEOVER_LOOP);
		dispatch(event);

		if (event.cancelled)
			return;

		music.play();
	}

	function retry()
	{
		if (retrying)
			return;

		var event:ScriptEvent = new ScriptEvent(GAMEOVER_RETRY);
		dispatch(event);

		if (event.cancelled)
			return;

		retrying = true;

		character?.playAnimation('end');

		music.destroy();
		startSound.destroy();

		// Gotta reset this!
		// Or else the character keeps bopping
		menuConductor.reset();

		FunkinSound.playOnce(getDeathSound('end'));

		FlxTimer.wait(1, () -> FlxG.camera.fade(0xFF000000, 2, false, close));
	}

	function buildCharacter()
	{
		final id:String = player?.meta?.death?.id ?? player?.id;

		character = CharacterRegistry.instance.fetchCharacter('$id-death');

		// Don't do the actual character stuff if it's null
		// Because I guess you never know when the death sprite doesn't exist
		if (character == null)
			return;

		character.scrollFactor.copyFrom(player?.scrollFactor);
		character.setPosition(player?.x, player?.y);

		character.playAnimation('start');

		add(character);
	}

	function getDeathMusic():String
	{
		final path:String = player?.meta?.death?.music ?? player?.id;

		return 'gameplay/characters/$path-death/music';
	}

	function getDeathSound(id:String)
	{
		final path:String = player?.meta?.death?.sounds ?? player?.id;

		return 'gameplay/characters/$path-death/$id';
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		character?.playAnimation('loop', true);

		// We still want the beat hit script event to work
		// So we're doing this >:)
		@:privateAccess
		PlayState.instance.beatHit(beat);
	}

	override public function close()
	{
		super.close();

		_parentState.persistentDraw = true;

		FlxG.camera.fade(0xFF000000, 1, true);

		PlayState.instance.resetSong();
	}

	override public function destroy()
	{
		super.destroy();

		instance = null;
	}
}

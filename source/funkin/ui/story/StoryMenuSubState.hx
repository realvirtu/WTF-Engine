package funkin.ui.story;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.data.story.LevelRegistry;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinText;
import funkin.play.PlayState;
import funkin.play.Playlist;
import funkin.save.Save;
import funkin.ui.menu.MainMenuState;
import funkin.ui.selector.DifficultyText;
import funkin.ui.story.Level;
import funkin.util.MathUtil;

/**
 * The story menu sub state for the engine.
 * This is the state where the player selects a level to play.
 */
class StoryMenuSubState extends FunkinSubState
{
	static var selectedLevel:Int = 0;
	static var selectedDiff:Int = 1;

	var skipIntro:Bool;
	var exitMovers:ExitMovers;
	var stateMachine:StateMachine;

	var level(get, never):Level;
	var difficulty(get, never):String;
	var levelScore:Int;
	var lerpScore:Float = 0;

	var blackTop:FunkinSprite;
	var blackBottom:FunkinSprite;
	var bg:FunkinSprite;
	var scoreText:FunkinText;
	var levelText:FunkinText;
	var titleGroup:TitleGroup;
	var songsText:FunkinText;
	var diffText:DifficultyText;
	var opponent:StoryCharacter;
	var player:StoryCharacter;
	var gf:StoryCharacter;

	public function new(skipIntro:Bool = false)
	{
		super();

		this.skipIntro = skipIntro;
	}

	override public function create()
	{
		super.create();

		_parentState.persistentDraw = false;

		exitMovers = new ExitMovers();
		stateMachine = new StateMachine();

		conductor.reset(100);

		blackTop = FunkinSprite.createSolidColor(0, 0, FlxG.width, 50, 0xFF000000);
		blackTop.active = false;
		blackTop.zIndex = 2;
		add(blackTop);

		blackBottom = FunkinSprite.createSolidColor(0, 0, FlxG.width, 280, 0xFF000000);
		blackBottom.y = FlxG.height - blackBottom.height;
		blackBottom.active = false;
		add(blackBottom);

		bg = FunkinSprite.createSolidColor(0, 0, FlxG.width, Std.int(FlxG.height - blackBottom.height - blackTop.height), 0xFFFFFFFF);
		bg.y = blackTop.height;
		bg.active = false;
		bg.zIndex = 1;
		add(bg);

		scoreText = new FunkinText(10);
		scoreText.alpha = 0.6;
		scoreText.size = 24;
		scoreText.y = (blackTop.height - scoreText.height) / 2;
		scoreText.zIndex = blackTop.zIndex;
		add(scoreText);

		levelText = new FunkinText();
		levelText.alpha = scoreText.alpha;
		levelText.size = scoreText.size;
		levelText.y = scoreText.y;
		levelText.zIndex = scoreText.zIndex;
		add(levelText);

		titleGroup = new TitleGroup(selectedLevel, blackBottom.y + 30, LevelRegistry.instance.listSorted());
		titleGroup.onChanged.add(changeLevel);
		add(titleGroup);

		songsText = new FunkinText();
		songsText.color = 0xFFFF4CAF;
		songsText.alpha = 0.6;
		songsText.size = 24;
		songsText.alignment = CENTER;
		songsText.y = blackBottom.y + 50;
		add(songsText);

		// TODO: Replace this with a much better system
		// Erect and Nightmare shouldn't be selectable difficulties
		diffText = new DifficultyText(selectedDiff, ['easy', 'normal', 'hard']);
		diffText.size = 56;
		diffText.onChanged.add(changeDiff);
		diffText.y = blackBottom.y + 50;
		add(diffText);

		opponent = new StoryCharacter();
		opponent.zIndex = bg.zIndex;
		add(opponent);

		player = new StoryCharacter();
		player.zIndex = opponent.zIndex;
		add(player);

		gf = new StoryCharacter();
		gf.zIndex = player.zIndex;
		add(gf);

		exitMovers.add(blackTop, null, -blackTop.height);
		exitMovers.add(blackBottom, FlxG.width);
		exitMovers.add(bg, -bg.width);
		exitMovers.add(scoreText, null, -scoreText.height);
		exitMovers.add(levelText, null, -levelText.height);
		exitMovers.add(songsText, FlxG.width);
		exitMovers.add(diffText, FlxG.width);

		titleGroup.forEach(title -> exitMovers.add(title, FlxG.width, FlxG.height));

		if (!skipIntro)
			stateMachine.transition(TRANSITIONING);

		changeLevel(selectedLevel);
		refresh();

		// Complete the bg color tween
		// because the color white is ugly
		FlxTween.completeTweensOf(bg);

		if (!skipIntro)
			intro();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.time = FunkinSound.music.time;
		conductor.update();

		_parentState.persistentDraw = stateMachine.transitioning();

		titleGroup.lerp = !stateMachine.transitioning();
		titleGroup.busy = !stateMachine.canInteract();
		diffText.busy = !stateMachine.canInteract();

		lerpScore = MathUtil.lerp(lerpScore, levelScore, 0.45);

		scoreText.text = Std.string(Math.round(lerpScore)).leadingZeros(10);

		if (controls.ACCEPT)
			confirm();
		if (controls.BACK)
			exit();
	}

	override function beatHit(beat:Int)
	{
		super.beatHit(beat);

		opponent.bop();
		player.bop();
		gf.bop();
	}

	function changeLevel(selected:Int)
	{
		selectedLevel = selected;

		// Level
		FlxTween.cancelTweensOf(bg);
		FlxTween.color(bg, 0.75, bg.color, FlxColor.fromString(level.color), {ease: FlxEase.quintOut});

		levelText.text = level.name;
		levelText.x = FlxG.width - levelText.width - 10;

		songsText.text = 'tracks\n';
		for (song in level.getSongNames())
			songsText.text += '\n$song';
		songsText.x = 200 - songsText.width / 2;

		// Characters
		opponent.load(level.opponent);
		opponent.x = 250 - opponent.width / 2;
		opponent.y = blackBottom.y - opponent.height - 30;

		player.load(level.player, true);
		player.screenCenter(X);
		player.y = blackBottom.y - player.height - 30;

		gf.load(level.gf);
		gf.x = FlxG.width - gf.width / 2 - 250;
		gf.y = blackBottom.y - gf.height - 30;

		// Applies exit movers
		exitMovers.add(opponent, -opponent.width);
		exitMovers.add(player, -player.width);
		exitMovers.add(gf, -gf.width);

		changeDiff(selectedDiff);
	}

	function changeDiff(selected:Int)
	{
		selectedDiff = selected;
		levelScore = Save.instance.getLevelScore(level.id, difficulty);

		diffText.x = FlxG.width - diffText.width / 2 - 220;

		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(INTERACTING);

		FlxTimer.wait(0.1, () -> stateMachine.reset());
	}

	function confirm()
	{
		if (!stateMachine.canInteract())
			return;

		// Can't play a level with no songs :(
		if (level.getSongs().length == 0)
		{
			FunkinSound.playOnce('ui/sounds/cancel');
			return;
		}

		stateMachine.transition(INTERACTING);
		titleGroup.title.flicker();

		player.playAnimation('confirm');

		FunkinSound.playOnce('ui/sounds/confirm');
		FlxTimer.wait(1, () ->
		{
			camera.fade(0xFF000000, 0.25, false, () ->
			{
				PlayState.difficulty = difficulty;

				Playlist.reset(level);
				Playlist.songs = level.getSongs().copy();
				Playlist.load();

				FlxG.switchState(() -> new PlayState());
			});
		});
	}

	function intro()
	{
		stateMachine.transition(TRANSITIONING);

		exitMovers.intro();
		exitMovers.onIntroDone = stateMachine.reset;
	}

	function exit()
	{
		if (!stateMachine.canInteract())
			return;
		stateMachine.transition(TRANSITIONING);

		exitMovers.outro();
		exitMovers.onOutroDone = close;

		FunkinSound.playOnce('ui/sounds/cancel');
	}

	@:noCompletion
	inline function get_level():Level
	{
		return titleGroup.level;
	}

	@:noCompletion
	inline function get_difficulty():String
	{
		return diffText.difficulty;
	}

	public static function build(skipIntro:Bool = true):FunkinState
	{
		var menu:MainMenuState = new MainMenuState();
		menu.openSubState(new StoryMenuSubState(skipIntro));
		return menu;
	}
}

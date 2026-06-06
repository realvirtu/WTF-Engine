package funkin.save;

import funkin.data.song.SongRegistry;
import funkin.data.story.LevelRegistry;
import funkin.play.song.Song;
import funkin.save.SaveData.SaveOptionsData;
import funkin.ui.story.Level;
import haxe.ds.StringMap;

/**
 * A class for saving and loading data.
 */
class Save
{
	public static var instance:Save;

	public var scores(get, never):StringMap<Int>;
	public var favorites(get, never):StringMap<Bool>;
	public var options(get, never):SaveOptionsData;

	var data:SaveData;

	public function new()
	{
		// Loads default data if there is none
		// Hehe merge
		FlxG.save.mergeData(getDefault());

		data = FlxG.save.data;

		//
		// LOAD
		//

		FlxG.drawFramerate = options.fpsCap;
		FlxG.updateFramerate = options.fpsCap;

		#if HAS_FPS_COUNTER
		Main.fpsCounter.visible = options.showFPS;
		Main.fpsCounter.bg.alpha = options.fpsBGOpacity / 100;
		#end

		#if HAS_DISCORD_RPC
		if (options.discordRPC)
			DiscordRPC.start();
		#end
	}

	public function flush()
	{
		FlxG.save.mergeData(data, true);
		FlxG.save.flush();
	}

	//
	// SONG
	//

	public function setSongScore(id:String, diff:String, score:Int, force:Bool = true)
	{
		return setScore('song-$id', diff, score, force);
	}

	public function getSongScore(id:String, diff:String)
	{
		return getScore('song-$id', diff);
	}

	public function setFavorite(id:String, ?variation:String, favorite:Bool)
	{
		if (variation?.isEmpty())
			variation = null;
		variation ??= Constants.DEFAULT_VARIATION;

		// Don't favorite the song if it's already favorited
		if (isSongFavorited(id, variation) == favorite)
			return;

		favorites.set('$id:$variation', favorite);

		if (favorite)
			trace('Favorited song $id ($variation).');
		else
			trace('Unfavorited song $id ($variation).');

		flush();
	}

	public function isSongFavorited(id:String, ?variation:String):Bool
	{
		if (variation?.isEmpty())
			variation = null;

		variation ??= Constants.DEFAULT_VARIATION;

		return favorites.get('$id:$variation') ?? false;
	}

	public function isSongComplete(id:String):Bool
	{
		var song:Song = SongRegistry.instance.fetchSong(id);

		if (song == null)
			return false;

		for (diff in song.difficulties)
		{
			if (getSongScore(song.id, diff) > 0)
				return true;
		}

		return false;
	}

	//
	// LEVEL
	//

	public function setLevelScore(id:String, diff:String, score:Int, force:Bool = true)
	{
		return setScore('level-$id', diff, score, force);
	}

	public function getLevelScore(id:String, diff:String):Int
	{
		return getScore('level-$id', diff);
	}

	public function isLevelComplete(id:String):Bool
	{
		var level:Level = LevelRegistry.instance.fetch(id);

		if (level == null)
			return false;

		for (diff in SongRegistry.instance.getDifficulties())
		{
			for (song in level.getSongs())
			{
				if (getScore(song, diff) > 0)
					return true;
			}
		}

		return false;
	}

	//
	// SCORE
	//

	function setScore(id:String, diff:String, score:Int, force:Bool = true)
	{
		// Don't save the score if it wasn't beaten
		if (score <= getScore(id, diff) && !force)
			return;
		scores.set('$id-$diff', score);

		trace('Updated score for $id to $score.');

		flush();
	}

	function getScore(id:String, diff:String):Int
	{
		return scores.get('$id-$diff') ?? 0;
	}

	//
	// GETTERS
	//

	@:noCompletion
	inline function get_scores():StringMap<Int>
	{
		return data.scores;
	}

	@:noCompletion
	inline function get_favorites():StringMap<Bool>
	{
		return data.favorites;
	}

	@:noCompletion
	inline function get_options():SaveOptionsData
	{
		return data.options;
	}

	inline function getDefault():SaveData
	{
		return {
			scores: new StringMap<Int>(),
			favorites: new StringMap<Bool>(),
			options: {
				downscroll: false,
				ghostTapping: true,
				showTimer: true,
				showFPS: true,
				fpsBGOpacity: 50,
				discordRPC: true,
				fpsCap: 200
			}
		}
	}
}

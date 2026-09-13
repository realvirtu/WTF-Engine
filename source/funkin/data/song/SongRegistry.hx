package funkin.data.song;

import funkin.data.song.SongData;
import funkin.data.story.LevelRegistry;
import funkin.play.song.Song;
import funkin.ui.freeplay.player.Player;
import funkin.ui.story.Level;
import funkin.util.FileUtil;
import funkin.util.SortUtil;
import json2object.JsonParser;

/**
 * A registry class for loading songs.
 */
class SongRegistry extends BaseRegistry<Song>
{
	public static var instance:SongRegistry;

	var metaParser(default, null) = new JsonParser<SongMetadata>();
	var chartParser(default, null) = new JsonParser<SongChartData>();

	var sorted:Array<String>;
	var diffs:Array<String>;

	public function new()
	{
		super('songs', 'gameplay/songs');
	}

	override function load()
	{
		super.load();

		sorted = null;
		diffs = null;

		//
		// VANILLA
		//

		for (id in FileUtil.listFolders(path))
		{
			final metaPath:String = Paths.json('$path/$id/meta');
			final chartPath:String = Paths.json('$path/$id/chart');

			// Skip the song if it doesn't have a chart or metadata file
			if (!Paths.exists(metaPath) || !Paths.exists(chartPath))
				continue;

			var song:Song = new Song(id, Constants.DEFAULT_VARIATION);

			song.meta = metaParser.fromJson(FileUtil.getText(metaPath));
			song.chart = chartParser.fromJson(FileUtil.getText(chartPath));

			register(id, song);

			// Checks for variations
			for (variation in FileUtil.listFolders('$path/$id'))
			{
				final metaPath:String = Paths.json('$path/$id/$variation/meta');
				final chartPath:String = Paths.json('$path/$id/$variation/chart');

				// Skip the variation if it doesn't have a chart or metadata file
				if (!Paths.exists(metaPath) || !Paths.exists(chartPath))
					continue;

				var songVariation:Song = new Song(id, variation);

				song.variations.set(variation, songVariation);

				songVariation.meta = metaParser.fromJson(FileUtil.getText(metaPath));
				songVariation.chart = chartParser.fromJson(FileUtil.getText(chartPath));
			}
		}

		//
		// SCRIPTED
		//

		final scripts:Array<String> = Song.listScriptClasses();

		trace('Loading ${scripts.length} scripted song(s)...'.info());

		for (script in scripts)
		{
			try
			{
				var song:Song = Song.scriptInit(script, '');
				var ogSong:Song = fetch(song.id);

				if (ogSong == null)
					continue;

				if (song.variation == null || song.variation.isEmpty())
					song.variation = Constants.DEFAULT_VARIATION;

				if (song.variation == Constants.DEFAULT_VARIATION)
					entries.set(song.id, song);
				else
				{
					var ogVariation:Song = ogSong.getVariation(song.variation);

					ogSong.variations.set(song.variation, song);
					ogSong = ogVariation;
				}

				song.meta = ogSong.meta;
				song.chart = ogSong.chart;
				song.variations = ogSong.variations;
			}
			catch (e)
				trace('Failed to load script $script.'.error());
		}
	}

	public function getDifficulties():Array<String>
	{
		// Use a cached array to make it real easy for the engine
		if (diffs != null)
			return diffs;

		diffs = [];

		for (song in entries)
		{
			for (diff in song.getDifficulties())
			{
				// Skip the difficulty if it's already in the list
				if (diffs.contains(diff))
					continue;
				diffs.push(diff);
			}
		}

		return diffs;
	}

	public function listWithDifficulty(diff:String, player:Player):Array<Song>
	{
		final result:Array<Song> = [];

		for (id in listSorted())
		{
			// Check if the song fits the difficulty and player specified
			final song:Song = SongRegistry.instance.fetch(id);

			if (song.hasDifficulty(diff, false) && player.isOwner(song.player))
			{
				result.push(song);
				continue;
			}

			// If the song doesn't work, check for a variation that works
			final variation:Song = song.variations.find(song -> return song.hasDifficulty(diff) && player.isOwner(song.player));

			if (variation != null)
			{
				result.push(variation);
				continue;
			}
		}

		return result;
	}

	override function listSorted():Array<String>
	{
		if (sorted != null)
			return sorted;

		sorted = list();

		final songs:Array<String> = [];

		for (id in LevelRegistry.instance.listSorted())
		{
			final level:Level = LevelRegistry.instance.fetch(id);

			for (song in level.getSongs())
			{
				if (songs.contains(song))
					continue;
				songs.push(song);
			}
		}

		sorted.sort(SortUtil.defaultsAlphabetically.bind(songs.concat(listDefaults())));

		return sorted;
	}

	override function listDefaults():Array<String>
	{
		return ['test', 't'];
	}
}

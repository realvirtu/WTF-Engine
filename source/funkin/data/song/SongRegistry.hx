package funkin.data.song;

import funkin.data.song.SongData;
import funkin.data.story.LevelRegistry;
import funkin.modding.ScriptBases.ScriptedSong;
import funkin.play.song.Song;
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

	var diffs:Array<String>;

	public function new()
	{
		super('songs', 'play/songs');
	}

	override public function load()
	{
		super.load();

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

		var scripts:Array<String> = ScriptedSong.listScriptClasses();

		trace('Loading ${scripts.length} scripted song(s)...');

		for (script in scripts)
		{
			try
			{
				var song:Song = ScriptedSong.scriptInit(script, '');
				var ogSong:Song = fetch(song.id);

				// Allows variations to have unique scripts :D
				// Only if the variation isn't the default one though
				if (song.variation?.isEmpty())
					song.variation = null;
				song.variation ??= Constants.DEFAULT_VARIATION;

				if (song.variation != Constants.DEFAULT_VARIATION)
				{
					ogSong = ogSong.getVariation(song.variation);

					// Can't use ogSong because it just wouldn't work
					// This is honestly better than the game crashing
					fetch(song.id).variations.set(song.variation, song);
				}
				else
					entries.set(song.id, song);

				song.meta = ogSong.meta;
				song.chart = ogSong.chart;
				song.variations = ogSong.variations;

				for (variation in song.variations.keys())
				{
					var songVariation:Song = ScriptedSong.scriptInit(script, '');
					var ogVariation:Song = ogSong.getVariation(variation);

					songVariation.meta = ogVariation.meta;
					songVariation.chart = ogVariation.chart;
					songVariation.variation = ogVariation.variation;

					song.variations.set(variation, songVariation);
				}
			}
			catch (e)
				trace('Failed to load script $script.');
		}
	}

	public function fetchSong(id:String, ?diff:String):Song
	{
		var song:Song = fetch(id);

		for (variation in song.variations)
		{
			if (variation.hasDifficulty(diff))
				return variation;
		}

		return song;
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

	public function listWithDifficulty(diff:String):Array<String>
	{
		var list:Array<String> = [];

		// List songs through levels to ensure proper order
		for (id in LevelRegistry.instance.listSorted())
		{
			var level:Level = LevelRegistry.instance.fetch(id);

			for (id in level.getSongs())
			{
				var song:Song = fetchSong(id);

				if (list.contains(id) || !song.hasDifficulty(diff))
					continue;
				list.push(id);
			}
		}

		// List songs through the entries themselves
		// Because not every song has a level
		for (id in listSorted())
		{
			var song:Song = fetch(id);

			if (list.contains(id) || !song.difficulties.contains(diff))
				continue;
			list.push(id);
		}

		return list;
	}

	public function listSorted():Array<String>
	{
		var list:Array<String> = list();
		list.sort(SortUtil.defaultsAlphabetically.bind(Constants.DEFAULT_SONGS));
		return list;
	}
}

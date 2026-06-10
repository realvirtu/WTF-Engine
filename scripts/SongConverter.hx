#if !interp
package scripts;

#end
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * A class for converting a V-Slice song to a song that the engine can take.
 * This is kinda taken from Funkin'.
 * 
 * TODO: Remove this once V-Slice songs can be converted.
 * 
 * Usage: Run `haxe --run SongConverter` from `scripts`.
 */
class SongConverter
{
	static function main()
	{
		Sys.stdout().writeString('Song directory: ');
		Sys.stdout().flush();

		final songDir:String = Sys.stdin().readLine();

		Sys.stdout().writeString('Variation: ');
		Sys.stdout().flush();

		final variation:String = Sys.stdin().readLine();

		// Retrieves the song id
		var songName:String = songDir;
		var isVariation:Bool = variation != 'default' && variation != '';

		songName = songName.replace('\\', '/');
		songName = songName.substr(songName.lastIndexOf('/') + 1);

		// Converts the song
		var metaPath:String = '$songDir/$songName-metadata';
		var chartPath:String = '$songDir/$songName-chart';

		if (isVariation)
		{
			metaPath += '-$variation';
			chartPath += '-$variation';
		}

		metaPath += '.json';
		chartPath += '.json';

		if (!FileSystem.exists(metaPath) || !FileSystem.exists(chartPath))
		{
			trace('Failed to convert song. Chart or metadata is missing!');
			return;
		}

		var meta:Dynamic = Json.parse(File.getContent(metaPath));
		var chart:Dynamic = Json.parse(File.getContent(chartPath));

		var timeChanges:Array<Dynamic> = meta.timeChanges;

		var wtfMeta:Dynamic = {}
		var wtfChart:Dynamic = {}

		wtfMeta.name = meta.songName;
		wtfMeta.bpm = timeChanges[0].bpm;
		wtfMeta.artist = meta.artist;
		wtfMeta.style = meta.playData.noteStyle;
		wtfMeta.difficulties = meta.playData.difficulties;
		wtfMeta.rating = meta.playData.ratings;
		wtfMeta.album = meta.playData.album;
		wtfMeta.stage = meta.playData.stage;
		wtfMeta.player = meta.playData.characters.player;
		wtfMeta.opponent = meta.playData.characters.opponent;
		wtfMeta.gf = meta.playData.characters.girlfriend;

		wtfChart.speed = chart.scrollSpeed;
		wtfChart.notes = chart.notes;
		wtfChart.events = [];

		for (event in chart.events ?? [])
		{
			var wtfEvent:Dynamic = {}

			var kind:String = '';
			var value:Dynamic = {}

			switch (event.e)
			{
				case 'FocusCamera':
					kind = 'focus-camera';

					var c:Dynamic = event.v.char;

					if (Std.isOfType(c, String))
						c = Std.parseInt(c);

					if (Type.typeof(event.v) == TInt)
						c = event.v;

					// Swap char because fuck
					if (c == 0)
						c = 1;
					else if (c == 1)
						c = 0;

					value.c = c;
				case 'PlayAnimation':
					kind = 'play-animation';

					var target:String = event.v.target;
					var c:Int = 0;

					if (target == 'boyfriend' || target == 'bf')
						c = 1;
					if (target == 'girlfriend' || target == 'gf')
						c = 2;

					value.c = c;
					value.a = event.v.anim;
					value.f = event.v.force;
				default:
					continue;
			}

			wtfEvent.t = event.t;
			wtfEvent.e = kind;
			wtfEvent.v = value;

			wtfChart.events.push(wtfEvent);
		}

		for (timeChange in timeChanges)
		{
			// Don't include the first time change
			if (timeChange.t == 0)
				continue;

			var time:Float = timeChange.t;
			var bpm:Float = timeChange.bpm;

			wtfChart.events.push({t: time, e: 'change-bpm', v: {b: bpm}});
		}

		wtfChart.events.sort((a, b) -> return a.t - b.t);

		// Saves the final song
		var output:String = '../assets/gameplay/songs/$songName';

		if (isVariation)
			output += '/$variation';

		FileSystem.createDirectory(output);

		File.saveContent('$output/meta.json', Json.stringify(wtfMeta, '\t'));
		File.saveContent('$output/chart.json', Json.stringify(wtfChart, '\t'));

		trace('Done converting song $songName ($variation).');
	}
}

#if !interp
package scripts;

#end
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

/**
 * From `scripts`, run `haxe --run SongConverter` to convert a song or all songs.
 */
class SongConverter
{
	static final WTF_SONGS:String = '../assets/gameplay/songs';

	static var path:String;
	static var variation:String;

	static function main()
	{
		Sys.stdout().writeString('V-Slice songs path: ');
		Sys.stdout().flush();

		path = Sys.stdin().readLine();

		Sys.stdout().writeString('Song (Leave blank to convert all): ');
		Sys.stdout().flush();

		final song:String = Sys.stdin().readLine();

		Sys.stdout().writeString('Variation: ');
		Sys.stdout().flush();

		variation = Sys.stdin().readLine();

		if (song != '')
			return convertSong(song);

		for (song in FileSystem.readDirectory(WTF_SONGS))
			convertSong(song);
	}

	static function convertSong(id:String)
	{
		trace('Converting song $id...');

		var suffix:String = '';
		if (variation != 'default' && variation != '')
			suffix = '-$variation';

		final path:String = '$path/$id';
		final metaPath:String = '$path/$id-metadata$suffix.json';
		final chartPath:String = '$path/$id-chart$suffix.json';

		if (!FileSystem.exists(metaPath) || !FileSystem.exists(chartPath))
			return trace('$id is NOT a valid song.');

		var path:String = '$WTF_SONGS/$id';
		if (variation != 'default' && variation != '')
			path += '/$variation';

		var meta:Dynamic = Json.parse(File.getContent(metaPath));
		var chart:Dynamic = Json.parse(File.getContent(chartPath));

		chart = convertChart(chart, meta.timeChanges.copy());
		meta = convertMeta(meta);

		FileSystem.createDirectory(path);

		File.saveContent('$path/meta.json', Json.stringify(meta, '\t'));
		File.saveContent('$path/chart.json', Json.stringify(chart, '\t'));
	}

	static function convertMeta(meta:Dynamic):Dynamic
	{
		return {
			name: meta.songName,
			bpm: meta.timeChanges[0].bpm,
			artist: meta.artist,
			charter: meta.charter,
			difficulties: meta.playData.difficulties,
			rating: meta.playData.ratings,
			album: meta.playData.album,
			style: meta.playData.noteStyle,
			stage: meta.playData.stage,
			player: meta.playData.characters.player,
			opponent: meta.playData.characters.opponent,
			gf: meta.playData.characters.girlfriend
		}
	}

	static function convertChart(chart:Dynamic, timeChanges:Array<Dynamic>):Dynamic
	{
		timeChanges.shift();

		// Converts events
		var events:Array<Dynamic> = [];

		for (event in chart.events ?? [])
			convertEvent(event, events);
		for (timeChange in timeChanges)
			events.push({t: timeChange.t, e: 'change-bpm', v: {b: timeChange.bpm}});

		events.sort((a, b) -> return a.t - b.t);

		return {
			speed: chart.scrollSpeed,
			notes: chart.notes,
			events: events
		}
	}

	static function convertEvent(event:Dynamic, output:Array<Dynamic>)
	{
		var kind:String = event.e;
		var value:Dynamic = {}

		switch (kind)
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
				return;
		}

		output.push({t: event.t, e: kind, v: value});
	}
}

#if !interp
package scripts;

#end
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * From `scripts`, run `haxe --run SongConverter` to convert a song or all songs.
 */
class SongConverter
{
	static final WTF_SONGS:String = '../assets/gameplay/songs';

	static var path:String;
	static var variation:String;

	static var song:String;

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

		song = id;

		var suffix:String = '';
		if (variation != 'default' && variation != '')
			suffix = '-$variation';

		final path:String = '$path/$id';
		final metaPath:String = '$path/$id-metadata$suffix.json';
		final chartPath:String = '$path/$id-chart$suffix.json';

		if (!FileSystem.exists(metaPath) || !FileSystem.exists(chartPath))
			return trace('$id$suffix is NOT a valid song.');

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
		var meta:Dynamic = {
			name: meta.songName,
			bpm: meta.timeChanges[0].bpm,
			artist: meta.artist,
			charter: meta.charter,
			difficulties: meta.playData.difficulties,
			rating: meta.playData.ratings,
			album: meta.playData.album,
			style: meta.playData.noteStyle,
			stage: convertStage(meta.playData.stage),
			player: convertCharacter(meta.playData.characters.player),
			opponent: convertCharacter(meta.playData.characters.opponent),
			gf: convertCharacter(meta.playData.characters.girlfriend)
		}

		if (song == 'tutorial')
			meta.gf = meta.opponent;

		return meta;
	}

	static function convertStage(id:String):String
	{
		if (id == null)
			return id;

		if (id.endsWith('Erect'))
			id = id.replace('Erect', '');

		return switch (id)
		{
			case 'mainStage':
				'stage';
			case 'spookyMansion':
				'spooky';
			case 'phillyTrain':
				'philly-train';
			case 'limoRide':
				'limo';
			case 'mallXmas':
				'mall';
			case 'mallEvil':
				'mall-evil';
			case 'schoolEvil':
				'school-evil';
			case 'tankmanBattlefield':
				'tank';
			case 'phillyStreets' | 'phillyBlazin':
				'philly-streets';
			default:
				id;
		}
	}

	static function convertCharacter(id:String):String
	{
		if (id == null)
			return id;

		if (id.endsWith('-car'))
			id = id.replace('-car', '');
		if (id.endsWith('-dark'))
			id = id.replace('-dark', '');
		if (id.endsWith('-playable'))
			id = id.replace('-playable', '');

		return switch (id)
		{
			case 'gf-tankmen':
				'gf-tankman';
			case 'parents-christmas':
				'parents';
			default:
				id;
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

		// Converts notes
		var notes:Dynamic = chart.notes;

		convertNotes(notes);

		return {
			speed: chart.scrollSpeed,
			notes: notes,
			events: events
		}
	}

	static function convertNotes(notes:Dynamic)
	{
		if (notes == null)
			return;

		for (diff in Reflect.fields(notes))
		{
			final notes:Array<Dynamic> = Reflect.field(notes, diff);

			for (note in notes)
			{
				if (note?.k == null)
					continue;

				if (song == 'blazin')
				{
					Reflect.deleteField(note, 'k');
					continue;
				}

				var k:String = note.k;

				if (k?.startsWith('weekend-1-'))
					k = k.replace('weekend-1-', '');

				switch (k)
				{
					case 'mom':
						k = 'alt';
					case 'noanim':
						k = 'no-anim';
					case 'hehPrettyGood':
						k = 'pretty-good';
					case 'lightcan':
						k = 'light-can';
					case 'kickcan':
						k = 'kick-can';
					case 'kneecan':
						k = 'knee-can';
					case 'cockgun':
						k = 'cock-gun';
					case 'firegun':
						k = 'fire-gun';
					default:
						// lmao do nothing
				}

				note.k = k;
			}
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
			case 'ZoomCamera':
				kind = 'zoom-camera';

				value.z = event.v.zoom;
				value.e = event.v.ease;

				if (event.v.duration != null)
					value.d = event.v.duration;

				if (event.v.easeDir != null)
					value.e += event.v.easeDir;
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

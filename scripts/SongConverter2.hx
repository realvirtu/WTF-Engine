import funkin.data.song.SongData.SongChartData;
import funkin.data.song.SongData.SongMetadata;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

#if !interp
package scripts;

#end
class SongConverter2
{
	static final WTF_SONGS:String = '../assets/gameplay/songs';

	static var path:String;

	static function main()
	{
		Sys.stdout().writeString('V-Slice songs path: ');
		Sys.stdout().flush();

		path = Sys.stdin().readLine();

		for (song in FileSystem.readDirectory(WTF_SONGS))
			convertSong(song);
	}

	static function convertSong(id:String)
	{
		trace('Converting song $id...');

		final path:String = '$path/$id';
		final metaPath:String = '$path/$id-metadata.json';
		final chartPath:String = '$path/$id-chart.json';

		if (!FileSystem.exists(metaPath) || !FileSystem.exists(chartPath))
			return trace('$id is NOT a valid song.');

		var meta:Dynamic = Json.parse(File.getContent(metaPath));
		var chart:Dynamic = Json.parse(File.getContent(chartPath));

		meta = convertMeta(meta);
		chart = convertChart(chart);

		FileSystem.createDirectory('$WTF_SONGS/$id');

		File.saveContent('$WTF_SONGS/$id/meta.json', Json.stringify(meta));
		File.saveContent('$WTF_SONGS/$id/chart.json', Json.stringify(chart));
	}

	static function convertMeta(meta:Dynamic):SongMetadata
	{
		return null;
	}

	static function convertChart(chart:Dynamic):SongChartData
	{
		return null;
	}
}

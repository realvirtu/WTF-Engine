// I know ma'am
// I have to do package source;
package source;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

using tools.AnsiTools;

class PostBuild
{
	public static final BUILD_TIME_FILE:String = '.buildTime';

	static function main()
	{
		if (!FileSystem.exists(BUILD_TIME_FILE))
			return;

		var input:FileInput = File.read(BUILD_TIME_FILE);
		var timestamp:Float = Sys.time() - input.readDouble();

		input.close();

		FileSystem.deleteFile(BUILD_TIME_FILE);

		Sys.println('Build took: ${formatBuildTime(timestamp)}'.info());
	}

	static function formatBuildTime(timestamp:Float):String
	{
		var result:String = '';

		var seconds:Int = Math.floor(timestamp) % 60;
		var minutes:Int = Math.floor(timestamp / 60) % 60;
		var hours:Int = Math.floor(minutes / 60);

		if (hours > 0)
			result += '$hours hour(s), ';
		if (minutes > 0)
			result += '$minutes minute(s), ';

		result += '$seconds second(s)';

		return result;
	}
}

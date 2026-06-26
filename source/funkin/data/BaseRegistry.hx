package funkin.data;

import funkin.util.SortUtil;
import haxe.ds.StringMap;

/**
 * The base class for the game's registries.
 */
class BaseRegistry<T>
{
	public var entries:StringMap<T> = new StringMap<T>();

	public var id:String;
	public var path:String;

	public function new(id:String, ?path:String)
	{
		this.id = id;
		this.path = path ?? this.id;

		load();
	}

	public function load()
	{
		// Clears the entries
		clear();

		// Loading entries should be done through extending this
		// Because you aren't a baby anymore
		// Grow up by extending this class and doing things the WTF Engine way
	}

	public function register(id:String, entry:T)
	{
		if (exists(id))
			trace('$id is already registered under ${this.id}!');
		else
			trace('Registered $id under ${this.id}.');
		entries.set(id, entry);
	}

	public function fetch(id:String):T
	{
		if (!exists(id))
			trace('$id does NOT exist under ${this.id}!');
		return entries.get(id);
	}

	public function list():Array<String>
	{
		return entries.keys().array();
	}

	public function listSorted():Array<String>
	{
		var result:Array<String> = list();
		result.sort(SortUtil.defaultsAlphabetically.bind(listDefaults()));
		return result;
	}

	public function listDefaults():Array<String>
	{
		return [];
	}

	public function exists(id:String):Bool
	{
		return entries.exists(id);
	}

	public function clear()
	{
		entries.clear();
	}
}

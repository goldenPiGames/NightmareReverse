import haxe.Json;
import openfl.Assets;

class Lang {
	public static var selected:String = "en";

	static var data:LangMap;

	public static function get(id:String):String {
		return data[id];
	}

	public static function setLang(name) {

	}

	static function loadData(name) {
		var raw:String = Assets.getText("assets/lang/"+name+".json");
		data = Json.parse(raw);
	}

	public static function ensureLoaded():Void {
		if (data == null) {
			loadData(selected);
		}
	}
}

/**
	thank you, Rudy/rges
*/
abstract LangMap(Dynamic<String>) {
	function new(d:Dynamic<String>) this = d;
	
	@:from
	static function fromDynamic<T>(d:Dynamic):LangMap {
		return new LangMap(cast d);
	}

	@:from
	static function fromDynamicT<T>(d:Dynamic<String>):LangMap {
		return new LangMap(d);
	}
	
	@:op([])
	public function get(key:String):String {
		return Reflect.field(this, key);
	}
}
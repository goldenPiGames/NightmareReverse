package scripting;

import entities.DreamEntity;
import haxe.Json;

class DreamScriptManager {
	var state:PlayState;
	var scripts:Map<String, DreamScript>;

	public function new(data:Dynamic) {
		if (data is String) {
			data = Json.parse(data);
		}
		scripts = new Map<String, DreamScript>();
		for(field in Reflect.fields(data)) {
			scripts.set(field, makeScript(Reflect.field(data, field)));
		}
	}
	
	function makeScript(stuff:Dynamic):DreamScript {
		var what:String = cast stuff.what;
		switch (what) {
			case "dialog": return new DialogScript(stuff);
			default: return null;
		}
	}

	public function setState(instate:PlayState) {
		state = instate;
	}

	public function activate(id:String, origin:DreamEntity) {
		var choosed:DreamScript = scripts.get(id);
		if (choosed != null) {
			choosed.activate(state);
		} else {
			trace("that script does not exist");
		}
	}
}
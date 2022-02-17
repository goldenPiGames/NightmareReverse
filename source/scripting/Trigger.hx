package scripting;

import entities.DreamEntity;
import entities.DreamPlayer;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;

class Trigger extends DreamEntity {
	var scriptID:String;
	
	public function new(args:EntityData) {
		super(args);
		infoName = "trigger";
		touchPriority = 64;
		makeGraphic(args.width, args.height, 0x00000000);
		setSize(args.width, args.height);
		visible = false;
		pathPass = OMNI;
		scriptID = args.values.scriptid;
	}

	public override function touch(other:DreamEntity) {
		if (Std.isOfType(other, DreamPlayer)) {
			activate();
		}
	}

	public function activate() {
		state.activateScript(scriptID, this);
		destroy();
	}

	public override function generalReset():Void {
		
	}
}
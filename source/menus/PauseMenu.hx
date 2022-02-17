package menus;

import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;
import flixel.input.keyboard.FlxKey;

class PauseMenu extends PrxUISubState {
	var unpauseBuffer:Bool;
	public override function create() {
		_xml_id = "pausemenu";
		super.create();
		unpauseBuffer = true;
	}

	public override function update(elapsed:Float) {
		if (Cont.pause.triggered && !unpauseBuffer) {
			//trace("bye");
			unpause();
		} else if (FlxG.keys.pressed.DELETE) {
			exit();
		} else {
			super.update(elapsed);
		}
		unpauseBuffer = false;
	}
	
	public override function getButtonEvent(name:String, params:Array<Dynamic>) {
		switch (params[0]) {
			case "unpause":
				unpause();
			case "returnmain":
				exit();
		}
	}
	
	function unpause():Void {
		close();
	}

	function exit() {
		FlxG.switchState(new MainMenu());
	}
}
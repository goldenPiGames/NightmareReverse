package menus;

import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;
import flixel.input.keyboard.FlxKey;

class PauseMenu extends PrxUISubState {
	public override function create() {
		_xml_id = "pausemenu";
		super.create();
	}

	public override function update(elapsed:Float) {
		if (FlxG.keys.anyJustPressed([FlxKey.P, FlxKey.ESCAPE])) {
			unpause();
		} else {
			super.update(elapsed);
		}
	}
	
	public override function getButtonEvent(name:String, params:Array<Dynamic>) {
		switch (params[0]) {
			case "unpause":
				unpause();
			case "returnmain":
				FlxG.switchState(new MainMenu());
		}
	}
	
	function unpause():Void {
		close();
	}
}
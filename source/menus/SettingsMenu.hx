package menus;

import flixel.FlxG;

class SettingsMenu extends PrxUIState {
	public override function create() {
		_xml_id = "settings";
		super.create();
	}

	public override function getButtonEvent(name:String, params:Array<Dynamic>) {
		switch (params[0]) {
			case "return":
				FlxG.switchState(new MainMenu());
		}
	}
}
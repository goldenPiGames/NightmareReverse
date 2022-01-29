package menus;

import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;

class VictoryMenu extends PrxMenuState {
	public override function create() {
		_xml_id = "victorymenu";
		super.create();
	}
	
	public override function getButtonEvent(name:String, params:Array<Dynamic>) {
		switch (params[0]) {
			case "returnmain":
				FlxG.switchState(new MainMenu());
		}
	}
}
package menus;

import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;

class VictoryMenu extends PrxMenuState {
	public override function create() {
		_xml_id = "mainmenu";
		super.create();
	}

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (destroyed)
			return;
		if (name == "down_button" && params != null && params.length >= 1) {
			if (params[1] == "returnmain") {
				FlxG.switchState(new MainMenu());
			}
		}
	}
}
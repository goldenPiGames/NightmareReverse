package menus;

import flixel.FlxG;

class MainMenu extends PrxMenuState {
	public override function create() {
		_xml_id = "mainmenu";
		super.create();
	}

	public override function getButtonEvent(name:String, params:Array<Dynamic>) {
		switch (params[0]) {
			case "playlevel":
				GameG.levelID = cast params[1];
				FlxG.switchState(new PlayState());
		}
	}
}
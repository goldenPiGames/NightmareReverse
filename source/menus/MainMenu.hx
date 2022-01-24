package menus;

import flixel.FlxG;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;

class MainMenu extends PrxMenuState {
	public override function create() {
		_xml_id = "mainmenu";
		trace("creating");
		super.create();
	}

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		trace(name, params);
		if (destroyed)
			return;
		if (name == "down_button" && params != null && params.length >= 2) {
			GameG.levelID = cast params[1];
			FlxG.switchState(new PlayState());
		}
	}
}
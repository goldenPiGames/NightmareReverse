package states;

import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import ui.PrxUIButton;

class VictoryMenu extends PrxState {
	static inline var BUTTON_WIDTH = 200;
	static inline var BUTTON_HEIGHT = 40;

	public override function create() {
		super.create();
		addUI();
		var butt = new PrxUIButton(FlxG.width/2-BUTTON_WIDTH/2, FlxG.height/3-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT);
		butt.addBackSlice(PrxUIButton.BEVELGREY_PATH, PrxUIButton.BEVELGREY_SLICE);
		butt.addTextLang("Victory_menu");
		butt.setOnClick(exit);
		ui.add(butt);
		ui.startCursorAtFirst();
		ui.connectAuto();
	}

	function exit() {
		FlxG.switchState(new MainMenu());
	}
}
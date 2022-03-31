package states;

import flixel.FlxState;
import ui.PrxUICanvas;

class PrxState extends FlxState {
	/** ui. it's not actually instantiated or added automatically */
	var ui:PrxUICanvas;
	override function create() {
		GameG.ensureSetup();
		super.create();
		//PrxMisc.ensureSetup();
	}

	function addUI() {
		ui = new PrxUICanvas();
		add(ui);
	}
}
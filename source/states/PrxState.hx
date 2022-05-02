package states;

import flixel.FlxG;
import flixel.FlxState;
import ui.PrxUICanvas;

class PrxState extends FlxState {
	/** ui. it's not actually instantiated or added automatically */
	var ui:PrxUICanvas;
	override function create() {
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		GameG.ensureSetup();
		super.create();
		//PrxMisc.ensureSetup();
	}

	function addUI() {
		ui = new PrxUICanvas();
		add(ui);
	}

	override function update(elapsed) {
		FlxG.watch.addQuick("elapsed", elapsed);
		super.update(elapsed);
	}
}
package states;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.input.keyboard.FlxKey;
import ui.PrxUIButton;
import ui.PrxUICanvas;

class PauseMenu extends FlxSubState {
	var ui:PrxUICanvas;
	var unpauseBuffer:Bool;
	static inline var BUTTON_WIDTH = 200;
	static inline var BUTTON_HEIGHT = 40;

	public override function create() {
		super.create();
		unpauseBuffer = true;
		ui = new PrxUICanvas();
		add(ui);
		var butt = new PrxUIButton(FlxG.width/2-BUTTON_WIDTH/2, FlxG.height/3-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT);
		butt.addBackSlice(PrxUIButton.BEVELGREY_PATH, PrxUIButton.BEVELGREY_SLICE);
		butt.addTextLang("Pause_unpause");
		butt.setOnClick(unpause);
		ui.add(butt);
		ui.startCursorAt(butt);
		butt = new PrxUIButton(FlxG.width/2-BUTTON_WIDTH/2, FlxG.height*2/3-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT);
		butt.addBackSlice(PrxUIButton.BEVELGREY_PATH, PrxUIButton.BEVELGREY_SLICE);
		butt.addTextLang("Pause_exit");
		butt.setOnClick(exit);
		ui.add(butt);
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
	
	function unpause():Void {
		close();
	}

	function exit() {
		FlxG.switchState(new MainMenu());
	}

	public function setState(stab:PlayState) {
		//TODO
	}
}
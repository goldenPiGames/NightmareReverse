package states;

import flixel.FlxG;
import flixel.math.FlxRect;
import ui.PrxUIButton;
import ui.PrxUICanvas;

class MainMenu extends PrxState {
	public override function create() {
		super.create();
		addUI();
		ui.add(new LevelStartButton(40, 40, "LucidTutorial"));
		ui.add(new LevelStartButton(40, 160, "DeepWoods"));
		ui.add(new LevelStartButton(400, 40, "test"));
		ui.add(new LevelStartButton(400, 160, "testsmall"));
		ui.startCursorAtFirst();
	}
}

class LevelStartButton extends PrxUIButton {
	var levelID:String;
	public function new(x, y, id) {
		super(x, y, 300, 40);
		levelID = id;
		addBackSlice(PrxUIButton.BEVELGREY_PATH, PrxUIButton.BEVELGREY_SLICE);
		addTextLang("level_"+id);
	}
	override function activate() {
		GameG.levelID = levelID;
		FlxG.switchState(new PlayState());
	}
}
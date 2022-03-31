package hud;

import flixel.FlxBasic;
import flixel.FlxG;
import misc.PrxTypedGroup;
import states.PlayState;

class DreamHUD extends PrxTypedGroup<FlxBasic> {
	var state:PlayState;
	public var dialog:Dialog;
	var dreamstones:DreamstoneDisplay;
	var enemies:EnemiesDisplay;

	public function new(instate:PlayState) {
		super();
		state = instate;
		dialog = new Dialog(FlxG.width*.2, FlxG.height*.6, FlxG.width*.6, 24);
		add(dialog);
		dreamstones = new DreamstoneDisplay(FlxG.width-100, 100, 100, state);
		add(dreamstones);
		enemies = new EnemiesDisplay(FlxG.width-100, 125, 100, state);
		add(enemies);
		GameG.toStaticCam(this);
	}
}
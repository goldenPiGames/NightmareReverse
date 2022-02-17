package hud;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class DreamHUD extends FlxTypedGroup<FlxBasic> {
	var state:PlayState;
	public var dialog:Dialog;
	var dreamstones:DreamstoneDisplay;
	var enemies:EnemiesDisplay;

	public function new(instate:PlayState) {
		super();
		state = instate;
		cameras = [new FlxCamera(0, 0, FlxG.width, FlxG.height, 1)];
		FlxG.cameras.add(camera, false);
		camera.bgColor = FlxColor.TRANSPARENT;
		dialog = new Dialog(FlxG.width*.2, FlxG.height*.6, FlxG.width*.6, 24);
		add(dialog);
		dreamstones = new DreamstoneDisplay(FlxG.width-100, 100, 100, state);
		add(dreamstones);
		enemies = new EnemiesDisplay(FlxG.width-100, 125, 100, state);
		add(enemies);
		//FlxG.watch.add(camera, "x");
	}
}
package hud;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class DreamHUD extends FlxTypedGroup<FlxBasic> {
	var state:PlayState;
	var dreamstones:DreamstoneDisplay;
	var enemies:EnemiesDisplay;

	public function new(instate:PlayState) {
		super();
		state = instate;
		cameras = [new FlxCamera(0, 0, FlxG.width, FlxG.height, 1)];
		FlxG.cameras.add(camera, false);
		camera.bgColor = FlxColor.TRANSPARENT;
		dreamstones = new DreamstoneDisplay(FlxG.width-100, 100, 100, state);
		add(dreamstones);
		enemies = new EnemiesDisplay(FlxG.width-100, 125, 100, state);
		add(enemies);
	}
}
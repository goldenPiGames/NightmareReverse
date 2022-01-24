package hud;

import flixel.text.FlxText;

class EnemiesDisplay extends FlxText {
	var state:PlayState;
	var lastCount:Int = -1;

	public function new(inx:Float, iny:Float, width:Float, instate:PlayState) {
		super(inx, iny, width, "Enemies");
		state = instate;
	}

	public override function update(elapsed:Float) {
		if (state.numEnemiesAlive != lastCount) {
			lastCount = state.numEnemiesAlive;
			text = "Enemies: "+lastCount;
		}
		super.update(elapsed);
	}
}
package hud;

import flixel.text.FlxText;

class DreamstoneDisplay extends FlxText {
	var state:PlayState;
	var lastCollected:Int = -1;

	public function new(inx:Float, iny:Float, width:Float, instate:PlayState) {
		super(inx, iny, width, "Dreamstones");
		state = instate;
	}

	public override function update(elapsed:Float) {
		if (state.dreamstonesCollected != lastCollected) {
			lastCollected = state.dreamstonesCollected;
			text = "Dreamstones: "+lastCollected+"/"+state.dreamstonesTotal;
		}
		super.update(elapsed);
	}
}
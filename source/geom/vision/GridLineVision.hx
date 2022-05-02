package geom.vision;

import flixel.FlxG;
import flixel.math.FlxPoint;
import geom.vision.Vision.VisionState;

class GridLineVision extends Vision {

	public function new(thestate:VisionState) {
		super(thestate);
		
		fog = new GridLineFogLayer();
		add(fog);
		fog.camera = FlxG.camera;
		fog.setVision(this);
	}

	override function update(elapsed:Float):Void {
		updatePre(elapsed);
		super.update(elapsed);
	}

	public function isVisibleAt(x:Float, y:Float):Bool {
		return map.rayVision(eyePos, FlxPoint.weak(x, y));
	}
}
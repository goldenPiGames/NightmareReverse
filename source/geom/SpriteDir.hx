package geom;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.util.FlxDirectionFlags;

class SpriteDir {
	public var prefix:String = "";
	public var flip:Bool = false;

	public function setAngle(looking:Float) {
		
	}

	function toString() {
		return prefix + (flip ? "F" : "");
	}
}

class SpriteDirStatic extends SpriteDir {
	public function new() {};
}

class SpriteDirSingleFlip extends SpriteDir {
	public function new() {};

	public override function setAngle(looking:Float) {
		var abdominals:Float = Math.abs(FlxAngle.wrapAngle(looking));
		if (abdominals > 91)
			flip = true;
		else if (abdominals < 89)
			flip = false;
	}
}

class SpriteDirOrthog3 extends SpriteDir {
	public function new() {
		prefix = "d";
	};

	public override function setAngle(looking:Float) {
		//FlxG.log.add(FlxAngle.wrapAngle(looking) / 90);
		
		switch ((Math.round(FlxAngle.wrapAngle(looking) / 90) + 4) % 4) {
			case 0: prefix = "s"; flip = false;
			case 1: prefix = "d"; flip = false;
			case 2: prefix = "s"; flip = true;
			case 3: prefix = "u"; flip = false;
		}
	}
}
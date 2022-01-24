package geom;

import flixel.util.FlxDirectionFlags;

class ClearWays {
	public var up:Bool;
	public var down:Bool;
	public var left:Bool;
	public var right:Bool;

	public function new(starting:Bool) {
		up = starting;
		down = starting;
		left = starting;
		right = starting;
	}

	public function getFacing(face:FlxDirectionFlags):Bool {
		switch (face) {
			case UP: return up;
			case DOWN: return down;
			case LEFT: return left;
			case RIGHT: return right;
			default: return true;
		}
	}

	public function getPrefFRLB(face:FlxDirectionFlags):FlxDirectionFlags {
		if (getFacing(face))
			return face;
		else if (getFacing(clockwiseOf(face)))
			return clockwiseOf(face);
		else if (getFacing(anticlockwiseOf(face)))
			return anticlockwiseOf(face);
		else
			return oppositeOf(face);
	}

	public static function clockwiseOf(face:FlxDirectionFlags):FlxDirectionFlags {
		switch (face) {
			case UP: return RIGHT;
			case RIGHT: return DOWN;
			case DOWN: return LEFT;
			case LEFT: return UP;
			default: return NONE;
		}
	}

	public static function anticlockwiseOf(face:FlxDirectionFlags):FlxDirectionFlags {
		switch (face) {
			case UP: return LEFT;
			case RIGHT: return UP;
			case DOWN: return RIGHT;
			case LEFT: return DOWN;
			default: return NONE;
		}
	}

	public static function oppositeOf(face:FlxDirectionFlags):FlxDirectionFlags {
		switch (face) {
			case UP: return DOWN;
			case RIGHT: return LEFT;
			case DOWN: return UP;
			case LEFT: return RIGHT;
			default: return NONE;
		}
	}
}
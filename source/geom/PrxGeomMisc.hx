package geom;

import flixel.math.FlxPoint;

class PrxGeomMisc {
	public static function arePointsColinear(a:FlxPoint, b:FlxPoint, c:FlxPoint):Bool {
		if ((a.x == b.x && b.x == c.x) || (a.y == b.y && b.y == c.y)) {
			return true;
		}
		//do something with slopes for diagonals
		return false;
	}
}
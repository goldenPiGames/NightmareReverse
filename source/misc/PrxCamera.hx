package misc;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxRect;

class PrxCamera extends FlxCamera {
	public var marker:String;

	override function toString() {
		return marker;
	}

	public function getWorldRect(?rect:FlxRect):FlxRect {
			rect = getViewRect(rect);
			rect.x += scroll.x;
			rect.y += scroll.y;
			return rect;
		}
}
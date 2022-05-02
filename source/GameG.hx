package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import geom.vision.Vision;
import misc.PrxCamera;

class GameG {
	public static var levelID:String;

	public static var movingCam:PrxCamera;
	public static var staticCam:PrxCamera;

	static var setup:Bool = false;

	public static function ensureSetup() {
		Lang.ensureLoaded();
		Cont.ensureLoaded();
		resetCameras();
		if (!setup) {
			FlxG.console.registerClass(GameG);
			FlxG.console.registerClass(Vision);
			setup = true;
		}
	}

	static function resetCameras() {
		movingCam = new PrxCamera(0, 0, FlxG.width, FlxG.height, 1);
		staticCam = new PrxCamera(0, 0, FlxG.width, FlxG.height, 1);
		movingCam.marker = "moving";
		staticCam.marker = "static";
		staticCam.bgColor = FlxColor.BLACK;
		staticCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.reset(movingCam);
		FlxG.cameras.add(staticCam, false);
		trace(FlxG.cameras.list);
	}

	public static function toStaticCam(thing:FlxBasic) {
		thing.cameras = [staticCam];
		if (Std.isOfType(thing, FlxGroup)) {
			var things:FlxGroup = cast thing;
			things.forEach(toStaticCam);
		}
	}
}

package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class GameG {
	public static var levelID:String;

	public static var movingCam:PrxCamera;
	public static var staticCam:PrxCamera;

	static var setup:Bool = false;

	public static function ensureSetup() {
		Lang.ensureLoaded();
		Cont.ensureLoaded();
		if (!setup) {
			FlxG.console.registerClass(GameG);
			setup = true;
		}
		setupCameras();
	}

	static function setupCameras() {
		movingCam = new PrxCamera(0, 0, FlxG.width, FlxG.height, 1);
		staticCam = new PrxCamera(0, 0, FlxG.width, FlxG.height, 1);
		movingCam.marker = "moving";
		staticCam.marker = "static";
		staticCam.bgColor = FlxColor.BLACK;
		staticCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.reset(movingCam);
		FlxG.cameras.add(staticCam, false);
	}

	public static function toStaticCam(thing:FlxBasic) {
		thing.cameras = [staticCam];
		if (Std.isOfType(thing, FlxGroup)) {
			var things:FlxGroup = cast thing;
			things.forEach(toStaticCam);
		}
	}
}

class PrxCamera extends FlxCamera {
	public var marker:String;

	override function toString() {
		return marker;
	}
}
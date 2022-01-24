package enemies;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import geom.ClearWays;
import geom.SpriteDir.SpriteDirOrthog3;

class FloatingEyeLarge extends FloatingEye {
	public function new(args:Dynamic) {
		super(args);
		infoName = "Floating Eye (Large)";
		loadGraphic("assets/images/FloatingEyeLarge.png", true, 64, 64);
		setSizeS(32, 32);
		offset.set(16, 32);
		addFloatingEyeAnims();
		sightRange = 300;
		patrolSpeed = 50;
		pursuitSpeed = 100;
	}
}
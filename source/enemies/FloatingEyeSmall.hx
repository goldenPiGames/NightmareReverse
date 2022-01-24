package enemies;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import geom.ClearWays;
import geom.SpriteDir.SpriteDirOrthog3;

class FloatingEyeSmall extends FloatingEye {
	public function new(args:Dynamic) {
		super(args);
		infoName = "Floating Eye (Small)";
		loadGraphic("assets/images/FloatingEyeSmall.png", true, 64, 64);
		setSizeS(16, 16);
		offset.set(24, 40);
		addFloatingEyeAnims();
		sightRange = 200;
		patrolSpeed = 50;
		pursuitSpeed = 100;
	}
}
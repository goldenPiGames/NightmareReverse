package projectiles;

import flixel.math.FlxPoint;
import geom.SpriteDir.SpriteDirOrthog3;

class PowerWave extends Projectile {
	public static inline var PLAYER_SPEED:Float = 320;
	
	public function new(source:DreamEntity, location:FlxPoint, speed:FlxPoint) {
		super();
		infoName = "Power Wave";
		loadGraphic("assets/images/PowerWave.png", true, 32, 32);
		setSource(source);
		setSize(4, 4);
		offset.set(14, 24);
		spriteDir = new SpriteDirOrthog3();
		animation.add("szoom", [0]);
		animation.add("uzoom", [1]);
		animation.add("dzoom", [1]);
		x = location.x-2;
		y = location.y-2;
		velocity = speed;
		playAnimation("zoom");
		updateSpriteDirByVelocity();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		destroyIfTouchingWall();
	}
}
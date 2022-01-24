package enemies;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import geom.ClearWays;
import geom.SpriteDir.SpriteDirOrthog3;

class FloatingEye extends Enemy {
	public function new(args:Dynamic) {
		super(args);
		spriteDir = new SpriteDirOrthog3();
		sightAngle = 90;
		behaveState = Enemy.BEH_PATROL;
		pathPass = FLYING;
		FlxG.watch.add(this, "behaveState");
		FlxG.watch.add(this, "nodes");
	}
	
	function addFloatingEyeAnims() {
		animation.add("dfloat", [0]);
		animation.add("dchase", [1]);
		animation.add("sfloat", [2]);
		animation.add("schase", [3]);
		animation.add("ufloat", [4]);
		animation.add("uchase", [5]);
		playSetStartAnimation("float");
	}

	public override function update(elapsed:Float) {
		behaveUpdate(elapsed);
		updateSpriteDir(looking);
		super.update(elapsed);
	}

	override function startPursuit() {
		super.startPursuit();
		playAnimation("chase");
	}

	override function stopPursuit() {
		super.stopPursuit();
		playAnimation("float");
	}
}
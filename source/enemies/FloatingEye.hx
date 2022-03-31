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
		setSpriteDir(SpriteDirOrthog3);
		sightAngle = 90;
		setStartBehave(behaveState = Enemy.BEH_PATROL);
		pathPass = FLYING;
		#if FLX_DEBUG
		//FlxG.watch.add(this, "behaveState");
		//FlxG.watch.add(this, "nodes");
		//FlxG.watch.add(this, "looking");
		FlxG.watch.add(this, "animationF");
		#end
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
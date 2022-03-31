package entities;

import enemies.Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.typeLimit.OneOfTwo;
import geom.AlarmedTile;
import geom.SpriteDir.SpriteDirSingleFlip;
import projectiles.PowerWave;
import states.PlayState;

typedef PlayerDeathSource = OneOfTwo<String, Enemy>;

class DreamPlayer extends DreamEntity {
	var walkSpeed:Float = 200;
	var powered:Bool = false;
	var footstepTimer:Float = 0;
	var paralyzed:Bool = false;
	public var checkpoint:Checkpoint;
	static inline var FOOTSTEP_INC_JOG:Float = 3;
	static inline var FOOTSTEP_INC_SNEAK:Float = 1.2;
	static inline var DEATH_BY_VOID = "void";
	static inline var DEATH_BY_SPIKE = "spike";
	public static inline var SNEAK_MAX = .25;

	public function new(args:EntityData) {
		super(args);
		infoName = "Ammette";
		touchPriority = 0;
		hittable = true;
		forceVisible = true;
		loadGraphic("assets/sprites/Ammette.png", true, 64, 64);
		team = DreamEntity.TEAM_PLAYER;
		setSpriteDir(SpriteDirSingleFlip);
		animation.add("stand", [0]);
		animation.add("jog", [1, 2, 3, 4, 5, 6, 7, 8], FOOTSTEP_INC_JOG*4, true);
		animation.add("sneak", [9, 10, 11, 12, 13, 14, 15, 16], FOOTSTEP_INC_SNEAK*4, true);
		setSizeS(16, 16);
		offset.set(24, 42);
		pathPass = GROUND;
		playSetStartAnimation("stand");
	}

	public override function setState(instate:PlayState) {
		super.setState(instate);
		instate.player = this;
		instate.fog.setEye(this);
	}

	public override function update(elapsed:Float) {
		if (!paralyzed) {
			var controlVector:FlxVector = getControlVector();
			velocity = controlVector.scaleNew(walkSpeed);
			//visual things
			//face the correct direction
			//play the animation
			if (controlVector.length > 0) {
				updateSpriteDir(controlVector.degrees);
				var snuck:Bool = controlVector.length <= SNEAK_MAX;
				if (!snuck) {
					playAnimation("jog");
					footstepTimer += elapsed * FOOTSTEP_INC_JOG;
				} else {
					playAnimation("sneak");
					footstepTimer += elapsed * FOOTSTEP_INC_SNEAK;
				}
				if (footstepTimer > 1) {
					makeFootstep();
					footstepTimer -= 1;
				}
			} else {
				if (footstepTimer > 0) {
					makeFootstep();
					footstepTimer = 0;
				}
				playAnimation("stand");
			}
		} else {

		}
		
		super.update(elapsed);
		
		FlxG.collide(this, state.wallmap);
		if (!paralyzed && !powered) {
			if (!state.wallmap.canEntityPassCoords(this, getMidpoint())) {
				fallIntoVoid();
			}
		}
		
		if (powered) {
			if (FlxG.mouse.justPressed) {
				var here:FlxPoint = getMidpoint();
				var zoomies:FlxVector = FlxG.mouse.getWorldPosition().subtractPoint(here);
				zoomies.length = PowerWave.PLAYER_SPEED;
				addProjectile(new PowerWave(this, here, zoomies));
			}
		}
	}
	
	public function getControlVector():FlxVector {
		return Cont.getMoveVector();
	}

	public override function playerPowered() {
		powered = true;
		touchPriority = 48;
	}

	public function getCaught(by:Enemy) {
		justDie(by);
	}

	function fallIntoVoid() {
		justDie(DEATH_BY_VOID);
	}
	
	public function getSpiked(by:AlarmedTile) {
		justDie(DEATH_BY_SPIKE);
	}

	function justDie(by:PlayerDeathSource) {
		paralyzed = true;
		velocity = new FlxPoint(0, 0);
		state.indicatePlayerDied(by);
	}

	function makeFootstep() {
		state.playDiegeticPlayerSound(SfxSrc.PLAYER_FOOTSTEP, getMidpoint(), SoundIndicator.VOLUME_MEDIUM);
	}

	override function playerDeathReset() {
		super.playerDeathReset();
		paralyzed = false;
		footstepTimer = 0;
	}

	public function playSelfDeathAnimation(cause:String):Float {
		switch (cause) {
			case DEATH_BY_VOID:
				goToNearestVoid();
				playAnimation("stand");
				return 1.2;
		}
		return 1;
	}

	function goToNearestVoid():Void {
		//TODO
	}

	public override function generalReset():Void {
		if (checkpoint == null) {
			x = startData.x - width/2;
			y = startData.y - height/2;
			flipX = startData.flippedX;
			faceStarting();
		} else {
			x = checkpoint.x;
			y = checkpoint.y;
		}
		playStartAnimation();
	}
}

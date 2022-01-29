package;

import enemies.Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.typeLimit.OneOfTwo;
import geom.SpriteDir.SpriteDirSingleFlip;
import projectiles.PowerWave;

typedef PlayerDeathSource = OneOfTwo<String, Enemy>;

class DreamPlayer extends DreamEntity {
	var walkSpeed:Float = 240;
	var powered:Bool = false;
	var footstepTimer:Float = 0;
	var paralyzed = false;
	static inline var FOOTSTEP_INTERVAL = .33;
	static inline var DEATH_BY_VOID = "void";

	public function new(args:EntityData) {
		super(args);
		infoName = "Ammette";
		touchPriority = 0;
		hittable = true;
		forceVisible = true;
		loadGraphic("assets/images/Ammette.png", true, 64, 64);
		team = DreamEntity.TEAM_PLAYER;
		spriteDir = new SpriteDirSingleFlip();
		animation.add("stand", [0]);
		animation.add("jog", [1, 2, 3, 4, 5, 6, 7, 8], 12, true);
		setSizeS(16, 16);
		offset.set(24, 40);
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
				playAnimation("jog");
				updateSpriteDir(controlVector.degrees);
				footstepTimer += elapsed;
				if (footstepTimer > FOOTSTEP_INTERVAL) {
					makeFootstep();
					footstepTimer -= FOOTSTEP_INTERVAL;
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
		var magnitude:Float = 1;
		var controlVector:FlxVector = new FlxVector(0, 0);
		if (FlxG.keys.anyPressed([FlxKey.LEFT, FlxKey.A])) {
			controlVector.x -= 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.RIGHT, FlxKey.D])) {
			controlVector.x += 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.UP, FlxKey.W])) {
			controlVector.y -= 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.DOWN, FlxKey.S])) {
			controlVector.y += 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.SHIFT])) {
			magnitude = .25;
		}
		controlVector.truncate(magnitude);
		return controlVector;
	}

	public override function playerPowered() {
		powered = true;
		touchPriority = 64;
	}

	public function getCaught(by:Enemy) {
		justDie(by);
	}

	function fallIntoVoid() {
		justDie(DEATH_BY_VOID);
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
}

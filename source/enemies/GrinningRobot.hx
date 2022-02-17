package enemies;

import DreamPopup.DeathPopup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import geom.ClearWays;
import geom.SpriteDir.SpriteDirOrthog3;

class GrinningRobot extends Enemy {
	var stepDelay:Float = 1;

	public function new(args:Dynamic) {
		super(args);
		infoName = "Grinning Robot";
		loadGraphic("assets/sprites/GrinningRobot.png", true, 64, 64);
		spriteDir = new SpriteDirOrthog3();
		setSizeS(12, 12);
		offset.set(26, 44);
		setStartBehave(Enemy.BEH_WAIT);
		pathPass = GROUND;
		pathShouldSimplify = false;
		pathOrthogOnly = true;
		sightAngle = 20;
		sightRange = 240;
		patrolSpeed = 30;
		pursuitSpeed = 90;
		animation.add("dstand", [0]);
		animation.add("sstand", [3]);
		animation.add("ustand", [6]);
		animation.add("dwalk", [0,1,0,2], patrolSpeed/10);
		animation.add("swalk", [3,4,3,5], patrolSpeed/10);
		animation.add("uwalk", [6,7,6,8], patrolSpeed/10);
		animation.add("dchase", [0,1,0,2], pursuitSpeed/10);
		animation.add("schase", [3,4,3,5], pursuitSpeed/10);
		animation.add("uchase", [6,7,6,8], pursuitSpeed/10);
		playSetStartAnimation("stand");
	}
	

	public override function update(elapsed:Float) {
		behaveUpdate(elapsed);
		updateSpriteDir(looking);
		super.update(elapsed);
	}

	/*override function startPursuit() {
		super.startPursuit();
		playAnimation("chase");
	}

	override function stopPursuit() {
		super.stopPursuit();
		playAnimation("float");
	}*/

	override function moveToNextNode(elapsed:Float, fastness:Float):Bool {
		if (nodesEnded) {
			return false;
		}
		if (nodes == null)
			return false;
		if (nodeCurrent == null)
			setNodeCurrent();
		if (nodeCurrent == null) {
			return false;
		}
		stepDelay -= elapsed * fastness / 20;
		if (stepDelay < 0) {
			stepDelay += 1;
			var prevPosition = getPosition();
			setPosition(nodeCurrent.x-width/2, nodeCurrent.y-height/2);
			var moved:FlxVector = getPosition().subtractPoint(prevPosition);
			looking = moved.degrees;
			updateSpriteDir(looking);
			faceLooking();
			state.playDiegeticSound(SfxSrc.GRINNINGROBOT_FOOTSTEP, getMidpoint(), SoundIndicator.VOLUME_LOUD);
			nodeIndex++;
			if (nodeIndex >= nodes.length) {
				if (nodesLoop)
					nodeIndex = 0;
				else
					nodesEnded = true;
			}
			setNodeCurrent();
			return false;
		} else {
			return true;
		}
	}

	override function returnedToSpawn() {
		generalReset();
	}

	override function canSeePlayer():Bool {
		if (behaveState == Enemy.BEH_WAIT) {
			//trace(state.player);
			var diff:FlxVector = getMidpoint().subtractPoint(state.player.getMidpoint());
			if (diff.length > sightRange)
				return false;
			switch (facing) {
				case UP: return state.player.y < y && Math.abs(diff.x) < 15 &&
						state.wallmap.rayVision(getMidpoint(), FlxPoint.weak(x, state.player.y));
				case DOWN: return state.player.y > y && Math.abs(diff.x) < 15 &&
						state.wallmap.rayVision(getMidpoint(), FlxPoint.weak(x, state.player.y));
				case LEFT: return state.player.x < x && Math.abs(diff.y) < 15 &&
						state.wallmap.rayVision(getMidpoint(), FlxPoint.weak(state.player.x, y));
				case RIGHT: return state.player.x > x && Math.abs(diff.y) < 15 &&
						state.wallmap.rayVision(getMidpoint(), FlxPoint.weak(state.player.x, y));
				default: return super.canSeePlayer();
			}
		} else {
			return super.canSeePlayer();
		}
	}

	override function startPursuit() {
		super.startPursuit();
		playAnimation("chase");
	}

	override function startReturn() {
		super.startReturn();
		playAnimation("walk");
	}

	/*override function getKillPopup():DeathPopup {
		return new GrinningRobotKillPopup();
	}*/
}

class GrinningRobotKillPopup extends DeathPopup {
	
	var cranium:FlxSprite;
	var jaw:FlxSprite;
	var headparts:FlxTypedGroup<FlxSprite>;

	override function create() {
		super.create();
		headparts = new FlxTypedGroup<FlxSprite>();
		cranium = new FlxSprite();
		jaw = new FlxSprite();
		add(headparts);
		headparts.add(jaw);
		headparts.add(cranium);
		headparts.forEach(setupHeadpart);

		cranium.animation.add("cranium", [0]);
		cranium.animation.play("cranium");
		jaw.animation.add("jaw", [1]);
		jaw.animation.play("jaw");
	}

	function setupHeadpart(part:FlxSprite) {
		part.loadGraphic("assets/popups/GrinningRobotJumpscare.png", 64, 64);
		part.setGraphicSize(Std.int(FlxG.width/2));
		part.scrollFactor.set(0, 0);
		part.updateHitbox();
		part.x = 0;
		part.y = 0;
		part.cameras = [state.hud.camera];
	}

	override function setState(instate:PlayState) {
		super.setState(instate);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		//mouth go woosh
	}

	override function draw() {
		super.draw();
	}
}
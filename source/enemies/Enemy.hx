package enemies;

import entities.DreamEntity;
import entities.DreamPlayer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import geom.PrxTilemapDijkstra;

class Enemy extends DreamEntity {
	var behaveState:String = "patrol";
	var lastBehaveState:String = "patrol";
	var startBehaveState:String = "patrol";
	var nodes:Array<FlxPoint>;
	var nodeIndex:Int = 0;
	var nodeCurrent:FlxPoint;
	var nodesLoop:Bool = true;
	var nodesEnded:Bool = false;
	var sightAngle:Float = 90;
	var sightRange:Float = 200;
	var lastSeenPlayerLoc:FlxPoint = null;
	var lastSeenPlayerTime:Float = Math.NEGATIVE_INFINITY;
	var lastReroutedTime:Float = Math.NEGATIVE_INFINITY;
	var behaveTimer:Float = 0;
	var turnTimer:Float = 0;

	var patrolSpeed:Float = 50;
	var pursuitSpeed:Float = 100;
	var lostLookTime:Float = 1.2;

	public static inline var BEH_WAIT = "wait";
	public static inline var BEH_PATROL = "patrol";
	public static inline var BEH_PURSUIT = "pursuit";
	public static inline var BEH_PURSUIT_CORRIDOR = "pursuit_corridor";
	public static inline var BEH_LOST = "lost";
	public static inline var BEH_RETURN = "return";
	public static inline var BEH_CRASHED = "crashed";
	public static inline var BEH_LONGING = "longing";
	public static inline var BEH_CATCHING = "catching";
	public static inline var BEH_PANIC = "panic";
	
	public function new(args:EntityData) {
		super(args);
		team = DreamEntity.TEAM_ENEMY;
		touchPriority = 16;
		hittable = true;
		if (args.nodes != null) {
			loadPatrolPath();
		}
	}

	public override function setState(instate:PlayState) {
		super.setState(instate);
	}

	function behaveUpdate(elapsed:Float) {
		if (behaveState != lastBehaveState)
			behaveTimer = 0;
		else
			behaveTimer += elapsed;
		lastBehaveState = behaveState;
		switch (behaveState) {
			case BEH_WAIT: behaveWait(elapsed);
			case BEH_PATROL: behavePatrol(elapsed);
			case BEH_PURSUIT: behavePursuit(elapsed);
			case BEH_PURSUIT_CORRIDOR: behavePursuitCorridor(elapsed);
			case BEH_LOST: behaveLost(elapsed);
			case BEH_RETURN: behaveReturn(elapsed);
			case BEH_LONGING: behaveLonging(elapsed);
			case BEH_PANIC: behavePanic(elapsed);
			case BEH_CATCHING: behaveCatching(elapsed);
			case BEH_CRASHED: behaveCrashed(elapsed);
			default: behaveOther(elapsed);
		}
	}

	function behaveWait(elapsed:Float) {
		if (canSeePlayer()) {
			startPursuit();
		}
	}
	
	function behavePatrol(elapsed:Float) {
		if (moveToNextNode(elapsed, patrolSpeed))
			lookVelocity();
		if (canSeePlayer()) {
			startPursuit();
		}
		/*var clear:ClearWays = findClearWays();
		facing = clear.getPrefFRLB(facing);
		velocity = getFacingVelocity(patrolSpeed);*/
	}

	function behavePursuit(elapsed:Float) {
		var prevSaw:FlxPoint = lastSeenPlayerLoc;
		var saw:Bool = canSeePlayer();
		var deek:PrxTilemapDijkstra;
		var paff:Array<FlxPoint>;
		if (nodesEnded && !saw) {
			stopPursuit();
			//TODO LATER: continue going down corridor
			//if (getMidpoint().distanceTo(lastSawPlayerLoc) < 5)
		} else {
			//lookVelocity();
			//faceLooking();
			if (lastSeenPlayerTime > lastReroutedTime && state.timeSince(lastReroutedTime) >= .2) {
				deek = state.wallmap.getDijkstra(this);
				paff = deek.getPathTo(lastSeenPlayerLoc);
				if (paff != null)
					setPursuitPath(paff);
				else {
					paff = deek.getPathNearest(lastSeenPlayerLoc);
					if (paff == null) {
						stopPursuit();
					} else if (paff.length <= 0 || paff[paff.length-1].distanceTo(getMidpoint()) <= 3) {
						startLonging();
					} else {
						setPursuitPath(paff);
					}
				}
			}
			moveToNextNode(elapsed, pursuitSpeed);
		}
	}

	function behavePursuitCorridor(elapsed) {
		
	}

	function behaveLost(elapsed) {
		turnTimer += elapsed;
		if (turnTimer > .3) {
			turnTimer = 0;
			//TODO make it random?
			looking = looking + 90;
			faceLooking();
		}
		if (canSeePlayer()) {
			startPursuit();
		} else if (behaveTimer > lostLookTime) {
			startReturn();
		}
	}

	function behaveReturn(elapsed) {
		if (moveToNextNode(elapsed, patrolSpeed))
			lookVelocity();
		if (canSeePlayer()) {
			startPursuit();
		} else if (nodesEnded) {
			returnedToSpawn();
		} else if (startData.nodes != null) {
			var here:FlxPoint = getMidpoint();
			for (i in 0...startData.nodes.length) {
				if (here.distanceTo(FlxPoint.weak(startData.nodes[i].x, startData.nodes[i].y)) < 3) {
					loadPatrolPath();
					nodeIndex = i;
					behaveState = BEH_PATROL;
				}
			}
		}
	}

	function behaveLonging(elapsed) {
		var saw:Bool = canSeePlayer();
		if (saw) {
			lookAt(lastSeenPlayerLoc);
			faceLooking();
		} else {
			startPursuit();
		}
	}
	
	function behavePanic(elapsed) {
		
	}

	function behaveCatching(elapsed) {

	}

	function behaveOther(elapsed) {
		behaveState = BEH_CRASHED;
	}

	function behaveCrashed(elapsed:Float) {
		velocity = new FlxPoint(0, 0);
	}

	function startPursuit() {
		behaveState = Enemy.BEH_PURSUIT;
		state.indicatePursuit();
		//setPursuitPath(findPathNearPlayer());
	}

	function stopPursuit() {
		velocity = new FlxPoint(0, 0);
		behaveState = Enemy.BEH_LOST;
		state.maybeStopPursuit();
	}

	function startLonging() {
		velocity = new FlxPoint(0, 0);
		lookAt(lastSeenPlayerLoc);
		behaveState = BEH_LONGING;
	}

	function startReturn() {
		behaveState = Enemy.BEH_RETURN;
		setPursuitPath(findPathToSpawn());
	}

	public function stillInPursuit():Bool {
		if (behaveState == BEH_PURSUIT)
			return true;
		return false;
	}

	function moveToNextNode(elapsed:Float, fastness:Float):Bool {
		if (nodesEnded) {
			//velocity = new FlxPoint(0, 0);
			return false;
		}
		if (nodes == null)
			return false;
		if (nodeCurrent == null)
			setNodeCurrent();
		if (nodeCurrent == null) {
			//stopPursuit();
			return false;
		}
		//FlxG.log.add("Current node is " + nodeCurrent);
		//i cannot fucking believe this. how fucking hard does it have to be two subtract one point from another and get the answer back without mutating either. i'm going to fucking break something.
		//var diff:FlxVector = new FlxVector().clone(nodeCurrent).subtractNew(getMidpoint());
		//i cannot be fucked anymore. i'm going to subtract the components individually like a fucking savage.
		var diff:FlxVector = new FlxVector(nodeCurrent.x - getMidpoint().x, nodeCurrent.y - getMidpoint().y);
		//this is the culmination of years of object-oriented programming and at least an hour of my life. fuck this. fuck you.
		//FlxG.log.add("Current node is again " + nodeCurrent);
		//FlxG.log.add("Midpoint is " + getMidpoint());
		//FlxG.log.add("Difference is " + diff);
		if (diff.length < 1) {
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
			diff.length = fastness;
			velocity = diff;
			lookVelocity();
			faceLooking();
			return true;
		}
	}

	inline function setNodeCurrent() {
		nodeCurrent = nodes[nodeIndex];
		//FlxG.log.add("Changing node to " + nodeCurrent);
	}

	function loadPatrolPath() {
		nodes = startData.nodes.map(n -> new FlxPoint(n.x, n.y));
		nodesLoop = true;
		nodeIndex = 0;
		nodeCurrent = null;
		nodesEnded = false;
	}

	function crashAndFreeze() {
		velocity = new FlxPoint(0, 0);
		behaveState = BEH_CRASHED;
	}

	function canSeePlayer():Bool {
		var pmid:FlxPoint = state.player.getMidpoint();
		var emid:FlxPoint = getMidpoint();
		var diff:FlxVector = new FlxVector(pmid.x-emid.x, pmid.y-emid.y);
		//distance
		if (diff.length > sightRange) {
			//FlxG.log.add("Out of range");
			return false;
		}
		//rotation: can see in all directions while pursuing
		if (behaveState != BEH_PURSUIT && Math.abs(FlxAngle.wrapAngle(diff.degrees - looking)) > sightAngle/2) {
			//FlxG.log.add("Not in field of view (" + Math.round(diff.degrees) + "-" + Math.round(looking) + ")");
			return false;
		}
		//line of sight
		if (!state.wallmap.rayVision(pmid, emid)) {
			//FlxG.log.add("Line of sight obstructed");
			return false;
		}
		lastSeenPlayerLoc = pmid;
		lastSeenPlayerTime = state.time;
		return true;
	}
	
	function lookVelocity() {
		//what the fuck is the problem with FlxVector.clone()
		//looking = new FlxVector().clone(velocity).degrees;
		var vect:FlxVector = new FlxVector(velocity.x, velocity.y);
		if (vect.length > 0.01)
			looking = vect.degrees;
	}

	function lookAt(at:FlxPoint) {
		var vect:FlxVector = getMidpoint().subtractPoint(at);
		return vect.degrees + 180;
	}

	function setPursuitPath(paff:Array<FlxPoint>):Bool {
		if (paff != null) {
			nodes = paff;
			nodeCurrent = null;
			nodeIndex = 0;
			nodesLoop = false;
			nodesEnded = false;
			lastReroutedTime = state.time;
			return true;
		} else {
			return false;
		}
	}

	function findPathToSpawn():Array<FlxPoint> {
		var edsger = state.wallmap.getDijkstra(this);
		return edsger.getPathTo(new FlxPoint(startData.x, startData.y));
	}

	public override function playerPowered() {
		velocity = new FlxPoint(0, 0);
		behaveState = BEH_PANIC;
	}

	public override function touch(other:DreamEntity) {
		if (Std.isOfType(other, DreamPlayer)) {
			var bup:DreamPlayer = cast other;
			bup.getCaught(this);
		}
	}

	override function generalReset() {
		super.generalReset();
		behaveState = startBehaveState;
		if (startData.nodes != null) {
			loadPatrolPath();
		}
	}


	public override function isPreventingVictory():Bool {
		return alive;
	}

	public override function kill() {
		super.kill();
		state.indicateEnemyDied();
	}

	public function playCatchAnimation(player:DreamPlayer):Float {
		behaveState = BEH_CATCHING;
		velocity = new FlxPoint(0, 0);
		return 2;
	}

	function setStartBehave(byeah:String) {
		behaveState = byeah;
		startBehaveState = byeah;
		lastBehaveState = byeah;
	}

	function returnedToSpawn() {
		loadPatrolPath();
		behaveState = startBehaveState;
	}

	public function getKillPopup():DreamPopup {
		return null;
	}
}
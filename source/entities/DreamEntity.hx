package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxDirectionFlags;
import geom.ClearWays;
import geom.FacingAnimationController;
import geom.PrxPassFlags;
import geom.PrxTilemap.PrxTilesetTileMetadata;
import geom.SpriteDir;
import projectiles.Projectile;
import states.PlayState;

class DreamEntity extends FlxSprite {
	//super boring internals - do not touch
	public var spriteDegrees:Float;
	var animationF:FacingAnimationController;
	var state:PlayState;

	//the stuff
	var startData:EntityData;
	var startAnimation:String;
	public var infoName:String;
	public var hittable:Bool = false;
	var team:Int;
	var forceVisible:Bool = false;
	public var touchPriority:Int = 0;
	var looking:Float = 0;

	public var pathPass:PrxPassFlags;
	public var pathShouldSimplify = true;
	public var pathOrthogOnly = false;

	public static inline var TEAM_PLAYER:Int = 1;
	public static inline var TEAM_ENEMY:Int = -1;

	public function new(?args:EntityData) {
		super();
		infoName = "???";
		flipX = false;
		startData = args;
		if (args != null) {
			x = args.x;
			y = args.y;
			flipX = args.flippedX;
			faceStarting();
		}
	}

	override function initVars() {
		super.initVars();
		animationF = new FacingAnimationController(this);
		animation = animationF;
	}

	inline function setSpriteDir(dirp:Class<SpriteDir>) {
		animationF.spriteDir = Type.createInstance(dirp, []);
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
		visible = forceVisible || state.powered || checkVisibility();
	}

	function checkVisibility():Bool {
		return checkVisibilityFrom(state.player.getMidpoint());
	}

	function checkVisibilityFrom(from:FlxPoint) {
		final numChecks:Int = 3;
		for (i in 0...numChecks) {
			if (state.wallmap.rayVision(from, FlxPoint.weak(x+width*i/numChecks, y))) {
				return true;
			}
			if (state.wallmap.rayVision(from, FlxPoint.weak(x+width, y+height*i/numChecks))) {
				return true;
			}
			if (state.wallmap.rayVision(from, FlxPoint.weak(x+width*(numChecks-i)/numChecks, y+height))) {
				return true;
			}
			if (state.wallmap.rayVision(from, FlxPoint.weak(x, y+height*(numChecks-i)/numChecks))) {
				return true;
			}
		}
		return false;
	}

	public function setState(instate:PlayState) {
		state = instate;
	}

	function setSizeS(w:Float, h:Float) {
		width = w;
		height = h;
		x = startData.x - width/2;
		y = startData.y - height/2;
	}

	
	function updateSpriteDirByVelocity() {
		var yeet:FlxVector = velocity;
		updateSpriteDir(yeet.degrees);
	}

	inline function updateSpriteDir(deg:Float) {
		spriteDegrees = deg;
	}

	public inline function getSpriteDegrees():Float {
		return spriteDegrees;
	}

	function playAnimation(nom:String) {
		animationF.playFace(nom);
	}

	function playSetStartAnimation(nom:String) {
		playAnimation(nom);
		startAnimation = nom;
	}

	function playStartAnimation() {
		playAnimation(startAnimation);
	}

	public inline function lefx() {
		return x;
	}
	public inline function midx() {
		return x + width/2;
	}
	public inline function rigx() {
		return x + width;
	}
	public inline function topy() {
		return y;
	}
	public inline function midy() {
		return y + height/2;
	}
	public inline function boty() {
		return y + height;
	}
	

	function findClearWays():ClearWays {
		var resolution:Float = .1;
		var length:Float = 5;
		var clear:ClearWays = new ClearWays(true);
		var checks = Math.ceil(Math.max(width, height) / 20);
		for (i in 0...checks+1) {
			if (clear.up)
				clear.up = state.wallmap.ray(new FlxPoint(x+width*i/checks, topy()),
						new FlxPoint(x+width*i/checks, topy()-length), null, resolution);
			if (clear.down)
				clear.down = state.wallmap.ray(new FlxPoint(x+width*i/checks, boty()),
						new FlxPoint(x+width*i/checks, boty()+length), null, resolution);
			if (clear.left)
				clear.left = state.wallmap.ray(new FlxPoint(lefx(), y+height*i/checks),
						new FlxPoint(lefx()-length, y+height*i/checks), null, resolution);
			if (clear.right)
				clear.right = state.wallmap.ray(new FlxPoint(rigx(), y+height*i/checks),
						new FlxPoint(rigx()+length, y+height*i/checks), null, resolution);
		}
		return clear;
	}

	public function touch(other:DreamEntity) {

	}

	public function playerPowered() {

	}

	public function addProjectile(yeet:Projectile) {
		state.addProjectile(yeet);
	}

	public function getHit(by:Projectile) {
		kill();
	}

	public function generalReset():Void {
		if (startData == null) {
			destroy();
		} else {
			playStartAnimation();
			x = startData.x - width/2;
			y = startData.y - height/2;
			flipX = startData.flippedX;
			faceStarting();
		}
	}

	function faceStarting() {
		if (startData.values != null && startData.values.facing != null) {
			//FlxG.log.add(args.values.facing);
			switch (startData.values.facing) {
				case "up": facing = UP;
				case "down": facing = DOWN;
				case "left": facing = LEFT;
				case "right": facing = RIGHT;
			}
			lookFacing();
		}
	}

	public function playerDeathReset() {
		generalReset();
	}

	public function isPreventingVictory():Bool {
		return false;
	}

	public function countIfEnemyAlive() {
		if (isPreventingVictory())
			state.numEnemiesAlive ++;
	}

	function faceLooking():Void {
		switch ((Math.round(FlxAngle.wrapAngle(looking) / 90) + 4) % 4) {
			case 0: facing = RIGHT;
			case 1: facing = DOWN;
			case 2: facing = LEFT;
			case 3: facing = UP;
		}
	}

	function getFacingVelocity(magnitude:Float):FlxVector {
		switch (facing) {
			case UP: return new FlxVector(0, -magnitude);
			case DOWN: return new FlxVector(0, magnitude);
			case LEFT: return new FlxVector(-magnitude, 0);
			case RIGHT: return new FlxVector(magnitude, 0);
			default: return new FlxVector(0, 0);
		}
	}

	function lookFacing():Void {
		switch (facing) {
			case UP: looking = 270;
			case DOWN: looking = 90;
			case LEFT: looking = 180;
			case RIGHT: looking = 0;
			default: return;
		}
	}

	public function getInitialPathDirection():FlxDirectionFlags {
		return facing;
	}

	public override function toString():String {
		return (exists?"":"--") + infoName + " x:"+Math.round(x) + " y:"+Math.round(y);
	}

	public function canPassTile(dab:PrxTilesetTileMetadata):Bool {
		if (dab.solid)
			return false;
		if ((dab.void || dab.spike) && !pathPass.hasType(0))
			return false;
		return true;
	}
}
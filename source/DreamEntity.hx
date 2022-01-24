package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxDirectionFlags;
import geom.ClearWays;
import geom.PrxPassFlags;
import geom.SpriteDir;
import projectiles.Projectile;

class DreamEntity extends FlxSprite {
	var state:PlayState;
	var startData:EntityData;
	var startAnimation:String;
	public var infoName:String;
	public var hittable:Bool = false;
	var spriteDir:SpriteDir;
	var animName:String;
	var team:Int;
	public var touchPriority:Int = 0;

	public var pathPass:PrxPassFlags;

	public static inline var TEAM_PLAYER:Int = 1;
	public static inline var TEAM_ENEMY:Int = -1;

	public function new(?args:EntityData) {
		super();
		infoName = "???";
		startData = args;
		if (args != null) {
			x = args.x;
			y = args.y;
			flipX = args.flippedX;
			if (args.values != null && args.values.facing != null) {
				//FlxG.log.add(args.values.facing);
				switch (args.values.facing) {
					case "up": facing = UP;
					case "down": facing = DOWN;
					case "left": facing = LEFT;
					case "right": facing = RIGHT;
				}
			}
		}
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

	function updateSpriteDir(deg:Float) {
		var prevPrefix:String = spriteDir.prefix;
		spriteDir.setAngle(deg);
		flipX = spriteDir.flip;
		if (spriteDir.prefix != prevPrefix) {
			var fr:Int = animation.frameIndex;
			animation.play(spriteDir.prefix+animName);
			//animation.frameIndex = fr;
			//FlxG.log.add(fr);
		}
	}
	
	function updateSpriteDirByVelocity() {
		var yeet:FlxVector = velocity;
		updateSpriteDir(yeet.degrees);
	}

	function playAnimation(nom:String) {
		animName = nom;
		animation.play(spriteDir.prefix + animName);
	}

	function playSetStartAnimation(nom:String) {
		playAnimation(nom);
		startAnimation = nom;
	}

	function playStartAnimation() {
		playAnimation(startAnimation);
	}

	inline function lefx() {
		return x;
	}
	inline function midx() {
		return x + width/2;
	}
	inline function rigx() {
		return x + width;
	}
	inline function topy() {
		return y;
	}
	inline function midy() {
		return y + height/2;
	}
	inline function boty() {
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

	public function playerDied():Void {
		if (startData == null) {
			destroy();
		} else {
			playStartAnimation();
			x = startData.x - width/2;
			y = startData.y - height/2;
		}
	}

	public function isPreventingVictory():Bool {
		return false;
	}

	public function countIfEnemyAlive() {
		if (isPreventingVictory())
			state.numEnemiesAlive ++;
	}
}
package geom;

import entities.DreamEntity;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxAnimationController;
import geom.SpriteDir;

class FacingAnimationController extends FlxAnimationController {
	var _spriteDream:DreamEntity;
	public var spriteDir:SpriteDir;
	var quidName:String;

	public function new(thesprite:DreamEntity) {
		super(thesprite);
		_spriteDream = thesprite;
		spriteDir = new SpriteDirStatic();
	}

	override function update(elapsed:Float) {
		updateSpriteDir(_spriteDream.getSpriteDegrees());
		super.update(elapsed);
	}
	
	function updateSpriteDir(deg:Float) {
		var prevPrefix:String = spriteDir.prefix;
		spriteDir.setAngle(deg);
		if (spriteDir.prefix != prevPrefix) {
			var prevAnim:FlxAnimationButItCanCopy = curAnim;
			play(spriteDir.prefix+quidName);
			prevAnim.copyTimingOnto(curAnim);
			//animation.frameIndex = fr;
			//FlxG.log.add(fr);
		}
		if (curAnim != null && spriteDir.flip != curAnim.flipX) {
			curAnim.flipX = spriteDir.flip;
		}
	}

	/** Use this to play a simple animation that isn't affected by facing. */
	public function playBasic(animName:String, force:Bool = false) {
		play(animName, force);
	}

	/** Use this to play an animation that updates facing correctly. */
	public function playFace(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		quidName = animName;
		play(spriteDir.prefix+animName, force, reversed, frame);
	}

	function toString() {
		return quidName + ";" + spriteDir;
	}
}

@:forward
abstract FlxAnimationButItCanCopy(FlxAnimation) from FlxAnimation to FlxAnimation {
	public function copyTimingOnto(other:FlxAnimation) {
		other.curFrame = this.curFrame;
		//reversed should go here if i ever bother using it
		@:privateAccess
		other._frameTimer = this._frameTimer;
	}
}
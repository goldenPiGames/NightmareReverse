import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxSound;
import states.PlayState;

class SoundIndicator extends FlxSprite {
	public static inline var VOLUME_LOUD = 3;
	public static inline var VOLUME_MEDIUM = 2;
	public static inline var VOLUME_SOFT = 1;
	var sound:FlxSound;
	var soundDone:Bool = false;
	var loudness:Int;
	var closeness:Float;
	var duration:Float;
	var timer:Float = 0;
	static inline var ALPHA_MAX = .5;
	
	public static final MAX_DISTANCE:haxe.ds.ReadOnlyArray<Float> = [40, 80, 150, 300];

	public function new(thesound:FlxSound, location:FlxPoint, inloud:Int) {
		super();
		//loadGraphic("assets/sprites/SoundIndicator.png", true, 16, 16);
		loadGraphic("assets/sprites/Soundwave.png", true, 32, 32);
		setSize(0, 0);
		offset.set(16, 16);
		sound = thesound;
		x = location.x;
		y = location.y;
		loudness = inloud;
		sound.onComplete = this.soundEnded;
		duration = Math.max(sound.length/1000, 16/30);
		animation.add("expand", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], 16/duration, false);
		animation.play("expand");
		//PrxG.traceAndLog(duration);
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
		timer += elapsed;
		if (timer > duration) {
			destroy();
		} else {
			alpha = ALPHA_MAX * closeness * (1 - timer / duration);
		}
	}

	function soundEnded() {
		soundDone = true;
	}

	public function setState(instate:PlayState) {
		var diff:FlxVector = instate.player.getMidpoint().subtract(x, y);
		if (diff.length > SoundIndicator.MAX_DISTANCE[loudness]) {
			closeness = 0;
		} if (diff.length < 15) {
			closeness = 1;
		} else {
			closeness = 1 - ((diff.length-20) / SoundIndicator.MAX_DISTANCE[loudness]);
		}
		sound.volume = closeness;
		alpha = ALPHA_MAX * closeness;
	}
}
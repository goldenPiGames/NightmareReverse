import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

class SoundIndicator extends FlxSprite {
	public static inline var VOLUME_LOUD = 3;
	public static inline var VOLUME_MEDIUM = 2;
	public static inline var VOLUME_SOFT = 1;
	var sound:FlxSound;
	var soundDone:Bool = false;
	var volume:Int;

	public function new(thesound:FlxSound, location:FlxPoint, involume:Int) {
		super();
		loadGraphic("assets/images/SoundIndicator.png", true, 16, 16);
		setSize(0, 0);
		offset.set(8, 8);
		sound = thesound;
		x = location.x;
		y = location.y;
		volume = involume;
		sound.onComplete = this.soundEnded;
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (soundDone)
			destroy();
	}

	function soundEnded() {
		soundDone = true;
	}
}
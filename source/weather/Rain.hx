package weather;

import entities.DreamEntity;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import misc.PrxTypedGroup;
import misc.SfxSrc;

class Rain extends DreamWeather {
	var drops:PrxTypedGroup<Raindrop>;
	var dropsPerPixelPerSecond:Float = 1/50;
	var outsideSound:FlxSound;

	public function new(b) {
		super(b);
		drops = new PrxTypedGroup<Raindrop>();
		add(drops);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		var vrect:FlxRect = GameG.movingCam.getWorldRect();
		var area = vrect.width * vrect.height;
		for (i in 0...Std.int(area*elapsed*dropsPerPixelPerSecond)) {
			addDrop(FlxG.random.float(vrect.left, vrect.right),
					FlxG.random.float(vrect.top, vrect.bottom));
		}
//		addDrop(vrect.x+vrect.width/2, vrect.y+vrect.height/2);
	}

	inline function addDrop(x:Float, y:Float) {
		var t = state.wallmap.getTStateByCoords(FlxPoint.weak(x, y));
		if (!t.roofed) {
			var drip = getDrop();
			drip.fallAt(x, y);
		}
	}

	function getDrop():Raindrop {
		var drip:Raindrop = drops.getFirstAvailable();
		if (drip == null) {
			drip = drops.add(new Raindrop());
			drip.setState(state);
		}
		return drip;
	}
	
	public override function toString():String {
		return "Rain\n" + drops.toString();
	}

	override function startSound() {
		outsideSound = FlxG.sound.play(SfxSrc.RAIN_OUTDOORS, 1, true);
	}
}

class Raindrop extends DreamEntity {
	
	public function new() {
		super();
		infoName = "Randrop";
		loadGraphic("assets/sprites/Raindrop.png", true, 16, 64);
		setSize(0, 0);
		offset.set(8, 56);
		animation.add("fall0", [0,2,3,4,5], 30, false);
		animation.add("fall1", [1,2,3,4,5], 30, false);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (animation.finished) {
			kill();
		}
	}

	public function fallAt(x, y) {
		revive();
		setPosition(x, y);
		animation.play("fall"+FlxG.random.int(0,1), true);
		updateVisibility();
	}
}
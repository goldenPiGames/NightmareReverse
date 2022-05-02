package geom.vision;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import misc.PrxTypedGroup;
using flixel.util.FlxSpriteUtil;

/**
 * Component that actually determines visibility.
 * @author people involve Tommy Elfving, Xerosugar, Nicky Case, ninja_muffin, and me
 */
abstract class Vision extends PrxTypedGroup<FlxBasic> {
	public var state:VisionState;
	public var fog:FogLayerBase;
	public var eyePos:FlxPoint;
	public var map:PrxTilemap;
	/** The sprite that shadows will be drawn to.
		Only used by some subclasses, but I have it here because bleh. */
	public var shadowCanvas:FlxSprite;
	
	public function new(thestate:VisionState) {
		super();
		state = thestate;
		map = state.getWallmap();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	function updatePre(elapsed:Float):Void {
		eyePos = state.getVisionEye();
	}

	public function reveal() {
		visible = false;
	}

	abstract public function isVisibleAt(x:Float, y:Float):Bool;

	public static function make(state:VisionState):Vision {
		return new GridLineVision(state);
		//return new PolygonVision(state);
	}
}

interface VisionState {
	public function getVisionSegments():Array<SegmentInfo>;

	public function getVisionEye():FlxPoint;

	public function getWallmap():PrxTilemap;
}

interface VisionEntity {
	public function getVisionSegments():Array<SegmentInfo>;
}

typedef SegmentInfo = {
	a: {
		x:Float,
		y:Float
	},
	b: {
		x:Float,
		y:Float
	},
	?nearestSq:Float,
	?furthestSq:Float,
}
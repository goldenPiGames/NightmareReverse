package geom.vision;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import geom.vision.Vision.SegmentInfo;
import geom.vision.Vision.VisionState;
import haxe.Timer;
import openfl.display.BlendMode;



class PolygonVision extends Vision {
	
	static inline var SHADOW_COLOR = 0xff000000;
	static inline var VIEWED_COLOR = 0xffffffff;

	public function new(thestate:VisionState) {
		super(thestate);
		
		shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(Std.int(FlxG.worldBounds.width), Std.int(FlxG.worldBounds.height), FlxColor.TRANSPARENT, true);
		add(shadowCanvas);
	}

	static inline function floatSort(a:Float, b:Float):Int {
		if (a < b)
			return -1;
		else if (a > b)
			return 1;
		else
			return 0;
	}

	override function update(elapsed:Float):Void {
		updatePre(elapsed);

		FlxSpriteUtil.fill(shadowCanvas, SHADOW_COLOR);
		
		if (eyePos == null)
			return;

		var stampStart:Float = Timer.stamp();
		//Assemble

		processSegments();

		var points:Array<FlxPoint> = [];
		for (seg in segments) {
			points.push(FlxPoint.get(seg.a.x, seg.a.y));
			points.push(FlxPoint.get(seg.b.x, seg.b.y));
		}

		var pointSet:Map<String, Bool> = new Map<String, Bool>();
		var uniquePoints:Array<FlxPoint> = points.filter(function(p) {
			var key = p.x + "," + p.y;
			if (pointSet.exists(key)) {
				return false;
			} else {
				pointSet[key] = true;
				return true;
			}
		});

		var uniqueAngles:Array<Float> = [];
		for (j in 0...uniquePoints.length) {
			var uniquePoint = uniquePoints[j];
			var angle = Math.atan2(uniquePoint.y - eyePos.y, uniquePoint.x - eyePos.x);
			uniqueAngles.push(angle - 0.0001);
			//uniqueAngles.push(angle);
			uniqueAngles.push(angle + 0.0001);
		}

		uniqueAngles.sort(floatSort);

		var stampAssemble:Float = Timer.stamp(); FlxG.watch.addQuick("assemble", stampAssemble - stampStart);
		//Intersect

		var intersects:Array<FlxPoint> = [];
		for (angle in 0...uniqueAngles.length) {
			//var realAngle:Float = 0;
			//realAngle += ((Math.PI * 2) * angle) / shadowDetail;
			var realAngle:Float = uniqueAngles[angle];

			var dx = Math.cos(realAngle);
			var dy = Math.sin(realAngle);

			var ray:SegmentInfo = {a: {x: eyePos.x, y: eyePos.y}, b: {x: eyePos.x + dx, y: eyePos.y + dy}};

			var closestIntersect:IntersectInfo = getClosestIntersection(ray);

			if (closestIntersect != null) {
				var daPoint:FlxPoint = FlxPoint.get(closestIntersect.x, closestIntersect.y);
				intersects.push(daPoint);
			}
		}

		var stampIntersect:Float = Timer.stamp(); FlxG.watch.addQuick("intersect", stampIntersect - stampAssemble);
		//Draw
		
		FlxSpriteUtil.drawPolygon(shadowCanvas, intersects, VIEWED_COLOR, null);

		var stampDraw:Float = Timer.stamp(); FlxG.watch.addQuick("draw", stampDraw - stampIntersect);
		FlxG.watch.addQuick("vertices", intersects.length);

		super.update(elapsed);
	}

	inline function distanceSqFromEye(px:Float, py:Float):Float {
		return Math.pow(px-eyePos.x, 2) + Math.pow(py-eyePos.y, 2);
	}

	function getClosestIntersection(ray:SegmentInfo) {
		var closest:IntersectInfo = null;
		var closestDistSq:Float = Math.POSITIVE_INFINITY;
		for (i in 0...segments.length) {
			if (segments[i].nearestSq > closestDistSq) {
				return closest;
			}
			var intersect:IntersectInfo = getIntersection(ray, segments[i]);
			if (intersect != null && (closest == null || intersect.param < closest.param)) {
				closest = intersect;
				closestDistSq = distanceSqFromEye(closest.x, closest.y);
			}
		}
		return closest;
	}

	function getIntersection(ray:SegmentInfo, segment:SegmentInfo):IntersectInfo {
		// RAY in parametric: Point + Direction*T1
		var r_px = ray.a.x;
		var r_py = ray.a.y;
		var r_dx = ray.b.x - ray.a.x;
		var r_dy = ray.b.y - ray.a.y;

		// SEGMENT in parametric: Point + Direction*T2
		var s_px = segment.a.x;
		var s_py = segment.a.y;
		var s_dx = segment.b.x - segment.a.x;
		var s_dy = segment.b.y - segment.a.y;

		var r_mag = Math.sqrt(r_dx * r_dx + r_dy * r_dy);
		var s_mag = Math.sqrt(s_dx * s_dx + s_dy * s_dy);

		if (r_dx / r_mag == s_dx / s_mag && r_dy / r_mag == s_dy / s_mag) {
			// Directions are the same.
			return null;
		}

		var T2 = (r_dx * (s_py - r_py) + r_dy * (r_px - s_px)) / (s_dx * r_dy - s_dy * r_dx);
		var T1 = (s_px + s_dx * T2 - r_px) / r_dx;

		// Must be within parametic whatevers for RAY/SEGMENT
		if (T1 < 0)
			return null;
		if (T2 < 0 || T2 > 1)
			return null;

		return {
			x: r_px + r_dx * T1,
			y: r_py + r_dy * T1,
			param: T1
		};
	}

	var segments:Array<SegmentInfo> = [];

	public function processSegments():Void {
		segments = state.getVisionSegments();

		for (segg in segments) {
			processSegmentMore(segg);
			//if (segg.a.x == 100.0 && segg.a.y == 140.0 && segg.b.y == 140.0) FlxG.watch.addQuick("the wall", Std.int(Math.sqrt(segg.nearestSq)) + " - " + Std.int(Math.sqrt(segg.furthestSq)));
		}

		segments.sort((a,b)->floatSort(a.nearestSq,b.nearestSq));
		//trace(segments);
	}

	function processSegmentMore(segg:SegmentInfo) {
		segg.furthestSq = Math.max(
				distanceSqFromEye(segg.a.x, segg.a.y),
				distanceSqFromEye(segg.b.x, segg.b.y)
		);
		var ax = eyePos.x - segg.a.x;
		var	ay = eyePos.y - segg.a.y;
		var bx = segg.b.x - segg.a.x;
		var	by = segg.b.y - segg.a.y;
		var bb = bx * bx + by * by;
	
		if (bb == 0) {
			segg.nearestSq = ax*ax + ay*ay;
		} else {
			var ab = ax*bx + ay*by;
			var t = FlxMath.bound(ab / bb, 0, 1);
		
			var rx = ax - t * bx;
			var ry = ay - t * by;
			segg.nearestSq = //
					//Math.pow(eyePos.x-rx, 2) + Math.pow(eyePos.y - ry, 2);
					rx*rx + ry*ry;//???
		}
	}

	public function isVisibleAt(x:Float, y:Float):Bool {
		var beep = shadowCanvas.pixels.getPixel32(Std.int(x), Std.int(y));
		return beep != 0 && beep > 0xFF400000;
	}
}

class PolygonVisionPlusGrid extends PolygonVision {
	public function new(thestate:VisionState) {
		super(thestate);

		shadowCanvas.visible = false;
		
		fog = new CopyingFogLayer();
		add(fog);
		fog.camera = FlxG.camera;
		fog.setVision(this);
	}
}

typedef IntersectInfo = {
	x:Float,
	y:Float,
	param:Float
}
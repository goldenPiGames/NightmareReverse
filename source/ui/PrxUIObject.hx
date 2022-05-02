package ui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxPoint;
import geom.vision.Vision.SegmentInfo;
import geom.vision.Vision.VisionEntity;
import misc.PrxTypedGroup;

class PrxUIObject extends PrxTypedGroup<FlxBasic> implements VisionEntity {
	var canvas:PrxUICanvas;
	public var x:Float;
	public var y:Float;
	var width:Float;
	var height:Float;
	public var mouseClicked:Bool;
	public var mouseHovered:Bool = false;
	public var connectUp:PrxUIObject = null;
	public var connectDown:PrxUIObject = null;
	public var connectLeft:PrxUIObject = null;
	public var connectRight:PrxUIObject = null;
	//var mouseHovered:Bool;

	public function new(?inx:Float, ?iny:Float, ?inwidth:Float, ?inheight:Float) {
		super();
		if (iny != null) {
			x = inx;
			y = iny;
			if (inheight != null) {
				width = inwidth;
				height = inheight;
			}
		}
	}

	public function setCanvas(thecanvas:PrxUICanvas):Void {
		canvas = thecanvas;
	}

	override function update(elapsed:Float) {
		mouseClicked = false;
		if (FlxG.mouse.justMoved) {
			mouseHovered = intersectsPoint(canvas.mouse);
		}
		if ((FlxG.mouse.justMoved || FlxG.mouse.justPressed) && mouseHovered) {
			canvas.mouseHover(this);
			//mouseHovered = true;
			if (FlxG.mouse.justPressed)
				mouseClicked = true;
		}
		if (mouseClicked) {
			activate();
		}
	}

	function intersectsPoint(punt:FlxPoint):Bool {
		return punt.x >= cursorLeft() && punt.x <= cursorRight() && punt.y >= cursorTop() && punt.y <= cursorBottom();
	}

	public function cursorLeft():Float {
		return x;
	}

	public function cursorRight():Float {
		return x+width;
	}

	public function cursorTop():Float {
		return y;
	}

	public function cursorBottom():Float {
		return y+height;
	}

	public function activate():Void {
		
	}

	public function getVisionSegments():Array<SegmentInfo> {
		return [
			{a:{x:cursorLeft(),y:cursorTop()},b:{x:cursorRight(),y:cursorTop()}},
			{a:{x:cursorLeft(),y:cursorBottom()},b:{x:cursorRight(),y:cursorBottom()}},
			{a:{x:cursorLeft(),y:cursorTop()},b:{x:cursorLeft(),y:cursorBottom()}},
			{a:{x:cursorRight(),y:cursorTop()},b:{x:cursorRight(),y:cursorBottom()}},
		];
	}

	public inline function isHovered():Bool {
		return canvas.cursor.hovered == this;
	}
}
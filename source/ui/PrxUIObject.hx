package ui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxPoint;
import misc.PrxTypedGroup;

class PrxUIObject extends PrxTypedGroup<FlxBasic> {
	var canvas:PrxUICanvas;
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var mouseClicked:Bool;
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
		if ((FlxG.mouse.justMoved || FlxG.mouse.justPressed) && intersectsPoint(canvas.mouse)) {
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
		return false;
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
}
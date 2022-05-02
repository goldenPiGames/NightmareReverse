package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import misc.PrxTypedGroup;

class PrxUICursor extends PrxTypedGroup<PrxUICursorCorner> {
	public var hovered:PrxUIObject;
	var destL:Float;
	var destR:Float;
	var destU:Float;
	var destD:Float;
	public var currL:Float;
	public var currR:Float;
	public var currU:Float;
	public var currD:Float;
	var cornUL:PrxUICursorCorner;
	var cornDL:PrxUICursorCorner;
	var cornUR:PrxUICursorCorner;
	var cornDR:PrxUICursorCorner;
	var lagBySecond:Float = 1.e-07;
	public var justMoved:Bool;
	
	public function new() {
		super();
		cornUL = add(new PrxUICursorCorner(this, false, false));
		cornDL = add(new PrxUICursorCorner(this, false, true));
		cornUR = add(new PrxUICursorCorner(this, true, false));
		cornDR = add(new PrxUICursorCorner(this, true, true));
		destL = 0;
		destR = FlxG.width;
		destU = 0;
		destD = FlxG.height;
		snapToDest();
		GameG.toStaticCam(this);
	}

	override function update(elapsed:Float) {
		
		if (Cont.menuUp.triggered) {
			hoverTo(hovered.connectUp);
		}
		if (Cont.menuDown.triggered) {
			hoverTo(hovered.connectDown);
		}
		if (Cont.menuLeft.triggered) {
			hoverTo(hovered.connectLeft);
		}
		if (Cont.menuRight.triggered) {
			hoverTo(hovered.connectRight);
		}

		var port = Math.pow(lagBySecond, elapsed);
		currL = currL*port + destL*(1-port);
		currR = currR*port + destR*(1-port);
		currU = currU*port + destU*(1-port);
		currD = currD*port + destD*(1-port);

		super.update(elapsed);

		if (Cont.confirm.triggered) {
			hovered.activate();
		}
	}

	function snapToDest() {
		currL = destL;
		currR = destR;
		currU = destU;
		currD = destD;
	}

	public function hoverTo(thing:PrxUIObject) {
		if (thing != null) {
			hovered = thing;
			destL = thing.cursorLeft();
			destR = thing.cursorRight();
			destU = thing.cursorTop();
			destD = thing.cursorBottom();
			justMoved = true;
		}
	}

	public function getMidpoint(?point:FlxPoint):FlxPoint {
		if (point == null)
			point = FlxPoint.get();
		return point.set((currL+currR)/2, (currU+currD)/2);
	}
}

class PrxUICursorCorner extends FlxSprite {
	var curse:PrxUICursor;
	public function new(thecurse:PrxUICursor, right:Bool, down:Bool) {
		super(0, 0, "assets/ui/CursorCorner.png");
		curse = thecurse;
		if (right) {
			flipX = true;
			offset.x = width;
		}
		if (down) {
			flipY = true;
			offset.y = height;
		}
	}

	override function update(elapsed:Float) {
		x = flipX ? curse.currR : curse.currL;
		y = flipY ? curse.currD : curse.currU;
		super.update(elapsed);
	}
}
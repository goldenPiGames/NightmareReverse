package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import misc.PrxTypedGroup;

class PrxUICursor extends PrxTypedGroup<PrxUICursorCorner> {
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
		
		var port = Math.pow(lagBySecond, elapsed);
		currL = currL*port + destL*(1-port);
		currR = currR*port + destR*(1-port);
		currU = currU*port + destU*(1-port);
		currD = currD*port + destD*(1-port);
		super.update(elapsed);
	}

	function snapToDest() {
		currL = destL;
		currR = destR;
		currU = destU;
		currD = destD;
	}

	public function hoverTo(thing:PrxUIObject) {
		destL = thing.cursorLeft();
		destR = thing.cursorRight();
		destU = thing.cursorTop();
		destD = thing.cursorBottom();
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
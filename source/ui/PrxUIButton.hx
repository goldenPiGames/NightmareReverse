package ui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

class PrxUIButton extends PrxUIObject {
	var text:FlxText;
	var back:FlxSprite;
	var onclick:()->Void = null;
	public static inline var BEVELGREY_PATH = "assets/ui/ButtonBevelGrey.png";
	public static var BEVELGREY_SLICE = new FlxRect(10, 10, 10, 10);

	public function new(x, y, width, height) {
		super(x, y, width, height);
	}

	public function addBackSlice(ass:FlxGraphicAsset, slice:FlxRect) {
		back = new PrxSliceSprite(ass, slice, width, height);
		back.x = this.x;
		back.y = this.y;
		add(back);
	}

	public function addTextLang(blah:String) {
		text = new PrxRectText(x, y, width, height, Lang.get(blah));
		add(text);
	}

	public function setOnClick(what:()->Void) {
		onclick = what;
	}

	override function activate():Void {
		if (onclick != null) {
			onclick();
		}
	}

	override function toString() {
		return (text != null ? text.text : "no text") + "("+Std.int(x)+","+Std.int(y)+")";
	}
}
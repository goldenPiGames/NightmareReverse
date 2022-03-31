package ui;

import flixel.text.FlxText;

class PrxRectText extends FlxText {
	public function new(inx:Float, iny:Float, inwidth:Float, inheight:Float, text:String) {
		iny -= FlxText.VERTICAL_GUTTER;
		inheight -= FlxText.VERTICAL_GUTTER;
		super(inx, iny, inwidth, text, Std.int(inheight));
		autoSize = true;
		wordWrap = false;
		regenGraphic();
		if (graphic.width > inwidth) {
			y += (size - (size * inwidth / graphic.width)) / 2;
			size = Std.int(size * inwidth / graphic.width);
			regenGraphic();
		}
	}
}
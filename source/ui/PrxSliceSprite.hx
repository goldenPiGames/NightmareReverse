package ui;

import flixel.FlxG;
import flixel.addons.display.FlxSliceSprite;

class PrxSliceSprite extends FlxSliceSprite {
	override function draw() {
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug) {
			drawDebug();
			return;
		}
		#end
		super.draw();
	}
}
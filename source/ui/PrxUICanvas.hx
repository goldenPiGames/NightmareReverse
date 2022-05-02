package ui;

import flixel.FlxG;
import flixel.math.FlxPoint;
import misc.PrxTypedGroup;

class PrxUICanvas extends PrxTypedGroup<PrxUIObject> {
	//var state:PrxState;
	public var cursor:PrxUICursor;
	public var mouse:FlxPoint;

	public function new() {
		super();
		cursor = new PrxUICursor();
	}
	
	public override function update(elapsed:Float) {
		cursor.justMoved = false;
		mouse = FlxG.mouse.getPositionInCameraView(GameG.staticCam, mouse);
		super.update(elapsed);
		cursor.update(elapsed);
	}

	public override function draw() {
		super.draw();
		cursor.draw();
	}

	override function add(thing:PrxUIObject) {
		thing.setCanvas(this);
		GameG.toStaticCam(thing);
		return super.add(thing);
	}

	public function mouseHover(thing:PrxUIObject) {
		cursor.hoverTo(thing);
	}

	override function toString() {
		return members.toString();
	}

	public function startCursorAt(ting:PrxUIObject) {
		cursor.hoverTo(ting);
	}

	public function startCursorAtFirst() {
		startCursorAt(members[0]);
	}

	public function connectAuto() {
		for (thing in members) {
			thing.connectDown = maxByFunc(oting->oting.y>thing.y?-oting.y-Math.abs(oting.x-thing.x)*2:-5318008);
			thing.connectUp = maxByFunc(oting->oting.y<thing.y?oting.y-Math.abs(oting.x-thing.x)*2:-5318008);
			thing.connectRight = maxByFunc(oting->oting.x>thing.x?-oting.x-Math.abs(oting.y-thing.y)*2:-5318008);
			thing.connectLeft = maxByFunc(oting->oting.x<thing.x?oting.x-Math.abs(oting.y-thing.y)*2:-5318008);
		}
	}
}
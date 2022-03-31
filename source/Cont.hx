import entities.DreamPlayer;
import flixel.FlxG;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;

class Cont {
	static var manager:PrxActionManager;
	public static var moveUp:FlxActionDigital;
	public static var moveDown:FlxActionDigital;
	public static var moveLeft:FlxActionDigital;
	public static var moveRight:FlxActionDigital;
	public static var sneak:FlxActionDigital;

	public static var menuLeft:FlxActionDigital;
	public static var menuRight:FlxActionDigital;
	public static var menuUp:FlxActionDigital;
	public static var menuDown:FlxActionDigital;
	public static var confirm:FlxActionDigital;

	public static var move:FlxActionAnalog;

	public static var pause:FlxActionDigital;

	static var loaded:Bool = false;
	
	public static function ensureLoaded():Void {
		//trace("fuck everything");
		if (!loaded) {
			loadAndStuff();
			FlxG.inputs.resetOnStateSwitch = false;
			loaded = true;
		}
	}

	public static function loadAndStuff():Void {
		//manager = FlxG.inputs.add(new PrxActionManager());
		manager = new PrxActionManager();
		manager.resetOnStateSwitch = ResetPolicy.NONE;
		FlxG.inputs.add(manager);
		
		moveUp = new FlxActionDigital("Move Up");
		moveDown = new FlxActionDigital("Move Down");
		moveLeft = new PrxActionDigital("Move Left");
		moveRight = new FlxActionDigital("Move Right");
		sneak = new FlxActionDigital("Sneak");
		move = new FlxActionAnalog("Move Analog");
		menuUp = new FlxActionDigital("Menu Up");
		menuDown = new FlxActionDigital("Menu Down");
		menuLeft = new FlxActionDigital("Menu Left");
		menuRight = new FlxActionDigital("Menu Right");
		confirm = new FlxActionDigital("Confirm");
		pause = new FlxActionDigital("Pause");
		//keyboard
		moveUp.addKey(UP, PRESSED);
		moveUp.addKey(W, PRESSED);
		moveDown.addKey(DOWN, PRESSED);
		moveDown.addKey(S, PRESSED);
		moveLeft.addKey(LEFT, PRESSED);
		moveLeft.addKey(A, PRESSED);
		moveRight.addKey(RIGHT, PRESSED);
		moveRight.addKey(D, PRESSED);
		sneak.addKey(SHIFT, PRESSED);
		menuUp.addKey(UP, JUST_PRESSED);
		menuUp.addKey(W, JUST_PRESSED);
		menuDown.addKey(DOWN, JUST_PRESSED);
		menuDown.addKey(S, JUST_PRESSED);
		menuLeft.addKey(LEFT, JUST_PRESSED);
		menuLeft.addKey(A, JUST_PRESSED);
		menuRight.addKey(RIGHT, JUST_PRESSED);
		menuRight.addKey(D, JUST_PRESSED);
		confirm.addKey(ENTER, JUST_PRESSED);
		confirm.addKey(Z, JUST_PRESSED);
		pause.addKey(P, JUST_PRESSED);
		pause.addKey(ESCAPE, JUST_PRESSED);
		//dpad
		moveUp.addGamepad(DPAD_UP, PRESSED);
		moveDown.addGamepad(DPAD_DOWN, PRESSED);
		moveLeft.addGamepad(DPAD_LEFT, PRESSED);
		moveRight.addGamepad(DPAD_RIGHT, PRESSED);
		sneak.addGamepad(LEFT_SHOULDER, PRESSED);
		menuUp.addGamepad(DPAD_UP, JUST_PRESSED);
		menuDown.addGamepad(DPAD_DOWN, JUST_PRESSED);
		menuLeft.addGamepad(DPAD_LEFT, JUST_PRESSED);
		menuRight.addGamepad(DPAD_RIGHT, JUST_PRESSED);
		confirm.addGamepad(A, JUST_PRESSED);
		pause.addGamepad(START, JUST_PRESSED);
		//sticks
		move.addGamepad(LEFT_ANALOG_STICK, MOVED, EITHER);
		menuUp.addGamepad(LEFT_STICK_DIGITAL_UP, JUST_PRESSED);
		menuDown.addGamepad(LEFT_STICK_DIGITAL_DOWN, JUST_PRESSED);
		menuLeft.addGamepad(LEFT_STICK_DIGITAL_LEFT, JUST_PRESSED);
		menuRight.addGamepad(LEFT_STICK_DIGITAL_RIGHT, JUST_PRESSED);
		//i'd like to speak to your manager
		manager.addActions([moveUp, moveDown, moveLeft, moveRight, sneak, move,
				menuUp, menuDown, menuLeft, menuRight, confirm, pause]);
	}

	public static function getMoveVector():FlxVector {
		var magnitude:Float = 1;
		var controlVector:FlxVector = new FlxVector(0, 0);
		if (moveUp.triggered) {
			controlVector.y -= 1;
		}
		if (moveDown.triggered) {
			controlVector.y += 1;
		}
		if (moveLeft.triggered) {
			controlVector.x -= 1;
		}
		controlVector.add(move.x, move.y);
		if (moveRight.triggered) {
			controlVector.x += 1;
		}
		if (sneak.triggered) {
			magnitude = DreamPlayer.SNEAK_MAX;
		}
		controlVector.truncate(magnitude);
		return controlVector;
		/*var magnitude:Float = 1;
		var controlVector:FlxVector = new FlxVector(0, 0);
		if (FlxG.keys.anyPressed([FlxKey.LEFT, FlxKey.A])) {
			controlVector.x -= 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.RIGHT, FlxKey.D])) {
			controlVector.x += 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.UP, FlxKey.W])) {
			controlVector.y -= 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.DOWN, FlxKey.S])) {
			controlVector.y += 1;
		}
		if (FlxG.keys.anyPressed([FlxKey.SHIFT])) {
			magnitude = DreamPlayer.SNEAK_MAX;
		}
		controlVector.truncate(magnitude);
		return controlVector;*/
	}

}

class PrxActionManager extends FlxActionManager {
	
	var numUpdates:Int = 0;
	public override function update() {
		super.update();
		//trace(numUpdates++);
		
	}

	public override function destroy() {
		//throw "fuck you";
	}
}

class PrxActionDigital extends FlxActionDigital {
	var numUpdates:Int = 0;
	public override function update() {

		super.update();
	}

	public override function destroy() {

		//throw "please just fucking die";
	}
}
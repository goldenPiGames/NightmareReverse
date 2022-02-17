package menus;

import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class PrxUICursor extends FlxUICursor {
	public function new(callback:(String,IFlxUIWidget)->Void) {
		super(callback);
		dispatchEvents = false;
	}

	private override function _checkKeys():Void {
		var wasInvisible = (visible == false);
		var lastLocation = location;
		if (Cont.menuUp.triggered)
			_doInput(0, -1);
		if (Cont.menuDown.triggered)
			_doInput(0, 1);
		if (Cont.menuLeft.triggered)
			_doInput(-1, 0);
		if (Cont.menuRight.triggered)
			_doInput(1, 0);

		if (wasInvisible && visible && lastLocation != -1) {
			location = lastLocation;
		}

		if (Cont.confirm.triggered) { // JUST PRESSED: send a press event only the first time it's pressed
			if (!ignoreNextInput) {
				_clickPressed = true;
				_clickTime = 0;
				_doPress();
			} else {
				ignoreNextInput = false;
			}
		} else if (_clickTime > 0) { // NOT PRESSED and not exact same frame as when it was just pressed
			if (_clickPressed) {// if we were previously just pressed...
				_doRelease(); // do the release action
				_clickPressed = false; // count this as "just released"
			}
		}
	}
}
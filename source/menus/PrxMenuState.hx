package menus;

import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;

class PrxMenuState extends FlxUIState {
	public override function create() {
		_makeCursor = true;
		super.create();
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD | FlxUICursor.KEYS_TAB| FlxUICursor.GAMEPAD_DPAD);
	}
}
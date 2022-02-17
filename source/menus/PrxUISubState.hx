package menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import menus.PrxUIState;

class PrxUISubState extends FlxUISubState implements IPrxUIState {
	var state:PlayState;
	var haveAnchoredCamera:Bool = false;

	public override function create() {
		_makeCursor = true;
		super.create();
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD | FlxUICursor.KEYS_TAB| FlxUICursor.GAMEPAD_DPAD);
	}

	//COPY FROM PrxMenuState

	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (destroyed)
			return;
		PrxUIState.getEventI(this, name, sender, data, params);
	}

	public function getButtonEvent(name:String, params:Array<Dynamic>) {

	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!haveAnchoredCamera) {
			tryToAnchorCamera();
		}
	}

	function tryToAnchorCamera():Void {
		cameras = [state.hud.camera];
		forceScrollFactor(0, 0);
		if (_ui != null) {
			haveAnchoredCamera = true;
			_ui.group.forEach(anchorObject);
		}
		//else trace("_ui does not exist yet");
		//for the museum: before i realized that the buttons are not kept in the state's normal group
		//forEachOfType(FlxObject, anchorObject);
	}

	function anchorObject(o:FlxObject) {
		o.scrollFactor.set(0, 0);
		o.cameras = [state.hud.camera];
	}

	public function setState(instate:PlayState) {
		state = instate;
		tryToAnchorCamera();
	}
}
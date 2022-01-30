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

class PrxUISubState extends FlxUISubState {
	var state:PlayState;

	public override function create() {
		_makeCursor = true;
		super.create();
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD | FlxUICursor.KEYS_TAB| FlxUICursor.GAMEPAD_DPAD);
	}

	//COPY FROM PrxMenuState

	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (destroyed)
			return;
		/*if (name == "down_button" && params != null && params.length >= 2) {
			GameG.levelID = cast params[1];
			switchState(new PlayState());
		}*/
		//arigato playstatewolf-sensei
		switch (name) { // check which event was called
			case FlxUITypedButton.CLICK_EVENT:
				var widget:IFlxUIWidget = cast(sender, IFlxUIWidget); // get the widget that called the event
				if (widget != null && (widget is FlxUIButton)) { // we are over a button indeed
					var btn:FlxUIButton = cast(widget, FlxUIButton); //  get the btn
					getButtonEvent(btn.name, params);
				}
		}
	}

	public function getButtonEvent(name:String, params:Array<Dynamic>) {

	}

	function anchorCamera():Void {
		cameras = [state.hud.camera];
		forEachOfType(FlxObject, anchorObject);
	}

	function anchorObject(o:FlxObject) {
		o.scrollFactor.set(0, 0);
		o.cameras = [state.hud.camera];
	}

	public function setState(instate:PlayState) {
		state = instate;
		anchorCamera();
	}
}
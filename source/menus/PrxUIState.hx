package menus;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;

interface IPrxUIState {
	public function getButtonEvent(name:String, params:Array<Dynamic>):Void;
}

class PrxUIState extends FlxUIState implements IPrxUIState {
	public override function create() {
		Lang.ensureLoaded();
		Cont.ensureLoaded();
		_makeCursor = true;
		super.create();
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD | FlxUICursor.KEYS_TAB| FlxUICursor.GAMEPAD_DPAD);
	}

	private override function createCursor() {
		return new PrxUICursor(onCursorEvent);
	}

	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (destroyed)
			return;
		getEventI(this, name, sender, data, params);
	}

	public static inline function getEventI(thisser:IPrxUIState, name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		/*if (name == "down_button" && params != null && params.length >= 2) {
			GameG.levelID = cast params[1];
			switchState(new PlayState());
		}*/
		//trace(name);
		//arigato playstatewolf-sensei
		switch (name) { // check which event was called
			case "click_button":
				var widget:IFlxUIWidget = cast(sender, IFlxUIWidget); // get the widget that called the event
				if (widget != null && (widget is FlxUIButton)) { // we are over a button indeed
					var btn:FlxUIButton = cast(widget, FlxUIButton); //  get the btn
					thisser.getButtonEvent(btn.name, params);
				}
			case "cursor_click":
				var widget:IFlxUIWidget = cast sender; // get the widget that called the event
				if (widget != null && (widget is FlxUIButton)) { // we are over a button indeed
					var btn:FlxUIButton = cast widget; //  get the btn
					thisser.getButtonEvent(btn.name, btn.params);
				}
		}
	}

	public function getButtonEvent(name:String, params:Array<Dynamic>) {

	}

	function switchState(nextState:FlxState) {
		//cursor.location = -1;
		FlxG.switchState(nextState);
	}
}
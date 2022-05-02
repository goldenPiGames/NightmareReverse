package weather;

import flixel.FlxBasic;
import misc.PrxTypedGroup;
import states.PlayState;

class DreamWeather extends PrxTypedGroup<FlxBasic> {
	var state:PlayState;
	public function new(thestate:PlayState) {
		super();
		state = thestate;
	}

	public function startSound() {
		
	}
}
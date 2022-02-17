import entities.DreamPlayer;
import flixel.FlxObject;

class CameraFocus extends FlxObject {
	var state:PlayState;
	var player:DreamPlayer;
	var lagBySecond:Float = .04;

	public function new(instate:PlayState) {
		super();
		state = instate;
		player = state.player;
		x = player.midx();
		y = player.midy();
		setSize(0, 0);
	}

	public override function update(elapsed:Float) {
		var port = Math.pow(lagBySecond, elapsed);
		x = x*port + player.midx()*(1-port);
		y = y*port + player.midy()*(1-port);
	}

	public function playerDeathReset() {
		x = player.midx();
		y = player.midy();
	}
}
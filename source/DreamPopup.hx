import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import states.PlayState;

class DreamPopup extends FlxSubState {
	var state:PlayState;
	var timer:Float = 0;

	public function setState(instate:PlayState) {
		state = instate;
	}

	public override function update(elapsed:Float) {
		timer += elapsed;
		state.updateBehindPopup(elapsed);
		super.update(elapsed);
	}
}

class DeathPopup extends DreamPopup {
	override function close() {
		super.close();
		state.resetAfterDeath();
	}
}

class VoidDeathPopup extends DeathPopup {
	var darkness:FlxSprite;
	static inline var VOID_RISE_START:Float = 0.5;
	static inline var VOID_RISE_END:Float = 0.7;
	static inline var VOID_TOTAL_LENGTH:Float = 1.2;

	override function create() {
		super.create();
		darkness = new FlxSprite();
		darkness.loadGraphic("assets/popups/Void.png");
		darkness.setGraphicSize(FlxG.width);
		darkness.scrollFactor.set(0, 0);
		darkness.updateHitbox();
		//darkness.width = FlxG.width;
		//darkness.height = FlxG.width;
		//darkness.offset.set(0, 0);
		darkness.x = 0;
		darkness.y = FlxG.height;
		darkness.cameras = [state.hud.camera];
		add(darkness);
	}

	override function setState(instate:PlayState) {
		super.setState(instate);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (timer > VOID_RISE_START && timer < VOID_RISE_END) {
			darkness.y = FlxG.height * (1 - 1.5 * ((timer - VOID_RISE_START) / (VOID_RISE_END - VOID_RISE_START)));
		} else if (timer > VOID_RISE_END) {
			close();
		}
	}

	override function draw() {
		super.draw();
	}
}
package entities;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import geom.SpriteDir;

class Checkpoint extends DreamEntity {

	public function new(args:EntityData) {
		super(args);
		infoName = "Checkpoint";
		touchPriority = 64;
		loadGraphic("assets/sprites/Checkpoint.png", true, 32, 32);
		spriteDir = new SpriteDirStatic();
		animation.add("down", [0], 1, true);
		animation.add("raise", [1,2,3], 15, false);
		setSizeS(16, 16);
		offset.set(8, 8);
		pathPass = GROUND;
		playAnimation("down");
	}

	override function generalReset() {

	}
	
	public override function touch(other:DreamEntity) {
		if (Std.isOfType(other, DreamPlayer)) {
			var player:DreamPlayer = cast other;
			if (player.checkpoint != this) {
				activate(player);
			}
		}
	}

	function activate(peep:DreamPlayer):Void {
		peep.checkpoint = this;
		state.entities.forEachOfType(Checkpoint, c->c.deactivate());
		playAnimation("raise");
	}

	function deactivate() {
		playAnimation("down");
	}
}
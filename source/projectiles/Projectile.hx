package projectiles;

import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import geom.PrxTilemap;

class Projectile extends DreamEntity {
	var source:DreamEntity;

	public function new(?args:EntityData) {
		super(args);
		touchPriority = 32;
	}

	function setSource(sauce:DreamEntity) {
		source = sauce;
		team = source.team;
	}

	public override function touch(other:DreamEntity) {
		if (other.hittable && other.team != this.team) {
			other.getHit(this);
			destroy();
		}
	}

	function destroyIfTouchingWall() {
		if (state.wallmap.overlaps(this))
			destroy();
	}
}
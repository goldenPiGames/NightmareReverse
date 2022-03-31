package geom;

import entities.DreamEntity;
import entities.DreamPlayer;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import geom.SpriteDir.SpriteDirStatic;

class AlarmedTile extends ConditionalTile {
	public function new(args:EntityData) {
		super(args);
		infoName = "Alarmed Tile";
		touchPriority = 48;
		loadGraphic("assets/sprites/SpikeTile.png", true, 20, 24);
		setSpriteDir(SpriteDirStatic);
		animation.add("inactive", [2,1,0], 30, false);
		animation.add("active", [1,2,3], 30, false);
		offset.set(0, 4);
		setSize(20, 20);
		playSetStartAnimation("inactive");
		typeWhenActive = {
			name:"Alarmed Tile",
			solid:false,
			void:false,
			spike:true,
			blend:null,
			vision:true,
		};
	}

	public override function isActive():Bool {
		return state.pursuit;
	}

	public override function touch(other:DreamEntity) {
		if (activated) {
			if (Std.isOfType(other, DreamPlayer)) {
				var bup:DreamPlayer = cast other;
				bup.getSpiked(this);
			}
		}
	}
}
package geom;

import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import geom.PrxTilemap.PrxTilesetTileMetadata;

class ConditionalTile extends TileEntity {
	var activated:Bool = false;
	var prevActivated:Bool = false;
	var typeWhenActive:PrxTilesetTileMetadata;

	public function new(args:EntityData) {
		super(args);
		setSize(20, 20);
	}

	public override function update(elapsed:Float) {
		prevActivated = activated;
		super.update(elapsed);
		activated = isActive();
		if (activated && !prevActivated)
			playAnimation("active");
		if (!activated && prevActivated)
			playAnimation("inactive");
	}

	public override function modifyT(t:PrxTilesetTileMetadata):PrxTilesetTileMetadata {
		if (activated)
			return typeWhenActive;
		else
			return t;
	}

	public function isActive():Bool {
		return false;
	}

	public override function generalReset() {
		
	}

	public override function toString():String {
		return super.toString()+" activated:"+activated;
	}
}
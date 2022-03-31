package geom;

import entities.DreamEntity;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import geom.PrxTilemap.PrxTilesetTileMetadata;
import states.PlayState;

class TileEntity extends DreamEntity {

	public function new(args:EntityData) {
		super(args);
	}

	public override function setState(instate:PlayState) {
		super.setState(instate);
		state.wallmap.addTileEntity(this);
	}

	public function addToTiles(map:PrxTilemap) {

	}

	public function modifyT(t:PrxTilesetTileMetadata):PrxTilesetTileMetadata {
		return t;
	}
}
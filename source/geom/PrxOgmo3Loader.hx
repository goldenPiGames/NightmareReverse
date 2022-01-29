package geom;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;

typedef PrxTilemapValues = {
	var tileset:String;
}

class PrxOgmo3Loader extends FlxOgmo3Loader {
	public function loadPrxTilemap(tileGraphic:FlxTilemapGraphicAsset, tileLayer:String = "tiles", ?tilemap:PrxTilemap):PrxTilemap {
		if (tilemap == null)
			tilemap = new PrxTilemap();

		//var layer = level.getTileLayer(tileLayer);
		var layer = FlxOgmo3Loader.getTileLayer(level, tileLayer);
		//var tileset = project.getTilesetData(layer.tileset);
		var tileset = FlxOgmo3Loader.getTilesetData(project, layer.tileset);
		switch (layer.arrayMode) {
			case 0:
				tilemap.loadFMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, getPaddedTileset(tileset, cast tileGraphic), tileset.tileWidth, tileset.tileHeight, AUTO);
			case 1:
				tilemap.loadFMapFrom2DArray(layer.data2D, getPaddedTileset(tileset, cast tileGraphic), tileset.tileWidth, tileset.tileHeight);
		}
		return tilemap;
	}

	public function getPrxTileset() {
		var values:PrxTilemapValues = cast level.values;
		return values.tileset;
	}

	/**
	@author GeoKureli
	*/
	inline function getPaddedTileset(tileset:ProjectTilesetData, path:FlxGraphicAsset, padding = 2) {
		return FlxTileFrames.fromBitmapAddSpacesAndBorders
			(path
			, FlxPoint.get(tileset.tileWidth, tileset.tileHeight)
			, FlxPoint.get(tileset.tileSeparationX, tileset.tileSeparationY)
			, FlxPoint.get(padding, padding)
			);
	}
}
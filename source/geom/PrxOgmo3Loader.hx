package geom;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;

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
				tilemap.loadFMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileGraphic, tileset.tileWidth, tileset.tileHeight, AUTO);
			case 1:
				tilemap.loadFMapFrom2DArray(layer.data2D, tileGraphic, tileset.tileWidth, tileset.tileHeight);
		}
		return tilemap;
	}
}
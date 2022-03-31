package geom;

import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import openfl.Assets;

typedef PrxTilemapValues = {
	music:String,
	?scripts:Dynamic
}

class PrxOgmo3Loader extends FlxOgmo3Loader {
	public function loadPrxTilemap(tileLayer:String = "tiles", ?tilemap:PrxTilemap):PrxTilemap {
		if (tilemap == null)
			tilemap = new PrxTilemap();
		//var layer = level.getTileLayer(tileLayer);
		var layer = FlxOgmo3Loader.getTileLayer(level, tileLayer);
		//var tileset = project.getTilesetData(layer.tileset);
		var tileset = FlxOgmo3Loader.getTilesetData(project, layer.tileset);
		tilemap.loadMetadata(tileset.label);
		var tileGraphic:FlxGraphicAsset = "assets/tilesets/"+tileset.label+".png";
		switch (layer.arrayMode) {
			case 0:
				tilemap.loadFMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, getPaddedTileset(tileset, cast tileGraphic), tileset.tileWidth, tileset.tileHeight, AUTO);
			case 1:
				tilemap.loadFMapFrom2DArray(layer.data2D, getPaddedTileset(tileset, cast tileGraphic), tileset.tileWidth, tileset.tileHeight);
		}
		tilemap.applyTProperties();
		return tilemap;
	}

	public function getMusic():String {
		var values:PrxTilemapValues = cast level.values;
		return values.music;
	}

	public function getScripts():Dynamic {
		var values:PrxTilemapValues = cast level.values;
		return values.scripts;
	}

	/**
	@author GeoKureli
	*/
	inline function getPaddedTileset(tileset:ProjectTilesetData, path:FlxGraphicAsset, padding = 2) {
		return FlxTileFrames.fromBitmapAddSpacesAndBorders(path, 
			FlxPoint.get(tileset.tileWidth, tileset.tileHeight), 
			FlxPoint.get(tileset.tileSeparationX, tileset.tileSeparationY), 
			FlxPoint.get(padding, padding));
	}

	public function setBounds():Void {
		FlxG.worldBounds.set(0, 0, level.width, level.height);
	}
}
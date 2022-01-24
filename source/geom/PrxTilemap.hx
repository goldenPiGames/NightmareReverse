package geom;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDirectionFlags;

class PrxTilemap extends FlxTilemap {

	static inline var VIS_PER_FUNC:Int = 16;

	/** The functional data, which is actually used for most custom calculations. */
	var _fdata:Array<Int>;

	public function new() {
		super();
		useScaleHack = false;
	}

	public function loadFMapFromArray(MapData:Array<Int>, WidthInTiles:Int, HeightInTiles:Int, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0,
			TileHeight:Int = 0, ?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1) {
		_fdata = MapData.copy();
		loadMapFromArray(MapData, WidthInTiles, HeightInTiles, TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
	}

	public function loadFMapFrom2DArray(MapData:Array<Array<Int>>, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0,
			?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1) {
		_fdata = FlxArrayUtil.flatten2DArray(MapData);
		loadMapFrom2DArray(MapData, TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
	}

	/**
	 * An internal function used by the binary auto-tilers. (16 tiles)
	 * @param	Index		The index of the tile you want to analyze.
	 */
	override function autoTile(Index:Int):Void {
		
		var thisf:Int = _fdata[Index];

		/** Which visual variation of the tile it is */
		var edgy:Int = 0;

		// UP
		if ((Index - widthInTiles < 0) || (_fdata[Index - widthInTiles] == thisf)) {
			edgy += 1;
		}
		// RIGHT
		if ((Index % widthInTiles >= widthInTiles - 1) || (_fdata[Index + 1] == thisf)) {
			edgy += 2;
		}
		// DOWN
		if ((Std.int(Index + widthInTiles) >= totalTiles) || (_fdata[Index + widthInTiles] == thisf)) {
			edgy += 4;
		}
		// LEFT
		if ((Index % widthInTiles <= 0) || (_fdata[Index - 1] == thisf)) {
			edgy += 8;
		}

		// The alternate algo checks for interior corners
		/*if ((auto == ALT) && (edgy == 15))
		{
			// BOTTOM LEFT OPEN
			if ((Index % widthInTiles > 0) && (Std.int(Index + widthInTiles) < totalTiles) && (_data[Index + widthInTiles - 1] <= 0))
			{
				_data[Index] = 1;
			}
			// TOP LEFT OPEN
			if ((Index % widthInTiles > 0) && (Index - widthInTiles >= 0) && (_data[Index - widthInTiles - 1] <= 0))
			{
				_data[Index] = 2;
			}
			// TOP RIGHT OPEN
			if ((Index % widthInTiles < widthInTiles - 1) && (Index - widthInTiles >= 0) && (_data[Index - widthInTiles + 1] <= 0))
			{
				_data[Index] = 4;
			}
			// BOTTOM RIGHT OPEN
			if ((Index % widthInTiles < widthInTiles - 1)
				&& (Std.int(Index + widthInTiles) < totalTiles)
				&& (_data[Index + widthInTiles + 1] <= 0))
			{
				_data[Index] = 8;
			}
		}*/

		_data[Index] = thisf * VIS_PER_FUNC + edgy + 1;
	}

	public function setFTileProperties(Tile:Int, AllowCollisions:FlxDirectionFlags = ANY) {
		for (i in (Tile*VIS_PER_FUNC+1)...((Tile+1)*VIS_PER_FUNC+1)) {
			setTileProperties(i, AllowCollisions);
		}
	}

	public function getDijkstra(thing:DreamEntity):PrxTilemapDijkstra {
		var edsger = new PrxTilemapDijkstra(thing, this);
		return edsger;
	}

	public function getAccessibilityArray(thing:DreamEntity) {
		return _fdata.map(f -> thing.pathPass.hasType(f));
	}

	inline function canEntityPassIndex(thing:DreamEntity, i:Int) {
		//trace(thing.pathPass+" on "+_fdata[i]);
		return thing.pathPass.hasType(_fdata[i]);
	}

	/*function canEntityPassIndexRect(thing:DreamEntity, dex:Int, width:Int, height:Int):Bool {
		for (i in 0...width) {
			for (j in 0...height) {
				if (!canEntityPassIndex(thing, dex + i + j*widthInTiles))
					return false;
			}
		}
		return true;
	}*/

	public function tileToString(index:Int):String {
		return "(tile="+index+",x="+(index%widthInTiles)+",y="+Std.int(index/widthInTiles)+",data="+_data[index]+",fdata="+_fdata[index]+")";
	}

	public function getSpriteWidthInTiles(thing:FlxSprite) {
		return Std.int((thing.width-1) / _tileWidth) + 1;
	}
	
	public function getSpriteHeightInTiles(thing:FlxSprite) {
		return Std.int((thing.height-1) / _tileHeight) + 1;
	}

	public function getPathPointOffset(wideness:Int, tallness:Int) {
		return new FlxPoint((wideness-1)/2*_tileWidth, (tallness-1)/2*_tileHeight);
	}

	public function getTileXByCoords(coord:FlxPoint):Int {
		var localX = coord.x - x;
		return Std.int(localX / _scaledTileWidth);
	}
	
	public function getTileYByCoords(coord:FlxPoint):Int {
		var localY = coord.y - y;
		return Std.int(localY / _scaledTileHeight);
	}

	public function getOpacityRect(x:Int, y:Int, width:Int, height:Int):Array<Bool> {
		var ray:Array<Bool> = new Array<Bool>();
		for (i in 0...width) {
			for (j in 0...height) {
				ray[i + j*width] = isTileOpaque(x+i, y+j);
			}
		}
		return ray;
	}

	public function isTileOpaque(a:Int, b:Int):Bool {
		if (a < 0 || a >= widthInTiles || b < 0 || b >= heightInTiles)
			return true;
		return (_fdata[a + b*widthInTiles] == 2);//TODO change this when i have more functional floor types
	}

	public function getTileWidth():Dynamic {
		return _tileWidth;
	}
}


package geom;

import entities.DreamEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDirectionFlags;
import haxe.Json;
import openfl.Assets;

class PrxTilemap extends FlxTilemap {

	static inline var VIS_PER_FUNC:Int = 16;

	var tileEntities:FlxTypedGroup<TileEntity>;
	var tileEntitiesGrouped:Array<Array<TileEntity>>;
	var needRegroupTileEntities:Bool = true;
	public var metadata:PrxTilesetMetadata;

	/** The functional data, which is actually used for most custom calculations. */
	var _fdata:Array<Int>;

	/** _fdata, modified by tile entites. **/
	var tstate:Array<PrxTilesetTileMetadata>;

	public function new() {
		super();
		useScaleHack = false;
		tileEntities = new FlxTypedGroup<TileEntity>();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (needRegroupTileEntities) {
			regroupTileEntities();
		}
		refreshTState();
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
	 * @param	index		The index of the tile you want to analyze.
	 */
	override function autoTile(index:Int):Void {
		
		var thisf:Int = _fdata[index];
		if (thisf < 0) {
			_fdata[index] = 0;
			thisf = 0;
		}

		var thist:PrxTilesetTileMetadata = metadata.tiles[thisf];

		/** Which visual variation of the tile it is */
		var edgy:Int = 0;

		// UP
		if ((index - widthInTiles < 0) || thist.blend[_fdata[index - widthInTiles]]) {
			edgy += 1;
		}
		// RIGHT
		if ((index % widthInTiles >= widthInTiles - 1) || thist.blend[_fdata[index + 1]]) {
			edgy += 2;
		}
		// DOWN
		if ((Std.int(index + widthInTiles) >= totalTiles) || thist.blend[_fdata[index + widthInTiles]]) {
			edgy += 4;
		}
		// LEFT
		if ((index % widthInTiles <= 0) || thist.blend[_fdata[index - 1]]) {
			edgy += 8;
		}

		// The alternate algo checks for interior corners
		/*if ((auto == ALT) && (edgy == 15))
		{
			// BOTTOM LEFT OPEN
			if ((index % widthInTiles > 0) && (Std.int(index + widthInTiles) < totalTiles) && (_data[index + widthInTiles - 1] <= 0))
			{
				_data[index] = 1;
			}
			// TOP LEFT OPEN
			if ((index % widthInTiles > 0) && (index - widthInTiles >= 0) && (_data[index - widthInTiles - 1] <= 0))
			{
				_data[index] = 2;
			}
			// TOP RIGHT OPEN
			if ((index % widthInTiles < widthInTiles - 1) && (index - widthInTiles >= 0) && (_data[index - widthInTiles + 1] <= 0))
			{
				_data[index] = 4;
			}
			// BOTTOM RIGHT OPEN
			if ((index % widthInTiles < widthInTiles - 1)
				&& (Std.int(index + widthInTiles) < totalTiles)
				&& (_data[index + widthInTiles + 1] <= 0))
			{
				_data[index] = 8;
			}
		}*/

		_data[index] = thisf * VIS_PER_FUNC + edgy + 1;
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

	public function getAccessibilityArray(thing:DreamEntity):Array<Bool> {
		var blem = new Array<Bool>();
		blem.resize(_fdata.length);
		for (i in 0...blem.length) {
			blem[i] = canEntityPassIndex(thing, i);
		}
		return blem;
	}

	public inline function canEntityPassIndex(thing:DreamEntity, i:Int):Bool {
		return thing.canPassTile(tstate[i]);
	}

	public function canEntityPassCoords(thing:DreamEntity, where:FlxPoint):Bool {
		//trace(thing.pathPass+" on "+_fdata[i]);
		return thing.canPassTile(tstate[getTileIndexByCoords(where)]);
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

	public function rayVision(start:FlxPoint, end:FlxPoint, ?precision:Float):Bool {
		if (precision == null) {
			precision = Math.max(_tileWidth, _tileHeight);
		}
		var startX:Float = (start.x - x) / _scaledTileWidth;
		var startY:Float = (start.y - y) / _scaledTileWidth;
		var endX:Float = (end.x - x) / _scaledTileWidth;
		var endY:Float = (end.y - y) / _scaledTileWidth;
		var diffX:Float = endX - startX;
		var diffY:Float = endY - startY;
		var numSteps:Int = Std.int(Math.max(Math.abs(diffX), Math.abs(diffY)) * precision);
		var stepX:Float = diffX / numSteps;
		var stepY:Float = diffY / numSteps;
		for (i in 0...numSteps) {
			if (!tstate[Std.int(startX+stepX*i) + Std.int(startY+stepY*i)*widthInTiles].vision) {
				return false;
			}
		}
		return true;
	}

	public function addTileEntity(thing:TileEntity) {
		tileEntities.add(thing);
	}

	public function regroupTileEntities() {
		tileEntitiesGrouped = new Array<Array<TileEntity>>();
		tileEntitiesGrouped.resize(_fdata.length);
		tileEntities.forEach(addTileEntityToTiles);
	}

	function addTileEntityToTiles(yeah:TileEntity) {
		var index:Int = getTileIndexByCoords(yeah.getMidpoint());
		if (tileEntitiesGrouped[index] == null)
			tileEntitiesGrouped[index] = new Array<TileEntity>();
		tileEntitiesGrouped[index].push(yeah);
	}

	function refreshTState():Void {
		tstate = _fdata.map(f->metadata.tiles[f]);
		for (i in 0...tstate.length) {
			if (tileEntitiesGrouped[i] != null) {
				for (dab in tileEntitiesGrouped[i]) {
					tstate[i] = dab.modifyT(tstate[i]);
				}
			}
		}
	}

	public function loadMetadata(label:String):Void {
		metadata = Json.parse(Assets.getText("assets/tilesets/"+label+".json"));
	}
	
	public function applyTProperties():Void {
		for (i in 0...metadata.tiles.length) {
			setFTileProperties(i, metadata.tiles[i].solid ? FlxDirectionFlags.ANY : FlxDirectionFlags.NONE);
		}
	}
}

typedef PrxTilesetMetadata = {
	bgColor:Int,
	tiles:Array<PrxTilesetTileMetadata>
}

typedef PrxTilesetTileMetadata = {
	name:String,
	solid:Bool,
	void:Bool,
	spike:Bool,
	vision:Bool,
	blend:Array<Bool>,
}
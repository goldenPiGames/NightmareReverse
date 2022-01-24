package geom;

import flixel.math.FlxPoint;
import flixel.math.FlxVector;


class PrxTilemapDijkstra {
	public var thing:DreamEntity;
	var thingWidth:Int;
	var thingHeight:Int;
	var thingPointOffset:FlxPoint;
	public var map:PrxTilemap;
	var entries:Array<PrxDijkstraEntry>;
	var rowSize:Int;
	var startIndex:Int;
	
	public function new(thething:DreamEntity, themap:PrxTilemap) {
		thing = thething;
		map = themap;
		entries = new Array<PrxDijkstraEntry>();
		thingWidth = map.getSpriteWidthInTiles(thing);
		thingHeight = map.getSpriteHeightInTiles(thing);
		thingPointOffset = map.getPathPointOffset(thingWidth, thingHeight);
		startIndex = map.getTileIndexByCoords(thing.getMidpoint().subtractPoint(thingPointOffset));
		rowSize = map.widthInTiles;
	}

	public function getPathTo(endPoint:FlxPoint):Array<FlxPoint> {

		var axes:Array<Bool> = map.getAccessibilityArray(thing);
		for (i in 0...axes.length-1) {
			entries[i] = new PrxDijkstraEntry(i, axes[i]);
		}
		if (thingWidth > 1 || thingHeight > 1) {
			var lastSizeSpace:Int = indexOffset(entries.length-1, 1-thingWidth, 1-thingHeight);
			for (i in 0...lastSizeSpace) {
				if (entries[i].accessible) {
					for (a in 0...thingWidth) {
						for (b in 0...thingHeight) {
							if (!isOffsetAccessible(i, a, b))
								entries[i].accessible = false;
						}
					}
				}
			}
			for (i in lastSizeSpace...entries.length) {
				entries[i].accessible = false;
			}
		}
		var indexEndBase = map.getTileIndexByCoords(endPoint);
		for (a in 0...thingWidth) {
			for (b in 0...thingHeight) {
				entries[indexOffset(indexEndBase, -a, -b)].ending = true;
			}
		}
		entries[startIndex].setStart();
		var currentIndex:Int = startIndex;
		var shortestDistance:Float;
		while (true) {
			//left
			maybeAddEdge(currentIndex, currentIndex-1, 1);
			//right
			maybeAddEdge(currentIndex, currentIndex+1, 1);
			//up
			maybeAddEdge(currentIndex, currentIndex-rowSize, 1);
			//down
			maybeAddEdge(currentIndex, currentIndex+rowSize, 1);
			//choose the next node
			//trace("at: "+tileToString(startIndex));
			entries[currentIndex].known = true;
			if (entries[currentIndex].ending)
				return tracePathTo(currentIndex);
			currentIndex = -1;
			shortestDistance = PrxDijkstraEntry.NOPE;
			for (i in 0...entries.length) {
				//trace("i="+i+", accessible="+dijks[i].accessible+",known="+!dijks[i].known+",touched="+dijks[i].touched+",distance="+dijks[i].distance+",shortest="+shortestDistance+")");
				if (entries[i].accessible && !entries[i].known && entries[i].touched && entries[i].distance < shortestDistance) {
					//trace("das a good one");
					currentIndex = i;
					shortestDistance = entries[i].distance;
				}
			}
			if (currentIndex == -1)
				return null;
		}
	}

	public function getPathNearest(endPoint:FlxPoint) {
		var closestDist:Float = Math.POSITIVE_INFINITY;
		var closestIndex:Int = -1;
		var diff:FlxVector;
		for (i in 0...entries.length) {
			if (entries[i].touched && entries[i].distance < closestDist) {
				diff = map.getTileCoordsByIndex(i).addPoint(thingPointOffset).subtractPoint(endPoint);
				if (diff.length < closestDist) {
					closestDist = diff.length;
					closestIndex = i;
				}
			}
		}
		return tracePathTo(closestIndex);
	}

	function tracePathTo(currIndex:Int):Array<FlxPoint> {
		if (currIndex < 0)
			return null;
		var path:Array<FlxPoint> = new Array<FlxPoint>();
		while (currIndex != startIndex) {
			//trace(tileToString(currIndex));
			path.unshift(map.getTileCoordsByIndex(currIndex, true).addPoint(thingPointOffset));
			//if (path.length > 69) {throw "fuck";}
			currIndex = entries[currIndex].previous;
		}
		var i:Int = 1;
		while (i < path.length - 1) {
			if (PrxGeomMisc.arePointsColinear(path[i-1], path[i], path[i+1])) {
				path.splice(i, 1);
			} else {
				i++;
			}
		}
		return path;
	}
	
	inline function indexOffset(from:Int, horiz:Int, vert:Int):Int {
		return from + horiz + vert*rowSize; //this will probably break if used at the edges
	}

	inline function isOffsetAccessible(from:Int, horiz:Int, vert:Int):Bool {
		return entries[indexOffset(from, horiz, vert)].accessible;
	}

	inline function maybeAddEdge(from:Int, to:Int, edgeLength:Float) {
		entries[to].maybeSetPath(from, entries[from].distance + edgeLength);
	}
}

class PrxDijkstraEntry {
	public static inline var NOPE:Float = 69420;
	public var index:Int;
	public var known:Bool;
	public var distance:Float;
	public var previous:Int;
	public var accessible:Bool;
	public var touched:Bool;
	public var ending:Bool;

	public function new(dex:Int, axe:Bool) {
		index = dex;
		known = false;
		touched = false;
		distance = NOPE;
		accessible = axe;
		previous = -1;
		ending = false;
	}

	public function setStart() {
		known = true;
		touched = true;
		distance = 0;
		previous = index;
	}

	public function maybeSetPath(from:Int, newDistance:Float):Bool {
		//trace(from+" to "+index+": "+newDistance+" vs "+distance+")");
		if (accessible && (newDistance < distance || !touched)) {
			previous = from;
			distance = newDistance;
			touched = true;
			return true;
		} else {
			return false;
		}
	}
}
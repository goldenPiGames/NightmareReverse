package geom;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.Shader;
import openfl.display.ShaderParameter;

class FogLayer extends FlxSprite {
	var shaderFog:FogLayerShader;
	var eye:DreamEntity;
	var map:PrxTilemap;
	var opaqueMapSprite:TilemapOpacitySprite;
	public static inline var OPAQ_ARRAY_MAX:Int = 576;

	public function new() {
		super();
		makeGraphic(FlxG.width, FlxG.height);
		scrollFactor.set(0, 0);
		shaderFog = new FogLayerShader();
		shader = shaderFog;
		shaderFog.data.width.value = [FlxG.width];
		shaderFog.data.height.value = [FlxG.height];
		shaderFog.data.maxRange.value = [120.0];
	}

	public function setEye(ent:DreamEntity) {
		eye = ent;
		/*FlxG.watch.add(camera, "zoom");
		FlxG.watch.add(camera, "width");
		FlxG.watch.add(this, "width");
		FlxG.watch.add(FlxG, "width");*/
	}

/*	public override function update(elapsed:Float) {
		super.update(elapsed);
		opaqRectX = map.getTileXByCoords(eyemid) - 7;
		opaqRectY = map.getTileYByCoords(eyemid) - 7;
		opaqRectWidth = 15;
		opaqRectHeight = 15;
		opaqArray = map.getOpacityRect(opaqRectX, opaqRectY, opaqRectWidth, opaqRectHeight);
		//trace(opaqArray);
		shaderFog.data.opaqRectX.value = [opaqRectX];
		shaderFog.data.opaqRectY.value = [opaqRectY];
		shaderFog.data.opaqRectWidth.value = [opaqRectWidth];
		shaderFog.data.opaqRectHeight.value = [opaqRectHeight];
		shaderFog.data.opaqArray.value = opaqArray;
		shaderFog.data.opaqArray.value[0] = opaqArray[0];
		shaderFog.data.opaqArray.value[1] = [true];
		//shaderFog.data.opaqArray.value = [true,true,false,false,false,false,true,true,true,true,false,false,true,true,true,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,false,true,true,true,true,true,true,true,true,true,false,false,false,true,true,false,true,true,true,true,true,true,false,false,true,false,false,false,true,true,false,false,false,false,false,false,false,false,false,true,false,false,false,false,true,false,false,false,false,false,false,false,false,false,true,false,false,false,false,true,false,false,false,false,false,true,true,false,false,true,false,false,false,false,true,false,false,false,false,false,true,true,false,false,false,false,false,false,false,true,false,false,false,false,false,true,true,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true];
	}*/

	public function setTilemap(damap:PrxTilemap) {
		map = damap;
		shaderFog.data.gridSize.value = [map.getTileWidth()];
		shaderFog.data.rowSize.value = [map.widthInTiles];
		shaderFog.data.numRows.value = [map.heightInTiles];
		var bundt:FlxRect = map.getBounds();
		shaderFog.data.boundRight.value = [bundt.right];
		shaderFog.data.boundBottom.value = [bundt.bottom];
		opaqueMapSprite = new TilemapOpacitySprite(map);
		shaderFog.data.opaqueMapSprite.input = opaqueMapSprite.graphic.bitmap;
	}

	override public function draw() {
		var eyemid:FlxPoint = eye.getMidpoint();
		shaderFog.data.eye.value = [eyemid.x, eyemid.y];
		shaderFog.data.cam.value = [camera.scroll.x, camera.scroll.y];
		shaderFog.data.camZoom.value = [camera.zoom];
		super.draw();
	}

	public function resetAfterWarp() {

	}
}

class FogLayerShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	uniform float width;
	uniform float height;
	uniform vec2 cam;
	uniform float camZoom;
	uniform float gridSize;
	uniform int rowSize;
	uniform int numRows;
	uniform vec2 eye;
	uniform sampler2D opaqueMapSprite;
	uniform float boundRight;
	uniform float boundBottom;
	uniform float maxRange;

	bool isInRange(vec2 where) {
		return distance(where, eye) <= maxRange;
	}
	bool isInBounds(vec2 where) {
		return where.x >= 0.0 && where.y >= 0.0 && where.x < boundRight && where.y < boundBottom;
	}
	bool isOpaque(vec2 where) {
		return texture2D(opaqueMapSprite, vec2(where.x/boundRight, where.y/boundBottom)).r != 0.0;
	}
	bool lineTraceToEye(vec2 where) {
		vec2 diff = where - eye;
		const float div = 200.0;
		//float div = length(diff);
		for (float i = 0.0; i < div; i++) {
			if (isOpaque(eye + diff * i / div))
				return false;
		}
		return true;
	}
	bool isVisibleStraight(vec2 where) {
		if (!isInBounds(where))
			return false;
		if (isOpaque(where))
			return false;
		return lineTraceToEye(where);
	}
	bool isVisible(vec2 where) {
		if (!isInBounds(where))
			return false;
		if (isOpaque(where)) {
			vec2 inCell = vec2(mod(where.x, gridSize), mod(where.y, gridSize));
			return inCell.x < 4.0 && isVisibleStraight(vec2(floor(where.x/gridSize)*gridSize-1.0, where.y))
				|| inCell.x > (gridSize-4.0) && isVisibleStraight(vec2(ceil(where.x/gridSize)*gridSize+1.0, where.y))
				|| inCell.y < 4.0 && isVisibleStraight(vec2(where.x, floor(where.y/gridSize)*gridSize-1.0))
				|| inCell.y > 5.0 && isVisibleStraight(vec2(where.x, ceil(where.y/gridSize)*gridSize+1.0));
		} else {
			return lineTraceToEye(where);
		}
	}
	void main() {
		vec2 worldcoords = vec2(gl_FragCoord.x + cam.x, height - gl_FragCoord.y + cam.y)/camZoom;
		if (isVisible(worldcoords)) {
			gl_FragColor = vec4(0, 0, 0, 0);
		} else {
			gl_FragColor = vec4(0.25, 0.0, 0.25, 1.0);
		}
	}
	')
	
	public function new() {
		super();
	}
}
/* in loving memory of a day of my life spent on this bullshit
	bool isOpaque(vec2 where) {
		int tileX = floor(where.x/gridSize)-opaqRectX;
		int tileY = floor(where.y/gridSize)-opaqRectY;
		int tileIndex = tileX + tileY*opaqRectWidth;
		//return opaqArray[0];
		if (tileX < 0 || tileY < 0 || tileX >= opaqRectWidth || tileY >= opaqRectHeight)
			return true;
		return opaqArray[tileIndex];
	}
*/

class TilemapOpacitySprite extends FlxSprite {
	var map:PrxTilemap;

	public function new(themap:PrxTilemap) {
		super(69, 69);
		map = themap;
		makeGraphic(map.widthInTiles, map.heightInTiles, FlxColor.TRANSPARENT);
		for (i in 0...map.widthInTiles) {
			for (j in 0...map.heightInTiles) {
				pixels.setPixel32(i, j, map.isTileOpaque(i, j) ? 0xFF808080 : 0x00000000);
				//trace(map.isTileOpaque(i, j) ? 0xFF808080 : 0x00000000);
			}
		}
	}
}
package geom.vision;

import entities.DreamEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import geom.vision.FogLayerBase.TilemapOpacitySprite;
import openfl.display.Shader;
import openfl.display.ShaderParameter;

class GridLineFogLayer extends FogLayerBase {

	public function new() {
		super();
		shaderFog = new GridLineFogLayerShader();
		shader = shaderFog;
	}

	public function setEye(ent:DreamEntity) {
		eye = ent;
		
	}

	override public function draw() {
		super.draw();
	}
}

class GridLineFogLayerShader extends FlxShader {
	@:glFragmentSource('
	#pragma header
	uniform float width;
	uniform float height;
	uniform vec2 cam;
	uniform float camDiv;
	uniform vec2 camAdd;
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
		const float div = 420.0;
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
			return inCell.x < 3.0 && isVisibleStraight(vec2(floor(where.x/gridSize)*gridSize-1.0, where.y))
				|| inCell.x > (gridSize-3.0) && isVisibleStraight(vec2(ceil(where.x/gridSize)*gridSize+1.0, where.y))
				|| inCell.y < 3.0 && isVisibleStraight(vec2(where.x, floor(where.y/gridSize)*gridSize-1.0))
				|| inCell.y > 5.0 && isVisibleStraight(vec2(where.x, ceil(where.y/gridSize)*gridSize+1.0));
		} else {
			return lineTraceToEye(where);
		}
	}
	void main() {
		vec2 pixelCoord = openfl_TextureCoordv * openfl_TextureSize;
		//vec2 worldcoords = pixelCoord / camDiv + vec2(cam.x, cam.y) + camAdd;
		vec2 worldcoords = pixelCoord + cam;
		
		if (isVisible(worldcoords)) {
			gl_FragColor = vec4(0, 0, 0, 0);
		} else {
			gl_FragColor = vec4(0.125, 0.0, 0.125, 1.0);
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
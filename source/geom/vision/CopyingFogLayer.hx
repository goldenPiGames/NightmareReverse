package geom.vision;

import flixel.system.FlxAssets.FlxShader;

class CopyingFogLayer extends FogLayerBase {
	public function new() {
		super();
		setVisionShader(new CopyingFogLayerShader());
	}

	override function draw() {
		shaderFog.data.visibleSprite.input = vision.shadowCanvas.graphic.bitmap;
		super.draw();
	}
}


class CopyingFogLayerShader extends FlxShader {
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
	uniform sampler2D visibleSprite;
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
	float isVisibleStraight(vec2 where) {
		if (!isInBounds(where))
			return 0.0;
		if (isOpaque(where))
			return 0.0;
		return texture2D(visibleSprite, vec2(where.x/boundRight, where.y/boundBottom)).r;
	}
	float isVisible(vec2 where) {
		if (!isInBounds(where))
			return 0.0;
		if (isOpaque(where)) {
			vec2 inCell = vec2(mod(where.x, gridSize), mod(where.y, gridSize));
			float viz = 0.0;
			if (inCell.x < 3.0) {
				viz = max(viz, isVisibleStraight(vec2(floor(where.x/gridSize)*gridSize-1.0, where.y)));
			}
			if (inCell.x > (gridSize-3.0)) {
				viz = max(viz, isVisibleStraight(vec2(ceil(where.x/gridSize)*gridSize+1.0, where.y)));
			}
			if (inCell.y < 3.0) {
				viz = max(viz, isVisibleStraight(vec2(where.x, floor(where.y/gridSize)*gridSize-1.0)));
			}
			if (inCell.y > 5.0) {
				viz = max(viz, isVisibleStraight(vec2(where.x, ceil(where.y/gridSize)*gridSize+1.0)));
			}
			return viz;
		} else {
			return isVisibleStraight(where);
		}
	}
	void main() {
		vec2 pixelCoord = openfl_TextureCoordv * openfl_TextureSize;
		//vec2 worldcoords = pixelCoord / camDiv + vec2(cam.x, cam.y) + camAdd;
		vec2 worldcoords = pixelCoord + cam;
		
		float viz = isVisible(worldcoords);
		if (viz >= 1.0) {
			gl_FragColor = vec4(0, 0, 0, 0);
		} else {
			gl_FragColor = vec4(0, 0, 0, 1.0-viz);
			//gl_FragColor = texture2D(visibleSprite, worldcoords);
		}
	}
	')
	
	public function new() {
		super();
	}
}
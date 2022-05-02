package geom.vision;

import entities.DreamEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.Shader;
import openfl.display.ShaderParameter;
import states.PlayState;

/** 
Component that displays the fog of war effect
*/
class FogLayerBase extends FlxSprite {
	var vision:Vision;
	var shaderFog:FlxShader;
	var eye:DreamEntity;
	var map:PrxTilemap;
	var opaqueMapSprite:TilemapOpacitySprite;

	public static inline var OPAQ_ARRAY_MAX:Int = 576;

	public function new() {
		super();
		makeGraphic(FlxG.width, FlxG.height);
		scrollFactor.set(0, 0);
		
	}

	function setVisionShader(shad:FlxShader) {
		shaderFog = shad;
		shader = shaderFog;
		shaderFog.data.width.value = [FlxG.width];
		shaderFog.data.height.value = [FlxG.height];
		shaderFog.data.maxRange.value = [120.0];
		
	}

	public function setVision(thevision:Vision) {
		vision = thevision;
		setTilemap(vision.state.getWallmap());
	}

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
		shaderFog.data.eye.value = [vision.eyePos.x, vision.eyePos.y];
		shaderFog.data.cam.value = [camera.scroll.x, camera.scroll.y];
		shaderFog.data.camDiv.value = [camera.zoom];
		shaderFog.data.camAdd.value = [(camera.zoom-1)*FlxG.width/camera.zoom/2, (camera.zoom-1)*FlxG.height/camera.zoom/2];
		super.draw();
	}

	public function resetAfterWarp() {

	}

	public static inline var FOG_SHADER_SHARED= '';
}

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
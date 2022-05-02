package states;

import flixel.FlxG;
import flixel.math.FlxPoint;
import geom.PrxTilemap;
import geom.vision.PolygonVision;
import geom.vision.Vision.SegmentInfo;
import geom.vision.Vision.VisionState;
import geom.vision.Vision;
import ui.PrxUIButton;

class MainMenu extends PrxState implements VisionState {
	var vision:Vision;
	var followingCursor:Bool;
	var eyePos:FlxPoint;
	
	public override function create() {
		super.create();
		vision = new PolygonVision(this);
		add(vision);
		GameG.movingCam.bgColor = 0xFFFFFFFF;
		addUI();
		ui.add(new LevelStartButton(40, 40, "LucidTutorial"));
		ui.add(new LevelStartButton(40, 160, "DeepWoods"));
		ui.add(new LevelStartButton(400, 40, "test"));
		ui.add(new LevelStartButton(400, 160, "testsmall"));
		ui.add(new LevelStartButton(400, 280, "testopen"));
		ui.startCursorAtFirst();
		ui.connectAuto();
	}

	public function getVisionSegments():Array<SegmentInfo> {
		var damap:Array<SegmentInfo> = [
			{a:{x:-1,y:-1},b:{x:FlxG.width,y:-1}},
			{a:{x:-1,y:FlxG.height},b:{x:FlxG.width,y:FlxG.height}},
			{a:{x:-1,y:-1},b:{x:-1,y:FlxG.height}},
			{a:{x:FlxG.width,y:-1},b:{x:FlxG.width,y:FlxG.height}},
		];
		var seggs:Array<SegmentInfo>;
		for (thing in ui.members) {
			if (followingCursor ? !thing.isHovered() : !thing.mouseHovered) {
				seggs = thing.getVisionSegments();
				if (seggs != null) {
					damap = damap.concat(seggs);
				}
			}
		}
		return damap;
	}

	public function getVisionEye():FlxPoint {
		return eyePos;
	}

	public function getWallmap():PrxTilemap {
		return null;
	}

	override function update(elapsed) {
		super.update(elapsed);
		if (FlxG.mouse.justMoved) {
			eyePos = FlxG.mouse.getPosition(eyePos);
			followingCursor = false;
		} else if (ui.cursor.justMoved) {
			followingCursor = true;
		}
		if (followingCursor) {
			eyePos = ui.cursor.getMidpoint();
		}
		FlxG.watch.addQuick("maus", eyePos);
	}
}

class LevelStartButton extends PrxUIButton {
	var levelID:String;
	public function new(x, y, id) {
		super(x, y, 300, 40);
		levelID = id;
		addBackSlice(PrxUIButton.BEVELGREY_PATH, PrxUIButton.BEVELGREY_SLICE);
		addTextLang("level_"+id);
	}
	override function activate() {
		GameG.levelID = levelID;
		FlxG.switchState(new PlayState());
	}
}
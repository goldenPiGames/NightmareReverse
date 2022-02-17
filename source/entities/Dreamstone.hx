package entities;

import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import geom.SpriteDir;

class Dreamstone extends DreamEntity {
	
	var dreamstoneIndex:Int = 0;

	public function new(args:EntityData) {
		super(args);
		infoName = "Dreamstone";
		touchPriority = 64;
		loadGraphic("assets/sprites/Dreamstone.png", true, 16, 16);
		spriteDir = new SpriteDirStatic();
		animation.add("float1", [0]);
		animation.add("float2", [1]);
		animation.add("float3", [2]);
		animation.add("float4", [3]);
		setSizeS(12, 12);
		offset.set(2, 2);
		pathPass = GROUND;
		//playAnimation("float1");
	}

	public override function setState(instate:PlayState) {
		super.setState(instate);
		dreamstoneIndex = instate.incrementDreamstones(this);
		playSetStartAnimation("float"+dreamstoneIndex);
		infoName = "Dreamstone #"+dreamstoneIndex;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		//FlxG.overlap(this, state.player, (ting, play) -> ting.getCollected(play));
	}

	function getCollected(by:DreamPlayer) {
		state.dreamstoneCollected(this);
		kill();
	}

	public override function touch(other:DreamEntity) {
		if (Std.isOfType(other, DreamPlayer)) {
			getCollected(cast other);
		}
	}
}
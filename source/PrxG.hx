package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxSoundAsset;
import haxe.Json;
import openfl.utils.Assets;

class PrxG {


	public static var sound:PrxSoundFrontend = new PrxSoundFrontend();

	
}

class PrxSoundFrontend {
	public var song:PrxMultiSong;

	public function new() {

	}

	public function playMusic(dataURL:String) {
		if (song == null || !song.alreadyIs(dataURL)) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.time = 0;
			song = new PrxMultiSong(dataURL);
		}
	}

	public function playMusicSide(dataURL:String, side:Int) {
		playMusic(dataURL);
		playSide(side);
	}

	public function playSide(side:Int) {
		song.playSide(side);
	}

	public function setMusicSidePursuit() {
		playSide(1);
	}
	
	public function setMusicSideCalm() {
		playSide(0);
	}
}

class PrxMultiSong {
	private var dataURL:String;
	private var data:Dynamic;

	public function new(dataURL:String) {
		this.dataURL = dataURL;
		var raw:String = Assets.getText(dataURL);
		//FlxG.log.add(raw);
		data = Json.parse(raw);
		
	}

	public function alreadyIs(otherURL:String):Bool {
		return dataURL == otherURL;
	}

	public function playSide(side:Int) {
		var pos:Float = 0;
		if (FlxG.sound.music != null)
			pos = FlxG.sound.music.time;
		FlxG.sound.playMusic("assets/music/"+data.sides[side].file, 1, true);
		FlxG.sound.music.time = pos;
	}
}
package hud;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Dialog extends FlxText {
	var lines:Array<DialogLine>;
	var lineIndex:Int = 0;
	var lineTime:Float = 0;
	var charIndex:Int = 0;
	var charTime:Float = 0;
	var lineCurrent:DialogLine = null;
	public static inline var CHAR_TIME = .080;

	public function new(x:Float, y:Float, width:Float, height:Int) {
		super(x, y, width, "", height);
	}

	public function play(newlines:Array<DialogLine>) {
		setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, .25, 2);
		lines = newlines;
		lineIndex = 0;
		setCurrentLine();
		//trace(lines);
	}

	public override function update(elapsed:Float) {
		if (lineCurrent != null) {
			lineTime += elapsed;
			if (lineTime >= lineCurrent.duration) {
				nextLine();
			} else {
				charTime += elapsed;
				if (charTime >= CHAR_TIME) {
					charTime -= CHAR_TIME;
					nextCharacter();
				}
			}
		}
		super.update(elapsed);
	}

	function nextCharacter() {
		charIndex++;
		if (charIndex < lineCurrent.text.length) {
			playCurrentCharacter();
		}
	}

	function playCurrentCharacter() {
		var currentChar:String = lineCurrent.text.charAt(charIndex);
		var filechar:String = getLetterCode(currentChar);
		if (filechar.length > 0)
			FlxG.sound.play("assets/sounds/animalese/"+lineCurrent.voicebank+"/"+filechar+".ogg", lineCurrent.voicevolume);
	}

	static inline function getLetterCode(car:String):String {
		switch (car.toLowerCase()) {
			case "a": return "a";
			case "b": return "b";
			case "c": return "c";
			case "d": return "d";
			case "e": return "e";
			case "f": return "f";
			case "g": return "g";
			case "h": return "h";
			case "i": return "i";
			case "j": return "j";
			case "k": return "k";
			case "l": return "l";
			case "m": return "m";
			case "n": return "n";
			case "o": return "o";
			case "p": return "p";
			case "q": return "q";
			case "r": return "r";
			case "s": return "s";
			case "t": return "t";
			case "u": return "u";
			case "v": return "v";
			case "w": return "w";
			case "x": return "x";
			case "y": return "y";
			case "z": return "z";
			//i'm doing it like this for the possibility of other languages
			default: return "";
		}
	}

	function nextLine():Bool {
		lineIndex++;
		if (lineIndex < lines.length) {
			setCurrentLine();
			return true;
		} else {
			lineCurrent = null;
			endDialog();
			return false;
		}
	}

	function endDialog() {
		visible = false;
		text = "";
	}

	function setCurrentLine():Void {
		visible = true;
		lineCurrent = lines[lineIndex];
		text = lineCurrent.speaker+": "+lineCurrent.text;
		color = lineCurrent.color;
		lineTime = 0;
		charIndex = 0;
		charTime = 0;
		font = lineCurrent.font;
		bold = lineCurrent.bold;
		playCurrentCharacter();
	}
}

class DialogLine {
	var textID:String;
	public var text:String;
	var speakerID:String;
	public var speaker:String;
	public var duration:Float;
	public var voicebank:String;
	public var color:FlxColor;
	public var font:String;
	public var bold:Bool;
	public var voicevolume:Float;

	public function new(args:Dynamic) {
		textID = cast args.id;
		text = Lang.get(textID);
		speakerID = cast args.speaker;
		speaker = Lang.get("speaker_"+speakerID);
		var defaults:DialogStyling = DialogCharacterStyling.get(speakerID);
		duration = text.length * Dialog.CHAR_TIME + .2;
		voicebank = defaults.voicebank;
		color = defaults.color;
		font = defaults.font;
		bold = defaults.bold;
		voicevolume = defaults.voicevolume;
	}
}

typedef DialogStyling = {
	font:String,
	bold:Bool,
	color:FlxColor,
	voicebank:String,
	voicevolume:Float
}

class DialogCharacterStyling {
	public static var DEFAULT:DialogStyling = {
		font:"Helvetica",
		bold:true,
		color:0x888888,
		voicebank:"prexot",
		voicevolume:0.7
	};
	public static var AMM:DialogStyling = {
		font:"Kandal Black",
		bold:false,
		color:0xCC2244,
		voicebank:"bleak",
		voicevolume:1.0,
	};
	public static var APS:DialogStyling = {
		font:"Helvetica",
		bold:true,
		color:0x776688,
		voicebank:"prexot",
		voicevolume:0.7
	};
	public static var LEIR:DialogStyling = {
		font:"Inconsolata",
		bold:true,
		color:0xBBAABB,
		voicebank:"prexot",
		voicevolume:0.7
	};
	public static var ME:DialogStyling = {
		font:"Inconsolata",
		bold:true,
		color:0xFF00FF,
		voicebank:"prexot",
		voicevolume:0.7
	};

	public static function get(id:String):DialogStyling {
		switch (id) {
			case "amm": return AMM;
			case "aps": return APS;
			case "leir": return LEIR;
			case "me": return ME;
			default: return DEFAULT;
		}
	}
}
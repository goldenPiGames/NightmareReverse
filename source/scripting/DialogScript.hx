package scripting;

import hud.Dialog.DialogLine;
import states.PlayState;

class DialogScript extends DreamScript {
	public var lines:Array<DialogLine>;
	public var interrupt:Bool = false;
	
	public function new(args:Dynamic) {
		super();
		var lineData:Array<Dynamic> = cast args.lines;
		lines = lineData.map(d->new DialogLine(d));
		interrupt = cast args.interrupt;
	}

	public override function activate(state:PlayState):Void {
		state.hud.dialog.play(lines);
	}
}
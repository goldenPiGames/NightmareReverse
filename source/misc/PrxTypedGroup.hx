package misc;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

/** FlxTypedGroup but with some more stuff tacked on */
class PrxTypedGroup<T:FlxBasic> extends FlxTypedGroup<T> {
	public function deletNonexistent():Void {
		var i = 0;
		while (i < this.members.length) {
			if (this.members[i].exists) {
				i++;
			} else {
				this.members.splice(i, 1)[0].destroy();
			}
		}
		//this.members = this.members.filter(deletNonexistentButt);
	}

	override function toString():String {
		var str = "0: "+this.members[0];
		for (i in 1...this.members.length) {
			str += "\n"+i+": "+this.members[i];
		}
		return str;
	}
}
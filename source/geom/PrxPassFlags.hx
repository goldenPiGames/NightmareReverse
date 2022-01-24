package geom;

@:enum abstract PrxPassFlags(Int) from Int to Int {
	var GROUND = 0x010;
	var FLYING = 0x011;
	
	public inline function hasType(type:Int):Bool {
		return this & (1 << (type * 4)) > 0;
	}

	
	public inline function hasFlags(flags:PrxPassFlags):Bool {
		return this & flags == flags;
	}
}
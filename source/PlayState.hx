package;

import enemies.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.util.FlxSort;
import geom.*;
import geom.FogLayer;
import hud.DreamHUD;
import menus.VictoryMenu;
import projectiles.Projectile;

class PlayState extends FlxState {
	var olevel:PrxOgmo3Loader;
	public var wallmap:PrxTilemap;
	public var player:DreamPlayer;
	public var entities:FlxTypedGroup<DreamEntity>;
	public var enemies:FlxTypedGroup<Enemy>;
	public var pursuit:Bool = false;
	public var powered:Bool = false;
	public var time:Float = 0;
	public var fog:FogLayer;
	public var hud:DreamHUD;
	public var dreamstonesCollected:Int = 0;
	public var dreamstonesTotal:Int = 0;
	public var numEnemiesAlive:Int = 0;
	var playerJustDied:Bool = false;
	var enemyJustDied:Bool = false;

	override public function create() {
		super.create();

		loadLevel();
		//map.loadMapFromCSV(FlxStringUtil.imageToCSV("assets/maps/test.png"), "assets/images/tilesetRevenge.png", 10, 10, AUTO);

		FlxG.worldBounds.set(0, 0, 800, 600);
		FlxG.worldDivisions = 8;
		FlxG.camera.follow(player, NO_DEAD_ZONE);
		FlxG.camera.followLerp = .001;
		//PrxG.sound.playMusicSide("assets/music/PeriTune_Ominous3.json", 0);
		//PrxG.sound.playMusicSide(AssetPaths.PeriTune_Ominous3__json, 0);
		PrxG.sound.playMusicSide(AssetPaths.Vermeen_TheHunt__json, 0);
	}

	private function loadLevel() {
		olevel = new PrxOgmo3Loader(AssetPaths.levels__ogmo,
			"assets/levels/"+GameG.levelID+".json"
			//AssetPaths.test__json
			//"assets/levels/testsmall.json"
			//AssetPaths.testsmall__json
		);
		wallmap = olevel.loadPrxTilemap(AssetPaths.TileHouse__png, "tiles");
		//wallmap.follow();
		wallmap.setFTileProperties(0, NONE);
		wallmap.setFTileProperties(1, NONE);
		wallmap.setFTileProperties(2, ANY);
		add(wallmap);
		fog = new FogLayer();
		add(fog);
		fog.camera = FlxG.camera;
		fog.setTilemap(wallmap);
		entities = new FlxTypedGroup<DreamEntity>();
		add(entities);
		enemies = new FlxTypedGroup<Enemy>();
		olevel.loadEntities(placeEntity, "entities");
		hud = new DreamHUD(this);
		add(hud);
		recountEnemies();
	}
	
	private function placeEntity(entity:EntityData) {
		var nent:DreamEntity;
		switch (entity.name) {
			case "player":
				nent = new DreamPlayer(entity);
			case "Dreamstone":
				nent = new Dreamstone(entity);
			case "FloatingEyeLarge":
				nent = new FloatingEyeLarge(entity);
			case "FloatingEyeSmall":
				nent = new FloatingEyeSmall(entity);
			default:
				FlxG.log.add(entity.name + " is not recognized");
				return;
		}
		entities.add(nent);
		nent.setState(this);
	}

	override public function update(elapsed:Float) {
		time += elapsed;
		super.update(elapsed);
		FlxG.overlap(entities, entities, touchyfunc);
		if (playerJustDied) {
			uponPlayerDeath();
		}
		entities.sort(FlxSort.byY, FlxSort.ASCENDING);
		if (enemyJustDied) {
			recountEnemies();
			if (numEnemiesAlive <= 0) {
				youWin();
			}
		}
	}

	function recountEnemies() {
		trace("blapplebutt");
		numEnemiesAlive = 0;
		entities.forEach(e->e.countIfEnemyAlive());
	}

	function touchyfunc(entA:DreamEntity, entB:DreamEntity) {
		//trace(entA.infoName + " - " + entB.infoName);
		if (entA.touchPriority >= entB.touchPriority)
			entA.touch(entB);
		else
			entB.touch(entA);
	}

	public function indicatePursuit() {
		FlxG.log.add("Time to die");
		FlxG.sound.play("assets/sounds/Spotted3.ogg");
		if (!pursuit) {
			pursuit = true;
			PrxG.sound.setMusicSidePursuit();
		}
	}

	function stopPursuit() {
		PrxG.sound.setMusicSideCalm();
	}

	public function timeSince(uh:Float):Float {
		return time - uh;
	}

	public function maybeStopPursuit() {
		pursuit = false;
		enemies.forEach(maybeRefreshPursuitFor);
		if (!pursuit)
			stopPursuit();
	}

	function maybeRefreshPursuitFor(enemy:Enemy) {
		if (enemy.stillInPursuit()) {
			pursuit = true;
		}
	}

	public function incrementDreamstones(stone:Dreamstone):Int {
		dreamstonesTotal++;
		return dreamstonesTotal;		
	}

	public function dreamstoneCollected(stone:Dreamstone) {
		dreamstonesCollected++;
		if (dreamstonesCollected >= dreamstonesTotal) {
			startHenshin();
		}
	}

	function startHenshin() {
		pursuit = false;
		powered = true;
		PrxG.sound.playMusicSide("assets/music/PeriTune_Prairie5.json", 0);
		entities.forEach(e->e.playerPowered());
		fog.visible = false;
	}

	public function addProjectile(yeet:Projectile) {
		entities.add(yeet);
		yeet.setState(this);
	}

	public function indicatePlayerDied() {
		playerJustDied = true;
	}

	function uponPlayerDeath() {
		stopPursuit();
		
		playerJustDied = false;
		entities.forEach(e->e.playerDied());
	}

	public function indicateEnemyDied() {
		enemyJustDied = true;
	}

	function youWin() {
		FlxG.switchState(new VictoryMenu());
	}
}

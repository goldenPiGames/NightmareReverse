package;

import DreamPlayer.PlayerDeathSource;
import enemies.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.util.FlxSort;
import geom.*;
import geom.FogLayer;
import haxe.ValueException;
import hud.DreamHUD;
import menus.VictoryMenu;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import projectiles.Projectile;

class PlayState extends FlxState {
	var olevel:PrxOgmo3Loader;
	public var wallmap:PrxTilemap;
	public var player:DreamPlayer;
	public var entities:FlxTypedGroup<DreamEntity>;
	public var soundIndicators:FlxTypedGroup<SoundIndicator>;
	public var pursuit:Bool = false;
	public var powered:Bool = false;
	public var time:Float = 0;
	public var fog:FogLayer;
	public var hud:DreamHUD;
	public var dreamstonesCollected:Int = 0;
	public var dreamstonesTotal:Int = 0;
	public var numEnemiesAlive:Int = 0;
	var playerJustDied:Bool = false;
	var playerDeathSource:PlayerDeathSource;
	var enemyJustDied:Bool = false;
	var sceneUpdateGroup:FlxTypedGroup<DreamEntity>;
	var inSceneMode:Bool = false;
	var sceneTime:Float = 0;
	var sceneType:String;
	var filterBlur:BlurFilter;
	var filterColor:ColorMatrixFilter;
	public static inline var SCENE_DEATH = "death";

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
		FlxG.camera.zoom = 2;
		filterBlur = new BlurFilter();
		filterBlur.blurX = 2;
		filterBlur.blurY = 2;
		filterColor = new ColorMatrixFilter([
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0]);
		FlxG.camera.setFilters([filterColor]);
		FlxG.camera.filtersEnabled = false;
	}

	private function loadLevel() {
		olevel = new PrxOgmo3Loader(AssetPaths.levels__ogmo,
			"assets/levels/"+GameG.levelID+".json"
			//AssetPaths.test__json
			//"assets/levels/testsmall.json"
			//AssetPaths.testsmall__json
		);
		wallmap = olevel.loadPrxTilemap("assets/images/"+olevel.getPrxTileset()+".png", "tiles");
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
		olevel.loadEntities(placeEntity, "entities");
		soundIndicators = new FlxTypedGroup<SoundIndicator>();
		add(soundIndicators);
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
		if (inSceneMode) {
			sceneUpdateGroup.update(elapsed);
			sceneTime -= elapsed;
			if (sceneTime <= 0) {
				inSceneMode = false;
				entities.active = true;
				entities.visible = true;
				wallmap.visible = true;
				fog.visible = true;
				switch (sceneType) {
					case SCENE_DEATH:
						resetAfterDeath();
				}
			}
		} else {
			entities.sort(FlxSort.byY, FlxSort.ASCENDING);
			if (enemyJustDied) {
				recountEnemies();
				if (numEnemiesAlive <= 0) {
					youWin();
				}
			}
			FlxG.overlap(entities, entities, touchyfunc);
			if (playerJustDied) {
				startPlayerDeath();
			}
		}
		if (FlxG.keys.justPressed.RBRACKET) {
			FlxG.camera.filtersEnabled = !FlxG.camera.filtersEnabled;
		}
	}

	override public function draw() {
		super.draw();
		if (!entities.visible) {
			sceneUpdateGroup.draw();
		}
	}

	function recountEnemies() {
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
		entities.forEachOfType(Enemy, maybeRefreshPursuitFor);
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

	public function indicatePlayerDied(sauce:PlayerDeathSource) {
		playerJustDied = true;
		playerDeathSource = sauce;
	}

	function startPlayerDeath() {
		stopPursuit();
		
		playerJustDied = false;
		entities.active = false;
		inSceneMode = true;
		sceneUpdateGroup = new FlxTypedGroup<DreamEntity>();
		sceneUpdateGroup.add(player);
		if (Std.isOfType(playerDeathSource, Enemy)) {
			var nem:Enemy = cast playerDeathSource;
			sceneUpdateGroup.add(nem);
			sceneTime = nem.playCatchAnimation(player);
			sceneType = SCENE_DEATH;
			wallmap.visible = false;
			fog.visible = false;
		} else {
			sceneTime = player.playSelfDeathAnimation(cast playerDeathSource);
			sceneType = SCENE_DEATH;
		}
	}

	function resetAfterDeath() {
		entities.forEach(e->e.playerDeathReset());
	}

	public function indicateEnemyDied() {
		enemyJustDied = true;
	}

	function youWin() {
		FlxG.switchState(new VictoryMenu());
	}

	public function playDiegeticSound(source:FlxSoundAsset, location:FlxPoint, volume:Int) {
		soundIndicators.add(new SoundIndicator(FlxG.sound.play(source), location, volume));
	}

	public function playDiegeticPlayerSound(source:FlxSoundAsset, location:FlxPoint, volume:Int) {
		playDiegeticSound(source, location, volume);
	}
}

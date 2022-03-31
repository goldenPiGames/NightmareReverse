package states;

import DreamPopup;
import enemies.*;
import entities.*;
import entities.DreamPlayer.PlayerDeathSource;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogClickAndDragMouseMotion;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.util.FlxSort;
import geom.*;
import geom.FogLayer;
import haxe.ValueException;
import hud.DreamHUD;
import misc.PrxTypedGroup;
import openfl.Assets;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import projectiles.Projectile;
import scripting.DreamScriptManager;
import scripting.Trigger;
import states.PauseMenu;
import states.VictoryMenu;

class PlayState extends PrxState {
	var olevel:PrxOgmo3Loader;
	public var wallmap:PrxTilemap;
	public var player:DreamPlayer;
	public var entities:PrxTypedGroup<DreamEntity>;
	public var soundIndicators:PrxTypedGroup<SoundIndicator>;
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
	var sceneUpdateGroup:PrxTypedGroup<FlxBasic>;
	var filterBlur:BlurFilter;
	var filterColor:ColorMatrixFilter;
	var scriptManager:DreamScriptManager;
	var cameraFocus:CameraFocus;
	public static inline var SCENE_DEATH = "death";

	override public function create() {
		super.create();

		loadLevel();
		//map.loadMapFromCSV(FlxStringUtil.imageToCSV("assets/maps/test.png"), "assets/sprites/tilesetRevenge.png", 10, 10, AUTO);

	//	FlxG.worldBounds.set(0, 0, 800, 600);
		FlxG.worldDivisions = 8;
		cameraFocus = new CameraFocus(this);
		add(cameraFocus);
		FlxG.camera.follow(cameraFocus, NO_DEAD_ZONE);
		FlxG.camera.followLerp = .001;
		FlxG.camera.zoom = 2;
		filterBlur = new BlurFilter();
		setBlur(.5);
		filterColor = new ColorMatrixFilter([
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0]);
		FlxG.camera.setFilters([filterBlur]);
		//FlxG.camera.filtersEnabled = false;
	}

	private function loadLevel() {
		olevel = new PrxOgmo3Loader("assets/levels/levels.ogmo",
			"assets/levels/"+GameG.levelID+".json"
		);
		PrxG.sound.playMusicSide("assets/music/"+olevel.getMusic()+".json", 0);
		olevel.setBounds();
		wallmap = olevel.loadPrxTilemap("tiles");
		//wallmap.follow();
		add(wallmap);
		scriptManager = new DreamScriptManager(Assets.getText("assets/levelscripts/"+GameG.levelID+".json"));
		scriptManager.setState(this);
		FlxG.camera.bgColor = wallmap.metadata.bgColor;
		fog = new FogLayer();
		add(fog);
		fog.camera = FlxG.camera;
		fog.setTilemap(wallmap);
		entities = new PrxTypedGroup<DreamEntity>();
		add(entities);
		olevel.loadEntities(placeEntity, "entities");
		soundIndicators = new PrxTypedGroup<SoundIndicator>();
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
			case "GrinningRobot":
				nent = new GrinningRobot(entity);
			case "Trigger":
				nent = new Trigger(entity);
			case "Checkpoint":
				nent = new Checkpoint(entity);
			case "AlarmedTile":
				nent = new AlarmedTile(entity);
			default:
				PrxG.traceAndLog(entity.name + " is not recognized");
				return;
		}
		entities.add(nent);
		nent.setState(this);
	}

	override public function update(elapsed:Float) {
		time += elapsed;
		super.update(elapsed);
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
		if (FlxG.keys.justPressed.RBRACKET) {
			FlxG.camera.filtersEnabled = !FlxG.camera.filtersEnabled;
		}
		if (Cont.pause.triggered) {
			pause();
		}
	}

	override public function draw() {
		super.draw();
		if (!entities.visible) {
			sceneUpdateGroup.draw();
		}
	}

	public function updateBehindPopup(elapsed:Float) {
		sceneUpdateGroup.update(elapsed);
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
		//FlxG.log.add("Time to die");
		FlxG.sound.play("assets/sounds/Spotted3.ogg");
		if (!pursuit) {
			pursuit = true;
			PrxG.sound.setMusicSidePursuit();
		}
	}

	function stopPursuit() {
		pursuit = false;
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
		
		playerJustDied = false;
		sceneUpdateGroup = new PrxTypedGroup<FlxBasic>();
		sceneUpdateGroup.add(player);
		sceneUpdateGroup.add(cameraFocus);
		var popup:DreamPopup = null;
		if (Std.isOfType(playerDeathSource, Enemy)) {
			var nem:Enemy = cast playerDeathSource;
			sceneUpdateGroup.add(nem);
			popup = nem.getKillPopup();
		} else {
			popup = new VoidDeathPopup();
		}
		if (popup == null) {
			resetAfterDeath();
		} else {
			openDreamPopup(popup);
		}
	}

	function openDreamPopup(poptepipic:DreamPopup) {
		openSubState(poptepipic);
		poptepipic.setState(this);
	}

	public function resetAfterDeath():Void {
		stopPursuit();
		entities.forEach(e->e.playerDeathReset());
		cameraFocus.playerDeathReset();
	}

	public function indicateEnemyDied():Void {
		enemyJustDied = true;
	}

	function youWin():Void {
		FlxG.switchState(new VictoryMenu());
	}

	public function playDiegeticSound(source:FlxSoundAsset, location:FlxPoint, volume:Int):SoundIndicator {
		var sonidito = new SoundIndicator(FlxG.sound.play(source), location, volume);
		sonidito.setState(this);
		soundIndicators.add(sonidito);
		return sonidito;
	}

	public function playDiegeticPlayerSound(source:FlxSoundAsset, location:FlxPoint, volume:Int):SoundIndicator {
		return playDiegeticSound(source, location, volume);
	}

	function setBlur(amount:Float):Void {
		filterBlur.blurX = amount;
		filterBlur.blurY = amount;
	}

	function pause():Void {
		var tempState:PauseMenu = new PauseMenu();
		openSubState(tempState);
		tempState.setState(this);
	}
	
	public function activateScript(id:String, ?source:DreamEntity) {
		scriptManager.activate(id, source);
	}
}

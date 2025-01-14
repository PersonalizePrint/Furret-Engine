package;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import Shaders.PulseEffect;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
#if windows
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

import Type.ValueType;

#if windows
import Discord.DiscordClient;
#end
#if sys
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
#if desktop
import Sys;
import sys.io.File;
import sys.FileSystem;
#end
#if neko
import Sys;
import sys.io.File;
import sys.FileSystem;
#end
#if cpp
import Sys;
import sys.FileSystem;
#end
#if android
import Sys;
import sys.io.File;
import sys.FileSystem;
#end

import hscript.Interp;
import hscript.Parser;

using StringTools;

class PlayState extends MusicBeatState
{
	static inline final BOPEEBO = 'bopeebo';

	public var hasCreated:Bool = false;
	public var hasCreatedgf:Bool = false;
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	public static var cpuControlled:Bool = false;

	var interp = new hscript.Interp();

	//3d stage stuff
	public var curbg:FlxSprite;
	public static var screenshader:Shaders.PulseEffect = new PulseEffect();
	public var da_3dbg:FlxSprite;

	public static var lolmode:Bool = false;

	var vcrEffect:Shaders.VCRDistorsionShader;

	var check:Int = 0;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var configurated:Bool = false;

	public var elapsedtime:Float = 0;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	var defaultPlayer2:String;
	var defaultPlayer1:String;

	var doNotExecute:Bool = false;

	var scoreBG:FlxSprite;
	
	var loadHScript:Bool = false;

	var player1BeforeChanges:String;
	var player2BeforeChanges:String;
	var scrollSpeedBeforeChanges:Float;
	
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;
	public var dadCameraOffsetX:Int = 0;
	public var dadCameraOffsetY:Int = 0;
	public var bfCameraOffsetX:Int = 0;
	public var bfCameraOffsetY:Int = 0;
	
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	var camFollowXDad:Float = 0;
	var camFollowYDad:Float = 0;
	var camFollowXBoyfriend:Float = 0;
	var camFollowYBoyfriend:Float = 0;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	public var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;

	public static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	public static var misses:Int = 0;
	public var accuracy:Float = 0.00;
	public var accuracyDefault:Float = 0.00;
	public var totalNotesHit:Float = 0;
	public var totalNotesHitDefault:Float = 0;
	public var totalPlayed:Int = 0;
	public var ss:Bool = false;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var songPositionBar:Float = 0;
	
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	public static var postPlayed:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var updateVarsNeedsToBeSetUp:Bool = false;

	public var stageAssets:Array<StageAsset> = [];

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var runningOnFE:FlxText;
	var nameOfTheSong:FlxText;
	var difficultySong:FlxText;
	var judgementTextTxt:FlxText;
	var missesTxt:FlxText;
	var sicksTxt:FlxText;
	var goodsTxt:FlxText;
	var badsTxt:FlxText;
	var shitsTxt:FlxText;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;
	var botplayTxt:FlxText;
	var botplaySine:Float = 0;

	var eventInterp = new hscript.Interp();

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var isNew:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	public var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	public var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;

	private var executeModchart = false;


	var hscriptStates:Map<String, Interp> = [];

	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}

	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			//trace("Function doesn't exist, silently skipping..."); //i don't want the console getting flooded with traces
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}

	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}

	public static var videoJson:VideoJsonPath;

	// hi

	// LUA SHIT
	
	#if windows
	public static var lua:State = null;
	#end

	#if windows
	function callLua(func_name : String, args : Array<Dynamic>, ?type : String) : Dynamic
	{
		var result : Any = null;

		Lua.getglobal(lua, func_name);

		for( arg in args ) {
		Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);

		if (getLuaErrorMessage(lua) != null)
			trace(func_name + ' LUA CALL ERROR ' + Lua.tostring(lua,result));

		if( result == null) {
			return null;
		} else {
			return convert(result, type);
		}

	}

	function getType(l, type):Any
	{
		return switch Lua.type(l,type) {
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type):String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l) {
		var lua_v:Int;
		var v:Any = null;
		while((lua_v = Lua.gettop(l)) != 0) {
			var type:String = getType(l,lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}


	private function convert(v : Any, type : String) : Dynamic { // I didn't write this lol
		if( Std.is(v, String) && type != null ) {
		var v : String = v;
		if( type.substr(0, 4) == 'array' ) {
			if( type.substr(4) == 'float' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Float> = new Array();

			for( vars in array ) {
				array2.push(Std.parseFloat(vars));
			}

			return array2;
			} else if( type.substr(4) == 'int' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Int> = new Array();

			for( vars in array ) {
				array2.push(Std.parseInt(vars));
			}

			return array2;
			} else {
			var array : Array<String> = v.split(',');
			return array;
			}
		} else if( type == 'float' ) {
			return Std.parseFloat(v);
		} else if( type == 'int' ) {
			return Std.parseInt(v);
		} else if( type == 'bool' ) {
			if( v == 'true' ) {
			return true;
			} else {
			return false;
			}
		} else {
			return v;
		}
		} else {
		return v;
		}
	}

	function getLuaErrorMessage(l) {
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name : String, object : Dynamic){
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua,object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name : String, type : String) : Dynamic {
		var result : Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua,-1);
		Lua.pop(lua,1);

		if( result == null ) {
		return null;
		} else {
		var result = convert(result, type);
		//trace(var_name + ' result: ' + result);
		return result;
		}
	}

	function createEventInterp():Void
	{
		var bf:Dynamic;
		bf = boyfriend;
		hscriptStates.set('eventInterp',eventInterp);
		eventInterp.variables.set("endSong", function() {
			endSong();
		});
		eventInterp.variables.set("Conductor", Conductor);
		eventInterp.variables.set("curBPM", Conductor.bpm);
		eventInterp.variables.set("bpm", SONG.bpm);
		eventInterp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		eventInterp.variables.set("scrollSpeed", SONG.speed);
		eventInterp.variables.set("crochet", Conductor.crochet);
		eventInterp.variables.set("stepCrochet", Conductor.stepCrochet);
		eventInterp.variables.set("songLength", FlxG.sound.music.length);
		eventInterp.variables.set("isStoryMode", PlayState.isStoryMode);
		eventInterp.variables.set("storyDifficulty", PlayState.storyDifficulty);
		eventInterp.variables.set("FurretEngineVersion", MainMenuState.furretEngineVer);
		eventInterp.variables.set("CoolUtil", CoolUtil);
		eventInterp.variables.set("botPlay", cpuControlled);
		eventInterp.variables.set("downscroll", FlxG.save.data.downscroll);
		eventInterp.variables.set("ghostTapping", FlxG.save.data.newInput);
		eventInterp.variables.set("hitsounds", FlxG.save.data.hitsoundspog);
		eventInterp.variables.set("judgement", FlxG.save.data.judgement);
		eventInterp.variables.set("middlescroll", FlxG.save.data.middlescroll);
		eventInterp.variables.set("noteSplash", FlxG.save.data.noteSplashON);
		eventInterp.variables.set("camFollowXDad", camFollowXDad);
		eventInterp.variables.set("camFollowYDad", camFollowYDad);
		eventInterp.variables.set("camFollowXBoyfriend", camFollowXBoyfriend);
		eventInterp.variables.set("camFollowYBoyfriend", camFollowYBoyfriend);
		eventInterp.variables.set("FlxSprite", FlxSprite);
		eventInterp.variables.set("FlxSound", FlxSound);
		eventInterp.variables.set("FlxGroup", flixel.group.FlxGroup);
		eventInterp.variables.set("FlxAngle", flixel.math.FlxAngle);
		eventInterp.variables.set("Paths", Paths);
		eventInterp.variables.set("Sound", flash.media.Sound);
		eventInterp.variables.set("FlxMath", flixel.math.FlxMath);
		eventInterp.variables.set("Math", flixel.math.FlxMath);
		eventInterp.variables.set("FlxPoint", flixel.math.FlxPoint);
		eventInterp.variables.set("Point", flixel.math.FlxPoint);
		eventInterp.variables.set("FlxRect", flixel.math.FlxRect);
		eventInterp.variables.set("Rect", flixel.math.FlxRect);
		eventInterp.variables.set("GlitchEffect", Shaders.GlitchEffect);
		eventInterp.variables.set("PulseEffect", Shaders.PulseEffect);
		eventInterp.variables.set("StringTools", StringTools);
		eventInterp.variables.set("SHADOW", FlxTextBorderStyle.SHADOW);
		eventInterp.variables.set("OUTLINE", FlxTextBorderStyle.OUTLINE);
		eventInterp.variables.set("OUTLINE_FAST", FlxTextBorderStyle.OUTLINE_FAST);
		eventInterp.variables.set("NONE", FlxTextBorderStyle.NONE);
		eventInterp.variables.set("CENTER", FlxTextAlign.CENTER);
		eventInterp.variables.set("JUSTIFY", FlxTextAlign.JUSTIFY);
		eventInterp.variables.set("LEFT", FlxTextAlign.LEFT);
		eventInterp.variables.set("RIGHT", FlxTextAlign.RIGHT);
		eventInterp.variables.set("SONG", SONG);
		eventInterp.variables.set("camFollow", camFollow);
		eventInterp.variables.set("Sys", Sys);
		eventInterp.variables.set("FileSystem", sys.FileSystem); //i shouldn't be doing this, people can do a lot of bad things with this
		eventInterp.variables.set("File", sys.io.File);
		eventInterp.variables.set("JSON", haxe.Json); //this isn't too bad isn't it?
		eventInterp.variables.set("dadCameraOffsetX", dadCameraOffsetX);
		eventInterp.variables.set("dadCameraOffsetY", dadCameraOffsetY);
		eventInterp.variables.set("bfCameraOffsetX", bfCameraOffsetX);
		eventInterp.variables.set("bfCameraOffsetY", bfCameraOffsetY);
		eventInterp.variables.set("value1", '');
		eventInterp.variables.set("value2", '');
		eventInterp.variables.set("curbg", curbg);
		eventInterp.variables.set("playerStrums", playerStrums);
		eventInterp.variables.set("cpuStrums", cpuStrums);
		eventInterp.variables.set("strumLineNotes", strumLineNotes);
		eventInterp.variables.set("elapsedtime", elapsedtime);
		eventInterp.variables.set("sicksTxt", sicksTxt);
		eventInterp.variables.set("goodsTxt", goodsTxt);
		eventInterp.variables.set("badsTxt", badsTxt);
		eventInterp.variables.set("shitsTxt", shitsTxt);
		eventInterp.variables.set("missesTxt", missesTxt);
		eventInterp.variables.set("judgementTextTxt", judgementTextTxt);
		eventInterp.variables.set("scoreTxt", scoreTxt);
		eventInterp.variables.set("runningOnFE", runningOnFE);
		eventInterp.variables.set("nameOfTheSong", nameOfTheSong);
		eventInterp.variables.set("difficultySong", difficultySong);
		eventInterp.variables.set("Preferences", Preferences);
		eventInterp.variables.set("killPlayer", function() {
			health = health - 404;
		});
		eventInterp.variables.set("camHUD", camHUD);
		eventInterp.variables.set("camGame", camGame);
		eventInterp.variables.set("healthBarBG", healthBarBG);
		eventInterp.variables.set("healthBar", healthBar);
		eventInterp.variables.set("scoreTxt", scoreTxt);
		eventInterp.variables.set("TitleState", TitleState);
		eventInterp.variables.set("makeRangeArray", CoolUtil.numberArray);
		eventInterp.variables.set("FlxG", flixel.FlxG);
		eventInterp.variables.set("FlxTimer", flixel.util.FlxTimer);
		eventInterp.variables.set("FlxTween", flixel.tweens.FlxTween);
		eventInterp.variables.set("Std", Std);
		eventInterp.variables.set("iconP1", iconP1);
		eventInterp.variables.set("iconP2", iconP2);
		eventInterp.variables.set("BLACK", FlxColor.BLACK);
		eventInterp.variables.set("BLUE", FlxColor.BLUE);
		eventInterp.variables.set("BROWN", FlxColor.BROWN);
		eventInterp.variables.set("CYAN", FlxColor.CYAN);
		eventInterp.variables.set("GRAY", FlxColor.GRAY);
		eventInterp.variables.set("GREEN", FlxColor.GREEN);
		eventInterp.variables.set("LIME", FlxColor.LIME);
		eventInterp.variables.set("MAGENTA", FlxColor.MAGENTA);
		eventInterp.variables.set("ORANGE", FlxColor.ORANGE);
		eventInterp.variables.set("PINK", FlxColor.PINK);
		eventInterp.variables.set("PURPLE", FlxColor.PURPLE);
		eventInterp.variables.set("RED", FlxColor.RED);
		eventInterp.variables.set("TRANSPARENT", FlxColor.TRANSPARENT);
		eventInterp.variables.set("WHITE", FlxColor.WHITE);
		eventInterp.variables.set("YELLOW", FlxColor.YELLOW);
		eventInterp.variables.set("StringTools", StringTools);
		eventInterp.variables.set("FlxTrail", FlxTrail);
		eventInterp.variables.set("FlxEase", FlxEase);
		eventInterp.variables.set("Reflect", Reflect);
		eventInterp.variables.set("health", 0);
		eventInterp.variables.set("curStep", 0);
		eventInterp.variables.set("curBeat", 0);
		eventInterp.variables.set("curSong", SONG.song);
		eventInterp.variables.set("FlxText", FlxText);
		eventInterp.variables.set("preloadImage", function(daThingToPreload:String) { //mandatory if you want to add an image to hscript
			var preload = new FlxSprite(1000,-1000).loadGraphic(Paths.image(daThingToPreload));
			add(preload);
			remove(preload);
		});
		eventInterp.variables.set("SONG", SONG);
		eventInterp.variables.set("Boyfriend", Boyfriend);
		eventInterp.variables.set("boyfriend", bf);
		eventInterp.variables.set("dad", dad);
		eventInterp.variables.set("gf", gf);
		eventInterp.variables.set("setDiscordPresence", function(daPresence:String) {
			#if windows
			DiscordClient.changePresence(daPresence, null);
			#else
			trace("[!] Ignoring discord presence change as we are not on Windows");
			#end
		});
		eventInterp.variables.set("changeCharacter", function(characterToReplace:String, characterThatWillBeReplaced, X:Int = 999999, Y:Int = 999999) {
			if (characterThatWillBeReplaced == 'dad')
			{
				remove(dad);
				if (X == 999999 || Y == 999999 || X & Y == 999999)
				{
					dad = new Character(dad.x, dad.y, characterToReplace);
					trace("[!] Haxe script: No X or Y or both specified");
				}
				else
				{
					dad = new Character(X, Y, characterToReplace);
				}
				add(dad);
				SONG.player2 = characterToReplace;
				remove(iconP2);
				iconP2 = new HealthIcon(SONG.player2, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				iconP2.cameras = [camHUD];
				add(iconP2);
				SONG.player2 = player2BeforeChanges;
			}
			else if (characterThatWillBeReplaced == 'bf' || characterThatWillBeReplaced == 'boyfriend')
			{
				remove(boyfriend);
				if (X == 999999 || Y == 999999 || X & Y == 999999)
				{
					boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
					trace("[!] Haxe script: No X or Y or both specified");
				}
				else
				{
					boyfriend = new Boyfriend(X, Y, characterToReplace);
				}
				add(boyfriend);
			}
			else if (characterThatWillBeReplaced == 'dad')
			{
				remove(boyfriend);
				if (X == 999999 || Y == 999999 || X & Y == 999999)
				{
					boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
					trace("[!] Haxe script: No X or Y or both specified");
				}
				else
				{
					boyfriend = new Boyfriend(X, Y, characterToReplace);
				}
				add(boyfriend);
				SONG.player1 = characterToReplace;
				remove(iconP1);
				iconP1 = new HealthIcon(SONG.player1, false);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				iconP1.cameras = [camHUD];
				add(iconP1);
				SONG.player1 = player1BeforeChanges;
			}
		});
		eventInterp.variables.set("getVariableFromAClass", function(varClass:String, variable:String) {
			var splittt:Array<String> = variable.split('.');
			if (splittt.length > 1) {
				var dyn:Dynamic = CoolUtil.getVarFromArray(Type.resolveClass(varClass), splittt[0]);
				for (i in 1...splittt.length-1) {
					dyn = CoolUtil.getVarFromArray(dyn, splittt[i]);
				}
				return CoolUtil.getVarFromArray(dyn, splittt[splittt.length-1]);
			}
			return CoolUtil.getVarFromArray(Type.resolveClass(varClass), variable);
		});
		eventInterp.variables.set("setVariableFromAClass", function(varClass:String, variable:String, value:Dynamic) {
			var splittt:Array<String> = variable.split('.');
			if (splittt.length > 1) {
				var dyn:Dynamic = CoolUtil.getVarFromArray(Type.resolveClass(varClass), splittt[0]);
				for (i in 1...splittt.length-1) {
					dyn = CoolUtil.getVarFromArray(dyn, splittt[i]);
				}
				CoolUtil.setVarFromArray(dyn, splittt[splittt.length-1], value);
				return true;
			}
			CoolUtil.setVarFromArray(Type.resolveClass(varClass), variable, value);
			return true;
		});
		eventInterp.variables.set("Character", Character);
		eventInterp.variables.set("PlayState", PlayState);
		eventInterp.variables.set("FlxG", FlxG);
		eventInterp.variables.set("ease", FlxEase);
		eventInterp.variables.set("camHUD", camHUD);
		eventInterp.variables.set("remove", function(something)
		{
			remove(something);
		});
		eventInterp.variables.set("add", function(something)
		{
			add(something);
		});
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch(id)
		{
			case 'boyfriend':
				return boyfriend;
			case 'girlfriend':
				return gf;
			case 'dad':
				return dad;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
			return strumLineNotes.members[Std.parseInt(id)];
		return luaSprites.get(id);
	}

	public static var luaSprites:Map<String,FlxSprite> = [];

	function makeLuaSprite(spritePath:String,toBeCalled:String, X:Int = -66666, Y:Int = -66666, drawBehind:Bool)
	{
		#if sys
		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + PlayState.SONG.song.toLowerCase() + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0,0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
		{
			scale = 1;
		}

		sprite.makeGraphic(Std.int(data.width * scale),Std.int(data.width * scale),FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;
		
		luaSprites.set(toBeCalled,sprite);
		// and I quote:
		// shitty layering but it works!
		if (drawBehind)
		{
			remove(gf);
			remove(boyfriend);
			remove(dad);
		}
		add(sprite);
		if (X == -66666 || Y == -66666)
		{
			trace("LUA: X and Y positions are not provided!");
		}
		else
		{
			sprite.x = X;
			sprite.y = Y;
		}
		if (drawBehind)
		{
			add(gf);
			add(boyfriend);
			add(dad);
		}
		#end
		return toBeCalled;
	}
	// LUA SHIT
	#end

	override public function create()
	{
		Preferences.refreshPreferences();
		if (loadHScript)
		{
			setAllHaxeVar('camZooming', camZooming);
			setAllHaxeVar('gfSpeed', gfSpeed);
			setAllHaxeVar('health', health);
		}
		
		createEventInterp();

		previousRate = songMultiplier - 0.05;
		stageAssets = [];
		isNew = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		SONG.speed /= songMultiplier;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if sys
		executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase()  + "/modchart"));
		#end
		#if !(windows)
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		
		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		if (executeModchart)
			songMultiplier = 1;

		#if windows
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		if (cpuControlled)
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: N/A | Score: N/A | Misses: N/A [!] BOTPLAY"); 
		}
		else
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		}
		#end


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;

		if (player2BeforeChanges != null)
		{
			SONG.player2 == player2BeforeChanges;
		}
		if (player1BeforeChanges != null)
		{
			SONG.player1 == player1BeforeChanges;
		}

		defaultPlayer2 == SONG.player1;
		defaultPlayer1 == SONG.player2;

		// prefer player 1
		#if android
		if (FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player1+'/'+SONG.song.toLowerCase()+'Dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/images/custom_chars/'+SONG.player1+'/'+SONG.song.toLowerCase()+'Dialog.txt');
		// if no player 1 unique dialog, use player 2
		} else if (FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player2+'/'+SONG.song.toLowerCase()+'Dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/images/custom_chars/'+SONG.player2+'/'+SONG.song.toLowerCase()+'Dialog.txt');
		// if no player dialog, use default
		}	else if (FileSystem.exists(BootUpCheck.getPath() + 'assets/data/'+SONG.song.toLowerCase()+'/dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/data/'+SONG.song.toLowerCase()+'/dialog.txt');
		} else if (FileSystem.exists(BootUpCheck.getPath() + 'assets/data/'+SONG.song.toLowerCase()+'/dialogue.txt')){
			// nerds spell dialogue properly gotta make em happy
			dialogue = CoolUtil.coolDynamicTextFile('assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt');
		// otherwise, make the dialog an error message
		} else {
			dialogue = [':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".'];
		}
		#else
		if (FileSystem.exists('assets/images/custom_chars/'+SONG.player1+'/'+SONG.song.toLowerCase()+'Dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/images/custom_chars/'+SONG.player1+'/'+SONG.song.toLowerCase()+'Dialog.txt');
		// if no player 1 unique dialog, use player 2
		} else if (FileSystem.exists('assets/images/custom_chars/'+SONG.player2+'/'+SONG.song.toLowerCase()+'Dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/images/custom_chars/'+SONG.player2+'/'+SONG.song.toLowerCase()+'Dialog.txt');
		// if no player dialog, use default
		}	else if (FileSystem.exists('assets/data/'+SONG.song.toLowerCase()+'/dialog.txt')) {
			dialogue = CoolUtil.coolDynamicTextFile('assets/data/'+SONG.song.toLowerCase()+'/dialog.txt');
		} else if (FileSystem.exists('assets/data/'+SONG.song.toLowerCase()+'/dialogue.txt')){
			// nerds spell dialogue properly gotta make em happy
			dialogue = CoolUtil.coolDynamicTextFile('assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt');
		// otherwise, make the dialog an error message
		} else {
			dialogue = [':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".'];
		}
		#end
		boyfriend = new Boyfriend(770, 450, SONG.player1);
		dad = new Character(100, 100, SONG.player2);
		gf = new Character(400, 130, SONG.gf);

	 if (SONG.stage == 'spooky')
		{
			curStage = "spooky";
			halloweenLevel = true;
	
			var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/halloween_bg.png', 'assets/images/halloween_bg.xml');
	
			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);
	
			isHalloween = true;
		}
		else if (SONG.stage == 'philly')
		{
			curStage = 'philly';
	
			var bg:FlxSprite = new FlxSprite(-100).loadGraphic('assets/images/philly/sky.png');
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);
	
			var city:FlxSprite = new FlxSprite(-10).loadGraphic('assets/images/philly/city.png');
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);
	
			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);
	
			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic('assets/images/philly/win' + i + '.png');
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}
	
			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic('assets/images/philly/behindTrain.png');
			add(streetBehind);
	
			phillyTrain = new FlxSprite(2000, 360).loadGraphic('assets/images/philly/train.png');
			add(phillyTrain);
	
			trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);
	
			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
	
			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic('assets/images/philly/street.png');
			add(street);
		}
		else if (SONG.stage == 'limo')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;
	
			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic('assets/images/limo/limoSunset.png');
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);
	
			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = FlxAtlasFrames.fromSparrow('assets/images/limo/bgLimo.png', 'assets/images/limo/bgLimo.xml');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);
	
			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);
	
			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}
	
			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('assets/images/limo/limoOverlay.png');
			overlayShit.alpha = 0.5;
			// add(overlayShit);
	
			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
	
			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
	
			// overlayShit.shader = shaderBullshit;
	
			var limoTex = FlxAtlasFrames.fromSparrow('assets/images/limo/limoDrive.png', 'assets/images/limo/limoDrive.xml');
	
			limo = new FlxSprite(-120, 550);
			limo.frames = limoTex;
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;
	
			fastCar = new FlxSprite(-300, 160).loadGraphic('assets/images/limo/fastCarLol.png');
			// add(limo);
		}
		else if (SONG.stage == 'mall')
		{
			curStage = 'mall';
	
			defaultCamZoom = 0.80;
	
			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic('assets/images/christmas/bgWalls.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);
	
			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/upperBop.png', 'assets/images/christmas/upperBop.xml');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);
	
			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic('assets/images/christmas/bgEscalator.png');
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);
	
			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic('assets/images/christmas/christmasTree.png');
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);
	
			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/bottomBop.png', 'assets/images/christmas/bottomBop.xml');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);
	
			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic('assets/images/christmas/fgSnow.png');
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);
	
			santa = new FlxSprite(-840, 150);
			santa.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/santa.png', 'assets/images/christmas/santa.xml');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (SONG.stage == 'mallEvil')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic('assets/images/christmas/evilBG.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);
	
			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic('assets/images/christmas/evilTree.png');
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);
	
			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assets/images/christmas/evilSnow.png");
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (SONG.stage == 'school')
		{
			curStage = 'school';
			// defaultCamZoom = 0.9;
	
			var bgSky = new FlxSprite().loadGraphic('assets/images/weeb/weebSky.png');
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);
	
			var repositionShit = -200;
	
			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic('assets/images/weeb/weebSchool.png');
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);
	
			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic('assets/images/weeb/weebStreet.png');
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);
	
			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic('assets/images/weeb/weebTreesBack.png');
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);
	
			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = FlxAtlasFrames.fromSpriteSheetPacker('assets/images/weeb/weebTrees.png', 'assets/images/weeb/weebTrees.txt');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);
	
			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/petals.png', 'assets/images/weeb/petals.xml');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);
	
			var widShit = Std.int(bgSky.width * 6);
	
			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);
	
			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();
	
			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);
	
			if (SONG.isMoody)
			{
				bgGirls.getScared();
			}
	
			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (SONG.stage == 'schoolEvil')
		{
			curStage = 'schoolEvil';
	
			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
	
			var posX = 400;
			var posY = 200;
	
			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/animatedEvilSchool.png', 'assets/images/weeb/animatedEvilSchool.xml');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
			trace("schoolEvilComplete");
			/*
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolBG.png');
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);
	
				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolFG.png');
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);
	
				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
			 */
	
			// bg.shader = wiggleShit.shader;
			// fg.shader = wiggleShit.shader;
	
			/*
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
	
				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);
	
				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);
	
				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();
	
				add(waveSprite);
				add(waveSpriteFG);
			 */
		}
		else if (SONG.stage == "stage")
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
	
			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);
	
			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;
	
			add(stageCurtains);
		} 
		else
		{
			#if android
			if (FileSystem.exists(BootUpCheck.getPath() + "assets/images/custom_stages/" + SONG.stage + "/stageData.json")) {
				trace("[i] Stage type: JSON");
				generateJsonStage();
			}
			else
			{
				if (FileSystem.exists(BootUpCheck.getPath() + "assets/images/custom_stages/" + SONG.stage + "/stageData.hx")) {
					trace("[i] Stage type: Haxe");
					generateHaxeStage();
				}
				else
				{
					Application.current.window.alert("The stage couldn't be found. The stage will be a black screen. Press OK to continue.");
				}
			}
			#else
			if (FileSystem.exists("assets/images/custom_stages/" + SONG.stage + "/stageData.json")) {
				trace("[i] Stage type: JSON");
				generateJsonStage();
			}
			else
			{
				if (FileSystem.exists("assets/images/custom_stages/" + SONG.stage + "/stageData.hx")) {
					trace("[i] Stage type: Haxe");
					generateHaxeStage();
				}
				else
				{
					Application.current.window.alert("The stage couldn't be found. The stage will be a black screen. Press OK to continue.");
				}
			}
			#end	
		}

		if (curStage == 'limo'){
			add(gf);
			add(limo);
		}

		var gfVersion:String = 'gf';

		gfVersion = SONG.gf;
		gf.scrollFactor.set(0.95, 0.95);

		if (isStoryMode)
			songMultiplier = 1;

		

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		
		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode )
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 130;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.x += 370;
				camPos.y += 300;
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.x += 370;
				camPos.y += 300;
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.x += 300;
			default:	
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
				if (dad.like == "gf") {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				}
		}

		
		


		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}


		// Shitty layering but whatev it works LOL
		if(!hasCreatedgf  && curStage!='limo'){
			add(gf);
		}
		if(!hasCreated){
			add(dad);
			add(boyfriend);
			hasCreated = true;
		}


		var doof:DialogueBox = new DialogueBox(false, dialogue);


		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;


		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		#if !(android)
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		#elseif android
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		#end
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		camFollowXDad = (dad.getMidpoint().x + 150) + dadCameraOffsetX;
		camFollowYDad = (dad.getMidpoint().y - 100) + dadCameraOffsetY;
		camFollowXBoyfriend = (boyfriend.getMidpoint().x - 100) + bfCameraOffsetX;
		camFollowYBoyfriend = (boyfriend.getMidpoint().y - 100) + bfCameraOffsetY;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		songLength = FlxG.sound.music.length / 1000;

		Conductor.crochet = ((60 / (SONG.bpm) * 1000)) / songMultiplier;
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
				if (FlxG.save.data.downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (FlxG.save.data.downscroll)
					songName.y -= 3;
				songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				add(songName);
				songName.cameras = [camHUD];
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		runningOnFE = new FlxText(0, FlxG.height/2-360, 0, "", 20);
		runningOnFE.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		runningOnFE.scrollFactor.set();

		nameOfTheSong = new FlxText(0, FlxG.height/2-340, 0, "", 20);
		nameOfTheSong.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		nameOfTheSong.scrollFactor.set();

		difficultySong = new FlxText(0, FlxG.height/2-320, 0, "", 20);
		difficultySong.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		difficultySong.scrollFactor.set();

		judgementTextTxt = new FlxText(0, FlxG.height/2-60, 0, "", 20);
		judgementTextTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		judgementTextTxt.scrollFactor.set();

		sicksTxt = new FlxText(0, FlxG.height/2-40, 0, "", 20);
		sicksTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		sicksTxt.scrollFactor.set();

		goodsTxt = new FlxText(0, FlxG.height/2-20, 0, "", 20);
		goodsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		goodsTxt.scrollFactor.set();

		badsTxt = new FlxText(0, FlxG.height/2, 0, "", 20);
		badsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		badsTxt.scrollFactor.set();

		shitsTxt = new FlxText(0, FlxG.height/2+20, 0, "", 20);
		shitsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shitsTxt.scrollFactor.set();

		missesTxt = new FlxText(0, FlxG.height/2+40, 0, "", 20);
		missesTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		missesTxt.scrollFactor.set();

		runningOnFE.text = "Furret Engine " + MainMenuState.furretEngineVer #if debug + " | [!] Running in debug mode!"#end;
		runningOnFE.cameras = [camHUD];
		nameOfTheSong.text = "Song: " + curSong;
		nameOfTheSong.cameras = [camHUD];
		difficultySong.text = "Difficulty: " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		difficultySong.cameras = [camHUD];

		judgementTextTxt.text = (Main.judgement ? "Judgement " + " " : "");
		missesTxt.text = (Main.judgement ? "Miss: " + misses + " " : "");
		sicksTxt.text = (Main.judgement ? "Sick: " + sicks + " " : "");
		goodsTxt.text = (Main.judgement ? "Good: " + goods + " " : "");
		badsTxt.text = (Main.judgement ? "Bad: " + bads + " " : "");
		shitsTxt.text = (Main.judgement ? "Shit: " + shits + " " : "");

		if (FlxG.save.data.hidehud)
		{
			trace("Hide hud option is enabled! Hud won't show");
			add(judgementTextTxt);
			judgementTextTxt.visible = false;
			add(missesTxt);
			missesTxt.visible = false;
			add(sicksTxt);
			sicksTxt.visible = false;
			add(goodsTxt);
			goodsTxt.visible = false;
			add(badsTxt);
			badsTxt.visible = false;
			add(shitsTxt);
			shitsTxt.visible = false;
		}
		else
		{
			add(runningOnFE);
			add(nameOfTheSong);
			add(difficultySong);
			add(judgementTextTxt);
			add(missesTxt);
			add(sicksTxt);
			add(goodsTxt);
			add(badsTxt);
			add(shitsTxt);
		}

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + (Main.watermarks && Main.furrettofnf ? " - " +  "Furret Engine " + MainMenuState.furretEngineVer + "" : "") + (Main.watermarks && !Main.furrettofnf ? " ->" + " FNF " + MainMenuState.gameVer + " " : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		if (FlxG.save.data.hidenotehittime)
		{
			trace("Hide note hit is enabled! Hit time won't show");
		}
		if (FlxG.save.data.hidehud)
		{
			trace("Hide hud option is enabled! Hud won't show");
		}
		else
		{

		}

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;


		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;

		scoreBG = new FlxSprite(scoreTxt.x - 10, scoreTxt.y).makeGraphic(Std.int(FlxG.width * 0.38), 18, 0xFF000000);
		scoreBG.alpha = 0.6;
		if (FlxG.save.data.hidehud)
		{
			trace("Hide hud option is enabled! Hud won't show");
			add(scoreTxt);
			scoreTxt.visible = false;
		}
		else
		{	
			add(scoreTxt);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
			{
				add(replayTxt);
			}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		judgementTextTxt.cameras = [camHUD];
		missesTxt.cameras = [camHUD];
		sicksTxt.cameras = [camHUD];
		goodsTxt.cameras = [camHUD];
		badsTxt.cameras = [camHUD];
		shitsTxt.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		scoreBG.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		#if android
		var directory:Array<String> = FileSystem.readDirectory(BootUpCheck.getPath() + "assets/data/" + curSong.toLowerCase());
		#else
		var directory:Array<String> = FileSystem.readDirectory("assets/data/" + curSong.toLowerCase());
		#end
		trace(directory);
		for (i in directory)
		{
			if (directory[check].endsWith(".hx"))
			{
				trace("Script detected! " + "assets/data/" + curSong.toLowerCase() + "/" + directory[check]);
			}
			else
			{
				// do nothing
			}
			loadHScript = true;
			check++;
		}
		check = 0;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (SONG.cutsceneType)
			{
				case "monster":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'angry-senpai':
					FlxG.sound.play('assets/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'spirit':
					schoolIntro(doof);
				case 'none':
					startCountdown();
				default:
					
					schoolIntro(doof);
			}
		}
		else
		{

			startCountdown();
			
		}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		var senpaiSound:Sound;
		// try and find a player2 sound first
		#if android
		if (FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg')) {
			senpaiSound = Sound.fromFile('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg');
		// otherwise, try and find a song one
		} else if (FileSystem.exists(BootUpCheck.getPath() + 'assets/data/'+SONG.song.toLowerCase()+'/Senpai_Dies.ogg')) {
			senpaiSound = Sound.fromFile(BootUpCheck.getPath() + 'assets/data/'+SONG.song.toLowerCase()+'Senpai_Dies.ogg');
		// otherwise, use the default sound
		} else {
			senpaiSound = Sound.fromFile('assets/sounds/Senpai_Dies.ogg');
		}
		#else
		if (FileSystem.exists('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg')) {
			senpaiSound = Sound.fromFile('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg');
		// otherwise, try and find a song one
		} else if (FileSystem.exists('assets/data/'+SONG.song.toLowerCase()+'/Senpai_Dies.ogg')) {
			senpaiSound = Sound.fromFile('assets/data/'+SONG.song.toLowerCase()+'Senpai_Dies.ogg');
		// otherwise, use the default sound
		} else {
			senpaiSound = Sound.fromFile('assets/sounds/Senpai_Dies.ogg');
		}
		#end
		var senpaiEvil:FlxSprite = new FlxSprite();
		// dialog box overwrites character
		trace("YO WE HIT THE POGGERS");
		if (FileSystem.exists('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png')) {
			#if android
			var evilImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png');
			#else
			var evilImage = BitmapData.fromFile('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png');
			#end
			#if android
			var evilXml = File.getContent(BootUpCheck.getPath() + 'assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.xml');
			#else
			var evilXml = File.getContent('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.xml');
			#end
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
			
		// character then takes precendence over default
		// will make things like monika way way easier
		} #if android else if (FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player2+'/crazy.png')) #else else if (FileSystem.exists('assets/images/custom_chars/'+SONG.player2+'/crazy.png')) #end {

			#if android
			var evilImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player2+'/crazy.png');
			#else
			var evilImage = BitmapData.fromFile('assets/images/custom_chars/'+SONG.player2+'/crazy.png');
			#end
			#if android
			var evilXml = File.getContent(BootUpCheck.getPath() + 'assets/images/custom_chars/'+SONG.player2+'/crazy.xml');
			#else
			var evilXml = File.getContent('assets/images/custom_chars/'+SONG.player2+'/crazy.xml');
			#end
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		} else {
			
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		}

		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		if (dad.isPixel) {
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		}
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (dialogueBox != null && dialogueBox.like != 'senpai')
		{
			remove(black);

			if (dialogueBox.like == 'spirit')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (dialogueBox.like == 'spirit')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(senpaiSound, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	#if windows
	var video:MP4Handler;
	#end

	function playCutscene(name:String)
	{
		inCutscene = true;

		#if windows
		video = new MP4Handler();
		
		video.finishCallback = function()
		{
			startCountdown();
		}
		video.playVideo(Paths.video(name));
		#end
	}

	function playEndCutscene(name:String)
	{
		inCutscene = true;

		#if windows
		video = new MP4Handler();
		video.finishCallback = function()
		{
			SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
			LoadingState.loadAndSwitchState(new PlayState());
		}
		video.playVideo(Paths.video(name));
		#end
	}

	function startCountdown():Void
	{	
		var bf = boyfriend;
		if (loadHScript)
		{
			trace("[!] A haxe state will be opened since there is a script");
			interp.variables.set("endSong", function() {
				endSong();
			});
			interp.variables.set("Conductor", Conductor);
			interp.variables.set("curBPM", Conductor.bpm);
			interp.variables.set("bpm", SONG.bpm);
			interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
			interp.variables.set("scrollSpeed", SONG.speed);
			interp.variables.set("crochet", Conductor.crochet);
			interp.variables.set("stepCrochet", Conductor.stepCrochet);
			interp.variables.set("songLength", FlxG.sound.music.length);
			interp.variables.set("isStoryMode", PlayState.isStoryMode);
			interp.variables.set("storyDifficulty", PlayState.storyDifficulty);
			interp.variables.set("FurretEngineVersion", MainMenuState.furretEngineVer);
			interp.variables.set("CoolUtil", CoolUtil);
			interp.variables.set("botPlay", cpuControlled);
			interp.variables.set("downscroll", FlxG.save.data.downscroll);
			interp.variables.set("ghostTapping", FlxG.save.data.newInput);
			interp.variables.set("hitsounds", FlxG.save.data.hitsoundspog);
			interp.variables.set("judgement", FlxG.save.data.judgement);
			interp.variables.set("middlescroll", FlxG.save.data.middlescroll);
			interp.variables.set("noteSplash", FlxG.save.data.noteSplashON);
			interp.variables.set("camFollowXDad", camFollowXDad);
			interp.variables.set("camFollowYDad", camFollowYDad);
			interp.variables.set("camFollowXBoyfriend", camFollowXBoyfriend);
			interp.variables.set("camFollowYBoyfriend", camFollowYBoyfriend);
			interp.variables.set("FlxSprite", FlxSprite);
			interp.variables.set("FlxSound", FlxSound);
			interp.variables.set("FlxGroup", flixel.group.FlxGroup);
			interp.variables.set("FlxAngle", flixel.math.FlxAngle);
			interp.variables.set("Paths", Paths);
			interp.variables.set("Sound", flash.media.Sound);
			interp.variables.set("FlxMath", flixel.math.FlxMath);
			interp.variables.set("Math", flixel.math.FlxMath);
			interp.variables.set("FlxPoint", flixel.math.FlxPoint);
			interp.variables.set("Point", flixel.math.FlxPoint);
			interp.variables.set("FlxRect", flixel.math.FlxRect);
			interp.variables.set("Rect", flixel.math.FlxRect);
			interp.variables.set("GlitchEffect", Shaders.GlitchEffect);
			interp.variables.set("PulseEffect", Shaders.PulseEffect);
			interp.variables.set("StringTools", StringTools);
			interp.variables.set("SHADOW", FlxTextBorderStyle.SHADOW);
			interp.variables.set("OUTLINE", FlxTextBorderStyle.OUTLINE);
			interp.variables.set("OUTLINE_FAST", FlxTextBorderStyle.OUTLINE_FAST);
			interp.variables.set("NONE", FlxTextBorderStyle.NONE);
			interp.variables.set("CENTER", FlxTextAlign.CENTER);
			interp.variables.set("JUSTIFY", FlxTextAlign.JUSTIFY);
			interp.variables.set("LEFT", FlxTextAlign.LEFT);
			interp.variables.set("RIGHT", FlxTextAlign.RIGHT);
			interp.variables.set("SONG", SONG);
			interp.variables.set("camFollow", camFollow);
			interp.variables.set("Sys", Sys);
			interp.variables.set("FileSystem", sys.FileSystem); //i shouldn't be doing this, people can do a lot of bad things with this
			interp.variables.set("File", sys.io.File);
			interp.variables.set("JSON", haxe.Json); //this isn't too bad isn't it?
			interp.variables.set("dadCameraOffsetX", dadCameraOffsetX);
			interp.variables.set("dadCameraOffsetY", dadCameraOffsetY);
			interp.variables.set("bfCameraOffsetX", bfCameraOffsetX);
			interp.variables.set("bfCameraOffsetY", bfCameraOffsetY);
			interp.variables.set("curbg", curbg);
			interp.variables.set("playerStrums", playerStrums);
			interp.variables.set("cpuStrums", cpuStrums);
			interp.variables.set("strumLineNotes", strumLineNotes);
			interp.variables.set("elapsedtime", elapsedtime);
			interp.variables.set("sicksTxt", sicksTxt);
			interp.variables.set("goodsTxt", goodsTxt);
			interp.variables.set("badsTxt", badsTxt);
			interp.variables.set("shitsTxt", shitsTxt);
			interp.variables.set("missesTxt", missesTxt);
			interp.variables.set("judgementTextTxt", judgementTextTxt);
			interp.variables.set("scoreTxt", scoreTxt);
			interp.variables.set("runningOnFE", runningOnFE);
			interp.variables.set("nameOfTheSong", nameOfTheSong);
			interp.variables.set("difficultySong", difficultySong);
			interp.variables.set("Preferences", Preferences);
			interp.variables.set("start", function (song) {});
			interp.variables.set("beatHit", function (beat) {});
			interp.variables.set("update", function (elapsed) {});
			interp.variables.set("stepHit", function(step) {});
			interp.variables.set("killPlayer", function() {
				health = health - 404;
			});
			interp.variables.set("camHUD", camHUD);
			interp.variables.set("camGame", camGame);
			interp.variables.set("healthBarBG", healthBarBG);
			interp.variables.set("healthBar", healthBar);
			interp.variables.set("scoreTxt", scoreTxt);
			interp.variables.set("TitleState", TitleState);
			interp.variables.set("makeRangeArray", CoolUtil.numberArray);
			interp.variables.set("FlxG", flixel.FlxG);
			interp.variables.set("FlxTimer", flixel.util.FlxTimer);
			interp.variables.set("FlxTween", flixel.tweens.FlxTween);
			interp.variables.set("Std", Std);
			interp.variables.set("iconP1", iconP1);
			interp.variables.set("iconP2", iconP2);
			interp.variables.set("BLACK", FlxColor.BLACK);
			interp.variables.set("BLUE", FlxColor.BLUE);
			interp.variables.set("BROWN", FlxColor.BROWN);
			interp.variables.set("CYAN", FlxColor.CYAN);
			interp.variables.set("GRAY", FlxColor.GRAY);
			interp.variables.set("GREEN", FlxColor.GREEN);
			interp.variables.set("LIME", FlxColor.LIME);
			interp.variables.set("MAGENTA", FlxColor.MAGENTA);
			interp.variables.set("ORANGE", FlxColor.ORANGE);
			interp.variables.set("PINK", FlxColor.PINK);
			interp.variables.set("PURPLE", FlxColor.PURPLE);
			interp.variables.set("RED", FlxColor.RED);
			interp.variables.set("TRANSPARENT", FlxColor.TRANSPARENT);
			interp.variables.set("WHITE", FlxColor.WHITE);
			interp.variables.set("YELLOW", FlxColor.YELLOW);
			interp.variables.set("StringTools", StringTools);
			interp.variables.set("FlxTrail", FlxTrail);
			interp.variables.set("FlxEase", FlxEase);
			interp.variables.set("Reflect", Reflect);
			interp.variables.set("health", 0);
			interp.variables.set("curStep", 0);
			interp.variables.set("curBeat", 0);
			interp.variables.set("curSong", SONG.song);
			interp.variables.set("FlxText", FlxText);
			interp.variables.set("preloadImage", function(daThingToPreload:String) { //mandatory if you want to add an image to hscript
				var preload = new FlxSprite(1000,-1000).loadGraphic(Paths.image(daThingToPreload));
				add(preload);
				remove(preload);
			});
			interp.variables.set("SONG", SONG);
			interp.variables.set("Boyfriend", Boyfriend);
			interp.variables.set("boyfriend", bf);
			interp.variables.set("dad", dad);
			interp.variables.set("gf", gf);
			interp.variables.set("setDiscordPresence", function(daPresence:String) {
				#if windows
				DiscordClient.changePresence(daPresence, null);
				#else
				trace("[!] Ignoring discord presence change as we are not on Windows");
				#end
			});
			interp.variables.set("changeCharacter", function(characterToReplace:String, characterThatWillBeReplaced, X:Int = 999999, Y:Int = 999999) {
				if (characterThatWillBeReplaced == 'dad')
				{
					remove(dad);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						dad = new Character(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						dad = new Character(X, Y, characterToReplace);
					}
					add(dad);
					SONG.player2 = characterToReplace;
                    remove(iconP2);
                    iconP2 = new HealthIcon(SONG.player2, false);
                    iconP2.y = healthBar.y - (iconP2.height / 2);
                    iconP2.cameras = [camHUD];
                    add(iconP2);
                    SONG.player2 = player2BeforeChanges;
				}
				else if (characterThatWillBeReplaced == 'bf' || characterThatWillBeReplaced == 'boyfriend')
				{
					remove(boyfriend);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						boyfriend = new Boyfriend(X, Y, characterToReplace);
					}
					add(boyfriend);
				}
				else if (characterThatWillBeReplaced == 'dad')
				{
					remove(boyfriend);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						boyfriend = new Boyfriend(X, Y, characterToReplace);
					}
					add(boyfriend);
					SONG.player1 = characterToReplace;
                    remove(iconP1);
                    iconP1 = new HealthIcon(SONG.player1, false);
                    iconP1.y = healthBar.y - (iconP1.height / 2);
                    iconP1.cameras = [camHUD];
                    add(iconP1);
                    SONG.player1 = player1BeforeChanges;
				}
			});
			interp.variables.set("getVariableFromAClass", function(varClass:String, variable:String) {
				var splittt:Array<String> = variable.split('.');
				if (splittt.length > 1) {
					var dyn:Dynamic = CoolUtil.getVarFromArray(Type.resolveClass(varClass), splittt[0]);
					for (i in 1...splittt.length-1) {
						dyn = CoolUtil.getVarFromArray(dyn, splittt[i]);
					}
					return CoolUtil.getVarFromArray(dyn, splittt[splittt.length-1]);
				}
				return CoolUtil.getVarFromArray(Type.resolveClass(varClass), variable);
			});
			interp.variables.set("setVariableFromAClass", function(varClass:String, variable:String, value:Dynamic) {
				var splittt:Array<String> = variable.split('.');
				if (splittt.length > 1) {
					var dyn:Dynamic = CoolUtil.getVarFromArray(Type.resolveClass(varClass), splittt[0]);
					for (i in 1...splittt.length-1) {
						dyn = CoolUtil.getVarFromArray(dyn, splittt[i]);
					}
					CoolUtil.setVarFromArray(dyn, splittt[splittt.length-1], value);
					return true;
				}
				CoolUtil.setVarFromArray(Type.resolveClass(varClass), variable, value);
				return true;
			});
			interp.variables.set("Character", Character);
			interp.variables.set("PlayState", PlayState);
			interp.variables.set("FlxG", FlxG);
			interp.variables.set("ease", FlxEase);
			interp.variables.set("camHUD", camHUD);
			interp.variables.set("remove", function(something)
			{
				remove(something);
			});
			interp.variables.set("add", function(something)
			{
				add(something);
			});
			specifyFlxGActions();
			#if android
			var directory:Array<String> = FileSystem.readDirectory(BootUpCheck.getPath() + "assets/data/" + PlayState.SONG.song.toLowerCase());
			#else
			var directory:Array<String> = FileSystem.readDirectory("assets/data/" + PlayState.SONG.song.toLowerCase());
			#end
			hscriptStates.set('interp',interp);
			trace(directory);
			for (i in directory) //I DID IT, I FUCKING DID IT, LMAO, TAKE THAT PSYCH ENGINE CODERS
			{
				if (directory[check].endsWith(".hx"))
				{
					#if android
					var getScript = File.getContent(BootUpCheck.getPath() + "assets/data/" + PlayState.SONG.song.toLowerCase() + "/" + directory[check]);
					#else
					var getScript = File.getContent("assets/data/" + PlayState.SONG.song.toLowerCase() + "/" + directory[check]);
					#end
					var daScript:String = getScript;
					var daScriptParser = new hscript.Parser();
					var script:Dynamic = 'metete tu "Local variable script used without being initialized" por el fondo del ano';
					try {
						script = daScriptParser.parseString(daScript);
					}
					catch(e) {
						Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
						doNotExecute = true;
					}
					if (!doNotExecute)
					{
						try {
							interp.execute(script);
						}
						catch(e) {
							Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
							Sys.println("[!] Invalid script");
						}
						doNotExecute = false;
					}
					else
					{
						Sys.println("[!] Invalid script");
					}
		
					try {
						callHscript("start", [SONG.song], 'interp');
					}
					catch(e) {
						Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
						Sys.println("[!] Invalid script");
					}
					trace("[OK] A haxe state has been executed");
				}
				else
				{
					// do nothing
				}
				check++;
			}
			check = 0;
		}
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		FlxG.camera.angle = 0;

		player1BeforeChanges = SONG.player1;
		player2BeforeChanges = SONG.player2;
		scrollSpeedBeforeChanges = SONG.speed;
		if (scrollSpeedBeforeChanges != 0 || scrollSpeedBeforeChanges != 1 || scrollSpeedBeforeChanges != 2 || scrollSpeedBeforeChanges != 3 || scrollSpeedBeforeChanges != 3 || scrollSpeedBeforeChanges != 4 || scrollSpeedBeforeChanges != 5 || scrollSpeedBeforeChanges != 6 || scrollSpeedBeforeChanges != 7 || scrollSpeedBeforeChanges != 8 || scrollSpeedBeforeChanges != 9 || scrollSpeedBeforeChanges != 10)
		{
			SONG.speed == scrollSpeedBeforeChanges;
		}
		

		#if windows
		if (executeModchart) // dude I hate lua (jkjkjkjk)
			{
				trace('opening a lua state (because we are cool :))');
				lua = LuaL.newstate();
				LuaL.openlibs(lua);
				trace("Lua version: " + Lua.version());
				trace("LuaJIT version: " + Lua.versionJIT());
				Lua.init_callbacks(lua);
				
				var result = LuaL.dofile(lua, Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart")); // execute le file
	
				if (result != 0)
					trace('COMPILE ERROR\n' + getLuaErrorMessage(lua));

				// get some fukin globals up in here bois
	
				setVar("bpm", Conductor.bpm);
				setVar("fpsCap", FlxG.save.data.fpsCap);
				setVar("downscroll", FlxG.save.data.downscroll);
	
				setVar("curStep", 0);
				setVar("curBeat", 0);
	
				setVar("hudZoom", camHUD.zoom);
				setVar("cameraZoom", FlxG.camera.zoom);
	
				setVar("cameraAngle", FlxG.camera.angle);
				setVar("camHudAngle", camHUD.angle);
	
				setVar("followXOffset",0);
				setVar("followYOffset",0);
	
				setVar("showOnlyStrums", false);
				setVar("strumLine1Visible", true);
				setVar("strumLine2Visible", true);
	
				setVar("screenWidth",FlxG.width);
				setVar("screenHeight",FlxG.height);
				setVar("hudWidth", camHUD.width);
				setVar("hudHeight", camHUD.height);
	
				// callbacks
	
				// sprites
	
				trace(Lua_helper.add_callback(lua,"makeSprite", makeLuaSprite));

				trace(Lua_helper.add_callback(lua,"makeLuaText", function(X:Int, Y:Int, Text:String, size:Int, isOnCamHUD:Bool = true) {
					var newText:FlxText = new FlxText(X, Y, Text, size);
					if (isOnCamHUD)
					{
						newText.cameras = [camHUD];
					}
					add(newText);
				}));
	
				Lua_helper.add_callback(lua,"destroySprite", function(id:String) {
					var sprite = luaSprites.get(id);
					if (sprite == null)
						return false;
					remove(sprite);
					return true;
				});

				//score/accuracy/health functions!1!!1

				trace(Lua_helper.add_callback(lua,"addScore", function (value:Int = 0) {
					songScore += value;
				}));

				trace(Lua_helper.add_callback(lua,"setScore", function (value:Int = 0) {
					songScore = value;
				}));
				
				trace(Lua_helper.add_callback(lua,"addMisses", function (value:Int = 0) {
					misses += value;
				}));

				trace(Lua_helper.add_callback(lua,"addScore", function (value:Int = 0) {
					songScore += value;
				}));

				trace(Lua_helper.add_callback(lua,"setHealth", function (value:Int = 0) {
					health = value;
				}));

				trace(Lua_helper.add_callback(lua,"addHealth", function (value:Int = 0) {
					health += value;
				}));
	
				// hud/camera

				trace(Lua_helper.add_callback(lua,"screenShake", function (intensity:Float, duration:Float) {
					var screenShaking:Bool = true;
					if (screenShaking)
					{
						FlxG.camera.shake(intensity, duration);
					}
					new FlxTimer().start(duration, function(tmr:FlxTimer)
					{
						screenShaking = false;
					});
				}));

				trace(Lua_helper.add_callback(lua,"makeCamFlash", function (color:String, duration:Int) {
					if (color == 'BLACK')
					{
						FlxG.camera.flash(FlxColor.BLACK, duration);
					}
					else if (color == 'BLUE')
					{
						FlxG.camera.flash(FlxColor.BLUE, duration);
					}
					else if (color == 'BROWN')
					{
						FlxG.camera.flash(FlxColor.BROWN, duration);
					}
					else if (color == 'CYAN')
					{
						FlxG.camera.flash(FlxColor.CYAN, duration);
					}
					else if (color == 'GRAY')
					{
						FlxG.camera.flash(FlxColor.GRAY, duration);
					}
					else if (color == 'GREEN')
					{
						FlxG.camera.flash(FlxColor.GREEN, duration);
					}
					else if (color == 'LIME')
					{
						FlxG.camera.flash(FlxColor.LIME, duration);
					}
					else if (color == 'MAGENTA')
					{
						FlxG.camera.flash(FlxColor.MAGENTA, duration);
					}
					else if (color == 'ORANGE')
					{
						FlxG.camera.flash(FlxColor.ORANGE, duration);
					}
					else if (color == 'PINK')
					{
						FlxG.camera.flash(FlxColor.PINK, duration);
					}
					else if (color == 'PURPLE')
					{
						FlxG.camera.flash(FlxColor.PURPLE, duration);
					}
					else if (color == 'RED')
					{
						FlxG.camera.flash(FlxColor.RED, duration);
					}
					else if (color == 'TRANSPARENT') //why tf would you want to make a transparent flash?
					{
						FlxG.camera.flash(FlxColor.TRANSPARENT, duration);
					}
					else if (color == 'WHITE')
					{
						FlxG.camera.flash(FlxColor.WHITE, duration);
					}
					else if (color == 'YELLOW')
					{
						FlxG.camera.flash(FlxColor.YELLOW, duration);
					}
					else
					{
						trace("LUA: Invalid color!");
					}
				}));

				trace(Lua_helper.add_callback(lua,"addCameraZoom", function (Camera:Bool, zoom:Int) {
					if (Camera == true)
					{
						camHUD.zoom += zoom;
					}
					else
					{
						FlxG.camera.zoom += zoom;
					}
				}));
	
				trace(Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
					camHUD.x = x;
					camHUD.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudX", function () {
					return camHUD.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudY", function () {
					return camHUD.y;
				}));
				
				trace(Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
					FlxG.camera.x = x;
					FlxG.camera.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraX", function () {
					return FlxG.camera.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraY", function () {
					return FlxG.camera.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Int) {
					FlxG.camera.zoom = zoomAmount;
				}));
	
				trace(Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Int) {
					camHUD.zoom = zoomAmount;
				}));
	
				// actors
				
				trace(Lua_helper.add_callback(lua,"getRenderedNotes", function() {
					return notes.length;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
					return notes.members[id].x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
					return notes.members[id].y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
					return notes.members[id].scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleY", function(id:Int) {
					return notes.members[id].scale.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteAlpha", function(id:Int) {
					return notes.members[id].alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Int,y:Int, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].x = x;
					notes.members[id].y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].setGraphicSize(Std.int(notes.members[id].width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleX", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleY", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
					getActorByName(id).x = x;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Int,id:String) {
					getActorByName(id).alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
					getActorByName(id).y = y;
				}));
							
				trace(Lua_helper.add_callback(lua,"setActorAngle", function(angle:Int,id:String) {
					getActorByName(id).angle = angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
					getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleX", function(scale:Float,id:String) {
					getActorByName(id).scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleY", function(scale:Float,id:String) {
					getActorByName(id).scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
					return getActorByName(id).width;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
					return getActorByName(id).height;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
					return getActorByName(id).alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
					return getActorByName(id).angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorX", function (id:String) {
					return getActorByName(id).x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorY", function (id:String) {
					return getActorByName(id).y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleX", function (id:String) {
					return getActorByName(id).scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleY", function (id:String) {
					return getActorByName(id).scale.y;
				}));

				// other stuff that idk would you want to use

				trace(Lua_helper.add_callback(lua,"makeTrace", function (daTrace:String) {
					trace("LUA: " + daTrace); //why would you do a trace?
				}));

				// sounds

				trace(Lua_helper.add_callback(lua,"playSound", function (sound:String, volume:Float) {
					FlxG.sound.play(Paths.sound(sound), volume);
				}));

				// gameplay

				trace(Lua_helper.add_callback(lua,"changeScrollSpeed", function (scroll:Float) {
					SONG.speed = scroll;
				}));

				trace(Lua_helper.add_callback(lua,"playAnimation", function (character:String, animationToPlay:String) {
					if (character == 'dad')
					{
						dad.playAnim(animationToPlay, true);
					}
					else if (character == 'boyfriend')
					{
						boyfriend.playAnim(animationToPlay, true);
					}
					else if (character == 'gf')
					{
						gf.playAnim(animationToPlay, true);
					}
				}));

				trace(Lua_helper.add_callback(lua,"switchCharacter", function (characterToReplace:String, character:String, X:Int = -66666, Y:Int = -66666) {

				if (characterToReplace == 'dad')
				{
					remove(dad);
					//-66666 == null
					if (X == -66666 || Y == -66666)
					{
						trace("LUA: Warning! X or Y positions are not provided! The new character will be place at the same location as before.");
						dad = new Character(dad.x, dad.y, character);
					}
					else
					{
						dad = new Character(X, Y, character);
					}
					add(dad);
					SONG.player2 = character;
					remove(iconP2);
					iconP2 = new HealthIcon(SONG.player2, false);
					iconP2.y = healthBar.y - (iconP2.height / 2);
					iconP2.cameras = [camHUD];
					add(iconP2);
					SONG.player2 = player2BeforeChanges;

				}
				else if (characterToReplace == 'boyfriend')
				{
					remove(boyfriend);
					if (X == -66666 || Y == -66666)
					{
						trace("LUA: Warning! X or Y positions are not provided! The new character will be place at the same location as before.");
						boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, character);
					}
					else
					{
						boyfriend = new Boyfriend(X, Y, character);
					}
					add(boyfriend);
					SONG.player1 = character;
					remove(iconP1);
					iconP1 = new HealthIcon(SONG.player1, false);
					iconP1.y = healthBar.y - (iconP1.height / 2);
					iconP1.cameras = [camHUD];
					add(iconP1);
					SONG.player1 = player1BeforeChanges;
				}
				else if (characterToReplace == 'gf')
				{
					remove(gf);
					if (X == -66666 || Y == -66666)
					{
						trace("LUA: Warning! X or Y positions are not provided! The new character will be place at the same location as before.");
						gf = new Character(gf.x, gf.y, character);
					}
					else
					{
						gf = new Character(X, Y, character);
					}
					add(gf);
				}
				else
				{
					trace("LUA: Invalid character to replace provided!");
				}

				}));
	
				// tweens
				
				Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});

				Lua_helper.add_callback(lua,"tweenCamZoom", function(zoom:Float, duration:Float) {
					FlxTween.tween(FlxG.camera, {zoom: zoom}, duration, {ease: FlxEase.expoOut,});
				});
	
				Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				for (i in 0...strumLineNotes.length) {
					var member = strumLineNotes.members[i];
					trace(strumLineNotes.members[i].x + " " + strumLineNotes.members[i].y + " " + strumLineNotes.members[i].angle + " | strum" + i);
					//setVar("strum" + i + "X", Math.floor(member.x));
					setVar("defaultStrum" + i + "X", Math.floor(member.x));
					//setVar("strum" + i + "Y", Math.floor(member.y));
					setVar("defaultStrum" + i + "Y", Math.floor(member.y));
					//setVar("strum" + i + "Angle", Math.floor(member.angle));
					setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
					trace("Adding strum" + i);
				}
	
				trace('calling start function');
	
				trace('return: ' + Lua.tostring(lua,callLua('start', [PlayState.SONG.song])));
			}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle', true);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('normal', ['ready.png', "set.png", "go.png"]);
			introAssets.set('pixel', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);
			#if !(android)
			for (field in CoolUtil.coolTextFile('assets/data/uitypes.txt')) {
				if (field != 'pixel' && field != 'normal') {
					#if android
					if (FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						introAssets.set(field, ['custom_ui/ui_packs/'+field+'/ready-pixel.png','custom_ui/ui_packs/'+field+'/set-pixel.png','custom_ui/ui_packs/'+field+'/date-pixel.png']);
					else
						introAssets.set(field, ['custom_ui/ui_packs/'+field+'/ready.png','custom_ui/ui_packs/'+field+'/set.png','custom_ui/ui_packs/'+field+'/go.png']);
					#else
					if (FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						introAssets.set(field, ['custom_ui/ui_packs/'+field+'/ready-pixel.png','custom_ui/ui_packs/'+field+'/set-pixel.png','custom_ui/ui_packs/'+field+'/date-pixel.png']);
					else
						introAssets.set(field, ['custom_ui/ui_packs/'+field+'/ready.png','custom_ui/ui_packs/'+field+'/set.png','custom_ui/ui_packs/'+field+'/go.png']);
					#end
				}
			}
			#end

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var intro3Sound:Sound;
			var intro2Sound:Sound;
			var intro1Sound:Sound;
			var introGoSound:Sound;
			for (value in introAssets.keys())
				{
					if (value == SONG.uiType)
					{
						introAlts = introAssets.get(value);
						// ok so apparently a leading slash means absolute soooooo
						#if android
						if (SONG.uiType == 'pixel' || FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#else
						if (SONG.uiType == 'pixel' || FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#end
							altSuffix = '-pixel';
					}
				}	
				if (SONG.uiType == 'normal') {
					intro3Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro3.ogg')));
					intro2Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro2.ogg')));
					intro1Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro1.ogg')));
					introGoSound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/introGo.ogg')));
				} else if (SONG.uiType == 'pixel') {
					intro3Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro3-pixel.ogg')));
					intro2Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro2-pixel.ogg')));
					intro1Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/intro1-pixel.ogg')));
					introGoSound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(Assets.getBytes('assets/sounds/introGo-pixel.ogg')));
				} else {
					// god is dead for we have killed him
					intro3Sound = Sound.fromFile("assets/images/custom_ui/ui_packs/"+SONG.uiType+'/intro3'+altSuffix+'.ogg');
					intro2Sound = Sound.fromFile("assets/images/custom_ui/ui_packs/"+SONG.uiType+'/intro2'+altSuffix+'.ogg');
					intro1Sound = Sound.fromFile("assets/images/custom_ui/ui_packs/"+SONG.uiType+'/intro1'+altSuffix+'.ogg');
					// apparently this crashes if we do it from audio buffer?
					// no it just understands 'hey that file doesn't exist better do an error'
					introGoSound = Sound.fromFile("assets/images/custom_ui/ui_packs/"+SONG.uiType+'/introGo'+altSuffix+'.ogg');
				}
				switch (swagCounter)

				{
					case 0:
						FlxG.sound.play(intro3Sound, 0.6);
					case 1:
						// my life is a lie, it was always this simple
						#if android
						var readyImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/'+introAlts[0]);
						#else
						var readyImage = BitmapData.fromFile('assets/images/'+introAlts[0]);
						#end
						var ready:FlxSprite = new FlxSprite().loadGraphic(readyImage);
						ready.scrollFactor.set();
						ready.updateHitbox();
	
						#if android
						if (SONG.uiType == 'pixel' || FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#else
						if (SONG.uiType == 'pixel' || FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#end
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
	
						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(intro2Sound, 0.6);
					case 2:
						#if android
						var setImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/'+introAlts[1]);
						#else
						var setImage = BitmapData.fromFile('assets/images/'+introAlts[1]);
						#end
						// can't believe you can actually use this as a variable name
						var set:FlxSprite = new FlxSprite().loadGraphic(setImage);
						set.scrollFactor.set();
	
						#if android
						if (SONG.uiType == 'pixel' || FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#else
						if (SONG.uiType == 'pixel' || FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#end
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
	
						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(intro1Sound, 0.6);
					case 3:
						#if android
						var goImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/'+introAlts[2]);
						#else
						var goImage = BitmapData.fromFile('assets/images/'+introAlts[2]);
						#end
						var go:FlxSprite = new FlxSprite().loadGraphic(goImage);
						go.scrollFactor.set();
	
						#if android
						if (SONG.uiType == 'pixel' || FileSystem.exists(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#else
						if (SONG.uiType == 'pixel' || FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/arrows-pixels.png"))
						#end
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
	
						go.updateHitbox();
	
						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(introGoSound, 0.6);
					case 4:
						// what is this here for?
				}
	

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	public function clearNotesBefore(time:Float)
		{
			var i:Int = unspawnNotes.length - 1;
			while (i >= 0) {
				var daNote:Note = unspawnNotes[i];
				if(daNote.strumTime - 500 < time)
				{
					daNote.active = false;
					daNote.visible = false;
	
					daNote.kill();
					unspawnNotes.remove(daNote);
					daNote.destroy();
				}
				--i;
			}
	
			i = notes.length - 1;
			while (i >= 0) {
				var daNote:Note = notes.members[i];
				if(daNote.strumTime - 500 < time)
				{
					daNote.active = false;
					daNote.visible = false;
	
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				--i;
			}
		}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	public static var songMultiplier = 1.0;
	public var previousRate = songMultiplier;

	public static var playstateVideoPath:String;

	public static function playVideo(videoPath:String):Void
	{
		#if windows
		FlxG.switchState(new FurretEngineMP4Handler());
		playstateVideoPath = videoPath;
		FurretEngineMP4Handler.playCutscene(videoPath);
		#else
		trace("this isn't windows, function ignored");
		#end
	}

	public static function parseJSONshit(videoCutsceneJson:String):VideoJsonPath
	{
		var swagShit:VideoJsonPath = cast CoolUtil.parseJson(videoCutsceneJson);
		return swagShit;
	}

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if android
			FlxG.sound.playMusic(Sound.fromFile(BootUpCheck.getPath() + 'assets/music/' + curSong + "_Inst.ogg"), 1, false);
			#else
			FlxG.sound.playMusic(Sound.fromFile(Paths.inst(PlayState.SONG.song)), 1, false);
			#end
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.YELLOW);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		if (cpuControlled)
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: N/A | Score: N/A | Misses: N/A [!] BOTPLAY");
		}
		else
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		}
		#end
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);

		}
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			#if android
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(BootUpCheck.getPath() + 'assets/music/' + curSong + "_Voices.ogg"));
			#else
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(PlayState.SONG.song)));
			#end
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if desktop
			var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (sys.FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', curSong.toLowerCase()).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push(songNotes.copy());
						eventNote();
					}
				}
			}
		}
		var customImage:Null<BitmapData> = null;
		var customXml:Null<String> = null;
		var arrowEndsImage:Null<BitmapData> = null;
		if (SONG.uiType != 'normal' && SONG.uiType != 'pixel') {
			#if android
			if (FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/NOTE_assets.xml") && FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/NOTE_assets.png")) {
				trace("has this been reached");
				customImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+'/NOTE_assets.png');
				#if android
				customXml = File.getContent(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+'/NOTE_assets.xml');
				#else
				customXml = File.getContent(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+'/NOTE_assets.xml');
				#end
			} else {
				customImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+'/arrows-pixels.png');
				arrowEndsImage = BitmapData.fromFile(BootUpCheck.getPath() + 'assets/images/custom_ui/ui_packs/'+SONG.uiType+'/arrowEnds.png');
			}
			#else
			if (FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/NOTE_assets.xml") && FileSystem.exists('assets/images/custom_ui/ui_packs/'+SONG.uiType+"/NOTE_assets.png")) {
				trace("has this been reached");
				customImage = BitmapData.fromFile('assets/images/custom_ui/ui_packs/'+SONG.uiType+'/NOTE_assets.png');
				customXml = File.getContent('assets/images/custom_ui/ui_packs/'+SONG.uiType+'/NOTE_assets.xml');
			} else {
				customImage = BitmapData.fromFile('assets/images/custom_ui/ui_packs/'+SONG.uiType+'/arrows-pixels.png');
				arrowEndsImage = BitmapData.fromFile('assets/images/custom_ui/ui_packs/'+SONG.uiType+'/arrowEnds.png');
			}
			#end
		}
		for (section in noteData)
		{
			var mn:Int = keyAmmo[mania]; //new var to determine max notes
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % mn);

					var gottaHitNote:Bool = section.mustHitSection;
	
					if (songNotes[1] >= mn)
					{
						gottaHitNote = !section.mustHitSection;
					}
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, customImage, customXml, arrowEndsImage);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
					
						sustainNote.mustPress = gottaHitNote;
					
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else
						{
							sustainNote.strumTime -= FlxG.save.data.offset;
						}
					}
			
					swagNote.mustPress = gottaHitNote;
	
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
				} else { //Event Notes
					eventNotes.push(songNotes.copy());
					eventNote();
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		// to get around how pecked up the note system is

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		generatedMusic = true;
	}

	function eventNote() {
		var value:Int = eventNotes.length-1;
		switch(eventNotes[value][2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				eventNotes[value][0] -= 280; //Plays 280ms before the actual position
		}
		eventNotes[value][0] += 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int):Void
	{var flippedNotes = false;
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (SONG.uiType)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

					var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					var pPre:Array<String> = ['left', 'down', 'up', 'right'];
					switch (mania)
					{
						case 1:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
						case 2:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
							babyArrow.x -= Note.tooMuch;
						case 3:
							nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'white', 'up', 'right'];
						case 4:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
						case 5:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'yel', 'violet', 'black', 'dark'];
							babyArrow.x -= Note.tooMuch;
						case 6:
							nSuf = ['SPACE'];
							pPre = ['white'];
						case 7:
							nSuf = ['LEFT', 'RIGHT'];
							pPre = ['left', 'right'];
						case 8:
							nSuf = ['LEFT', 'SPACE', 'RIGHT'];
							pPre = ['left', 'white', 'right'];
					}
					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
					babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

					var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					var pPre:Array<String> = ['left', 'down', 'up', 'right'];
					switch (mania)
					{
						case 1:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
						case 2:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
							babyArrow.x -= Note.tooMuch;
						case 3:
							nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'white', 'up', 'right'];
						case 4:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
						case 5:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'yel', 'violet', 'black', 'dark'];
							babyArrow.x -= Note.tooMuch;
						case 6:
							nSuf = ['UP'];
							pPre = ['UP'];
						case 7:
							nSuf = ['LEFT', 'RIGHT'];
							pPre = ['left', 'right'];
						case 8:
							nSuf = ['LEFT', 'SPACE', 'RIGHT'];
							pPre = ['left', 'white', 'right'];
					}
					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
					babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			if (FlxG.save.data.middlescroll && player == 1)
				babyArrow.x -= 275;
			if (FlxG.save.data.middlescroll && player == 0)
				babyArrow.alpha = 0;

			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			if (cpuControlled)
			{
				DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + "[!] BOTPLAY", null);
			}
			else
			{
				DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			}
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				if (cpuControlled)
				{
					DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: N/A | Score: N/A | Misses: N/A [!] BOTPLAY");
				}
				else
				{
					DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
				}
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);

		}

		#if windows
		if (cpuControlled)
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: N/A | Score: N/A | Misses: N/A [!] BOTPLAY");
		}
		else
		{
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		}
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	function generateRanking():String
	{
		var ranking:String = "N/A";

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (misses == 0) // Regular FC
			ranking = "(FC)";
		else if (misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 100, // GOD
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for(i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch(i)
				{
					case 0:
						ranking += " GOD";
					case 1:
						ranking += " AAAAA";
					case 2:
						ranking += " AAAA:";
					case 3:
						ranking += " AAAA.";
					case 4:
						ranking += " AAAA";
					case 5:
						ranking += " AAA:";
					case 6:
						ranking += " AAA.";
					case 7:
						ranking += " AAA";
					case 8:
						ranking += " AA:";
					case 9:
						ranking += " AA.";
					case 10:
						ranking += " AA";
					case 11:
						ranking += " A:";
					case 12:
						ranking += " A.";
					case 13:
						ranking += " A";
					case 14:
						ranking += " B";
					case 15:
						ranking += " C";
					case 16:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
		if (loadHScript)
		{
			callAllHScript('update', [elapsed]);
			setHaxeVar('curStep', curStep, 'interp');
			setHaxeVar('health', health, 'interp');
			interp.variables.set("curBeat", curBeat);
			interp.variables.set("score", songScore);
			interp.variables.set("misses", misses);
			interp.variables.set("combo", combo);
			interp.variables.set("accuracy", truncateFloat(accuracy, 2));
			interp.variables.set("ranking", generateRanking());
		}
		setAllHaxeVar('camZooming', camZooming);
		setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);
		setAllHaxeVar('curStep', curStep);
		
		elapsedtime += elapsed;
		if (curbg != null)
		{
			if (curbg.active) //3d stage stuff
			{
				var shad = cast(curbg.shader, Shaders.GlitchShader);
				shad.uTime.value[0] += elapsed;
			}
		}

		if (songScore > 1)
		{
			scoreBG.height = 92;
		}

		if(Character.is3d)
		{
			dad.y += (Math.sin(elapsedtime) * 0.6);
		}
		if(Character.is3d)
		{
			boyfriend.y += (Math.sin(elapsedtime) * 0.6);
		}
		/*if(funnyFloatyBoys.contains(dadmirror.curCharacter.toLowerCase()))
		{
			dadmirror.y += (Math.sin(elapsedtime) * 0.6);
		}*/
		if(Character.is3d)
		{
			gf.y += (Math.sin(elapsedtime) * 0.6);
		}

		if(controls.RESET && FlxG.save.data.resetKey){
			FlxG.resetState();
		}
		if (FlxG.save.data.middlescroll)
		{
			for (i in 0...keyAmmo[mania])
			{
				strumLineNotes.members[i].visible = false;
			}
		}
		#if !debug
		perfectMode = false;
		#end
		
		if (cpuControlled)
		{
			songScore = 0; //lol not today
		}

		#if windows
		if (executeModchart && lua != null && songStarted)
		{
			setVar('songPos',Conductor.songPosition);
			setVar('hudZoom', camHUD.zoom);
			setVar('cameraZoom',FlxG.camera.zoom);
			callLua('update', [elapsed]);

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = getVar("strum" + i + "X", "float");
				member.y = getVar("strum" + i + "Y", "float");
				member.angle = getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = getVar('cameraAngle', 'float');
			camHUD.angle = getVar('camHudAngle','float');

			if (getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = getVar("strumLine1Visible",'bool');
			var p2 = getVar("strumLine2Visible",'bool');

			for (i in 0...keyAmmo[mania])
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for(i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (!offsetTesting)
		{
			if (FlxG.save.data.accuracyDisplay)
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + (Conductor.safeFrames != 10 ? songScore + " (" + songScoreDef + ")" : "" + songScore) + " // Misses:" + misses + " // Accuracy:" + truncateFloat(accuracy, 2) + "% // Ranking: " + generateRanking();
			}
			else
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + songScore;
			}

		if (cpuControlled)
		{
			scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:0 [BOTPLAY] // Misses:" + misses + " // Accuracy:N/A";
		}

		}
		else
		{
			scoreTxt.text = "Suggested Offset: " + offsetTest;

		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			songMultiplier = 1;
			#if windows
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (FlxG.save.data.changejudgementcolors)
		{
			if (healthBar.percent < 20)
			{
				//FlxColor.fromRGB(255, 64, 64)
				scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 64, 64), 0.3);
				iconP1.animation.curAnim.curFrame = 1;
				if(iconP2.animation.curAnim.numFrames == 3)
					iconP2.animation.curAnim.curFrame = 2;
			}
			else if (healthBar.percent > 80)
			{
				//FlxColor.fromRGB(100, 255, 100)
				scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(100, 255, 100), 0.3);
				iconP2.animation.curAnim.curFrame = 1;
				if(iconP1.animation.curAnim.numFrames == 3)
					iconP1.animation.curAnim.curFrame = 2;
			}
			else
			{
				iconP1.animation.curAnim.curFrame = 0;
				iconP2.animation.curAnim.curFrame = 0;
				scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 255, 255), 0.3);
			}
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */


		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			#if windows
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
			#end
		}
		
	

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)] != null)
			{
				// Make sure Girlfriend cheers only for certain songs
				if(allowedToHeadbang)
				{
					// Don't animate GF if something else is already animating her (eg. train passing)
					if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
					{
						// Per song treatment since some songs will only have the 'Hey' at certain times
						switch(curSong)
						{
							case 'Philly':
							{
								// General duration of the song
								if(curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if(curBeat != 184 && curBeat != 216)
									{
										if(curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if(!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}else triggeredAlready = false;
									}
								}
							}
							case 'Bopeebo':
							{
								// Where it starts || where it ends
								if(curBeat > 5 && curBeat < 130)
								{
									if(curBeat % 8 == 7)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
							case 'Blammed':
							{
								if(curBeat > 30 && curBeat < 190)
								{
									if(curBeat < 90 || curBeat > 128)
									{
										if(curBeat % 4 == 2)
										{
											if(!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}else triggeredAlready = false;
									}
								}
							}
							case 'Cocoa':
							{
								if(curBeat < 170)
								{
									if(curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if(curBeat % 16 == 15)
										{
											if(!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}else triggeredAlready = false;
									}
								}
							}
							case 'Eggnog':
							{
								if(curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if(curBeat % 8 == 7)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
					}
				}
				
				if (generatedMusic && PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)] != null)
					{
						setAllHaxeVar("mustHit", PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)].mustHitSection);
						if (curBeat % 4 == 0)
						{
							// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
						}
			
						if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)].mustHitSection)
						{
							camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
							// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
							if (dad.like == 'mom')
								camFollow.y = dad.getMidpoint().y;
							if (dad.like == 'senpai' || dad.like == 'senpai-angry') {
								camFollow.y = dad.getMidpoint().y - 430;
								camFollow.x = dad.getMidpoint().x - 100;
							}
							if (dad.isCustom) {
								camFollow.y = dad.getMidpoint().y + dad.followCamY;
								camFollow.x = dad.getMidpoint().x + dad.followCamX;
							}
							camFollow.x+=dadCameraOffsetX;
							camFollow.y+=dadCameraOffsetY;
							vocals.volume = 1;
			
							if (SONG.song.toLowerCase() == 'tutorial')
							{
								tweenCamIn();
							}
						}
			
						if (PlayState.SONG.notes[Std.int((curStep / 16) / songMultiplier)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
						{
							camFollow.setPosition((boyfriend.getMidpoint().x - 100), (boyfriend.getMidpoint().y - 100));
			
							switch (curStage)
							{
								// not sure that's how variable assignment works
								case 'limo':
									((camFollow.x = boyfriend.getMidpoint().x - 300) + boyfriend.followCamX); // why are you hard coded
								case 'mall':
									((camFollow.y = boyfriend.getMidpoint().y - 200) + boyfriend.followCamY);
								case 'school':
									((camFollow.x = boyfriend.getMidpoint().x - 200) + boyfriend.followCamX);
									((camFollow.y = boyfriend.getMidpoint().y - 200) + boyfriend.followCamY);
								case 'schoolEvil':
									((camFollow.x = boyfriend.getMidpoint().x - 200) + boyfriend.followCamX);
									((camFollow.y = boyfriend.getMidpoint().y - 200) + boyfriend.followCamY);
							}
			
							if (boyfriend.isCustom) {
								camFollow.y = boyfriend.getMidpoint().y + boyfriend.followCamY;
								camFollow.x = boyfriend.getMidpoint().x + boyfriend.followCamX;
			
							}
							 camFollow.x+=bfCameraOffsetX;
							camFollow.y+=bfCameraOffsetY;
							if (SONG.song.toLowerCase() == 'tutorial')
							{
								FlxTween.tween(FlxG.camera, {zoom: 1}, ((Conductor.stepCrochet * 4 / 1000) / songMultiplier), {ease: FlxEase.elasticInOut});
							}
						}
					}
			}
			if (camZooming)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
			{
				FlxG.watch.addQuick('rep rpesses',repPresses);
				FlxG.watch.addQuick('rep releases',repReleases);
				// FlxG.watch.addQuick('Queued',inputsQueued);
			}

		if (unspawnNotes[0] != null)
			{
				var time:Float = 3000;//shit be werid on 4:3
	
				while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
				{
					var dunceNote:Note = unspawnNotes[0];
					notes.insert(0, dunceNote);
	
					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
				}
			}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (!cpuControlled && health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(),"\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
	
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
	
		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
			{
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
				if (vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
	
			}
		#end

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = "";
	
						if (SONG.notes[Math.floor((curStep / 16) / songMultiplier)] != null)
							{
								if ((SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnimNum > 0 && SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnimNum != null) || SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnim)
									// backwards compatibility shit
									if (SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnimNum == 1 || SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnim)
										altAnim = '-alt';
									else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum != 0)
										altAnim = '-' + SONG.notes[Math.floor((curStep / 16) / songMultiplier)].altAnimNum+'alt';
							}
						if(Character.shakeWhenSing)
							{
								FlxG.camera.shake(0.0075, 0.1);
								camHUD.shake(0.0045, 0.1);
							}
	
						if (mania == 0)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 2:
										dad.playAnim('singUP' + altAnim, true);
									case 3:
										dad.playAnim('singRIGHT' + altAnim, true);
									case 1:
										dad.playAnim('singDOWN' + altAnim, true);
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
								}
							}
							else if (mania == 1)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 1:
										dad.playAnim('singUP' + altAnim, true);
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 2:
										dad.playAnim('singRIGHT' + altAnim, true);
									case 3:
										dad.playAnim('singLEFT' + altAnim, true);
									case 4:
										dad.playAnim('singDOWN' + altAnim, true);
									case 5:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 2)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 1:
										dad.playAnim('singDOWN' + altAnim, true);
									case 2:
										dad.playAnim('singUP' + altAnim, true);
									case 3:
										dad.playAnim('singRIGHT' + altAnim, true);
									case 4:
										dad.playAnim('singUP' + altAnim, true);
									case 5:
										dad.playAnim('singLEFT' + altAnim, true);
									case 6:
										dad.playAnim('singDOWN' + altAnim, true);
									case 7:
										dad.playAnim('singUP' + altAnim, true);
									case 8:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 3)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 1:
										dad.playAnim('singDOWN' + altAnim, true);
									case 2:
										dad.playAnim('singUP' + altAnim, true);
									case 3:
										dad.playAnim('singUP' + altAnim, true);
									case 4:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 4)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 1:
										dad.playAnim('singUP' + altAnim, true);
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 2:
										dad.playAnim('singRIGHT' + altAnim, true);
									case 3:
										dad.playAnim('singUP' + altAnim, true);
									case 4:
										dad.playAnim('singLEFT' + altAnim, true);
									case 5:
										dad.playAnim('singDOWN' + altAnim, true);
									case 6:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 5)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 1:
										dad.playAnim('singDOWN' + altAnim, true);
									case 2:
										dad.playAnim('singUP' + altAnim, true);
									case 3:
										dad.playAnim('singRIGHT' + altAnim, true);
									case 4:
										dad.playAnim('singLEFT' + altAnim, true);
									case 5:
										dad.playAnim('singDOWN' + altAnim, true);
									case 6:
										dad.playAnim('singUP' + altAnim, true);
									case 7:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 6)
							{
								switch(Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singUP' + altAnim, true);
								}
							}
							else if (mania == 7)
							{
								switch(Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 1:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else if (mania == 8)
							{
								switch(Math.abs(daNote.noteData))
								{
									case 0:
										dad.playAnim('singLEFT' + altAnim, true);
									case 1:
										dad.playAnim('singUP' + altAnim, true);
									case 2:
										dad.playAnim('singRIGHT' + altAnim, true);
								}
							}

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}
	
						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;

						callAllHScript('opponentNoteHit', [Math.abs(daNote.noteData)]);

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (spr.animation.finished)
							{
								spr.animation.play('static');
								spr.centerOffsets();
							}
						});
					}

					if (cpuControlled)
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (spr.animation.finished)
								{
									spr.animation.play('static');
									spr.centerOffsets();
								}
							});
						}

					if(cpuControlled) {
						boyfriend.holdTimer = daNote.sustainLength;
					}
	
					if (FlxG.save.data.downscroll)
						daNote.y = (strumLine.y - ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (-0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));
					else
						daNote.y = (strumLine.y - ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll) && daNote.mustPress)
					{

							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
							else
							{
								if (!cpuControlled)
								health -= 0.075;
								vocals.volume = 0;

								noteMiss(daNote.noteData);
							}

							if (!cpuControlled) {
								daNote.active = false;
								daNote.visible = false;
			
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
						
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}

		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime) {
				break;
			}
	
			var value1:Dynamic = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];
	
			var value2:Dynamic = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];
	
			switch(eventNotes[0][2]) {
				case 'Hey!':
					var value:Int = Std.parseInt(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(time) || time <= 0) time = 0.6;
	
					if(value != 0) {
						if(dad.curCharacter == 'gf') { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
							dad.playAnim('cheer', true);
						} else {
							gf.playAnim('cheer', true);
						}
	
						if(curStage == 'mall') {
							bottomBoppers.animation.play('hey', true);
						}
					}
					if(value != 1) {
						boyfriend.playAnim('hey', true);
					}
	
				case 'Set GF Speed':
					var value:Int = Std.parseInt(value1);
					if(Math.isNaN(value)) value = 1;
					gfSpeed = value;
				case 'Add Camera Zoom':
					if(FlxG.camera.zoom < 1.35) {
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;
	
						FlxG.camera.zoom += camZoom / songMultiplier;
						camHUD.zoom += hudZoom / songMultiplier;
					}
				case 'Play Animation':
					var daCharacter:Character = dad;
					if (value2 == 'bf' || value2 == 'boyfriend')
					{
						daCharacter = boyfriend;
					}
					else if (value2 == 'gf' || value2 == 'girlfriend')
					{
						daCharacter = gf;
					}
					else if (value2 == 'dad')
					{
						daCharacter = dad;
					}
					else
					{
						trace("[!] No character specified, no animation will be played");
					}
					daCharacter.playAnim(value1, true);
				case 'Screen Shake':
					var values:Array<String> = [value1, value2];
					var cameras:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...cameras.length)
					{
						var daSplit:Array<String> = values[i].split(',');
						var intensity:Float = 0;
						var duration:Float = 0;
						if(daSplit[0] != null) duration = Std.parseFloat(daSplit[0].trim());
						if(daSplit[1] != null) intensity = Std.parseFloat(daSplit[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;

						if(duration > 0 && intensity != 0) {
							cameras[i].shake(intensity, duration);
						}
					}
				case 'Switch Character':
					switch(value1.toLowerCase())
					{
						case 'dad':
							remove(dad);
							dad = new Character(dad.x, dad.y, value2);
							add(dad);
							remove(iconP2);
							iconP2 = new HealthIcon(value2, false);
							iconP2.y = healthBar.y - (iconP2.height / 2);
							iconP2.cameras = [camHUD];
							add(iconP2);
						case 'bf' | 'boyfriend':
							remove(boyfriend);
							boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, value2);
							add(boyfriend);
							remove(iconP1);
							iconP1 = new HealthIcon(value2, false);
							iconP1.y = healthBar.y - (iconP1.height / 2);
							iconP1.cameras = [camHUD];
							add(iconP1);
						case 'gf' | 'girlfriend':
							remove(gf);
							gf = new Character(gf.x, gf.y, value2);
							add(gf);
					}
				case 'Screen Flash':
					var daDuration = Std.parseFloat(value2);
					switch(value1.toLowerCase())
					{
						case 'black':
						FlxG.camera.flash(FlxColor.BLACK, daDuration);
						case 'blue':
						FlxG.camera.flash(FlxColor.BLUE, daDuration);
						case 'brown':
						FlxG.camera.flash(FlxColor.BROWN, daDuration);
						case 'cyan':
						FlxG.camera.flash(FlxColor.CYAN, daDuration);
						case 'gray':
						FlxG.camera.flash(FlxColor.GRAY, daDuration);
						case 'green':
						FlxG.camera.flash(FlxColor.GREEN, daDuration);
						case 'lime':
						FlxG.camera.flash(FlxColor.LIME, daDuration);
						case 'magenta':
						FlxG.camera.flash(FlxColor.MAGENTA, daDuration);
						case 'orange':
						FlxG.camera.flash(FlxColor.ORANGE, daDuration);
						case 'pink':
						FlxG.camera.flash(FlxColor.PINK, daDuration);
						case 'purple':
						FlxG.camera.flash(FlxColor.PURPLE, daDuration);
						case 'red':
						FlxG.camera.flash(FlxColor.RED, daDuration);
						case 'transparent':
						FlxG.camera.flash(FlxColor.TRANSPARENT, daDuration);
						case 'white':
						FlxG.camera.flash(FlxColor.WHITE, daDuration);
						case 'yellow':
						FlxG.camera.flash(FlxColor.YELLOW, daDuration);
						default:
						trace("[!] Invalid color");
					}
				case 'Tween Camera Zoom':
					var zoom = Std.parseFloat(value1);
					var duration = Std.parseFloat(value2);
					FlxTween.tween(FlxG.camera, {zoom: value1}, value2, {ease: FlxEase.expoOut,});
				default: //custom event
					#if android
					var getScript = File.getContent(BootUpCheck.getPath() + "assets/events/" + eventNotes[0][2] + ".hx");
					#else
					var getScript = File.getContent("assets/events/" + eventNotes[0][2] + ".hx");
					#end
					var daScript:String = getScript;
					var daScriptParser = new hscript.Parser();
					var script = daScriptParser.parseString(daScript);
					setHaxeVar('value1', value1, 'eventInterp');
					setHaxeVar('value2', value2, 'eventInterp');
					trace("Custom event: " + eventNotes[0][2]);
					eventInterp.execute(script);
					
			}
			eventNotes.shift();
		}


		if (!inCutscene)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function specifyFlxGActions():Void {
		trace("[OK] FlxG loaded in the haxe state sucessfully!");
		//da functions
		interp.variables.set("getFullscreen", function()
		{
			return FlxG.fullscreen;
		});
		interp.variables.set("setFullscreen", function(tf:Bool)
		{
			return FlxG.fullscreen = tf;
		});
		interp.variables.set("justPressed", FlxG.keys.justPressed);
		interp.variables.set("pressed", FlxG.keys.pressed);
		interp.variables.set("justReleased", FlxG.keys.justReleased);
		interp.variables.set("resizeGame", function (Width:Int, Height:Int) {
			return FlxG.resizeGame(Width, Height);
		});
		interp.variables.set("resizeWindow", function (Width:Int, Height:Int) {
			return FlxG.resizeWindow(Width, Height);
		});
		interp.variables.set("openURL", function(url:String) {
			return FlxG.openURL(url);
		});
		interp.variables.set("execute", function(order:String) {
			return order;
		});
	}

	function endSong():Void
	{
		#if windows
		if (executeModchart)
		{
			Lua.close(lua);
			lua = null;
		}
		#end

		if (Character.is3d)
		{
			Character.is3d = false;
		}
		if (Character.shakeWhenSing)
		{
			Character.shakeWhenSing = false;
		}

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());
					#if windows
					if (lua != null)
					{
						Lua.close(lua);
						lua = null;
					}
					#end

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					var videoCutsceneJson:String = "";

					#if windows
					if(FileSystem.exists("assets/data/" + PlayState.SONG.song.toLowerCase() + "/video.txt"))
					{
						trace("A video txt file has been found, the cutscene will begin");
						var videoJsonContent:String;
						videoJsonContent = File.getContent("assets/data/" + PlayState.SONG.song.toLowerCase() + "/video.txt");
						playVideo(videoJsonContent);
					}
					#end

					trace(Paths.videojson(PlayState.SONG.song.toLowerCase()  + "/video"));

					/*switch(curSong.toLowerCase()) //just in case you want to hard code it, uncomment-it then change bopeebo with the name of your song
					{
						case 'bopeebo':
						playVideo('videopath');
					}*/

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + StoryMenuState.diffic, PlayState.storyPlaylist[0].toLowerCase());
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				#if android
				var parsed:Dynamic = CoolUtil.parseJson(File.getContent(BootUpCheck.getPath() + 'assets/data/freeplaySongJson.jsonc'));
				#else
				var parsed:Dynamic = CoolUtil.parseJson(File.getContent('assets/data/freeplaySongJson.jsonc'));
				#end

				if(parsed.length==1){
					FreeplayState.id = 0;
					FlxG.switchState(new FreeplayState());
				}else{
					FlxG.switchState(new FreeplayCategory());
				}
				cpuControlled = false;
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1){
				totalNotesHit += wife;
			}else if (FlxG.save.data.accuracyMod == 2){
				totalNotesHit+=1;
			}
			var daRating = daNote.rating;
			
				switch(daRating)
				{
					case 'shit':
						score = -300;
						health -= 0.2;
						ss = false;
						shits++;
						if (FlxG.save.data.accuracyMod == 0)
							totalNotesHit += 0.25;
					case 'bad':
						daRating = 'bad';
						score = 0;
						health -= 0.06;
						ss = false;
						bads++;
						if (FlxG.save.data.accuracyMod == 0)
							totalNotesHit += 0.50;
					case 'good':
						daRating = 'good';
						score = 200;
						ss = false;
						goods++;
						if (health < 2)
							health += 0.04;
						if (FlxG.save.data.accuracyMod == 0)
							totalNotesHit += 0.75;
					case 'sick':
						if (health < 2)
							health += 0.1;
						if (FlxG.save.data.accuracyMod == 0)
							totalNotesHit += 1;
						sicks++;
				}

			if (FlxG.save.data.noteSplashON)
			{
			var sploosh:FlxSprite = new FlxSprite(daNote.x, playerStrums.members[daNote.noteData].y);
			if (!curStage.startsWith('school'))
			{
				sploosh.frames = FlxAtlasFrames.fromSparrow('assets/images/noteSplashes.png', 'assets/images/noteSplashes.xml');
				sploosh.animation.addByPrefix('splash 0 0', 'note impact 1 purple', 24, false);
				sploosh.animation.addByPrefix('splash 0 1', 'note impact 1  blue', 24, false);
				sploosh.animation.addByPrefix('splash 0 2', 'note impact 1 green', 24, false);
				sploosh.animation.addByPrefix('splash 0 3', 'note impact 1 red', 24, false);
				sploosh.animation.addByPrefix('splash 1 0', 'note impact 2 purple', 24, false);
				sploosh.animation.addByPrefix('splash 1 1', 'note impact 2 blue', 24, false);
				sploosh.animation.addByPrefix('splash 1 2', 'note impact 2 green', 24, false);
				sploosh.animation.addByPrefix('splash 1 3', 'note impact 2 red', 24, false);
				if (mania == 0)
				{
					if (daRating == 'sick')
					{
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 0.6;
					sploosh.offset.x += 90;
					sploosh.offset.y += 80;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
					}
				}
			}
			}
			
			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
	
			
			var msTiming = truncateFloat(noteDiff / songMultiplier, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (FlxG.save.data.hidenotehittime)
			{
				add(currentTimingShown);
				currentTimingShown.visible = false;
			}
			else
			{
				add(currentTimingShown);
			}
			
			


			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		var l1Hold:Bool = false;
		var uHold:Bool = false;
		var r1Hold:Bool = false;
		var l2Hold:Bool = false;
		var dHold:Bool = false;
		var r2Hold:Bool = false;

		var a0Hold:Bool = false;
		var a1Hold:Bool = false;
		var a2Hold:Bool = false;
		var a3Hold:Bool = false;
		var a4Hold:Bool = false;
		var a5Hold:Bool = false;
		var a6Hold:Bool = false;

		var n0Hold:Bool = false;
		var n1Hold:Bool = false;
		var n2Hold:Bool = false;
		var n3Hold:Bool = false;
		var n4Hold:Bool = false;
		var n5Hold:Bool = false;
		var n6Hold:Bool = false;
		var n7Hold:Bool = false;
		var n8Hold:Bool = false;

		var reachBeat:Float;

	private function keyShit():Void
	{
		// HOLDING
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var l1 = controls.L1;
		var u = controls.U1;
		var r1 = controls.R1;
		var l2 = controls.L2;
		var d = controls.D1;
		var r2 = controls.R2;

		var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;

		var l1R = controls.L1_R;
		var uR = controls.U1_R;
		var r1R = controls.R1_R;
		var l2R = controls.L2_R;
		var dR = controls.D1_R;
		var r2R = controls.R2_R;

		var a0 = controls.A0;
		var a1 = controls.A1;
		var a2 = controls.A2;
		var a3 = controls.A3;
		var a4 = controls.A4;
		var a5 = controls.A5;
		var a6 = controls.A6;

		var a0P = controls.A0_P;
		var a1P = controls.A1_P;
		var a2P = controls.A2_P;
		var a3P = controls.A3_P;
		var a4P = controls.A4_P;
		var a5P = controls.A5_P;
		var a6P = controls.A6_P;

		var a0R = controls.A0_R;
		var a1R = controls.A1_R;
		var a2R = controls.A2_R;
		var a3R = controls.A3_R;
		var a4R = controls.A4_R;
		var a5R = controls.A5_R;
		var a6R = controls.A6_R;


		var n0 = controls.N0;
		var n1 = controls.N1;
		var n2 = controls.N2;
		var n3 = controls.N3;
		var n4 = controls.N4;
		var n5 = controls.N5;
		var n6 = controls.N6;
		var n7 = controls.N7;
		var n8 = controls.N8;

		var n0P = controls.N0_P;
		var n1P = controls.N1_P;
		var n2P = controls.N2_P;
		var n3P = controls.N3_P;
		var n4P = controls.N4_P;
		var n5P = controls.N5_P;
		var n6P = controls.N6_P;
		var n7P = controls.N7_P;
		var n8P = controls.N8_P;

		var n0R = controls.N0_R;
		var n1R = controls.N1_R;
		var n2R = controls.N2_R;
		var n3R = controls.N3_R;
		var n4R = controls.N4_R;
		var n5R = controls.N5_R;
		var n6R = controls.N6_R;
		var n7R = controls.N7_R;
		var n8R = controls.N8_R;

		if (cpuControlled)
		{
			up = false; //UP;
			right = false; //RIGHT;
			down = false; //DOWN;
			left = false; //LEFT;
	
			upP = false; //UP_P;
			rightP = false; //RIGHT_P;
			downP = false; //DOWN_P;
			leftP = false; //LEFT_P;
	
			upR = false; //UP_R;
			rightR = false; //RIGHT_R;
			downR = false; //DOWN_R;
			leftR = false; //LEFT_R;
	
			l1 = false; //L1;
			u = false; //U1;
			r1 = false; //R1;
			l2 = false; //L2;
			d = false; //D1;
			r2 = false; //R2;
	
			l1P = false; //L1_P;
			uP = false; //U1_P;
			r1P = false; //R1_P;
			l2P = false; //L2_P;
			dP = false; //D1_P;
			r2P = false; //R2_P;
	
			l1R = false; //L1_R;
			uR = false; //U1_R;
			r1R = false; //R1_R;
			l2R = false; //L2_R;
			dR = false; //D1_R;
			r2R = false; //R2_R;
	
	
			n0 = false; //N0;
			n1 = false; //N1;
			n2 = false; //N2;
			n3 = false; //N3;
			n4 = false; //N4;
			n5 = false; //N5;
			n6 = false; //N6;
			n7 = false; //N7;
			n8 = false; //N8;
	
			n0P = false; //N0_P;
			n1P = false; //N1_P;
			n2P = false; //N2_P;
			n3P = false; //N3_P;
			n4P = false; //N4_P;
			n5P = false; //N5_P;
			n6P = false; //N6_P;
			n7P = false; //N7_P;
			n8P = false; //N8_P;
	
			n0R = false; //N0_R;
			n1R = false; //N1_R;
			n2R = false; //N2_R;
			n3R = false; //N3_R;
			n4R = false; //N4_R;
			n5R = false; //N5_R;
			n6R = false; //N6_R;
			n7R = false; //N7_R;
			n8R = false; //N8_R;
		}
		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input


			//if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			//timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			//timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);

			
			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "up";
				rightP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "right";
				downP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "down";
				leftP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "left";	

				upR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "up";
				rightR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition  && rep.replay.keyReleases[repReleases].key == "right";
				downR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "down";
				leftR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep) // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		// FlxG.watch.addQuick('asdfa', upP);
		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (l1P || uP || r1P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, l2P, dP, r2P];
		}
		else if (mania == 2)
		{
			ankey = (n0P || n1P || n2P || n3P || n4P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n4P, n5P, n6P, n7P, n8P];
		}
		else if (mania == 3)
		{
			ankey = (leftP || downP || n4P || upP || rightP);
			controlArray = [leftP, downP, n4P, upP, rightP];
		}
		else if (mania == 4)
		{
			ankey = (l1P || uP || r1P || n4P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, n4P, l2P, dP, r2P];
		}
		else if (mania == 5)
		{
			ankey = (n0P || n1P || n2P || n3P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n5P, n6P, n7P, n8P];
		}
		else if (mania == 6)
		{
			ankey = (n4P);
			controlArray = [n4P];
		}
		else if (mania == 7)
		{
			ankey = (leftP || rightP);
			controlArray = [leftP, rightP];
		}
		else if (mania == 8)
		{
			ankey = (leftP || n4P || rightP);
			controlArray = [leftP, n4P, rightP];
		}
		// FlxG.watch.addQuick('asdfa', upP);
		if (ankey && !boyfriend.stunned && generatedMusic)
			{
				repPresses++;
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
				});
	
				
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{

								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
									if (!inIgnoreList && !isNew){
										badNoteCheck();		
									}					
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition / songMultiplier);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
									{
										if (NearlyEquals(coolNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
										{
											var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition / songMultiplier);

											if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
												coolNote.rating = "shit";
											else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
												coolNote.rating = "bad";
											else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
												coolNote.rating = "good";
											else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
												coolNote.rating = "sick";
											goodNoteHit(coolNote);
											trace('force note hit');
										}
										else
											noteCheck(controlArray, daNote);
									}
								else
									noteCheck(controlArray, coolNote);
							}
						}
					}
					else // regular notes?
					{	
						if (loadRep)
						{
							if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition / songMultiplier);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					/* 
						if (controlArray[daNote.noteData])

					 */
					// trace(daNote.noteData);
					/* 
						switch (daNote.noteData)

						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				else if(!isNew){
					badNoteCheck();
				}
			}
			var condition = ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic);
			if (mania == 1)
			{
				condition = ((l1 || u || r1 || l2 || d || r2) && generatedMusic || (l1Hold || uHold || r1Hold || l2Hold || dHold || r2Hold) && loadRep && generatedMusic);
			}
			else if (mania == 2)
			{
				condition = ((n0 || n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8) && generatedMusic || (n0Hold || n1Hold || n2Hold || n3Hold || n4Hold || n5Hold || n6Hold || n7Hold || n8Hold) && loadRep && generatedMusic);
			}
			else if (mania == 3)
			{
				condition = ((left || down || n4 || up || right) && generatedMusic || (leftHold || downHold || n4Hold || upHold || rightHold) && loadRep && generatedMusic);
			}
			else if (mania == 4)
			{
				condition = ((l1 || u || r1 || n4 || l2 || d || r2) && generatedMusic || (l1Hold || uHold || r1Hold || n4Hold || l2Hold || dHold || r2Hold) && loadRep && generatedMusic);
			}
			else if (mania == 5)
			{
				condition = ((n0 || n1 || n2 || n3 || n5 || n6 || n7 || n8) && generatedMusic || (n0Hold || n1Hold || n2Hold || n3Hold || n5Hold || n6Hold || n7Hold || n8Hold) && loadRep && generatedMusic);
			}
			else if (mania == 6)
			{
				condition = ((n4) && generatedMusic || (n4Hold) && loadRep && generatedMusic);
			}
			else if (mania == 7)
			{
				condition = ((left || right) && generatedMusic || (leftHold || rightHold) && loadRep && generatedMusic);
			}
			else if (mania == 8)
			{
				condition = ((left || n4 || right) && generatedMusic || (leftHold || n4Hold || rightHold) && loadRep && generatedMusic);
			}
			if (condition)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						if (mania == 0)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (up || upHold)
										goodNoteHit(daNote);
								case 3:
									if (right || rightHold)
										goodNoteHit(daNote);
								case 1:
									if (down || downHold)
										goodNoteHit(daNote);
								case 0:
									if (left || leftHold)
										goodNoteHit(daNote);
							}
						}
						else if (mania == 1)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0:
									if (l1 || l1Hold)
										goodNoteHit(daNote);
								case 1:
									if (u || uHold)
										goodNoteHit(daNote);
								case 2:
									if (r1 || r1Hold)
										goodNoteHit(daNote);
								case 3:
									if (l2 || l2Hold)
										goodNoteHit(daNote);
								case 4:
									if (d || dHold)
										goodNoteHit(daNote);
								case 5:
									if (r2 || r2Hold)
										goodNoteHit(daNote);
							}
						}
						else if (mania == 2)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0: if (n0 || n0Hold) goodNoteHit(daNote);
								case 1: if (n1 || n1Hold) goodNoteHit(daNote);
								case 2: if (n2 || n2Hold) goodNoteHit(daNote);
								case 3: if (n3 || n3Hold) goodNoteHit(daNote);
								case 4: if (n4 || n4Hold) goodNoteHit(daNote);
								case 5: if (n5 || n5Hold) goodNoteHit(daNote);
								case 6: if (n6 || n6Hold) goodNoteHit(daNote);
								case 7: if (n7 || n7Hold) goodNoteHit(daNote);
								case 8: if (n8 || n8Hold) goodNoteHit(daNote);
							}
						}
						else if (mania == 3)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (n4 || n4Hold)
										goodNoteHit(daNote);
								case 3:
									if (right || rightHold)
										goodNoteHit(daNote);
								case 4:
									if (up || upHold)
										goodNoteHit(daNote);
								case 1:
									if (down || downHold)
										goodNoteHit(daNote);
								case 0:
									if (left || leftHold)
										goodNoteHit(daNote);
							}
						}
						else if (mania == 4)
							{
								switch (daNote.noteData)
								{
									// NOTES YOU ARE HOLDING
									case 0:
										if (l1 || l1Hold)
											goodNoteHit(daNote);
									case 1:
										if (u || uHold)
											goodNoteHit(daNote);
									case 2:
										if (r1 || r1Hold)
											goodNoteHit(daNote);
									case 3:
										if (n4 || n4Hold)
											goodNoteHit(daNote);
									case 4:
										if (l2 || l2Hold)
											goodNoteHit(daNote);
									case 5:
										if (d || dHold)
											goodNoteHit(daNote);
									case 6:
										if (r2 || r2Hold)
											goodNoteHit(daNote);
								}
							}
						else if (mania == 5)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0: if (n0 || n0Hold) goodNoteHit(daNote);
								case 1: if (n1 || n1Hold) goodNoteHit(daNote);
								case 2: if (n2 || n2Hold) goodNoteHit(daNote);
								case 3: if (n3 || n3Hold) goodNoteHit(daNote);
								case 4: if (n5 || n5Hold) goodNoteHit(daNote);
								case 5: if (n6 || n6Hold) goodNoteHit(daNote);
								case 6: if (n7 || n7Hold) goodNoteHit(daNote);
								case 7: if (n8 || n8Hold) goodNoteHit(daNote);
							}
						}
						else if (mania == 6)
						{
							switch(daNote.noteData)
							{
								//bymark es gay lol | NOTES YOU ARE HOLDING
								case 0: if (n4 || n4Hold) goodNoteHit(daNote);
							}
						}
						else if (mania == 7)
						{
							switch(daNote.noteData)
							{
								//bymark es gay lol | NOTES YOU ARE HOLDING
								case 0: if (left || leftHold) goodNoteHit(daNote);
								case 1: if (right || rightHold) goodNoteHit(daNote);
							}
						}
						else if (mania == 8)
						{
							switch(daNote.noteData)
							{
								//sharkmitty | NOTES YOU ARE HOLDING
								case 0: if (left || leftHold) goodNoteHit(daNote);
								case 1: if (n4 || n4Hold) goodNoteHit(daNote);
								case 2: if (right || rightHold) goodNoteHit(daNote);
							}
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
				{
					if (mania == 0)
					{
						switch (spr.ID)
						{
							case 2:
								if (upP && spr.animation.curAnim.name != 'confirm')
								{
									spr.animation.play('pressed');
								}
								if (upR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 3:
								if (rightP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (downP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (downR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 0:
								if (leftP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 1)
					{
						switch (spr.ID)
						{
							case 0:
								if (l1P && spr.animation.curAnim.name != 'confirm')
								{
									spr.animation.play('pressed');
									trace('play');
								}
								if (l1R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (uP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (uR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 2:
								if (r1P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (r1R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 3:
								if (l2P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (l2R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 4:
								if (dP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (dR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 5:
								if (r2P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (r2R)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 2)
					{
						switch (spr.ID)
						{
							case 0:
								if (n0P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n0R) spr.animation.play('static');
							case 1:
								if (n1P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n1R) spr.animation.play('static');
							case 2:
								if (n2P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n2R) spr.animation.play('static');
							case 3:
								if (n3P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n3R) spr.animation.play('static');
							case 4:
								if (n4P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n4R) spr.animation.play('static');
							case 5:
								if (n5P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n5R) spr.animation.play('static');
							case 6:
								if (n6P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n6R) spr.animation.play('static');
							case 7:
								if (n7P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n7R) spr.animation.play('static');
							case 8:
								if (n8P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n8R) spr.animation.play('static');
						}
					}
					else if (mania == 3)
					{
						switch (spr.ID)
						{
							case 2:
								if (n4P && spr.animation.curAnim.name != 'confirm')
								{
									spr.animation.play('pressed');
									trace('play');
								}
								if (n4R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 3:
								if (upP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (upR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 4:
								if (rightP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (downP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (downR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 0:
								if (leftP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 4)
					{
						switch (spr.ID)
						{
							case 0:
								if (l1P && spr.animation.curAnim.name != 'confirm')
								{
									spr.animation.play('pressed');
									trace('play');
								}
								if (l1R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (uP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (uR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 2:
								if (r1P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (r1R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 3:
								if (n4P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (n4R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 4:
								if (l2P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (l2R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 5:
								if (dP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (dR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 6:
								if (r2P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (r2R)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 5)
					{
						switch (spr.ID)
						{
							case 0:
								if (n0P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n0R) spr.animation.play('static');
							case 1:
								if (n1P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n1R) spr.animation.play('static');
							case 2:
								if (n2P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n2R) spr.animation.play('static');
							case 3:
								if (n3P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n3R) spr.animation.play('static');
							case 4:
								if (n5P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n5R) spr.animation.play('static');
							case 5:
								if (n6P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n6R) spr.animation.play('static');
							case 6:
								if (n7P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n7R) spr.animation.play('static');
							case 7:
								if (n8P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
								if (n8R) spr.animation.play('static');
						}
					}
					else if (mania == 6)
					{
						switch (spr.ID)
						{
							case 0:
								if (n4P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (n4R)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 7)
					{
						switch (spr.ID)
						{
							case 0:
								if (leftP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (rightP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					else if (mania == 8)
					{
						switch (spr.ID)
						{
							case 0:
								if (leftP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 1:
								if (n4P && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (n4R)
								{
									spr.animation.play('static');
									repReleases++;
								}
							case 2:
								if (rightP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
						}
					}
					
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
		}

		function noteMiss(direction:Int = 1):Void
		{
			if (cpuControlled)
			{
				sicks++;
			}
			else
			{
				if (!boyfriend.stunned)
				{
					health -= 0.04;
					if (combo > 5 && gf.animOffsets.exists('sad'))
					{
						gf.playAnim('sad');
					}
					combo = 0;
					misses++;
			
					songScore -= 10;
			
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
					var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					if (mania == 1)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 2)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}
					else if (mania == 3)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
					}
					else if (mania == 4)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 5)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}
					else if (mania == 6)
					{
						sDir = ['UP'];
					}
					else if (mania == 7)
					{
						sDir = ['LEFT', 'RIGHT'];
					}
					else if (mania == 7)
					{
						sDir = ['LEFT', 'UP', 'RIGHT'];
					}
					
					boyfriend.playAnim('sing' + sDir[direction] + 'miss', true);
			
					updateAccuracy();
				}
			}
		}

	function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			var l1P = controls.L1_P;
			var uP = controls.U1_P;
			var r1P = controls.R1_P;
			var l2P = controls.L2_P;
			var dP = controls.D1_P;
			var r2P = controls.R2_P;

			var a0P = controls.A0_P;
			var a1P = controls.A1_P;
			var a2P = controls.A2_P;
			var a3P = controls.A3_P;
			var a4P = controls.A4_P;
			var a5P = controls.A5_P;
			var a6P = controls.A6_P;

			var n0P = controls.N0_P;
			var n1P = controls.N1_P;
			var n2P = controls.N2_P;
			var n3P = controls.N3_P;
			var n4P = controls.N4_P;
			var n5P = controls.N5_P;
			var n6P = controls.N6_P;
			var n7P = controls.N7_P;
			var n8P = controls.N8_P;
			
			if (mania == 0)
			{
				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
			}
			else if (mania == 1)
			{
				if (l1P)
					noteMiss(0);
				else if (uP)
					noteMiss(1);
				else if (r1P)
					noteMiss(2);
				else if (l2P)
					noteMiss(3);
				else if (dP)
					noteMiss(4);
				else if (r2P)
					noteMiss(5);
			}
			else if (mania == 2)
			{
				if (n0P) noteMiss(0);
				if (n1P) noteMiss(1);
				if (n2P) noteMiss(2);
				if (n3P) noteMiss(3);
				if (n4P) noteMiss(4);
				if (n5P) noteMiss(5);
				if (n6P) noteMiss(6);
				if (n7P) noteMiss(7);
				if (n8P) noteMiss(8);
			}
			else if (mania == 3)
			{
				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(3);
				if (rightP)
					noteMiss(4);
				if (n4P)
					noteMiss(2);
				if (downP)
					noteMiss(1);
			}
			else if (mania == 4)
				{
					if (l1P)
						noteMiss(0);
					else if (uP)
						noteMiss(1);
					else if (r1P)
						noteMiss(2);
					else if (n4P)
						noteMiss(3);
					else if (l2P)
						noteMiss(4);
					else if (dP)
						noteMiss(5);
					else if (r2P)
						noteMiss(6);
				}
			else if (mania == 5)
			{
				if (n0P) noteMiss(0);
				if (n1P) noteMiss(1);
				if (n2P) noteMiss(2);
				if (n3P) noteMiss(3);
				if (n5P) noteMiss(4);
				if (n6P) noteMiss(5);
				if (n7P) noteMiss(6);
				if (n8P) noteMiss(7);
			}
			else if (mania == 6)
			{
				if (n4P) noteMiss(0);
			}
			else if (mania == 7)
			{
				if (leftP) noteMiss(0);
				if (rightP) noteMiss(1);
			}
			else if (mania == 8)
			{
				if (leftP) noteMiss(0);
				if (n4P) noteMiss(1);
				if (rightP) noteMiss(2);
			}
			updateAccuracy();
		}
	
	function updateAccuracy() 
{
				totalPlayed += 1;
				accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
				accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

				missesTxt.text = (Main.judgement ? "Miss: " + misses + " " : "");
				sicksTxt.text = (Main.judgement ? "Sick: " + sicks + " " : "");
				goodsTxt.text = (Main.judgement ? "Good: " + goods + " " : "");
				badsTxt.text = (Main.judgement ? "Bad: " + bads + " " : "");
				shitsTxt.text = (Main.judgement ? "Shit: " + shits + " " : "");

			
			
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{

			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
				note.rating = "shit";
			else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
				note.rating = "bad";
			else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
				note.rating = "good";
			else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
				note.rating = "sick";
			
			if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note);
					}
				}
			}
			else if (controlArray[note.noteData])
				{
					for (b in controlArray) {
						if (b)
							mashing++;
					}

					// ANTI MASH CODE FOR THE BOYS

					if (mashing <= getKeyPresses(note) && mashViolations < 2)
					{
						mashViolations++;
						
						goodNoteHit(note, (mashing <= getKeyPresses(note)));
					}
					else
					{
						// this is bad but fuck you
						playerStrums.members[0].animation.play('static');
						playerStrums.members[1].animation.play('static');
						playerStrums.members[2].animation.play('static');
						playerStrums.members[3].animation.play('static');
						health -= 0.2;
						trace('mash ' + mashing);
					}

					if (mashing != 0)
						mashing = 0;
				}
		}

		var nps:Int = 0;

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if (!note.isSustainNote)
					notesHitArray.push(Date.now());

				if (resetMashViolation)
					mashViolations--;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
						if (FlxG.save.data.hitsoundspog)
						{
							FlxG.sound.play(Paths.sound('note_click'));
						}
					}
					else{
						totalNotesHit += 1;
					}
					
					var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					if (mania == 1)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 2)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}
					else if (mania == 3)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
					}
					else if (mania == 4)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 5)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}
					else if (mania == 6)
					{
						sDir = ['UP'];
					}
					else if (mania == 7)
					{
						sDir = ['LEFT', 'RIGHT'];
					}
					else if (mania == 8)
					{
						sDir = ['LEFT', 'UP', 'RIGHT'];
					}

					boyfriend.playAnim('sing' + sDir[note.noteData], true);

					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						//spr.updateHitbox();
					});
		
					if (!loadRep)
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
						});

					if (cpuControlled)
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
						});

		
					note.wasGoodHit = true;
					vocals.volume = 1;

					callAllHScript('goodNoteHit', [note.noteData]);
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		

	var fastCarCanDrive:Bool = true;

	function generateHaxeStage(){
		var stageInterp = new hscript.Interp();
		var bitmap:BitmapData;
		stageInterp.variables.set("defaultCamZoom", defaultCamZoom);
		stageInterp.variables.set("setCamZoom", function(daZoom:Float) {
			defaultCamZoom = daZoom;
		});
		stageInterp.variables.set("CoolUtil", CoolUtil);
		stageInterp.variables.set("curStage", curStage);
		stageInterp.variables.set("FlxSprite", FlxSprite);
		stageInterp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		stageInterp.variables.set("Std", Std);
		stageInterp.variables.set("FlxG", FlxG);
		stageInterp.variables.set("boyfriend", boyfriend);
		stageInterp.variables.set("gf", gf);
		stageInterp.variables.set("dad", dad);
		stageInterp.variables.set("setBfPosition", function(X:Int, Y:Int) {
			boyfriend.x += X;
			boyfriend.y += Y;
		});
		stageInterp.variables.set("setDadPosition", function(X:Int, Y:Int) {
			dad.x += X;
			dad.y += Y;
		});
		stageInterp.variables.set("setGfPosition", function(X:Int, Y:Int) {
			gf.x += X;
			gf.y += Y;
		});
		stageInterp.variables.set("setDadCameraPosition", function(X:Int, Y:Int) {
			dadCameraOffsetX = X;
			dadCameraOffsetY = Y;
		});
		stageInterp.variables.set("setBfCameraPosition", function(X:Int, Y:Int) {
			bfCameraOffsetX = X;
			bfCameraOffsetY = Y;
		});
		stageInterp.variables.set("setSpriteVars", function(varSprite:FlxSprite, spriteName:String, x:Float = 0, y:Float = 0, size:Float = 999999, scrollFactorX:Float, scrollFactorY:Float, antialiasing:Bool = false, active:Bool = false) {
				bitmap = CoolUtil.getBitmap('assets/images/custom_stages/' + SONG.stage + "/" + spriteName + ".png");
			// }
			var varSprite:FlxSprite;
			varSprite = new FlxSprite(x, y).loadGraphic(bitmap);
			varSprite.scrollFactor.set(scrollFactorX, scrollFactorY);
			if (size == 999999) {
				trace("[i] No size specified");
			}
			else
			{
				varSprite.setGraphicSize(Std.int(varSprite.width * size));
			}
			varSprite.antialiasing = antialiasing;
			varSprite.active = active;
		});
		stageInterp.variables.set("modifySize", function(daSprite:FlxSprite, size:Float) {
			daSprite.setGraphicSize(Std.int(daSprite.width * 0.9));
		});
		stageInterp.variables.set("add", function(varSprite:FlxSprite) {
			add(varSprite);
		});
		stageInterp.variables.set("remove", function(varSprite:FlxSprite) {
			remove(varSprite);
		});
		#if android
		var getScript = File.getContent(BootUpCheck.getPath() + "assets/images/custom_stages/" + SONG.stage + "/stageData.hx");
		#else
		var getScript = File.getContent("assets/images/custom_stages/" + SONG.stage + "/stageData.hx");
		#end
		var daScript:String = getScript;
		var daScriptParser = new hscript.Parser();
		var script = daScriptParser.parseString(daScript);
		stageInterp.execute(script);
	}
	function generateJsonStage(){
	
		curStage = "";
	
		var fl:String = "assets/images/custom_stages/"+SONG.stage+"/stageData.json";
		var allStageData:Dynamic= CoolUtil.parseJson(CoolUtil.getContent("assets/images/custom_stages/"+SONG.stage+"/stageData.json"));	
		var stageData:Dynamic= CoolUtil.getDynamic(allStageData,"assets",fl,false);
		defaultCamZoom = CoolUtil.getFloat(allStageData,"cameraZoom",fl,1);
		var offsetData:Dynamic=  CoolUtil.getDynamic(allStageData,"offsets",fl,false);
		hasCreated = false;
		hasCreatedgf = false;
		if(stageData!=null){
			for(i in 0...stageData.length){
				var inst:Dynamic = stageData[i];
				var isInFront = CoolUtil.getBool(inst,"isInFrontOfPlayers",fl,false);
				var isInFrontgf = CoolUtil.getBool(inst,"isInFrontOfGf",fl,false);
				var is3dStage = CoolUtil.getBool(inst,"is3dStage",fl,false);
				if(isInFront && !hasCreated){
					if(!hasCreatedgf){
						add(gf);
						hasCreatedgf = true;
					}
					add(dad);
					add(boyfriend);
					hasCreated = true;
				}
				if(isInFrontgf && !hasCreatedgf){
					add(gf);
					hasCreatedgf = true;
				}
				if(!inst.animated){
					
					var newInst:BitmapData;
					// if (FileSystem.exists('assets/images/custom_stages/'+SONG.stage+"/"+inst.name+".png")) {
						newInst = CoolUtil.getBitmap('assets/images/custom_stages/'+SONG.stage+"/"+ CoolUtil.getString(inst,'name',fl)+".png");
					// }
					var bg:FlxSprite = new FlxSprite(CoolUtil.getInt(inst,'x',fl), CoolUtil.getInt(inst,'y',fl)).loadGraphic(newInst);
					bg.antialiasing = true;
					bg.scrollFactor.set(CoolUtil.getFloat(inst,'scrollFactorX',fl,1), CoolUtil.getFloat(inst,'scrollFactorY',fl,1));
					if (is3dStage)
					{
						bg.active = true;
					}
					else
					{
						bg.active = false;
					}
					bg.setGraphicSize(Std.int(bg.width * CoolUtil.getFloat(inst,"size",fl,1)));
					bg.updateHitbox();
					add(bg);
					if (is3dStage)
					{
						var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
						testshader.waveAmplitude = 0.1;
						testshader.waveFrequency = 5;
						testshader.waveSpeed = 2;
						bg.shader = testshader.shader;
						curbg = bg;
					}
				}else{
					var bAnim = CoolUtil.getString(inst,'beatAnimation',fl,"");
					var idleAnim = CoolUtil.getString(inst,'idleAnimation',fl,"");	
					var istxt = CoolUtil.getBool(inst,"istxt",fl,false);
					var boppers = new StageAsset(CoolUtil.getInt(inst,'x',fl), CoolUtil.getInt(inst,'y',fl),bAnim,idleAnim,0,CoolUtil.getFloat(inst,'beatAnimationSize',fl,1),CoolUtil.getFloat(inst,'idleAnimationSize',fl,1));
					boppers.originalSize = boppers.width;
					var name =  CoolUtil.getString(inst,"name",fl);
					var rawPic = CoolUtil.getBitmap("assets/images/custom_stages/"+SONG.stage+"/"+name+".png");
					var rawXml = "";
					boppers.hasIdleAnimation = CoolUtil.getBool(inst,"hasIdleAnimation",fl,false) ;
					boppers.hasBeatAnimation = CoolUtil.getBool(inst,"hasBeatAnimation",fl,false) ;
					if(!istxt){
						rawXml = CoolUtil.getContent("assets/images/custom_stages/"+SONG.stage+"/"+name+".xml");
						boppers.frames = FlxAtlasFrames.fromSparrow(rawPic,rawXml);

					}else{
						trace("getting raw");
						rawXml = CoolUtil.getContent("assets/images/custom_stages/"+SONG.stage+"/"+name+".txt");
						boppers.frames = FlxAtlasFrames.fromSpriteSheetPacker(rawPic,rawXml);
					}
					boppers.setGraphicSize(Std.int(boppers.width * CoolUtil.getFloat(inst,'size',fl,1)));
					boppers.beatAnimationOffset = CoolUtil.getInt(inst,'beatAnimationOffset',fl,0);
				
					if(boppers.beatAnimation!="" ||boppers.hasBeatAnimation){
						var bFreq =  CoolUtil.getFloat(inst,'beatAnimationFrequency',fl,4);
						boppers.beatFrequency = bFreq;
						boppers.setGraphicSize(Std.int(boppers.width * CoolUtil.getFloat(inst,'beatAnimationSize',fl,1)));
						var bFramerate = CoolUtil.getInt(inst,'beatAnimationFramerate',fl,24);

						if(!istxt){
							boppers.animation.addByPrefix('bop', bAnim, bFramerate, false);
						}else{	
							var txtorder =  CoolUtil.getDynamic(inst,"txtBeatOrder",fl,true);
							boppers.animation.add('bop', txtorder, bFramerate);
						}
					}
					if(boppers.idleAnimation!="" ||boppers.hasIdleAnimation){
						var iFramerate = CoolUtil.getInt(inst,'idleAnimationFramerate',fl,4);
						boppers.setGraphicSize(Std.int(boppers.width * CoolUtil.getFloat(inst,'idleAnimationSize',fl,1)));
						if(!istxt){
							boppers.animation.addByPrefix('bop', idleAnim, iFramerate, false);
						}else{
							var txtorder =  CoolUtil.getDynamic(inst,"txtIdleOrder",fl,true);
							trace("loading raw");
							trace(txtorder);
							boppers.animation.add('idle', txtorder, iFramerate);
						}
					}
					boppers.antialiasing = true;
					boppers.scrollFactor.set(CoolUtil.getFloat(inst,'scrollFactorX',fl,1), CoolUtil.getFloat(inst,'scrollFactorY',fl,1));
					boppers.setGraphicSize(Std.int(boppers.width * CoolUtil.getFloat(inst,"size",fl,1)));
					boppers.updateHitbox();
					add(boppers);
					stageAssets.push(boppers);
					
	
	
				}
	
			}
		}
		if(!hasCreated){
			add(gf);
			add(dad);
			add(boyfriend);
			hasCreated = true;
		}
		if(offsetData!=null){
			for(i in 0...offsetData.length){
				var inst:Dynamic = offsetData[i];
				var offx:Int =  CoolUtil.getInt(inst,'x',fl,0);
				var offy:Int = CoolUtil.getInt(inst,'y',fl,0);
				trace(CoolUtil.getString(inst,'name',fl));
				switch(CoolUtil.getString(inst,'name',fl)){
					case 'bf':
						boyfriend.x +=offx;
						boyfriend.y += offy;
					case 'dad':
						dad.x += offx;
						dad.y +=offy;
					case 'gf':
						gf.x += offx;
						gf.y += offy;
					case 'dadCamera':
						dadCameraOffsetX = offx;
						dadCameraOffsetY = offy;
					case 'bfCamera':
						bfCameraOffsetX = offx;
						bfCameraOffsetY = offy;
				}
			}
		}
	
	}			
	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		if (loadHScript)
		{
			callAllHScript("stepHit", [curStep]);
		}
		super.stepHit();
		for(i in 0...stageAssets.length){
			var asset = stageAssets[i];
			if((asset.beatAnimation!=""||asset.hasBeatAnimation) && (curStep%asset.beatFrequency) == asset.beatAnimationOffset){
				asset.setGraphicSize(Std.int(asset.originalSize * asset.beatAnimationSize));
				asset.animation.play('bop', true);
			}else if((asset.idleAnimation!="" || asset.hasIdleAnimation) && asset.animation.curAnim==null){
				asset.setGraphicSize(Std.int(asset.originalSize * asset.idleAnimationSize));
				
				asset.animation.play('idle', true);
			}
		}
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		
		#if windows
		if (executeModchart && lua != null)
		{
			setVar('curStep',curStep);
			callLua('stepHit',[curStep]);
		}
		#end

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}


		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		if (cpuControlled)
		{
			DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: N/A | Score: N/A | Misses: N/A [!] BOTPLAY");
		}
		else
		{
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		}
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (loadHScript)
		{
			setAllHaxeVar('curBeat', curBeat);
			callAllHScript('beatHit', [curBeat]);
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}
		#if windows
		if (executeModchart && lua != null)
		{
			setVar('curBeat',curBeat);
			callLua('beatHit',[curBeat]);
		}
		#end

		if (SONG.notes[Math.floor((curStep / 16) / songMultiplier)] != null)
		{
			if (SONG.notes[Math.floor((curStep / 16) / songMultiplier)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor((curStep / 16) / songMultiplier)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
	
			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor((curStep / 16) / songMultiplier)].mustHitSection)
				dad.dance();
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (cpuControlled))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);
	
		// HARDCODING FOR MILF ZOOMS!
		/*if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}*/ //no longer needed since we now have events
	
		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015 / songMultiplier; 
			camHUD.zoom += 0.03 / songMultiplier;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && SONG.isHey)
			{
				boyfriend.playAnim('hey', true);
	
				if (SONG.song == 'Tutorial' && dad.like == 'gf')
				{
					dad.playAnim('cheer', true);
				}
			}

		var funny:Float = (healthBar.percent * 0.01) + 0.01;

		if (curBeat % gfSpeed == 0)
		{
			curBeat % ((gfSpeed * 2 ) / songMultiplier) == 0 ? {
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);
	
				FlxTween.angle(iconP1, -15, 0, (Conductor.crochet / 1300) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, (Conductor.crochet / 1300) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
			} : {
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);
	
				FlxTween.angle(iconP2, -15, 0, (Conductor.crochet / 1300) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 15, 0, (Conductor.crochet / 1300) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
				}
	
			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, (Conductor.crochet / 1250) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, (Conductor.crochet / 1250) / songMultiplier * gfSpeed, {ease: FlxEase.quadOut});
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				trace("QWEQWEQWEQW");
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);
				trace("spongus amongus");

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}
			
		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
 
class StageAsset extends FlxSprite{
	public var beatAnimation:String;
	public var idleAnimation:String;
	public var beatFrequency:Float;
	public var beatAnimationSize:Float;
	public var beatAnimationOffset:Int;
	public var idleAnimationSize:Float;
	public var originalSize:Float;
	public var hasIdleAnimation:Bool;
	public var hasBeatAnimation:Bool;
	public function new(x,y,beatAnimations:String,idleAnimations:String,beatFrequencys:Float,beatAnimationSizes:Float,idleAnimationSizes:Float)
	{
		super(x, y);
		beatAnimation = beatAnimations;
		idleAnimation = idleAnimations;
		beatFrequency = beatFrequencys;
		beatAnimationSize = beatAnimationSizes;
		idleAnimationSize = idleAnimationSizes;
	}
}
typedef VideoJsonPath =
{
	var videoPath:String;
}
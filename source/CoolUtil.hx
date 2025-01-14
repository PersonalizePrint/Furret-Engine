package;

import flash.display.BitmapData;
import lime.utils.Assets;
import tjson.TJSON;
import lime.app.Application;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import Type.ValueType;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if android
import android.os.Build;
import android.Permissions;
#end
import flash.media.Sound;

using StringTools;

class CoolUtil
{
	#if android
	public static var androidDir:String = null;
    public static var externalS:Dynamic = android.os.Environment.getExternalStorageDirectory();
    public static function getPath() //this will be used for almost every single hx file, how exciting
    {   
        var applicationNameSplit:Dynamic /*removes spaces from "Furret Engine" ("Furret Engine" -> "FurretEngine")*/ = Application.current.meta.get("file").split(" ");
        var applicationName:String = "" + applicationNameSplit[0] + applicationNameSplit[1] + "";
        androidDir = externalS + "/" + "." + applicationName + "/";
        return androidDir;
    }
	#end
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

	public static var globalAntialiasing:Bool = true;

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;
		if(newValue < min) newValue = min;
		else if(newValue > max) newValue = max;
		return newValue;
	}

	public static var difficultyStuff:Array<Dynamic> = [
		['Easy', '-easy'],
		['Normal', ''],
		['Hard', '-hard']
	];

	public static function getSound(path:String) 
	{
		#if android
		path = getPath() + path;
		#end
		if(!FileSystem.exists(path)){
			Application.current.window.alert('[!] Missing file: "'+path+'"');
		}
		var sound:Sound = Paths.returnSound(path);
		return sound;
	}

	public static function getVarFromArray(instance:Dynamic, variable:String):Any
	{
		var split:Array<String> = variable.split('[');
		if(split.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, split[0]);
			for (i in 1...split.length)
			{
				var leNum:Dynamic = split[i].substr(0, split[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		switch(Type.typeof(instance)) {
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return instance.get(variable);
			default:
				return Reflect.getProperty(instance, variable);
		};
		return null;
	}

	public static function setVarFromArray(instance:Dynamic, variable:String, value:Dynamic):Any
	{
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, shit[0]);
			for (i in 1...shit.length)
			{
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				if(i >= shit.length-1)
					blah[leNum] = value;
				else
					blah = blah[leNum];
			}
			return blah;
		}

		switch(Type.typeof(instance)) {
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				instance.set(variable, value);
			default:
				Reflect.setProperty(instance, variable, value);
		};
		return true;
	}

	public static function difficultyString():String
	{
		return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
	}
	
	public static function getString(dyn:Dynamic,key:String,jsonName:String,?d:String):String{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){
			trace("asdqwe6b");
			return d;
		}
		Application.current.window.alert('[!] "'+key+'" not found in '+jsonName);
		return "";
	}	public static function getInt(dyn:Dynamic,key:String,jsonName:String,?d:Int):Int{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('[!] "'+key+'" not found in '+jsonName);
		return 0;
	}public static function getDynamic(dyn:Dynamic,key:String,jsonName:String,crash:Bool):Dynamic{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(crash){
			Application.current.window.alert('[!] "'+key+'" not found in '+jsonName);
		}
		return null;
	}
	public static function getFloat(dyn:Dynamic,key:String,jsonName:String,?d:Float):Float{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('[!] "'+key+'" not found in '+jsonName);
		return 0;
	}	public static function getBool(dyn:Dynamic,key:String,jsonName:String,?d:Bool):Bool{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('[!] "'+key+'" not found in '+jsonName);
		return false;
	}
	public static function getBitmap(file:String):BitmapData{
		#if android
		file = getPath() + file;
		#end
		if(!FileSystem.exists(file)){
			Application.current.window.alert('[!] Missing file: "'+file+'"');
		}
		return BitmapData.fromFile(file);
	}
	public static function getContent(file:String):String{
		#if android
		file = getPath() + file;
		#end
		if(!FileSystem.exists(file)){
			Application.current.window.alert('[!] Missing file: "'+file+'"');
		}
		return File.getContent(file);
	}
	public static function coolTextFile(path:String):Array<String>
	{
		#if android
		path = getPath() + path;
		var daList:Array<String> = File.getContent(path).trim().split('\n');
		#else
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function parseJson(json:String):Dynamic {
		// the reason we do this is to make it easy to swap out json parsers

		return TJSON.parse(json);
	}
	public static function coolStringFile(path:String):Array<String>
		{
			#if android
			path = getPath() + path;
			#end
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function stringifyJson(json:Dynamic, ?fancy:Bool = true):String {
		// use tjson to prettify it
		var style:String = if (fancy) 'fancy' else null;
		return TJSON.encode(json,style);
	}
	public static function coolDynamicTextFile(path:String):Array<String>
		{
			#if android
			var daList:Array<String> = File.getContent(BootUpCheck.getPath() + path).trim().split('\n');
			#else
			var daList:Array<String> = File.getContent(path).trim().split('\n');
			#end
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function smoothColorChange(from:FlxColor, to:FlxColor, speed:Float):FlxColor

	{

	   	speed = speed / 10;

	    var result:FlxColor = FlxColor.fromRGBFloat
	    (
	        FlxMath.lerp(from.redFloat, to.redFloat, speed), //red

	        FlxMath.lerp(from.greenFloat, to.greenFloat, speed), //green

	        FlxMath.lerp(from.blueFloat, to.blueFloat, speed) //blue
	    );

	    return result;

	   

	}
	public static function camLerpShit(a:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * a;
	}
	public static function coolLerp(a:Float, b:Float, c:Float):Float
	{
		return a + CoolUtil.camLerpShit(c) * (b - a);
	}
}

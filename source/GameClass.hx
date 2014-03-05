package;

import flash.Lib;
import flash.events.Event;
import flash.display.StageDisplayState;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxCamera;

class GameClass extends FlxGame
{
	var gameWidth:Int = 640; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 480; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = PlayState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	/**
	 * You can pretty much ignore this logic and edit the variables above.
	 */
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		super(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
	}
	
	override function step()
	{
		super.step();
		#if !FLX_NO_KEYBOARD
			#if (flash || js)
			//if (FlxG.keyboard.justReleased("F5"))
			if(FlxG.keys.justReleased.F5)
			#else
			if (FlxG.keys.justPressed.ESCAPE)
			#end
			{
				toggle_fullscreen();
			}
		#end
	}

	private function toggle_fullscreen()
	{
		if (FlxG.stage.displayState == StageDisplayState.NORMAL) 
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
		else 
			FlxG.stage.displayState = StageDisplayState.NORMAL;

		// The next function contains steps 2-4
		window_resized();
	}

	// This is called every time the window is resized
	// It's a separate function than toggle_fullscreen because we want to call it when the window
	// size changed even if the user didn't click the fullscreen button (eg by pressing escape to exit fullscreen mode)
	private function window_resized(e:Event = null)
	{
		FlxCamera.defaultZoom = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
		FlxG.camera.zoom = FlxCamera.defaultZoom;

		// position game container in center of window
		this.x = (FlxG.stage.stageWidth - (FlxG.width * FlxCamera.defaultZoom )) / 2;
		this.y = (FlxG.stage.stageHeight - (FlxG.height * FlxCamera.defaultZoom )) / 2;

		FlxG.stage.color = 0x000000;
		
		FlxG.game.onResize(e);
	}
}

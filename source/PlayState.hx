package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var board:Board;
	public var tiles:Array<Array<Tile>>;
	public var timer:FlxTimer;
	public var time:Int;
	public var isGameOver:Bool;
	public var tilesMarked:Int;
	public var tilesRevealed:Int;
	
	public var timeText:FlxText;
	public var markedText:FlxText;
	public var statusText:FlxText;

	public var boardX:Float;
	public var boardY:Float;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.camera.bgColor = 0xffdddddd;
		
		board = new Board(8, 8, 10);
		
		boardX = FlxG.width / 2 - (board.width * Tile.WIDTH) / 2;
		boardY = FlxG.height - board.height * Tile.HEIGHT;
		
		tiles = new Array<Array<Tile>>();
		
		tilesMarked = 0;
		tilesRevealed = 0;
		isGameOver = false;
		time = 0;
		
		FlxG.watch.add(this, "tilesMarked", "Tiles Marked: ");
				
		var tile:Tile = null;
		
		// Create graphical tiles
		for ( x in 0...board.width)
		{
			tiles[x] = [];
			
			for ( y in 0...board.height)
			{
				tile = new Tile(boardX + x * Tile.WIDTH, boardY + y * Tile.HEIGHT, board.grid[x][y]);
				
				tiles[x].push(tile);
				add(tile);
				
			}
		}
				
		// Time text
		timeText = new FlxText(0, 0, FlxG.width, Std.int(time / 60) + ":" + StringTools.lpad(Std.string(time % 60), "0", 2), 20);
		timeText.setFormat(null, 20, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE_FAST, FlxColor.BLACK);
		add(timeText);
		
		// Tiles Marked Text
		markedText = new FlxText(timeText.x, timeText.y + timeText.height, FlxG.width,
			StringTools.lpad(Std.string(board.numMines - tilesMarked), "0", 2), 20);
		markedText.setFormat(null, 20, FlxColor.RED, "center", FlxText.BORDER_OUTLINE_FAST, FlxColor.BLACK);
		add(markedText);
		
		// Victory or Game over Text
		statusText = new FlxText(markedText.x, FlxG.height / 2, FlxG.width,
			"", 60);
		statusText.setFormat(null, 60, FlxColor.RED, "center", FlxText.BORDER_OUTLINE_FAST, FlxColor.WHITE);
		add(statusText);
		
		// Use timer to count seconds (0 = loops forever)
		timer = new FlxTimer(1, onTimer, 0);
		
		var newGameBtn:FlxButton = new FlxButton(0, 0, "New Game", newGame);
		add(newGameBtn);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		board = null;
		statusText = null;
		markedText = null;
		timeText = null;
		tiles = null;
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		#if !FLX_NO_MOUSE
		if (FlxG.mouse.justPressed && !isGameOver)
		{
			if (FlxG.mouse.x >= boardX && FlxG.mouse.y >= boardY)
			{
				var xClick:Int = Std.int((FlxG.mouse.x - boardX) / Tile.WIDTH);
				var yClick:Int = Std.int((FlxG.mouse.y - boardY) / Tile.HEIGHT);
				
				if (xClick >= 0 && xClick < board.width && yClick >= 0 && yClick < board.height)
				{
					reveal(xClick, yClick);
				}
			}
		}
		#end
		
		#if !FLX_NO_MOUSE_ADVANCED
		if (FlxG.mouse.justPressedRight && !isGameOver)
		{
			var xClick:Int = Std.int((FlxG.mouse.x - boardX) / Tile.WIDTH);
			var yClick:Int = Std.int((FlxG.mouse.y - boardY) / Tile.HEIGHT);
			
			if (xClick >= 0 && xClick < board.width && yClick >= 0 && yClick < board.height)
			{
				if (tiles[xClick][yClick].cover.visible)
				{
					if (tiles[xClick][yClick].flag.visible)
					{
						tilesMarked--;
						tiles[xClick][yClick].toggleFlag();
					}
					else if(tilesMarked < board.numMines)
					{
						tilesMarked++;
						tiles[xClick][yClick].toggleFlag();
					}
				}
			}
		}
		#end
		
		// Update text
		timeText.text = Std.int(time / 60) + ":" + StringTools.lpad(Std.string(time % 60), "0", 2);
		markedText.text = StringTools.lpad(Std.string(board.numMines - tilesMarked), "0", 2);
		if (isGameOver)
		{
			if (countRevealed() == board.width * board.height - board.numMines)
				statusText.text = "YOU WIN!";
				
			else
				statusText.text = "GAME OVER";
		}
	}
	
	/**
	 * @usage	Uses grid position to reveal it and also ends the game when applicable
	 * @param	X	Grid X position of tile
	 * @param	Y	Grid Y position of tile
	 */
	private function reveal(X:Int, Y:Int)
	{
		var clickedTile:Tile = tiles[X][Y];
				
		// Clicked a mine!
		if (board.grid[X][Y] < 0  && !isGameOver)
		{
			// Reveal all and gameover!
			revealBoard();
			isGameOver = true;
			playExplode();
		}
		else if (tiles[X][Y].cover.visible)
		{
			recSearch(X, Y);
			
			playBlip(); // Play a click sound
		}
		
		// Check if all tiles have been revealed
		if (countRevealed() == board.width * board.height - board.numMines)
		{
			isGameOver = true;	
		}
	}
	
	/**
	 * @usage	Reveal the entire board
	 */
	private function revealBoard():Void
	{
		for (x in 0...tiles.length)
		{
			for (y in 0...tiles[x].length)
			{
				tiles[x][y].cover.visible = false;
				tilesRevealed++;
			}
		}
	}
	
	/**
	 * @usage	Recursively reveal surrounding tiles that are covered
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	private function recSearch(TileX:Int, TileY:Int):Void
	{
		
		if (tiles[TileX][TileY].cover.visible)
		{
			recSearchLeft(TileX, TileY);
			recSearchRight(TileX, TileY);
			recSearchDown(TileX, TileY);
			recSearchUp(TileX, TileY);
			
			tiles[TileX][TileY].cover.visible = false;
			tilesRevealed++;
			
			unmarkTile(TileX, TileY);
		}
	}
	
	/**
	 * @usage	Recursively search from upward tile
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	private function recSearchUp(TileX:Int, TileY:Int):Void
	{
		if (TileY > 0 && board.grid[TileX][TileY] == 0) // Search up
		{
			recSearch(TileX, TileY - 1);
		}
		
		if (tiles[TileX][TileY].cover.visible)
		{
			tiles[TileX][TileY].cover.visible = false;
			tilesRevealed++;
			
			unmarkTile(TileX, TileY);
		}
	}
	
	/**
	 * @usage	Recursively search from downward tile
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	private function recSearchDown(TileX:Int, TileY:Int):Void
	{
		if (TileY < board.height - 1 && board.grid[TileX][TileY] == 0) // Search down
		{
			recSearch(TileX, TileY + 1);
		}
		
		if (tiles[TileX][TileY].cover.visible)
		{
			tiles[TileX][TileY].cover.visible = false;
			tilesRevealed++;
			
			unmarkTile(TileX, TileY);
		}
	}
	
	/**
	 * @usage	Recursively search from left tile
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	private function recSearchLeft(TileX:Int, TileY:Int):Void
	{
		if (TileX > 0  && board.grid[TileX][TileY] == 0) // Search left
		{
			recSearch(TileX - 1, TileY);
		}
				
		if (tiles[TileX][TileY].cover.visible)
		{
			tiles[TileX][TileY].cover.visible = false;
			tilesRevealed++;
			
			unmarkTile(TileX, TileY);
		}
	}
	
	/**
	 * @usage	Recursively search from right tile
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	private function recSearchRight(TileX:Int, TileY:Int):Void
	{
		if (TileX < board.width - 1 && board.grid[TileX][TileY] == 0) // Search right
		{
			recSearch(TileX + 1, TileY);
		}
		
		if (tiles[TileX][TileY].cover.visible)
		{
			tiles[TileX][TileY].cover.visible = false;
			tilesRevealed++;
			
			unmarkTile(TileX, TileY);
		}
	}
	
	/**
	 * @usage	Unmark a flagged tile when revealing tiles
	 * @param	TileX	X position of tile on grid
	 * @param	TileY	Y position of tile on grid
	 */
	function unmarkTile(TileX:Int, TileY:Int):Void
	{
		if (tiles[TileX][TileY].flag.visible)
		{
			tiles[TileX][TileY].flag.visible = false;
			tilesMarked--;
		}
	}
	
	/**
	 * @usage	Timer callback, counts up seconds spent
	 * @param	Timer	timer this callback is attached to
	 */
	private function onTimer(Timer:FlxTimer):Void
	{
		if(!isGameOver)
			time++;
	}
	
	/**
	 * @usage	Resets the game state
	 */
	private function newGame():Void
	{
		//FlxG.resetState();
		FlxG.switchState(new PlayState());
	}
	
	/**
	 * @usage	Plays a random "blip" sound
	 */
	private function playBlip():Void
	{
		var r = Math.ceil(Math.random() * 3);
		FlxG.sound.play("blip" + r, FlxG.sound.volume);
	}
	
	/**
	 * @usage	Plays an explosion sound
	 */
	private function playExplode():Void
	{
		FlxG.sound.play("explode", FlxG.sound.volume);
	}
	
	/**
	 * @usage	Count all tiles on the board currently revealed
	 * @return	Returns the number of currently revealed tiles
	 */
	private function countRevealed():Int
	{
		var revealed:Int = 0;
		
		for ( x in 0...tiles.length)
		{
			for ( y in 0...tiles[x].length)
			{
				if (!tiles[x][y].cover.visible)
					revealed++;
			}
		}
		
		return revealed;
	}
}
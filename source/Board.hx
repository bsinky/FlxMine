package ;
import flixel.FlxG;

/**
 * ...
 * @author Benjamin Sinkula
 */
class Board
{
	public var grid:Array<Array<Int>>;
	public var width:Int;
	public var height:Int;
	public var numMines:Int;
	
	private var mineLocations:Array<{X:Int, Y:Int}>;
	
	// Constant used to represent a mine
	inline static public var MINE:Int = -9999;
	
	/**
	 * 
	 * @param	GameWidth:  Width of the board
	 * @param	GameHeight:  Height of the board
	 * @param	Mines:  Number of mines to place
	 */
	public function new(GameWidth:Int, GameHeight:Int, Mines:Int=10) 
	{
		width = GameWidth;
		height = GameHeight;
		numMines = 0;
		
		// DEBUG
		FlxG.watch.add(this, "numMines", "Mines: ");
		
		grid = new Array<Array<Int>>();
		
		// Initialize grid
		makeGrid();
		
		// Place mines and create numbers
		placeMines(Mines);
	}
	
	/**
	 * @usage	Creates the gameboard
	 */
	private function makeGrid():Void
	{
		for ( x in 0...width)
		{
			grid[x] = new Array<Int>();
			
			for ( y in 0...height)
			{
				grid[x][y] = 0;
			}
		}
	}
	
	/**
	 * 
	 * @param	Mines:	Number of mines to place on the board
	 */
	private function placeMines(Mines:Int):Void
	{
		// X and Y coordinates to create a mine
		var x = 0;
		var y = 0;
		
		for ( m in 0...Mines)
		{
			// Randomly generate X and Y values
			x = Math.floor(Math.random() * width);
			y = Math.floor(Math.random() * height);
			
			// Place the mind on the grid
			grid[x][y] = MINE;
			numMines++;
			
			// Fill surrounding blocks with numbers
			generateNumber(x - 1, y);
			generateNumber(x + 1, y);
			generateNumber(x, y - 1);
			generateNumber(x, y + 1);
			generateNumber(x + 1, y + 1);
			generateNumber(x - 1, y + 1);
			generateNumber(x - 1, y - 1);
			generateNumber(x + 1, y - 1);
		}
	}
	
	/**
	 * @usage	Increase mine-indicator number if tile is not a mine
	 */
	private function generateNumber(TileX:Int, TileY:Int):Void
	{
		if (TileX >= 0 && TileX < width && TileY >= 0 && TileY < height)
		{
			if (grid[TileX][TileY] >= 0)
				grid[TileX][TileY]++;
		}
	}
}
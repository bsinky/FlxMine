package ;
import flixel.effects.FlxSpriteFilter;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author Benjamin Sinkula
 */
class Tile extends FlxGroup
{
	public var x:Float;
	public var y:Float;
	public var cover:FlxSprite;
	public var flag:FlxSprite;
	
	static inline public var WIDTH:Int = 50;
	static inline public var HEIGHT:Int = 50;
	
	public function new(X:Float, Y:Float, Number:Int)
	{
		super();
		
		x = Std.int(X);
		y = Std.int(Y);
		
		// Tile background
		add(new FlxSprite(X, Y, "assets/images/tile.png"));
		
		var text:FlxText = null;
		
		// Create Mine Tile
		// Uses < 0 as Mine values may be slightly higher than the constant Board.MINE
		if (Number < 0)
		{
			add(new FlxSprite(X, Y, "assets/images/mine.png"));
		}
		
		// Create Number tile ("0" tiles left blank)
		else
		{
			if (Number > 0)
			{
				var color = 0xffffffff;
				
				if (Number == 2)
					color = 0xff0000ff;
					
				else if (Number > 2)
					color = 0xffff0000;
				
				text = new FlxText(X, Y, WIDTH, Std.string(Number));
				text.setFormat(null, 24, color, "center", FlxText.BORDER_OUTLINE_FAST);
				text.y += 2;
				add(text);
			}
		}
		
		// Create covering
		cover = new FlxSprite(X, Y, "assets/images/cover.png");
		add(cover);
		
		// Create Flag
		flag = new FlxSprite(X, Y, "assets/images/flag.png");
		flag.visible = false;
		add(flag);
	}
	
	public function toggleFlag():Void
	{
		flag.visible = !flag.visible;
	}
}
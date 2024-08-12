package objects;

class CreditPopUp extends FlxSpriteGroup
{
    public var totalWidth(default, null):Float = 0;
    public var totalHeight(default, null):Float = 0;

    public function new(x:Float = 0, y:Float = 0, songName:String, authors:Array<String>)
    {
        super();

        var song = add(new FlxText(5, 5, songName, 16));
        song.color = 0xFFFDBB40;

        var bar = add(new FlxSprite(5, song.y + song.height + 5));
        var barHeight = 8;

        totalHeight = bar.y + barHeight + 5;
        for(name in authors)
        {
            var text = add(new FlxText(5, totalHeight, name, 16));
            totalHeight += text.height + 5;
            totalWidth = Math.max(totalWidth, text.width);
        }

        bar.makeGraphic(Std.int(totalWidth), barHeight, FlxColor.WHITE);
    }
}
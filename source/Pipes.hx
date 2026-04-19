package;

import flixel.FlxSprite;

class Pipes extends FlxSprite {
    public var scoreable:Bool = false;

    public function new(x:Float, y:Float, speed:Float, isTop:Bool) {
        super(x, y);
        
        velocity.x = -speed;
        antialiasing = false;
        flipY = isTop;
        scoreable = isTop;

        loadGraphic("assets/images/flappy-bird/pipe.png");
        setGraphicSize(Std.int(this.width * 2));
        updateHitbox();

        this.y -= isTop ? this.height : 0;
    }

    public function resetPipe(x:Float, y:Float, speed:Float, isTop:Bool) {
        reset(x, y);
        velocity.x = -speed;
        scoreable = isTop;
        flipY = isTop;
        this.y -= isTop ? this.height : 0;
    }
}
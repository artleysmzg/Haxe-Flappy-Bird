package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class ReadySubState extends FlxSubState {
    var black:FlxSprite;
    var ready:FlxSprite;

    override function create() {
        super.create();

        black = new FlxSprite();
        black.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        black.alpha = 0.5;
        add(black);

        ready = new FlxSprite();
        ready.loadGraphic("assets/images/flappy-bird/ui/ready.png");
        ready.setGraphicSize(Std.int(ready.width * 2));
        ready.updateHitbox();
        ready.screenCenter();
        ready.antialiasing = false;
        add(ready);

        FlxG.camera.fade(0xFF000000, 0.5, true);
    }

    var allowInteract:Bool = true;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!allowInteract) return;

        if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed) {
            allowInteract = false;

            var playState = cast(FlxG.state, PlayState);
            
            playState.persistentUpdate = true;
            playState.spawnPipe(); 
            playState.flap();     
            
            FlxTween.tween(playState.scoreText, {y: 30}, 0.5, {ease: FlxEase.cubeOut});
            FlxTween.tween(black, {alpha: 0}, 0.5);
            FlxTween.tween(ready, {alpha: 0}, 0.5, {
                onComplete: function(_) {
                    close(); 
                }
            });            
        }
    }
}
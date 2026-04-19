package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState; 
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;

class MainMenuState extends FlxState {
    var logo:FlxSprite;
    var menuButton:FlxSprite;
    var playButton:FlxSprite;
    
    var background_day:FlxBackdrop;
    var background_night:FlxBackdrop;
    var ground:FlxBackdrop;
    
    var bird:FlxSprite;
    var someText:FlxBitmapText;

    override function create() {
        super.create();
        
        background_day = new FlxBackdrop("assets/images/flappy-bird/background-day.png", X);
        background_day.setGraphicSize(0, FlxG.height);
        background_day.updateHitbox();
        background_day.velocity.x = -20;
        background_day.antialiasing = false;
        add(background_day);

        background_night = new FlxBackdrop("assets/images/flappy-bird/background-night.png", X);
        background_night.setGraphicSize(0, FlxG.height);
        background_night.updateHitbox();
        background_night.velocity.x = -20;
        background_night.antialiasing = false;
        background_night.alpha = 0;
        add(background_night);

        ground = new FlxBackdrop("assets/images/flappy-bird/base.png", X);
        ground.setGraphicSize(Std.int(ground.width * 1.3));
        ground.updateHitbox();
        ground.setPosition(0, FlxG.height - ground.height + 30);
        ground.velocity.x = -150;
        ground.antialiasing = false;
        add(ground);

        bird = new FlxSprite();
        bird.loadGraphic("assets/images/flappy-bird/bird.png", true, 37, 24);
        bird.animation.add("flap", [0, 1, 2], 10, true);
        bird.animation.play("flap");
        bird.setGraphicSize(Std.int(bird.width * 2.5));
        bird.updateHitbox();
        bird.screenCenter();
        bird.antialiasing = false;
        add(bird);

        logo = new FlxSprite();
        logo.loadGraphic("assets/images/flappy-bird/ui/label_flappy_bird.png");
        logo.setGraphicSize(Std.int(logo.width * 4));
        logo.updateHitbox();
        logo.screenCenter();
        logo.antialiasing = false;
        add(logo);

        playButton = new FlxSprite(0, FlxG.height - 180);
        playButton.loadGraphic("assets/images/flappy-bird/ui/button_play_normal.png");
        playButton.setGraphicSize(Std.int(playButton.width * 3));
        playButton.updateHitbox();
        playButton.screenCenter(X);
        playButton.x += 150;
        playButton.antialiasing = false;
        add(playButton);

        menuButton = new FlxSprite(0, FlxG.height - 180);
        menuButton.loadGraphic("assets/images/flappy-bird/ui/button_back.png");
        menuButton.setGraphicSize(Std.int(menuButton.width * 3));
        menuButton.updateHitbox();
        menuButton.screenCenter(X);
        menuButton.x -= 150;
        menuButton.antialiasing = false;
        add(menuButton);

        someText = new FlxBitmapText(0, FlxG.height - 70, "Original by .GEARS Studios");
        someText.scale.set(4, 4);
        someText.updateHitbox();
        someText.screenCenter(X);
        someText.antialiasing = false;
        someText.color = 0xFFFFF6CC;
        someText.borderStyle = OUTLINE;
        someText.borderSize = 1;
        someText.borderColor = 0xFFCFA83C;
        add(someText);

        bird.x += 200;
        logo.x -= 50;
        bird.y -= 130;
        logo.y -= 100;
    }

    var iTime:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);

        iTime += elapsed;

        bird.offset.y = 20 * Math.sin(4 * iTime);
        logo.offset.y = 20 * Math.sin(4 * iTime);

        if (FlxG.keys.justPressed.ENTER || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(playButton))) {
            playButton.loadGraphic("assets/images/flappy-bird/ui/button_play_pressed.png");
            FlxG.sound.play("assets/sounds/flappy-bird/swoosh.ogg"); 
            FlxG.camera.fade(0xFF000000, 0.5, false, function() {
                FlxG.switchState(new PlayState());
            });
        }
        
        if (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuButton))) {
        }
    }
}
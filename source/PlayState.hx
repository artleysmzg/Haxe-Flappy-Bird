package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class PlayState extends FlxState {

    // Background elements
    var background_day:FlxBackdrop;
    var background_night:FlxBackdrop;
    var ground:FlxBackdrop;
    var pipes:FlxTypedGroup<Pipes>;
    
    var bird:FlxSprite;
    
    // UI elements
    public var scoreText:FlxBitmapText;

    // Gameplay variables
    public var score:Int = 0;
    var getHit:Bool = false;
    public var botplay:Bool = false;
    
    // Logic variables
    var flyForce:Float = 700; 
    var gravity:Float = 800;

    var pipeTimer:Float = 0;
    var pipeSpeed:Float = 150;
    var pipeGap:Float = 130;

    var nightTimer:Float = 0;
    var isNight:Bool = false;

    override function create() {
        super.create();

        if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
        
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

        pipes = new FlxTypedGroup<Pipes>();
        add(pipes);

        ground = new FlxBackdrop("assets/images/flappy-bird/base.png", X);
        ground.setGraphicSize(Std.int(ground.width * 1.3));
        ground.updateHitbox();
        ground.setPosition(0, FlxG.height - ground.height + 30);
        ground.velocity.x = -pipeSpeed;
        ground.antialiasing = false;
        add(ground);

        bird = new FlxSprite(0, 0);
        bird.loadGraphic("assets/images/flappy-bird/bird.png", true, 37, 24);
        bird.animation.add("flap", [0, 1, 2, 1], 10, true);
        bird.animation.play("flap");
        bird.setGraphicSize(Std.int(bird.width * 2));
        bird.updateHitbox();
        bird.screenCenter();
        bird.antialiasing = false;
        add(bird);

        var font = FlxBitmapFont.fromMonospace("assets/images/flappy-bird/ui/score-number.png", "0123456789", FlxPoint.get(34, 46));
        scoreText = new FlxBitmapText(0, 50, "0", font);
        scoreText.scale.set(2, 2);
        scoreText.updateHitbox();
        scoreText.screenCenter(X);
        scoreText.antialiasing = false;
        scoreText.letterSpacing = -8;
        add(scoreText);

        openSubState(new ReadySubState());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        bird.velocity.y += gravity * elapsed * 3;

        if (!getHit) {
            if (botplay) {
                botLogic();
            } else if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed) {
                flap();
            }
        }

        if (bird.velocity.y > 0) {
            bird.angle = FlxMath.lerp(bird.angle, 60, 0.1);
        }

        if (bird.y + bird.height > ground.y) {
            bird.y = ground.y - bird.height;
            bird.velocity.y = 0;
            bird.acceleration.y = 0;
            if (!getHit) gotHit();
            gameOver();
        }

        if (bird.y < -bird.height - 10 && !getHit) {
            gotHit();
        }

        pipeTimer += elapsed;
        if (pipeTimer >= 2 && !getHit) {
            pipeTimer = 0;
            spawnPipe();
        }

        pipes.forEachAlive(function(pipe:Pipes) {
            if (pipe.x + pipe.width < 0) {
                pipe.kill();
            }

            if (pipe.x + pipe.width < bird.x && pipe.scoreable && !getHit) {
                score++;
                scoreText.text = Std.string(score);
                scoreText.screenCenter(X);
                pipe.scoreable = false;
                FlxG.sound.play("assets/sounds/flappy-bird/point.ogg");
            }
        });

        FlxG.overlap(bird, pipes, function(_, _) {
            if (!getHit) gotHit();
        });

        nightTimer += elapsed;
        if (nightTimer >= 20) {
            nightTimer = 0;
            isNight = !isNight;
            FlxTween.tween(background_night, {alpha: isNight ? 1 : 0}, 2);
        }
    }

    public function spawnPipe() {
        var centerY = FlxG.random.int(Std.int(pipeGap + 50), Std.int(ground.y - pipeGap - 50));

        var pipeTop = pipes.recycle(Pipes);
        pipeTop.resetPipe(FlxG.width, centerY - pipeGap, pipeSpeed, true);

        var pipeBottom = pipes.recycle(Pipes);
        pipeBottom.resetPipe(FlxG.width, centerY + pipeGap, pipeSpeed, false);
    }

    public function flap() {
        bird.velocity.y = -flyForce;
        bird.angle = -30;
        FlxG.sound.play("assets/sounds/flappy-bird/wing.ogg");
    }

    function gotHit() {
        FlxG.camera.flash(0xFFFFFFFF, 0.2);
        FlxG.sound.play("assets/sounds/flappy-bird/hit.ogg");
        FlxG.sound.play("assets/sounds/flappy-bird/die.ogg");
        getHit = true;
        bird.velocity.set(0, 800);
        ground.velocity.x = 0;
        pipes.forEach(function(pipe) pipe.velocity.x = 0);
    }

    function gameOver() {
        persistentUpdate = false;
        openSubState(new GameOverSubState());
    }

    function botLogic() {
        var targetPipe:Pipes = null;
        pipes.forEachAlive(function(pipe) {
            if (!pipe.flipY && pipe.x + pipe.width > bird.x) {
                if (targetPipe == null || pipe.x < targetPipe.x)
                    targetPipe = pipe;
            }
        });

        if (targetPipe == null) return;

        var gapCenter = targetPipe.y - pipeGap/2; 
        if (bird.y > gapCenter) flap();
    }
}
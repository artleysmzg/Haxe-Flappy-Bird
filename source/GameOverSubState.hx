package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;

class GameOverSubState extends FlxSubState {
    var black:FlxSprite;
    var gameover:FlxSprite;
    
    var panel:FlxTypedSpriteGroup<FlxSprite>;
    var panel_background:FlxSprite;
    var panel_medal:FlxSprite;
    var panel_medal_sparkle:FlxSprite;
    var panel_label_new:FlxSprite;
    var panel_highscore:FlxBitmapText;
    var panel_score:FlxBitmapText;
    var retryButton:FlxSprite;
    var menuButton:FlxSprite;

    var isNewHighscore = false;
    var allowInteract = false;
    var medal = "";

    var highscore:Int = 0;

    override function create() {
        super.create();

        if (FlxG.save.data.flappyBirdHighscore == null)
            FlxG.save.data.flappyBirdHighscore = 0;
        
        highscore = FlxG.save.data.flappyBirdHighscore;

        var currentScore:Int = cast(FlxG.state, PlayState).score;

        if (highscore < currentScore) { 
            FlxG.save.data.flappyBirdHighscore = currentScore;
            highscore = currentScore;
            isNewHighscore = true;
            FlxG.save.flush(); 
        }

        black = new FlxSprite();
        black.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        black.alpha = 0;
        add(black);

        gameover = new FlxSprite(0, FlxG.height);
        gameover.loadGraphic("assets/images/flappy-bird/ui/gameover.png");
        gameover.setGraphicSize(Std.int(gameover.width * 2));
        gameover.updateHitbox();
        gameover.screenCenter(X);
        gameover.antialiasing = false;
        add(gameover);

        panel = new FlxTypedSpriteGroup<FlxSprite>(0, 0);

        panel_background = new FlxSprite();
        panel_background.loadGraphic("assets/images/flappy-bird/ui/panel_score.png");
        panel_background.setGraphicSize(Std.int(panel_background.width * 4));
        panel_background.updateHitbox();
        panel_background.screenCenter();
        panel_background.antialiasing = false;
        panel.add(panel_background);

        panel_label_new = new FlxSprite(panel_background.x + panel_background.width - 180, panel_background.y + 117);
        panel_label_new.loadGraphic("assets/images/flappy-bird/ui/panel_new.png");
        panel_label_new.setGraphicSize(Std.int(panel_label_new.width * 4));
        panel_label_new.updateHitbox();
        panel_label_new.antialiasing = false;
        panel_label_new.visible = isNewHighscore;
        panel.add(panel_label_new);

        panel_medal = new FlxSprite(panel_background.x + 51, panel_background.y + 85);
        panel_medal.loadGraphic("assets/images/flappy-bird/ui/medal_bronze.png");
        panel_medal.visible = false;
        panel_medal.setGraphicSize(Std.int(panel_medal.width * 4));
        panel_medal.updateHitbox();
        panel_medal.antialiasing = false;
        panel.add(panel_medal);

        panel_medal_sparkle = new FlxSprite();
        panel_medal_sparkle.visible = false;
        panel.add(panel_medal_sparkle);

        var font = FlxBitmapFont.fromMonospace("assets/images/flappy-bird/ui/score-number.png", "0123456789", FlxPoint.get(34, 46));

        panel_score = new FlxBitmapText(panel_background.x + 365, panel_background.y + 60, "0", font);
        panel_score.antialiasing = false;
        panel_score.letterSpacing = -8;
        panel.add(panel_score);

        panel_highscore = new FlxBitmapText(0, panel_background.y + 142, Std.string(highscore), font);
        panel_highscore.antialiasing = false;
        panel_highscore.letterSpacing = -8;
        panel_highscore.x = panel_background.x + 365 - panel_highscore.width/2;
        panel.add(panel_highscore);

        panel.y = FlxG.height;
        add(panel);

        retryButton = new FlxSprite(0, FlxG.height + 20);
        retryButton.loadGraphic("assets/images/flappy-bird/ui/button_ok.png");
        retryButton.setGraphicSize(Std.int(retryButton.width * 3));
        retryButton.updateHitbox();
        retryButton.screenCenter(X);
        retryButton.x += 100;
        retryButton.offset.y = 0;
        retryButton.antialiasing = false;
        add(retryButton);

        menuButton = new FlxSprite(0, FlxG.height + 20);
        menuButton.loadGraphic("assets/images/flappy-bird/ui/button_menu.png");
        menuButton.setGraphicSize(Std.int(menuButton.width * 3));
        menuButton.updateHitbox();
        menuButton.screenCenter(X);
        menuButton.x -= 100;
        menuButton.offset.y = 0;
        menuButton.antialiasing = false;
        add(menuButton);

        if (currentScore >= 5) medal = "bronze";
        if (currentScore >= 10) medal = "silver";
        if (currentScore >= 20) medal = "gold";
        if (currentScore >= 40) medal = "platinum";
        
        if (medal != "") {
            panel_medal.loadGraphic("assets/images/flappy-bird/ui/medal_" + medal + ".png");
            panel_medal.visible = true;
        }
        
        intro();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!allowInteract) return;

        if (FlxG.keys.justPressed.ENTER || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(retryButton))) {
            retryButton.offset.y = -2;
            FlxG.sound.play("assets/sounds/flappy-bird/swoosh.ogg");
            FlxG.camera.fade(0xFF000000, 0.5, false, function() {
                FlxG.switchState(new PlayState());
            });
        }

        if (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuButton))) {
            menuButton.offset.y = -2;
            FlxG.sound.play("assets/sounds/flappy-bird/swoosh.ogg");
            FlxG.camera.fade(0xFF000000, 0.5, false, function() {
                FlxG.switchState(new MainMenuState());
            });
        }
    }

    function intro() {
        FlxTween.tween(black, {alpha: 0.5}, 1);
        FlxTween.tween(gameover, {y: 100}, 1, {ease: FlxEase.cubeInOut});
        FlxTween.tween(panel, {y: 0}, 1.5, {ease: FlxEase.cubeInOut});
        FlxTween.tween(retryButton, {y: FlxG.height - 180}, 1, {startDelay: 1, ease: FlxEase.cubeInOut});
        FlxTween.tween(menuButton, {y: FlxG.height - 180}, 1, {startDelay: 1, ease: FlxEase.cubeInOut});

        var finalScore = cast(FlxG.state, PlayState).score;

        FlxTween.num(0, finalScore, 1, {
            startDelay: 0.5, 
            ease: FlxEase.linear,
            onComplete: function(tween) {
                allowInteract = true;
            }}, 
            function(v) {
                panel_score.text = Std.string(Std.int(v)); 
                panel_score.x = panel_background.x + 365 - panel_score.width/2;
            }
        );
    }
}
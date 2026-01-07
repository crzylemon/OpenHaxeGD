package menu;
import ccsim.CocosSim;
import nongd.GameConfig;
import nongd.Helpers;
import misc.PlatformToolbox;
import misc.GameManager;

class MenuLayer extends CCLayer {
    // MenuLayer.h
    //protected:
    private var mProfileButton:CCMenuItemSpriteExtra;
    private var mProfileHelpText:CCSprite;
    private var mProfileText:CCLabelBMFont;
    public static function scene(reload:Bool) {
        // 'scene' is an autorelease object
        var sc = CCScene.create(); //Renamed

        var pApp = AppDelegate.get();
        pApp.mMenuScene = sc;
        // 'layer' is an autorelease object
        var layer = MenuLayer.node();

        // add layer as a child to scene
        sc.addChild(layer);

        if (reload)
        {
            var delay:CCDelayTime = CCDelayTime.create(0.0);
            var callFunc:CCCallFunc = CCCallFunc.create(layer, callfun_selector(MenuLayer.onOptionsInstant));
            var sequence:CCSequence = CCSequence.create([delay,callFunc,null]);
            layer.runAction(sequence);
        }
        // return the scene
        return sc;
    }
    public static function node():MenuLayer {
        var pRet:MenuLayer = new MenuLayer();
        if (pRet.init())
        {
            pRet.autorelease();
            return pRet;
        }
        else
        {
            pRet = null;
            return null;
        }
    }
    public function new() {
        super();
        mProfileHelpText = null;
        mProfileText = null;
        mProfileButton = null;
    }
    override public function init():Bool {
        super.init();
        //if (!CCLayer.init()) {
        //    return false;
        //}
        var pDirector:CCDirector = CCDirector.sharedDirector();
        var pTouchDispatcher:CCTouchDispatcher = pDirector.getTouchDispatcher();
        pTouchDispatcher.setForcePrio(-500);

        var pGameManager:GameManager = GameManager.sharedState();
        pGameManager.fadeInMusic("menuLoop.mp3");
        pGameManager.mUnknownBool1 = true;
        pGameManager.mUnknownInt1 = 0;
        pGameManager.mUnknownBool2 = false;

        this.setKeypadEnabled(true);

        var winSize:CCSize = pDirector.getWinSize();

        // ----------------------------------------------------------------------------------------------
        // Logos
        // ----------------------------------------------------------------------------------------------

        var logo:CCSprite = CCSprite.createWithSpriteFrameName("GJ_logo_001.png");
        this.addChild(logo);
        // Port note: No CCPoint here, because setPosition in Heaps takes x and y args.
        logo.setCCPosition(winSize.width * 0.5, pDirector.getScreenTop() - 50.0);
        if (GameConfig.GD_VERSION == "GD_SUBZERO") {
            var subLogo:CCSprite = CCSprite.createWithSpriteFrameName("gj_subzeroLogo_001.png");
            this.addChild(subLogo);
            subLogo.setCCPosition(logo.GetCCPos().x + 120.0, logo.GetCCPos().y - 44.0);
        } else if (GameConfig.GD_VERSION == "GD_MELTDOWN") {
            var subLogo:CCSprite = CCSprite.createWithSpriteFrameName("GJ_md_001.png");
            this.addChild(subLogo);
            subLogo.setCCPosition(logo.GetCCPos().x + 140.0, logo.GetCCPos().y - 44.0);
        } else if (GameConfig.GD_VERSION == "GD_WORLD") {
            var subLogo:CCSprite = CCSprite.createWithSpriteFrameName("gj_worldLogo_001.png");
            this.addChild(subLogo);
            subLogo.setCCPosition(logo.GetCCPos().x + 120.0, logo.GetCCPos().y - 44.0);
        } else if (GameConfig.GD_VERSION == "GD_LITE") {
            var subLogo:CCSprite = CCSprite.createWithSpriteFrameName("GJ_lite_001.png");
            this.addChild(subLogo);
            subLogo.setCCPosition(logo.GetCCPos().x + 150.0, logo.GetCCPos().y - 30.0);
        }

        // ----------------------------------------------------------------------------------------------
        // Main Menu
        // ----------------------------------------------------------------------------------------------

        var mainMenu:CCMenu = CCMenu.create();

        var playButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_playBtn_001.png");
        var playExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(playButton, null, this, menu_selector(MenuLayer.onPlay));
        mainMenu.addChild(playExtra);
        this.addChild(mainMenu);
        mainMenu.ccX = winSize.width * 0.5;
        mainMenu.ccY = (winSize.height * 0.5) + 10.0;

        var garageButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_garageBtn_001.png");
        var garageExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(garageButton, null, this, menu_selector(MenuLayer.onGarage));
        
        mainMenu.addChild(garageExtra);
        garageExtra.ccX = playExtra.GetCCPos().x + -110.0;
        garageExtra.ccY = playExtra.GetCCPos().y;

        if (!pGameManager.mUsedGarageButton)
        {
            var chrSel:CCSprite = CCSprite.createWithSpriteFrameName("GJ_chrSel_001.png");
            this.addChild(chrSel);
            // Port Note: This is a bit different than the original implementation, but it should do the same. (AbsPos = WorldSpace???)
            chrSel.ccX = garageExtra.GetCCPos().x + -110.0;
            chrSel.ccY = garageExtra.GetCCPos().y + 30.0;
        }
        var fullExtra:CCMenuItemSpriteExtra; //Port Note: I SURE DO HATE C++ WITH EVERY FIBER OF MY BEING!!!!!!
        if (GameConfig.GD_VERSION == "GD_LITE" || GameConfig.GD_VERSION == "GD_WORLD") {
            var fullButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_fullBtn_001.png");
            fullExtra = CCMenuItemSpriteExtra.create(fullButton, null, this, menu_selector(MenuLayer.onFullVersion));
        } else {
            var fullButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_creatorBtn_001.png");
            fullExtra = CCMenuItemSpriteExtra.create(fullButton, null, this, menu_selector(MenuLayer.onCreator));
        }
        mainMenu.addChild(fullExtra);
        fullExtra.ccX = playExtra.GetCCPos().x + 110.0;
        fullExtra.ccY = playExtra.GetCCPos().y;

        if (GameConfig.GD_VERSION == "GD_LITE" || GameConfig.GD_VERSION == "GD_WORLD") {
            if (!pGameManager.mUsedCreatorButton)
            {  
                var lvlEditButton:CCSprite;
                if (GameConfig.GD_VERSION == "GD_WORLD") {
                    lvlEditButton = CCSprite.createWithSpriteFrameName("GJ_lvlEditWorld_001.png");
                } else {
                    lvlEditButton = CCSprite.createWithSpriteFrameName("GJ_lvlEdit_001.png");
                }
                this.addChild(lvlEditButton);
                lvlEditButton.ccX = fullExtra.GetCCPos().x + 50.0;
                lvlEditButton.ccY = fullExtra.GetCCPos().y + -50.0;
            }
        }
        // ----------------------------------------------------------------------------------------------
        // Bottom Menu
        // ----------------------------------------------------------------------------------------------

        var bottomMenu:CCMenu = CCMenu.create();
        this.addChild(bottomMenu);

        var achievementsButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_achBtn_001.png");
        var achievementsExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(achievementsButton, null, this, menu_selector(MenuLayer.onAchievements));
        bottomMenu.addChild(achievementsExtra);

        var optionsButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_optionsBtn_001.png");
        var optionsExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(optionsButton, null, this, menu_selector(MenuLayer.onOptions));
        bottomMenu.addChild(optionsExtra);

        var statsButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_statsBtn_001.png");
        var statsExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(statsButton, null, this, menu_selector(MenuLayer.onStats));
        bottomMenu.addChild(statsExtra);

        if (GameConfig.GD_PLATFORM == "MOBILE") {
            var everyplayButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_everyplayBtn_001.png");
            everyplayButton.setScale(1.0); //Port Note: Why?
            var everyplayExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(everyplayButton, null, this, menu_selector(MenuLayer.onEveryplay));
            bottomMenu.addChild(everyplayExtra);
        }

        var newgroundsButton = CCSprite.createWithSpriteFrameName("GJ_ngBtn_001.png");
        var newgroundsExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(newgroundsButton, null, this, menu_selector(MenuLayer.onNewgrounds));
        bottomMenu.addChild(newgroundsExtra);

        bottomMenu.ccX = winSize.width * 0.5;
        bottomMenu.ccY = pDirector.getScreenBottom() + 45.0;
        bottomMenu.alignItemsHorizontallyWithPadding(20.0);

        // ----------------------------------------------------------------------------------------------
        // Social Menu
        // ----------------------------------------------------------------------------------------------

        var robtopLogo:CCSprite = CCSprite.createWithSpriteFrameName("robtoplogo_small.png");
        robtopLogo.setScale(0.8);
        var robtopExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(robtopLogo, null, this, menu_selector(MenuLayer.onRobtop));
        if (GameConfig.GD_PRE22MENUS) {
            robtopExtra.setSizeMult(1.5);
        } else {
            robtopExtra.setSizeMult(1.1);
        }

        var socialsMenu:CCMenu = CCMenu.create();
        // Port Note: this line wasnt in the original, it was originally in the args for create()
        socialsMenu.addChild(robtopExtra);
        this.addChild(socialsMenu);
        socialsMenu.ccX = pDirector.getScreenLeft() + 50.0;
        socialsMenu.ccY = pDirector.getScreenBottom() + 30.0 - 60.0;

        var facebookIcon:CCSprite = CCSprite.createWithSpriteFrameName("GJ_fbIcon_001.png");
        facebookIcon.setScale(0.8);
        var facebookExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(facebookIcon, null, this, menu_selector(MenuLayer.onFacebook));
        facebookExtra.setSizeMult(1.5);
        socialsMenu.addChild(facebookExtra);

        var twitterIcon:CCSprite = CCSprite.createWithSpriteFrameName("GJ_twIcon_001.png");
        twitterIcon.setScale(0.8);
        var twitterExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(twitterIcon, null, this, menu_selector(MenuLayer.onTwitter));
        twitterExtra.setSizeMult(1.5);
        socialsMenu.addChild(twitterExtra);

        var youtubeIcon:CCSprite = CCSprite.createWithSpriteFrameName("GJ_ytIcon_001.png");
        youtubeIcon.setScale(0.8);
        var youtubeExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(youtubeIcon, null, this, menu_selector(MenuLayer.onYoutube));
        youtubeExtra.setSizeMult(1.5);
        socialsMenu.addChild(youtubeExtra);
        var twitchExtra:CCMenuItemSpriteExtra;
        var discordExtra:CCMenuItemSpriteExtra;
        if (!GameConfig.GD_PRE22MENUS) { //Port Note: ifndef = if (![condition])
            var twitchIcon:CCSprite = CCSprite.createWithSpriteFrameName("GJ_twitchIcon_001.png");
            twitchIcon.setScale(0.8);
            twitchExtra = CCMenuItemSpriteExtra.create(twitchIcon, null, this, menu_selector(MenuLayer.onTwitch));
            twitchExtra.setSizeMult(1.5);
            socialsMenu.addChild(twitchExtra);

            var discordIcon:CCSprite = CCSprite.createWithSpriteFrameName("GJ_discordIcon_001.png");
            discordIcon.setScale(0.8);
            discordExtra = CCMenuItemSpriteExtra.create(discordIcon, null, this, menu_selector(MenuLayer.onDiscord));
            discordExtra.setSizeMult(1.5);
            socialsMenu.addChild(discordExtra);
        }

        // Position social icons relative to each other
        facebookExtra.ccX = convertToNodeX(socialsMenu, pDirector.getScreenLeft() + 22.0);
        facebookExtra.ccY = convertToNodeY(socialsMenu, pDirector.getScreenBottom() + 30.0 + 25.0);
        twitterExtra.ccX = facebookExtra.ccX + 30.0;
        twitterExtra.ccY = facebookExtra.ccY;
        youtubeExtra.ccX = twitterExtra.ccX + 30.0;
        youtubeExtra.ccY = twitterExtra.ccY;
        //if (!GameConfig.GD_PRE22MENUS) {
        //    if (twitchExtra != null) {
        //        twitchExtra.ccX = youtubeExtra.ccX + 29.0;
        //        twitchExtra.ccY = youtubeExtra.ccY;
        //    }
        //    if (discordExtra != null) {
        //        discordExtra.ccX = youtubeExtra.ccX + 29.0;
        //        discordExtra.ccY = youtubeExtra.ccY + -29.0;
        //    }
        //}

        // ----------------------------------------------------------------------------------------------
        // Extra Menu
        // ----------------------------------------------------------------------------------------------

        var freeLevelsExtra:CCMenuItemSpriteExtra;
        if (GameConfig.GD_VERSION == "GD_LITE") {
            var freeLevelsButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_freeLevelsBtn_001.png");
            freeLevelsExtra = CCMenuItemSpriteExtra.create(freeLevelsButton, null, this, menu_selector(MenuLayer.onFreeLevels));
            
            if (!pGameManager.getGameVariable("0053"))
            {
                var scaleTo:CCScaleTo = CCScaleTo.create(0.5, 1.1);
                var easeInOut:CCEaseInOut = CCEaseInOut.create(scaleTo, 2.0);
                var scaleTo2:CCScaleTo = CCScaleTo.create(0.5, 1.0);
                var easeInOut2:CCEaseInOut = CCEaseInOut.create(scaleTo2, 2.0);
                var sequence:CCSequence = CCSequence.create([easeInOut, easeInOut2]);
                var repeatForever = CCRepeatForever.create(sequence);
                freeLevelsButton.runAction(repeatForever);
            }
        } else {
            var freeLevelsButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_moreGamesBtn_001.png");
            freeLevelsExtra = CCMenuItemSpriteExtra.create(freeLevelsButton, null, this, menu_selector(MenuLayer.onMoreGames));
        }

        var extraMenu = CCMenu.create();
        extraMenu.addChild(freeLevelsExtra);
        this.addChild(extraMenu);

        extraMenu.ccX = pDirector.getScreenRight() - 43.0;
        extraMenu.ccY = pDirector.getScreenBottom() + 45.0;

        if (GameConfig.GD_PLATFORM == "MOBILE") {
            if (!pGameManager.mUnknownBool3) {
                if (!pGameManager.getGameVariable("0106")) {
                    // Only show promo once
                    pGameManager.setGameVariable("0106", true);

                    var delay:CCDelayTime = CCDelayTime.create(0.1);
                    var callFunc:CCCallFunc = CCCallFunc.create(this, callfun_selector(MenuLayer.showMeltdownPromo));
                    var sequence:CCSequence = CCSequence.create([delay,callFunc]);
                    this.runAction(sequence);
                }
            }
        }

        pGameManager.mUnknownBool4 = false;

        if (GameConfig.GD_PLATFORM == "DESKTOP") {
            var closeButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_closeBtn_001.png");
            closeButton.setScale(0.7);
            var closeExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(closeButton, null, this, menu_selector(MenuLayer.onQuit));
            extraMenu.addChild(closeExtra);
            closeExtra.ccX = convertToNodeX(extraMenu, pDirector.getScreenLeft() + 18.0);
            closeExtra.ccY = convertToNodeY(extraMenu, pDirector.getScreenTop() - 18.0);
        }

        if (PlatformToolbox.isControllerConnected())
        {
            // TODO(C++): Implement MenuLayer::init
        }

        var profileButton:CCSprite = CCSprite.createWithSpriteFrameName("GJ_profileButton_001.png");
        this.mProfileButton = CCMenuItemSpriteExtra.create(profileButton, null, this, menu_selector(MenuLayer.onMyProfile));
        mainMenu.addChild(this.mProfileButton);
        this.mProfileButton.ccX = convertToNodeX(mainMenu, 45.0);
        this.mProfileButton.ccY = convertToNodeY(mainMenu, 105.0);
        

        this.mProfileText = CCLabelBMFont.create(" ", Helpers.LoadFont("goldFont"));
        this.addChild(this.mProfileText);
        this.mProfileText.ccX = 45.0 + 2.0;
        this.mProfileText.ccY = 105.0 + 36.0;

        if (!pGameManager.getGameVariable("0048") && pGameManager.mUsedGarageButton)
        {
            this.mProfileHelpText = CCSprite.createWithSpriteFrameName("GJ_viewProfileTxt_001.png");
            this.addChild(this.mProfileHelpText);
            this.mProfileHelpText.ccX = 45.0 + 76.0;
            this.mProfileHelpText.ccY = 105.0 + -1.0;
        }

        this.updateUserProfileButton();
        pGameManager.mCurrentMenu = this;

        var dailyButton:CCSprite;
        if (GameConfig.GD_VERSION != "GD_LITE" && GameConfig.GD_VERSION != "GD_WORLD") {
            dailyButton = CCSprite.createWithSpriteFrameName("GJ_dailyRewardBtn_001.png");
        } else {
            dailyButton = CCSprite.createWithSpriteFrameName("GJ_freeStuffBtn_001.png");
        }
        var dailyExtra:CCMenuItemSpriteExtra = CCMenuItemSpriteExtra.create(dailyButton, null, this, menu_selector(MenuLayer.onDaily));
        bottomMenu.addChild(dailyExtra);
        dailyExtra.ccX = convertToNodeX(bottomMenu, pDirector.getScreenRight() - 40.0);
        dailyExtra.ccY = convertToNodeY(bottomMenu, winSize.height * 0.5 + 20.0);
        dailyExtra.setSizeMult(1.5);

        return true;
    }

    public static function onOptionsInstant() {}
    public static function showMeltdownPromo() {}
    public dynamic function updateUserProfileButton() {
        // This implementation is specific to SubZero

        mProfileButton.setVisible(false);
        mProfileText.setVisible(false);
        if (mProfileHelpText != null) {
            mProfileHelpText.setVisible(false);
        }
    }
    public dynamic function willClose() {
        //GameManager.sharedState.mUnknownBool1 = false;
    }
    public static function onPlay(pSender) {
        // Get the current menu layer instance
        var menuLayer = cast(GameManager.sharedState().mCurrentMenu, MenuLayer);
        menuLayer.willClose();
        GameManager.sharedState().mUnknownInt1 = 8;

        //var pDirector = CCDirector.sharedDirector();
        //if (GameConfig.GD_VERSION == "GD_WORLD") {
        //    
        //}
        //var levelSelect = LevelSelectLayer.scene(0);
        //var fade = CCTransitionFade.create(0.5, levelSelect);
        //pDirector.replaceScene(fade);
    }
    public static function onGarage(pSender) {
        var menuLayer = cast(GameManager.sharedState().mCurrentMenu, MenuLayer);
        menuLayer.willClose();
        GameManager.sharedState().mUsedGarageButton = true;
    }
    public static function onCreator(pSender) {
        var menuLayer = cast(GameManager.sharedState().mCurrentMenu, MenuLayer);
        menuLayer.willClose();
        GameManager.sharedState().mUsedCreatorButton = true;
    }
    public static function onMyProfile(pSender) {}
    public static function onAchievements(pSender) {}
    public static function onOptions(pSender) {}
    public static function onStats(pSender) {}
    public static function onDaily(pSender) {}
    public static function onEveryplay(pSender) {}
    public static function onNewgrounds(pSender) {}
    public static function onRobtop(pSender) {}
    public static function onFacebook(pSender) {}
    public static function onTwitter(pSender) {}
    public static function onYoutube(pSender) {}
    public static function onTwitch(pSender) {}
    public static function onDiscord(pSender) {}
    public static function onMoreGames(pSender) {}
    public static function onFreeLevels(pSender) {}
    public static function onFullVersion(pSender) {}
    public static function onQuit(pSender) {
        if (GameConfig.CC_TARGET_PLATFORM == "CC_PLATFORM_WINRT" || GameConfig.CC_TARGET_PLATFORM == "CC_PLATFORM_WP8") {
            CCMessageBox("You pressed the close button. Windows Store Apps do not implement a close button.", "Alert");
        } else {
            CCDirector.sharedDirector().end(); //close
        }
    }

}
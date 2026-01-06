package misc;
import ccsim.CocosSim;

class GameManager {
    //GameManager.h
    //private:
    private var mCurrentBackground:Int;
    public var mUseLowQualityTextures:Bool;
    //public:
    public var mUnknownBool1:Bool;
    public var mUnknownBool4:Bool;
    public var mUnknownBool3:Bool;
    public var mUnknownInt1:Int;
    public var mUnknown1:Dynamic;
    public var mUnknown4:Dynamic;
    public var mUsedGarageButton:Bool;
    public var mShouldLoadLevelSaveData:Bool;
    public var mUnknownBool2:Bool;
    public var mUnknownBool5:Bool;
    public var mUnknownBool6:Bool;
    public var mUsedCreatorButton:Bool;
    public var mCurrentMenu:CCLayer;
    public var mGroundTexture:Int;
    public var mUnknownNew100:Dynamic;
    public var mUnknownNew101:Dynamic;
    public var mUnknownNew103:Dynamic;
    public var mUnknownNew104:Dynamic;
    
    private static var instance:GameManager;
    private var mGameVariables:Map<String, Bool>;
    
    public function new() {
        mCurrentBackground = 0;
        mGroundTexture = 0;
        mUseLowQualityTextures = false;

        mUnknownBool1 = false;
        mUnknownBool4 = false;
        mUnknownBool3 = false;
        mUnknownInt1 = 0;
        mUnknown1 = false;
        mUnknown4 = false;
        mUsedGarageButton = false;
        mShouldLoadLevelSaveData = false;
        mUnknownBool2 = false;
        mUsedCreatorButton = false;
        mCurrentMenu = null; 
        
        mGameVariables = new Map<String, Bool>();
    }
    public function init():Bool {
        this.firstLoad();
        return true;
    }
    public function firstLoad() {
        //GameLevelManager.sharedState().firstSetup();
    }
    public function getBGTexture(index:Int):String {
        var num:Int = 1;
        if (index > 0)
        {
            num = index;
            if (index > 22)
                num = 22;
        }
        this.loadBackground(num);
        var s:String = "game_bg_" + Std.string(num) + "_001.png";
        return s;
    }
    public function loadBackground(index:Int) {
        var num:Int = 1;
        if (index > 0)
        {
            num = index;
            if (index > 22)
                num = 22;
        }
        
        var currentBG:Int = mCurrentBackground;
        
        if (num != currentBG)
        {
            if (currentBG > 0)
            {
                var old:String = "game_bg_" + Std.string(currentBG) + "_001.png";
            }

            var s:String = "game_bg_" + Std.string(num) + "_001.png";

            var pApp:AppDelegate = AppDelegate.get();
            var useLQTextures:Bool = true;
            if (!pApp.mLowQualityTextures)
                useLQTextures = mUseLowQualityTextures;

            mCurrentBackground = num;
        }
    }
    public function updateMusic() {}
    public function fadeInMusic(music:String) {}
    public function setGameVariable(name:String, value:Bool) {
        mGameVariables.set(name, value);
        trace("Set game variable " + name + " = " + value);
    }
    public function getGameVariable(name:String):Bool {
        return mGameVariables.exists(name) ? mGameVariables.get(name) : false;
    }
    public function syncPlatformAchievements() {}
    public function tryCacheAd() {}
    
    public static function sharedState():GameManager {
        if (instance == null) {
            instance = new GameManager();
            instance.init();
        }
        return instance;
    }
}
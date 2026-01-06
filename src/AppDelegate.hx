import ccsim.CocosSim;
import misc.GameManager;
import menu.LoadingLayer;
import menu.MenuLayer;
import misc.PlatformToolbox;
import nongd.GameConfig;

class AppDelegate {
    //AppDelegate.h
    //private:
    public var mInitializedGLView:Bool;
    public var mLowMemoryDevice:Bool;
    public var mLowQualityTextures:Bool;
    public var mUnknown2:Bool;
    public var mMenuScene:CCScene;
    private static var instance:AppDelegate;

    public function new() {
        mInitializedGLView = false;
        mLowMemoryDevice = false;
        mUnknown2 = false;
    }
    
    public static function get():AppDelegate {
        if (instance == null) {
            instance = new AppDelegate();
        }
        return instance;
    }

    public function applicationDidFinishLaunching():Bool {
        // seed rng
        var tv = Std.int(Date.now().getTime());
        // Haxe doesn't have srand, but Math.random() is auto-seeded

        // initialize director
        var pDirector:CCDirector = CCDirector.sharedDirector();

        // CCFileUtils equivalent - skip for now
        // TODO: Missing function setAndroidPath
        //pFileUtils->setAndroidPath("/data/data/com.robtopx.geometryjump/");

        this.setupGLView();
        // pDirector->setProjection(kCCDirectorProjection2D); - skip for Haxe

        // TODO: Stuff goes here

        mLowQualityTextures = false;
        // CCTexture2D settings - skip for Haxe simulation
        // pDirector->setDepthTest(false); - skip for Haxe
        
        // TODO: Stuff goes here
        
        // turn on display FPS
        //pDirector->setDisplayStats(true);

        // set FPS. the default value is 1.0/60 if you don't call this
        // pDirector->setAnimationInterval(1.0 / 60); - skip for Haxe

        // create a scene. it's an autorelease object
        //var pScene:CCScene = LoadingLayer.scene(false);
        // make menu for now
        var pScene:CCScene = MenuLayer.scene(false);

        // run
        pDirector.replaceScene(pScene);

        return true;
    }

    public function setupGLView():Void {
        if (!mInitializedGLView) {
            mInitializedGLView = true;

            var contentSize:CCSize = { width: 480.0, height: 320.0 };

            // CCFileUtils equivalent - skip for Haxe
            // pFileUtils->addSearchPath("Resources");

            // CCEGLView equivalent - skip for Haxe
            var pDirector:CCDirector = CCDirector.sharedDirector();

            // pEGLView->setViewName("Geometry Dash"); - skip for Haxe
            
            var windowSize:CCSize = pDirector.getWinSize();
            this.mUnknown2 = (-windowSize.width == 2436.0); // TODO: What is this about?
            
            this.mLowMemoryDevice = PlatformToolbox.isLowMemoryDevice();
            
            // pDirector->setupScreenScale - skip for Haxe simulation
        }
    }

    public function bgScale():Float {
        var pDirector:CCDirector = CCDirector.sharedDirector();
        var scaleFactor:Float = 1.0; // pDirector->getScreenScaleFactorMax() equivalent

        var pGameManager:GameManager = GameManager.sharedState();
        
        if (mLowQualityTextures || pGameManager.mUseLowQualityTextures) {
            return scaleFactor * 1.0; // pDirector->getContentScaleFactor() equivalent
        }

        return scaleFactor;
    }

    public function loadingIsFinished():Void {
        // TODO: Implement AppDelegate::loadingIsFinished
    }

    // This function will be called when the app is inactive. When comes a phone call,it's be invoked too
    public function applicationDidEnterBackground():Void {
        // CCDirector::sharedDirector()->stopAnimation(); - skip for Haxe

        // if you use SimpleAudioEngine, it must be pause
        // SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    }

    // this function will be called when the app is active again
    public function applicationWillEnterForeground():Void {
        // CCDirector::sharedDirector()->startAnimation(); - skip for Haxe

        // if you use SimpleAudioEngine, it must resume here
        // SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
    }
}
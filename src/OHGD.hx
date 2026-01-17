// Contributions:
// Crzy (crzylemon)
// Sources:
// Crzy (crzylemon)

import ccsim.Stubs.CCDirector;
import nongd.GameConfig;
import ccsim.*;

//import hxd.App;
/*
import nongd.GameConfig;
import nongd.Helpers;

import ccsim.*;

class OHGD extends App {
    public var cocosRoot:h2d.Object;
    override function init() {
        // init gameconfig
        GameConfig.init();

        // init resource loader
        hxd.Res.initEmbed();

        Helpers.setBaseSize(1920,1080);
        
        cocosRoot = new h2d.Object(s2d);

        CCDirector.app = this;
        
        // appdelegate
        var appDelegate = new AppDelegate();
        appDelegate.applicationDidFinishLaunching();
    }

    static function main() {
        new OHGD();
    }
}
*/
#if ENABLE_MODLOADER
import ModLoad;
#end

class OHGD {
    public function new() {
        // init gameconfig
        GameConfig.init();

        // cocos
        var director = CCDirector.getInstance();

        // no appdelegate yet

        // mod loader
        #if ENABLE_MODLOADER
        ModLoader.getInstance().loadDynamicMods(function() {
            ModLoader.getInstance().initMods();
            Hooks.call(Hooks.Defs.OnGameLoadStart, [], null);
        });
        #end
    }
    //empty
    static function main() {
        new OHGD();
    }
}
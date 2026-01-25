// Contributions:
// Crzy (crzylemon)
// Sources:
// Crzy (crzylemon)

import ccsim.Stubs;
import nongd.GameConfig;
import nongd.ResourcePath;
//import ccsim.*;

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
        
        // Get resource path
        var resPath = ResourcePath.getResourcePath();
        if (resPath == "") {
            trace("[OHGD] No valid resource path provided, exiting");
            #if sys
            Sys.exit(1);
            #end
            return;
        }
        trace('[OHGD] Using resource path: $resPath');

        // cocos
        var director = CCDirector.getInstance();

        // no appdelegate yet

        // mod loader
        #if ENABLE_MODLOADER
        ModLoader.getInstance().loadDynamicMods(function() {
            ModLoader.getInstance().initMods();
            Hooks.call(Hooks.Defs.OnGameLoadStart, [], null);
            
            // Keep program running on sys targets
            #if sys
            trace("[OHGD] Press Ctrl+C to exit loop (this is for mods to run)");
            while (true) {
                Sys.sleep(0.1);
            }
            #end
        });
        #end
    }
    //empty
    static function main() {
        new OHGD();
    }
}
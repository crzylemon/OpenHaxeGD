import hxd.App;
import nongd.GameConfig;
import nongd.Helpers;
import ccsim.CocosSim.CCDirector;

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

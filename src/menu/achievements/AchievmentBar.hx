package menu.achievements;
import ccsim.CocosSim;

class AchievmentBar {
    public function new() {
    }
    
    public static function AchievmentBar() {}
    public static function create(title:String, description:String, icon:String) {
        var pRet = new AchievmentBar();
        if (pRet.init(title,description,icon)) {
            pRet.autorelease();
            return pRet;
        } else {
            pRet = null;
            return null;
        }
    }
    // init (override of base class, put "override")
    public function init(title:String, description:String, icon:String):Bool {
        CCLOG("creating achievement bar for %s", [title]);
        return true;
    }
    public function autorelease() {
        return;
    }
}
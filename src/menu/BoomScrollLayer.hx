// Contributions:
// Crzy (crzylemon)
// Source:
// aloaf's 1.7 decomp (May be outdated?)
package menu;
import ccsim.*;

class BoomScrollLayerDelegate {
    public static function scrollLayerMoved(p0:CCPoint) {}
    public static function scrollLayerScrolledToPage(bsl:BoomScrollLayer, p1:Int) {}
    public static function scrollLayerScrollingStarted(bsl:BoomScrollLayer) {}
}

class BoomScrollLayer {
    public var m_bslDelegate:Dynamic;
    
    public function new() {
        m_bslDelegate = null;
    }
    
    public dynamic function create(pages:Array<Dynamic>, width:Float, height:Float):BoomScrollLayer {
        //BoomScrollLayer* ret = new BoomScrollLayer();
        var ret = new BoomScrollLayer();
        if (ret.init()) {
            ret.autorelease();
            return ret;
        }
        return null;
    }

    public function init():Bool {
        return true;
    }
    public function autorelease() {
        return;
    }
}
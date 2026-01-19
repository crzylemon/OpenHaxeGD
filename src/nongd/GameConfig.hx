// Contributions:
// Crzy (crzylemon)
package nongd;

class GameConfig {
    public static var SCREEN_WIDTH:Int = {
        #if js
        var canvas = js.Browser.document.getElementById("webgl");
        canvas.clientWidth;
        #else
        800; // Default width
        #end
    };
    
    public static var SCREEN_HEIGHT:Int = {
        #if js
        var canvas = js.Browser.document.getElementById("webgl");
        canvas.clientHeight;
        #else
        600; // Default height
        #end
    };
    // -------------------- CHANGE BELOW --------------------
    // Geometry Dash

    // Replace the "GD" string if you want a different game!
    // Can be:
    // GD_SUBZERO
    // GD_MELTDOWN
    // GD_WORLD
    // GD_LITE
    // GD_TRIAL_VERSION (Another name for GD_LITE...)
    public static var GD_VERSION:String = "GD";
    // Replace "DESKTOP" if you want a different platform!
    // Can be:
    // DESKTOP
    // MOBILE
    // Others if i find one
    public static var GD_PLATFORM:String = "DESKTOP";
    // You can replace these:
    public static var GD_PRE22MENUS:Bool = false;
    public static var CC_TARGET_PLATFORM:String = {
        #if cpp
        "CC_PLATFORM_WIN32"; //Change to WINRT or WP8 if you want the Windows Store quit pop up for some reason...
        #elseif android
        "CC_PLATFORM_ANDROID";
        #elseif ios
        "CC_PLATFORM_IOS";
        #else
        "CC_PLATFORM_WIN32"; //default
        #end
    }; 
    // Cocos2d-x
    public static var CC_ENABLE_SCRIPT_BINDING:Bool = false;
    public static var CC_USE_PHYSICS:Bool = false;
    public static var CC_ENABLE_GC_FOR_NATIVE_OBJECTS:Bool = false;

    // Lapis
    public static var LAPIS_DEBUG:Bool = true;

    // -------------------- CHANGE ABOVE --------------------
    
    public static function init() {
        trace("GameConfig initialized");
    }
}
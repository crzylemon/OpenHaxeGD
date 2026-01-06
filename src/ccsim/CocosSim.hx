package ccsim;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;
import h2d.Scene;
import h2d.Text;
import h2d.Font;
import nongd.Helpers;
//simulate multiple cocos2d funcs or types if they dont exist normally

//CCPoint
typedef CCPoint = { x:Float, y:Float };
//CCLOG function that logs
function CCLOG(format:String, ?args:Array<Dynamic>):Void {
    var message = format;
    if (args != null) {
        for (i in 0...args.length) {
            message = StringTools.replace(message, "%s", Std.string(args[i]));
        }
    }
    trace(message);
}

//CCMessageBox function
function CCMessageBox(message:String, title:String = "Alert"):Void {
    #if js
    js.Browser.alert(title + ": " + message);
    #elseif (cpp && windows)
    untyped __cpp__("MessageBoxA(NULL, {0}, {1}, MB_OK)", message, title);
    #elseif (cpp && mac)
    Sys.command('osascript -e "display dialog \"' + message + '\" with title \"' + title + '\""');
    #elseif (cpp && linux)
    Sys.command('zenity --info --title="' + title + '" --text="' + message + '"');
    #else
    trace(title + ": " + message);
    #end
}

class CCSprite extends Bitmap {
    public function new(?texture:h2d.Tile = null) {
        super(texture);
        // Add a colored rectangle if no texture
        this.scaleY = -1;

        if (texture == null) {
            var g = new h2d.Graphics(this);
            g.beginFill(0xFF0000); // Red color for visibility
            g.drawRect(0, 0, 50, 50);
            g.endFill();
        }
        
    }

    public static function create(?texture:h2d.Tile = null):CCSprite {
        return new CCSprite(texture);
    }

    public static function createWithSpriteFrameName(frameName:String):CCSprite {
        try {
            // Try direct resource access first
            var tile = hxd.Res.load(frameName).toTile();
            return new CCSprite(tile);
        } catch (e:Dynamic) {
            try {
                // Try loading from spritesheets
                var tile = loadFromSpriteSheet(frameName);
                if (tile != null) {
                    return new CCSprite(tile);
                }
            } catch (e2:Dynamic) {}
            
            // Fallback to colored rectangle
            trace("Could not load sprite: " + frameName);
            var sprite = new CCSprite();
            var g = new h2d.Graphics(sprite);
            g.beginFill(0x00FF00);
            g.drawRect(0, 0, 64, 64);
            g.endFill();
            return sprite;
        }
    }
    
    private static function loadFromSpriteSheet(frameName:String):h2d.Tile {
        var sheets = ["GJ_LaunchSheet", "GJ_GameSheet", "GJ_GameSheet02", "GJ_GameSheet03", "GJ_GameSheet04",
            "GJ_GameSheetEditor", "GJ_GameSheetGlow", "GJ_GameSheetIcons", "GJ_ShopSheet", 
            "GJ_ShopSheet01", "GJ_ShopSheet02", "GJ_ShopSheet03", "GJ_ParticleSheet", "GJ_PathSheet",
            "CCControlColourPickerSpriteSheet", "DungeonSheet", "FireSheet_01", "GauntletSheet",
            "PixelSheet_01", "SecretSheet", "TowerSheet", "TreasureRoomSheet", "WorldSheet"];
        
        for (sheet in sheets) {
            try {
                var plistData = hxd.Res.load(sheet + ".plist").entry.getText();
                var frameData = parsePlistForFrame(plistData, frameName);
                
                if (frameData != null) {
                    var texture = hxd.Res.load(sheet + ".png").toTile();
                    var tile = texture.sub(frameData.x, frameData.y, frameData.w, frameData.h);
                    
                    if (frameData.rotated) {
                        // For rotated textures, create a sprite that rotates counter-clockwise
                        var sprite = new CCSprite(tile);
                        sprite.rotation = -Math.PI / 2; // -90 degrees (counter-clockwise)
                        return sprite.tile;
                    }
                    return tile;
                }
            } catch (e:Dynamic) {
                continue;
            }
        }
        return null;
    }
    
    private static function parsePlistForFrame(plistXml:String, frameName:String):{x:Int, y:Int, w:Int, h:Int, rotated:Bool} {
        // Find frame entry
        var frameIndex = plistXml.indexOf('<key>' + frameName + '</key>');
        if (frameIndex >= 0) {
            var dictStart = plistXml.indexOf('<dict>', frameIndex);
            var dictEnd = plistXml.indexOf('</dict>', dictStart);
            if (dictStart >= 0 && dictEnd >= 0) {
                var frameDict = plistXml.substring(dictStart, dictEnd);
                
                // Extract textureRect
                var rectStart = frameDict.indexOf('textureRect');
                if (rectStart >= 0) {
                    var coordStart = frameDict.indexOf('{{', rectStart);
                    var coordEnd = frameDict.indexOf('}}', coordStart);
                    if (coordStart >= 0 && coordEnd >= 0) {
                        var coords = frameDict.substring(coordStart + 2, coordEnd);
                        var parts = coords.split('},{');
                        if (parts.length == 2) {
                            var pos = parts[0].split(',');
                            var size = parts[1].split(',');
                            if (pos.length == 2 && size.length == 2) {
                                // Check if rotated - look for textureRotated followed by true
                                var rotatedIndex = frameDict.indexOf('textureRotated');
                                var rotated = false;
                                if (rotatedIndex >= 0) {
                                    var trueIndex = frameDict.indexOf('<true/>', rotatedIndex);
                                    var falseIndex = frameDict.indexOf('<false/>', rotatedIndex);
                                    rotated = (trueIndex >= 0 && (falseIndex < 0 || trueIndex < falseIndex));
                                }
                                
                                return {
                                    x: Std.parseInt(pos[0]),
                                    y: Std.parseInt(pos[1]),
                                    w: Std.parseInt(size[0]),
                                    h: Std.parseInt(size[1]),
                                    rotated: rotated
                                };
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public function runAction(action:Object):Void {
        // Stub for action execution
    }

    public function setVisible(visible:Bool):Void {
        this.visible = visible;
    }
    
    public function setCCPosition(x:Float, y:Float):Void {
        this.ccX = x;
        this.ccY = y;
    }
    
    public var ccX(get, set):Float;
    public var ccY(get, set):Float;

    function get_ccX():Float return this.x;
    function set_ccX(v:Float):Float return this.x = v;

    function get_ccY():Float return this.y;
    function set_ccY(v:Float):Float return this.y = v;

    
    public function GetCCPos():{x:Float, y:Float} {
        return {x: this.get_ccX(), y: this.get_ccY()};
    }
    
    public function SetCCScale(scale:Float):Void {
        this.scaleX = scale;
        this.scaleY = scale;
    }

}

class CCLabelBMFont extends h2d.Text {
    private var textStr:String;
    public var size:Float = 1.0;

    public function new(textStr:String = "", ?font:Font = null) {
        super(font != null ? font : hxd.res.DefaultFont.get());
        this.textStr = textStr;
        this.text = textStr;
        this.textColor = 0xFFFFFF;
    }

    public static function create(textStr:String = "", ?font:Font = null):CCLabelBMFont {
        return new CCLabelBMFont(textStr, font);
    }

    public function setString(textStr:String):Void {
        this.textStr = textStr;
        this.text = textStr;
    }
    
    public function setVisible(visible:Bool):Void {
        this.visible = visible;
    }

    public function setCCPosition(x:Float, y:Float):Void {
        this.ccX = x;
        this.ccY = y;
    }
    
    public var ccX(get, set):Float;
    public var ccY(get, set):Float;

    function get_ccX():Float return this.x;
    function set_ccX(v:Float):Float return this.x = v;

    function get_ccY():Float return this.y;
    function set_ccY(v:Float):Float return this.y = v;

    
    public function GetCCPos():{x:Float, y:Float} {
        return {x: this.get_ccX(), y: this.get_ccY()};
    }
    
    public function SetCCScale(scale:Float):Void {
        this.scaleX = scale;
        this.scaleY = scale;
    }
}

class CCScene extends Scene {
    public function new() {
        super();
    }

    public static function create():CCScene {
        return new CCScene();
    }

}

class CCDelayTime extends Object {
    private var duration:Float;

    public function new(duration:Float) {
        super();
        this.duration = duration;
    }

    public static function create(duration:Float):CCDelayTime {
        return new CCDelayTime(duration);
    }
}

class CCCallFunc extends Object {
    private var target:Dynamic;
    private var callback:Dynamic;

    public function new(target:Dynamic, callback:Dynamic) {
        super();
        this.target = target;
        this.callback = callback;
    }

    public static function create(target:Dynamic, callback:Dynamic):CCCallFunc {
        return new CCCallFunc(target, callback);
    }
}

class CCSequence extends Object {
    private var actions:Array<Object>;

    public function new(actions:Array<Object>) {
        super();
        this.actions = actions;
    }

    public static function create(actions:Array<Object>):CCSequence {
        return new CCSequence(actions);
    }
}

class CCLayer extends Object {
    public function new() {
        super();
    }

    public static function create():CCLayer {
        return new CCLayer();
    }

    public function init():Bool {
        return true;
    }

    public function runAction(action:Object):Void {
        // Stub
    }

    public function autorelease():Void {
        // Stub
    }

    public function setKeypadEnabled(enabled:Bool):Void {
        // Stub
    }
    
    public function setVisible(visible:Bool):Void {
        this.visible = visible;
    }
    
    public function setCCPosition(x:Float, y:Float):Void {
        this.ccX = x;
        this.ccY = y;
    }
    
    public var ccX(get, set):Float;
    public var ccY(get, set):Float;

    function get_ccX():Float return this.x;
    function set_ccX(v:Float):Float return this.x = v;

    function get_ccY():Float return this.y;
    function set_ccY(v:Float):Float return this.y = v;

    
    public function GetCCPos():{x:Float, y:Float} {
        return {x: this.get_ccX(), y: this.get_ccY()};
    }
    
    public function SetCCScale(scale:Float):Void {
        this.scaleX = scale;
        this.scaleY = scale;
    }
}

typedef CCSize = { width:Float, height:Float };

class CCMenu extends Object {
    public function new() {
        super();
    }

    public static function create():CCMenu {
        return new CCMenu();
    }

    public function alignItemsHorizontallyWithPadding(padding:Float):Void {
        var children = this.children;
        if (children.length == 0) return;
        
        var totalWidth = 0.0;
        for (child in children) {
            var w = child.getBounds().width / child.scaleX;
            totalWidth += w + padding;
        }
        totalWidth -= padding; // Remove last padding
        
        var startX = -totalWidth * 0.5;
        var currentX = startX;
        
        for (child in children) {
            var w = child.getBounds().width / child.scaleX;
            child.x = currentX + w * 0.5;
            currentX += w + padding;
        }
    }

    public function setCCPosition(x:Float, y:Float):Void {
        this.ccX = x;
        this.ccY = y;
    }
    
    public var ccX(get, set):Float;
    public var ccY(get, set):Float;

    function get_ccX():Float return this.x;
    function set_ccX(v:Float):Float return this.x = v;

    function get_ccY():Float return this.y;
    function set_ccY(v:Float):Float return this.y = v;

    
    public function GetCCPos():{x:Float, y:Float} {
        return {x: this.get_ccX(), y: this.get_ccY()};
    }
    
    public function SetCCScale(scale:Float):Void {
        this.scaleX = scale;
        this.scaleY = scale;
    }
}

class CCDirector {
    private static var instance:CCDirector;
    private var currentScene:CCScene;
    public static var app:OHGD;

    public function new() {
        currentScene = null;
    }

    public static function sharedDirector():CCDirector {
        if (instance == null) instance = new CCDirector();
        return instance;
    }

    public function getTouchDispatcher():CCTouchDispatcher {
        return new CCTouchDispatcher();
    }

    public function getWinSize():CCSize {
        return { width: 1280, height: 720 };
    }

    public function getScreenTop():Float return getWinSize().height;
    public function getScreenBottom():Float return 0;
    public function getScreenLeft():Float return 0;
    public function getScreenRight():Float return getWinSize().width;
    
    public function replaceScene(scene:Object):Void {
        trace("Replacing scene with: " + scene);
        
        // Remove current scene from render tree
        if (currentScene != null && app != null) {
            app.cocosRoot.removeChild(currentScene);
        }
        
        // Set new scene as current
        if (Std.isOfType(scene, CCScene)) {
            currentScene = cast(scene, CCScene);
            trace("Scene set as current");
            
            // Add to render tree
            if (app != null) {
                app.cocosRoot.addChild(currentScene);
            }
            
            // Initialize all layers in the scene
            for (i in 0...currentScene.numChildren) {
                var child = currentScene.getChildAt(i);
                trace("Initializing child: " + child);
                if (Std.isOfType(child, CCLayer)) {
                    var layer = cast(child, CCLayer);
                    layer.init();
                }
            }
        }
    }
    
    public function getCurrentScene():CCScene {
        return currentScene;
    }
    
    public function end():Void {
        trace("Ending application");
        #if sys
        Sys.exit(0);
        #else
        // For web/other platforms, just trace
        trace("Application end requested");
        #end
    }
}

class CCTouchDispatcher {
    public function new() {}

    public function setForcePrio(prio:Int):Void {}
}

function menu_selector(func:Dynamic):Dynamic {
    return func;
}

class CCScaleTo extends Object {
    private var duration:Float;
    private var tscale:Float;

    public function new(duration:Float, scale:Float) {
        super();
        this.duration = duration;
        this.tscale = scale;
    }

    public static function create(duration:Float, scale:Float):CCScaleTo {
        return new CCScaleTo(duration, scale);
    }
}

class CCEaseInOut extends Object {
    private var action:Object;
    private var rate:Float;

    public function new(action:Object, rate:Float) {
        super();
        this.action = action;
        this.rate = rate;
    }

    public static function create(action:Object, rate:Float):CCEaseInOut {
        return new CCEaseInOut(action, rate);
    }
}

class CCRepeatForever extends Object {
    private var action:Object;

    public function new(action:Object) {
        super();
        this.action = action;
    }

    public static function create(action:Object):CCRepeatForever {
        return new CCRepeatForever(action);
    }
}

class CCTransitionFade extends Object {
    private var duration:Float;
    private var scene:Object;

    public function new(duration:Float, scene:Object) {
        super();
        this.duration = duration;
        this.scene = scene;
    }

    public static function create(duration:Float, scene:Object):CCTransitionFade {
        return new CCTransitionFade(duration, scene);
    }
}

function callfun_selector(func:Dynamic):Dynamic {
    return func;
}

typedef MenuCallback = Void->Void;
class CCMenuItemSpriteExtra extends h2d.Interactive {
    public var normal:CCSprite;
    public var selected:CCSprite;
    public var callback:MenuCallback;
    public var enabled:Bool = true;

    public function new(normal:CCSprite, ?selected:CCSprite = null, ?callback:MenuCallback = null) {
        super(64, 64); // Set interactive area size
        this.normal = normal;
        this.selected = selected != null ? selected : normal;
        this.callback = callback;
        
        addChild(normal); // Add sprite to this container
        
        // Add click handler
        this.onClick = function(e) {
            if (enabled && callback != null) {
                callback();
            }
        };
        
        this.cursor = hxd.Cursor.Button;
    }

    // Simulate a click
    public function activate():Void {
        if (enabled && callback != null) callback();
    }

    // Visibility
    public function setVisible(flag:Bool):Void {
        this.visible = flag;
        normal.visible = flag;
        if (selected != null) selected.visible = flag;
    }

    // Optional: swap sprite if you want hover/selected effect
    public function select(flag:Bool):Void {
        if (flag) {
            if (selected != null) {
                removeChild(normal);
                addChild(selected);
            }
        } else {
            removeChild(selected);
            addChild(normal);
        }
    }

    // Factory method like C++ create()
    public static function create(normal:CCSprite, ?selected:CCSprite = null, ?target:Dynamic = null, ?callback:Dynamic = null):CCMenuItemSpriteExtra {
        return new CCMenuItemSpriteExtra(normal, selected, callback);
    }

    public function setSizeMult(mult:Float):Void {
        this.scaleX = mult;
        this.scaleY = mult;
    }
    
    public function setCCPosition(x:Float, y:Float):Void {
        this.ccX = x;
        this.ccY = y;
    }
    
    public var ccX(get, set):Float;
    public var ccY(get, set):Float;

    function get_ccX():Float return this.x;
    function set_ccX(v:Float):Float return this.x = v;

    function get_ccY():Float return this.y;
    function set_ccY(v:Float):Float return this.y = v;

    
    public function GetCCPos():{x:Float, y:Float} {
        return {x: this.get_ccX(), y: this.get_ccY()};
    }
    
    public function SetCCScale(scale:Float):Void {
        this.scaleX = scale;
        this.scaleY = scale;
    }
}
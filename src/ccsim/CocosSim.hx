package ccsim;

import h2d.*;
import h2d.Bitmap;
import h2d.Text;
import h2d.Font;

//help

// CCPoint and CCSize
typedef CCPoint = { x:Float, y:Float };
typedef CCSize = { width:Float, height:Float };

// ------------------------
// Helpers
// ------------------------
function CCLOG(format:String, ?args:Array<Dynamic>):Void {
    var message = format;
    if(args != null) for(i in 0...args.length) {
        message = StringTools.replace(message, "%s", Std.string(args[i]));
    }
    trace(message);
}

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

function convertToNodeSpace(parent:Dynamic, screenPos:CCPoint):CCPoint {
    var parentPos = parent.GetCCPos();
    return { x: screenPos.x - parentPos.x, y: screenPos.y - parentPos.y };
}
function convertToNodeX(parent:Dynamic, screenX:Float):Float {
    return screenX - parent.GetCCPos().x;
}
function convertToNodeY(parent:Dynamic, screenY:Float):Float {
    return screenY - parent.GetCCPos().y;
}
function printSceneStructure(obj:Object, indent:String = ""):Void {
    var className = Type.getClassName(Type.getClass(obj));
    if (className == null) className = "Object";
    
    var pos = "";
    if (Std.isOfType(obj, CCSprite) || Std.isOfType(obj, CCLabelBMFont) || Std.isOfType(obj, CCMenuItemSpriteExtra)) {
        var ccObj:Dynamic = obj;
        if (ccObj.GetCCPos != null) {
            var ccPos = ccObj.GetCCPos();
            pos = ' ccPos(${ccPos.x}, ${ccPos.y})';
        }
    }
    
    trace('${indent}${className} x:${obj.x} y:${obj.y}${pos} visible:${obj.visible}');
    
    for (i in 0...obj.numChildren) {
        printSceneStructure(obj.getChildAt(i), indent + "  ");
    }
}

// ------------------------
// Base CCNode
// ------------------------
class CCNode extends Object {
    public var anchorX:Float = 0.5;
    public var anchorY:Float = 0.5;

    public function new() { super(); }

    public var ccX(get,set):Float;
    public var ccY(get,set):Float;

    function get_ccX():Float return x + getBounds().width * anchorX;
    function set_ccX(v:Float):Float return x = v - getBounds().width * anchorX;

    function get_ccY():Float return CCDirector.sharedDirector().getWinSize().height - y - getBounds().height * anchorY;
    function set_ccY(v:Float):Float return y = CCDirector.sharedDirector().getWinSize().height - v - getBounds().height * anchorY;

    public function SetCCScale(scale:Float):Void { scaleX = scale; scaleY = scale; }
    public function GetCCPos():CCPoint { return { x: ccX, y: ccY }; }
}

// ------------------------
// CCSprite
// ------------------------
class CCSprite extends Bitmap {
    public var anchorX:Float = 0.5;
    public var anchorY:Float = 0.5;
    public var texture:h2d.Tile;

    public function new(?texture:h2d.Tile = null) {
        super(texture);
        this.texture = texture;

        if(texture != null) {
            x = -texture.width * anchorX;
            y = -texture.height * anchorY;
        } else {
            var g = new Graphics(this);
            g.beginFill(0xFF0000);
            g.drawRect(-25,-25,50,50);
            g.endFill();
        }
    }

    public static function create(?texture:h2d.Tile = null):CCSprite return new CCSprite(texture);

    public static function createWithSpriteFrameName(frameName:String):CCSprite {
        try {
            var tile = hxd.Res.load(frameName).toTile();
            return new CCSprite(tile);
        } catch(e:Dynamic) {
            // Try loading from spritesheets
            var sprite = loadFromSpriteSheet(frameName);
            if (sprite != null) return sprite;
            
            // Fallback to placeholder
            trace("Could not load sprite: " + frameName);
            var sprite = new CCSprite();
            var g = new Graphics(sprite);
            g.beginFill(0x00FF00);
            g.drawRect(0,0,64,64);
            g.endFill();
            return sprite;
        }
    }
    
    private static function loadFromSpriteSheet(frameName:String):CCSprite {
        var sheets = ["GJ_LaunchSheet", "GJ_GameSheet", "GJ_GameSheet02", "GJ_GameSheet03", "GJ_GameSheet04"];
        
        for (sheet in sheets) {
            try {
                var plistData = hxd.Res.load(sheet + ".plist").entry.getText();
                var frameData = parsePlistForFrame(plistData, frameName);
                
                if (frameData != null) {
                    var texture = hxd.Res.load(sheet + ".png").toTile();
                    var tile = texture.sub(frameData.x, frameData.y, frameData.w, frameData.h);
                    
                    if (frameData.rotated) {
                        // Create a rotated sprite
                        var sprite = new CCSprite(tile);
                        sprite.rotation = -Math.PI / 2; // -90 degrees counter-clockwise
                        return sprite;
                    }
                    return new CCSprite(tile);
                }
            } catch (e:Dynamic) continue;
        }
        return null;
    }
    
    private static function parsePlistForFrame(plistXml:String, frameName:String):{x:Int, y:Int, w:Int, h:Int, rotated:Bool} {
        var frameIndex = plistXml.indexOf('<key>' + frameName + '</key>');
        if (frameIndex >= 0) {
            var dictStart = plistXml.indexOf('<dict>', frameIndex);
            var dictEnd = plistXml.indexOf('</dict>', dictStart);
            if (dictStart >= 0 && dictEnd >= 0) {
                var frameDict = plistXml.substring(dictStart, dictEnd);
                
                // Check if rotated
                var rotatedIndex = frameDict.indexOf('textureRotated');
                var rotated = false;
                if (rotatedIndex >= 0) {
                    var trueIndex = frameDict.indexOf('<true/>', rotatedIndex);
                    var falseIndex = frameDict.indexOf('<false/>', rotatedIndex);
                    rotated = (trueIndex >= 0 && (falseIndex < 0 || trueIndex < falseIndex));
                }
                
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

    public function runAction(action:Object):Void {}
    public function setVisible(v:Bool):Void this.visible = v;

    public function setCCPosition(x:Float, y:Float):Void { ccX = x; ccY = y; }
    public function applyAnchor():Void {
        if(texture != null) { this.x = -texture.width * anchorX; this.y = -texture.height * anchorY; }
    }

    public var ccX(get,set):Float;
    public var ccY(get,set):Float;

    function get_ccX():Float return x + (texture != null ? texture.width * anchorX : 0);
    function set_ccX(v:Float):Float return x = v - (texture != null ? texture.width * anchorX : 0);

    function get_ccY():Float return CCDirector.sharedDirector().getWinSize().height - y - (texture != null ? texture.height * anchorY : 0);
    function set_ccY(v:Float):Float return y = CCDirector.sharedDirector().getWinSize().height - v - (texture != null ? texture.height * anchorY : 0);

    public function GetCCPos():CCPoint {
        return { x: x + (texture != null ? texture.width * anchorX : 0), 
                 y: CCDirector.sharedDirector().getWinSize().height - y - (texture != null ? texture.height * anchorY : 0) };
    }
}

// ------------------------
// CCLabelBMFont
// ------------------------
class CCLabelBMFont extends Text {
    private var textStr:String;
    public var anchorX:Float = 0.5;
    public var anchorY:Float = 0.5;
    public var size:Float = 1.0;

    public function new(textStr:String = "", ?font:Font = null) {
        super(font != null ? font : hxd.res.DefaultFont.get());
        this.textStr = textStr;
        this.text = textStr;
        this.textColor = 0xFFFFFF;
    }

    public static function create(textStr:String = "", ?font:Font = null):CCLabelBMFont return new CCLabelBMFont(textStr, font);

    public function setString(str:String):Void { textStr = str; text = str; }
    public function setVisible(v:Bool):Void this.visible = v;
    public function setCCPosition(x:Float, y:Float):Void { ccX = x; ccY = y; }

    public var ccX(get,set):Float;
    public var ccY(get,set):Float;

    function get_ccX():Float return x + textWidth * anchorX;
    function set_ccX(v:Float):Float return x = v - textWidth * anchorX;

    function get_ccY():Float return CCDirector.sharedDirector().getWinSize().height - y - textHeight * anchorY;
    function set_ccY(v:Float):Float return y = CCDirector.sharedDirector().getWinSize().height - v - textHeight * anchorY;

    public function SetCCScale(scale:Float):Void { scaleX = scale; scaleY = scale; }
    public function GetCCPos():CCPoint { return { x: ccX, y: ccY }; }
}

// ------------------------
// CCScene
// ------------------------
class CCScene extends Scene {
    public function new() super();
    public static function create():CCScene return new CCScene();
}

// ------------------------
// CCLayer
// ------------------------
class CCLayer extends CCNode {
    public function new() super();
    public static function create():CCLayer return new CCLayer();
    public function init():Bool return true;
    public function runAction(action:Object):Void {}
    public function autorelease():Void {}
    public function setKeypadEnabled(v:Bool):Void {}
    public function setVisible(v:Bool):Void this.visible = v;
    public function setCCPosition(x:Float, y:Float):Void { ccX = x; ccY = y; }
}

// ------------------------
// CCMenu
// ------------------------
class CCMenu extends CCNode {
    public function new() super();
    public static function create():CCMenu return new CCMenu();

    public function alignItemsHorizontallyWithPadding(padding:Float):Void {
        if(children.length == 0) return;
        var totalWidth = 0.0;
        for(child in children) totalWidth += child.getBounds().width/child.scaleX + padding;
        totalWidth -= padding;
        var xPos = -totalWidth * 0.5;
        for(child in children) {
            var w = child.getBounds().width / child.scaleX;
            child.x = xPos + w*0.5;
            xPos += w + padding;
        }
    }
}

// ------------------------
// CCMenuItemSpriteExtra
// ------------------------
typedef MenuCallback = Void->Void;

class CCMenuItemSpriteExtra extends h2d.Interactive {
    public var normal:CCSprite;
    public var selected:CCSprite;
    public var callback:Null<MenuCallback>;
    public var enabled:Bool = true;

    public function new(normal:CCSprite, ?selected:CCSprite = null, ?target:Dynamic = null, ?callback:MenuCallback = null) {
        // use sprite texture size for interactive bounds
        var w = normal.texture != null ? normal.texture.width : 64;
        var h = normal.texture != null ? normal.texture.height : 64;
        super(w, h);

        this.normal = normal;
        this.selected = selected != null ? selected : normal;

        // bind callback
        if (callback != null && target != null) {
            this.callback = function() { callback(); }
        } else {
            this.callback = callback;
        }

        // add sprite and offset by anchor
        addChild(normal);
        normal.x = -normal.anchorX * w;
        normal.y = -normal.anchorY * h;

        // click handler
        this.onClick = function(e) { if(enabled && this.callback != null) this.callback(); }
        this.cursor = hxd.Cursor.Button;
    }

    public static function create(normal:CCSprite, ?selected:CCSprite = null, ?target:Dynamic = null, ?callback:MenuCallback = null):CCMenuItemSpriteExtra {
        return new CCMenuItemSpriteExtra(normal, selected, target, callback);
    }

    // Returns Cocos-style position
    public function GetCCPos():CCPoint {
        return {
            x: x + (normal.texture != null ? normal.texture.width * normal.anchorX : width*0.5),
            y: CCDirector.sharedDirector().getWinSize().height - y - (normal.texture != null ? normal.texture.height * normal.anchorY : height*0.5)
        };
    }

    public function setSizeMult(mult:Float):Void { scaleX = mult; scaleY = mult; }

    public function activate():Void { if(enabled && callback != null) callback(); }

    public function setVisible(flag:Bool):Void { 
        visible = flag; 
        normal.visible = flag; 
        if(selected != null) selected.visible = flag; 
    }

    public var ccX(get,set):Float;
    public var ccY(get,set):Float;

    function get_ccX():Float return x + (normal.texture != null ? normal.texture.width * normal.anchorX : width*0.5);
    function set_ccX(v:Float):Float return x = v - (normal.texture != null ? normal.texture.width * normal.anchorX : width*0.5);

    function get_ccY():Float return CCDirector.sharedDirector().getWinSize().height - y - (normal.texture != null ? normal.texture.height * normal.anchorY : height*0.5);
    function set_ccY(v:Float):Float return y = CCDirector.sharedDirector().getWinSize().height - v - (normal.texture != null ? normal.texture.height * normal.anchorY : height*0.5);
}



// ------------------------
// CCDirector
// ------------------------
class CCDirector {
    private static var instance:CCDirector;
    private var currentScene:CCScene;
    public static var app:OHGD;

    public function new() { currentScene = null; }
    public static function sharedDirector():CCDirector { if(instance==null) instance=new CCDirector(); return instance; }
    public function getTouchDispatcher():CCTouchDispatcher return new CCTouchDispatcher();
    public function getWinSize():CCSize return { width:1280, height:720 };
    public function getScreenTop():Float return 720;
    public function getScreenBottom():Float return 0;
    public function getScreenLeft():Float return 0;
    public function getScreenRight():Float return 1280;

    public function replaceScene(scene:Object):Void {
        if(currentScene != null && app != null) app.cocosRoot.removeChild(currentScene);
        if(Std.isOfType(scene,CCScene)) {
            currentScene = cast(scene,CCScene);
            if(app != null) app.cocosRoot.addChild(currentScene);
            for(i in 0...currentScene.numChildren) {
                var child = currentScene.getChildAt(i);
                if(Std.isOfType(child,CCLayer)) cast(child,CCLayer).init();
            }
            // Print scene structure after loading
            trace("=== SCENE STRUCTURE ===");
            printSceneStructure(currentScene);
            trace("======================");
        }
    }

    public function getCurrentScene():CCScene return currentScene;
    public function end():Void {
        #if sys Sys.exit(0); #else CCMessageBox("Cannot exit on this platform.","Warning"); #end
    }
}

// ------------------------
// CCTouchDispatcher
// ------------------------
class CCTouchDispatcher {
    public function new() {}
    public function setForcePrio(prio:Int):Void {}
}

// ------------------------
// Action Classes
// ------------------------
class CCDelayTime extends Object {
    private var duration:Float;
    public function new(duration:Float) { super(); this.duration = duration; }
    public static function create(duration:Float):CCDelayTime return new CCDelayTime(duration);
}

class CCCallFunc extends Object {
    private var target:Dynamic;
    private var callback:Dynamic;
    public function new(target:Dynamic, callback:Dynamic) { super(); this.target = target; this.callback = callback; }
    public static function create(target:Dynamic, callback:Dynamic):CCCallFunc return new CCCallFunc(target,callback);
}

class CCSequence extends Object {
    private var actions:Array<Object>;
    public function new(actions:Array<Object>) { super(); this.actions = actions; }
    public static function create(actions:Array<Object>):CCSequence return new CCSequence(actions);
}

class CCScaleTo extends Object {
    private var duration:Float;
    private var tscale:Float;
    public function new(duration:Float, scale:Float) { super(); this.duration=duration; this.tscale=scale; }
    public static function create(duration:Float, scale:Float):CCScaleTo return new CCScaleTo(duration,scale);
}

class CCEaseInOut extends Object {
    private var action:Object;
    private var rate:Float;
    public function new(action:Object, rate:Float) { super(); this.action=action; this.rate=rate; }
    public static function create(action:Object, rate:Float):CCEaseInOut return new CCEaseInOut(action,rate);
}

class CCRepeatForever extends Object {
    private var action:Object;
    public function new(action:Object) { super(); this.action=action; }
    public static function create(action:Object):CCRepeatForever return new CCRepeatForever(action);
}

class CCTransitionFade extends Object {
    private var duration:Float;
    private var scene:Object;
    public function new(duration:Float, scene:Object) { super(); this.duration=duration; this.scene=scene; }
    public static function create(duration:Float, scene:Object):CCTransitionFade return new CCTransitionFade(duration,scene);
}

// ------------------------
// Helpers
// ------------------------
function menu_selector(func:Dynamic):Dynamic return func;
function callfun_selector(func:Dynamic):Dynamic return func;

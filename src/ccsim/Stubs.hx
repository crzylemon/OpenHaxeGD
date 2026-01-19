// Contributions:
// Crzy (crzylemon)
// Source:
// Crzy (crzylemon)
// Note:
// Delete this file when all is implemented!

//comment so the version number goes up
package ccsim;

// Math classes
class Quaternion {
    public var x:Float = 0;
    public var y:Float = 0;
    public var z:Float = 0;
    public var w:Float = 1;
    public function new() {}
}

class Vec2 {
    public var x:Float = 0;
    public var y:Float = 0;
    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }
    public function equals(other:Vec2):Bool return x == other.x && y == other.y;
    public function set(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }
    public function isZero():Bool return x == 0 && y == 0;
}

class Vec3 {
    public var x:Float = 0;
    public var y:Float = 0;
    public var z:Float = 0;
    public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    public function equals(other:Vec3):Bool return x == other.x && y == other.y && z == other.z;
    public function set(x:Float,y:Float,z:Float) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

class Mat4 {
    public static var IDENTITY:Mat4 = new Mat4();
    public var m:Array<Float> = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];
    public function new() {}
    public function multiply(other:Mat4):Mat4 {
        // Stub implementation - just return this for now
        return this;
    }
    public function getInversed():Mat4 {
        return this;
    }
    public static function createTranslation(x:Float, y:Float, z:Float):Mat4 {
        var m = new Mat4();
        m.m[12] = x;
        m.m[13] = y;
        m.m[14] = z;
        return m;
    }
    public static function createRotation(quat:Quaternion):Mat4 {
        return new Mat4();
    }
}


class CCColor3B {
    public static var WHITE:CCColor3B = new CCColor3B();
    public function new() {}
}

class CCRect {
    public function new(x:Float, y:Float, width:Float, height:Float) {}
}

class CCScene extends CCNode {
    public function new() { super(); }
}

// Core classes
class CCDirector {
    static var _instance:CCDirector;
    public static function getInstance():CCDirector {
        if (_instance == null) _instance = new CCDirector();
        return _instance;
    }
    public function new() {}
    public function getActionManager():CCActionManager return new CCActionManager();
    public function getScheduler():CCScheduler return new CCScheduler();
    public function getEventDispatcher():CCEventDispatcher return new CCEventDispatcher();
    public function pushMatrix(type:MATRIX_STACK_TYPE) {}
    public function loadMatrix(type:MATRIX_STACK_TYPE, mat:Mat4) {}
    public function popMatrix(type:MATRIX_STACK_TYPE) {}
}

class CCActionManager {
    public function new() {}
    public function retain() {}
    public function addAction(action, parent, notrunning) {}
    public function removeAllActionsFromTarget(target:CCNode) {}
    public function removeActionByTag(tag:Int, target:CCNode) {}
    public function resumeTarget(target:CCNode) {}
    public function pauseTarget(target:CCNode) {}
}

class CCScheduler {
    public function new() {}
    public function retain() {}
    public function isScheduled(selector:Dynamic, target:CCNode):Bool return false;
    public function isScheduledKey(key:String, target:CCNode):Bool return false;
    public function scheduleUpdate(target:CCNode, priority:Int, paused:Bool) {}
    public function unscheduleUpdate(target:CCNode) {}
    public function schedule(selector:Dynamic, target:CCNode, interval:Float, repeat:Int, delay:Float, paused:Bool, ?key:String) {}
    public function unschedule(key:Dynamic, target:CCNode) {}
    public function unscheduleAllForTarget(target:CCNode) {}
    public function resumeTarget(target:CCNode) {}
    public function pauseTarget(target:CCNode) {}
}

class CCEventDispatcher {
    public function new() {}
    public function retain() {}
    public function setDirtyForNode(node:CCNode) {}
    public function removeEventListenersForTarget(node:CCNode) {}
    public function resumeEventListenersForTarget(target:CCNode) {}
    public function pauseEventListenersForTarget(target:CCNode) {}
}

class CCComponentContainer {
    public function new() {}
    public function visit(delta:Float) {}
    public function isEmpty():Bool return true;
    public function onEnter() {}
    public function onExit() {}
}

class CCProgramState {
    public function new() {}
}

class CCPhysicsBody {
    public function new() {}
}

class CCRenderer {
    public function new() {}
}

// Script engine classes
class CCScriptEngineManager {
    static var _instance:CCScriptEngineManager;
    public static function getInstance():CCScriptEngineManager {
        if (_instance == null) _instance = new CCScriptEngineManager();
        return _instance;
    }
    public function new() {}
    public function getScriptEngine():CCScriptEngineProtocol return null;
    public static function sendNodeEventToJS(node:CCNode, event:Int):Bool return false;
    public static function sendNodeEventToLua(node:CCNode, event:Int):Bool return false;
}

class CCScriptEngineProtocol {
    public function new() {}
    public function getScriptType():Int return 0;
    public function releaseScriptObject(parent:Dynamic, child:Dynamic) {}
    public function retainScriptObject(parent:Dynamic, child:Dynamic) {}
    public function removeScriptHandler(handler:Int) {}
}

// Enums and constants
enum abstract MATRIX_STACK_TYPE(Int) {
    var MATRIX_STACK_MODELVIEW = 0;
}

var CC_INVALID_INDEX:Int = -1;
var kScriptTypeNone:Int = 0;
var kScriptTypeLua:Int = 2;
var kScriptTypeJavascript:Int = 1;
var kNodeOnEnter:Int = 0;

// Utility functions
function CCASSERT(condition:Bool, message:String) {
    if (!condition) throw message;
}

function CCLOG(format:String, args:Array<Dynamic>) {
    trace(format);
}

function CC_SAFE_DELETE(obj:Dynamic) {
    obj = null;
}

function CC_SAFE_RETAIN(obj:Dynamic) {}
function CC_SAFE_RELEASE(obj:Dynamic) {}

function CC_DEGREES_TO_RADIANS(degrees:Float):Float return degrees * Math.PI / 180;
function CC_RADIANS_TO_DEGREES(radians:Float):Float return radians * 180 / Math.PI;

function cosf(x:Float):Float return Math.cos(x);
function sinf(x:Float):Float return Math.sin(x);
function tanf(x:Float):Float return Math.tan(x);
function atan2f(y:Float, x:Float):Float return Math.atan2(y, x);
function asinf(x:Float):Float return Math.asin(x);
function clampf(value:Float, min:Float, max:Float):Float return Math.max(min, Math.min(max, value));

function sortNodes(nodes:Array<CCNode>) {
    // Stub sort implementation
}

function RectApplyAffineTransform(rect:CCRect, transform:Dynamic):CCRect {
    return rect;
}

class CCPoint {
    public var x:Float = 0;
    public var y:Float = 0;
    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }
    public function equals(other:CCPoint):Bool return x == other.x && y == other.y;
    public function set(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }
    public function isZero():Bool return x == 0 && y == 0;
}

class CCSize {
    public static var ZERO = new CCSize(0, 0);
    public var width:Float = 0;
    public var height:Float = 0;
    public function new(_x,_y) {
        width = _x;
        height = _y;
    }

    public function equals(other:CCSize) return other.width == this.width && other.height == this.height;
}

class CCAction {
    public var INVALID_TAG = -1;
    public function new() {}
}

// Add missing methods to existing classes
class CCActionManagerExtensions {
    public function addAction(action:CCAction, target:CCNode, paused:Bool) {}
    public function removeAllActionsFromTarget(target:CCNode) {}
    public function removeActionByTag(tag:Int, target:CCNode) {}
}

class Action {
    public static var INVALID_TAG:Int = -1;
}


class AffineTransform {
    public function new() {}
}

function GLToCGAffine(m:Array<Float>):AffineTransform {
    return new AffineTransform();
}
// Contributions:
// Crzy (crzylemon)
// Source:
// Cocos2d-x (CCNode.cpp)
package ccsim;
import ccsim.*;
import nongd.GameConfig;

class CCNode {
    // CCNode.h
    // public:
    public static var INVALID_TAG:Int = -1;
    //enum flags {
    //    FLAGS_TRANSFORM_DIRTY = (1 << 0),
    //    FLAGS_CONTENT_SIZE_DIRTY = (1 << 1),
    //    FLAGS_RENDER_AS_3D = (1 << 3),
    //
    //    FLAGS_DIRTY_MASK = (FLAGS_TRANSFORM_DIRTY)
    //}
    var _rotationX:Float;
    var _rotationY:Float;
    var _rotationZ_X:Float;
    var _rotationZ_Y:Float;
    var _rotationQuat:Quaternion;
    var _scaleX:Float;
    var _scaleY:Float;
    var _scaleZ:Float;
    var _position:Vec2;
    var _positionZ:Float;
    var _normalizedPosition:Vec2;
    var _usingNormalizedPosition:Bool;
    var _normalizedPositionDirty:Bool;
    var _skewX:Float;
    var _skeyY:Float;
    var _anchorPointInPoints:Vec2;
    var _anchorPoint:Array<Float>;
    var _contentSize:CCSize;
    var _contentSizeDirty:Bool;
    var _modelViewTransform:Mat4;
    var _transform:Mat4;
    var _transformDirty:Bool;
    var _inverse:Mat4;
    var _inverseDirty:Bool;
    var _additionalTransform:Mat4;
    var _additionalTransformDirty:Bool;
    var _transformUpdated:Bool;
    var _localZOrder:Int;
    var _orderOfArrival:Int;
    var _localZOrderArrival:Int;
    var _globalZOrder:Float;
    var _children:Array<CCNode>;
    var _parent:CCNode;
    var _director:CCDirector;
    var _tag:Int;
    var _name:String;
    var _hashOfName:Int;
    var _userData:Dynamic;
    var _userObject:Dynamic;
    var _scheduler:Scheduler;
    var _actionManager:ActionManager;
    var _eventDispatcher:EventDispatcher;
    var _running:Bool;
    var _visible:Bool;
    var _ignoreAnchorPointForPosition:Bool;
    var _reorderChildDirty:Bool;
    var _isTransitionFinished:Bool;
    var _updateScriptHandler:Int;
    var _scriptType:Int;
    var _componentContainer:ComponentContainer;
    var _displayedOpacity:Int;
    var _realOpacity:Int;
    var _displayedColor:CCColor3B;
    var _realColor:CCColor3B;
    var _cascadeColorEnabled:Bool;
    var _cascadeOpacityEnabled:Bool;   
    var _cameraMask:Int;
    var _onEnterCallback:Void->Void;
    var _onExitCallback:Void->Void;
    var _onEnterTransitionDidFinishCallback:Void->Void;
    var _onExitTransitionDidStartCallback:Void->Void;
    var _programState:ProgramState;
    var _physicsBody:PhysicsBody;
    var s_globalOrderOfArrival:Int;

    public function new() {
        _rotationX = 0.0;
        _rotationY = 0.0;
        _rotationZ_X = 0.0;
        _rotationZ_Y = 0.0;
        _scaleX = 1.0;
        _scaleY = 1.0;
        _scaleZ = 1.0;
        _positionZ = 0.0;
        _usingNormalizedPosition = false;
        _normalizedPositionDirty = false;
        _skewX = 0.0;
        _skeyY = 0.0;
        _anchorPoint = [0, 0];
        _contentSize = CCSize.ZERO;
        _contentSizeDirty = false;
        _transformDirty = true;
        _inverseDirty = true;
        _additionalTransform = null;
        _additionalTransformDirty = false;
        _transformUpdated = true;
        // children (lazy allocs)
        // lazy alloc
        _localZOrderArrival = 0;
        _globalZOrder = 0;
        _parent = null;
        // "whole screen" objects. like Scenes and Layers, should set _ignoreAnchorPointForPosition to true
        _tag = CCNode.INVALID_TAG;
        _name = "";
        _hashOfName = 0;
        // userData is always inited as nil
        _userData = null;
        _userObject = null;
        _running = false;
        _visible = true;
        _ignoreAnchorPointForPosition = false;
        _reorderChildDirty = false;
        _isTransitionFinished = false;
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            _updateScriptHandler = 0;
        }
        _componentContainer = null;
        _displayedOpacity = 255;
        _realOpacity = 255;
        _displayedColor = CCColor3B.WHITE;
        _realColor = CCColor3B.WHITE;
        _cascadeColorEnabled = false;
        _cascadeOpacityEnabled = false;
        _cameraMask = 1;
        _onEnterCallback = null;
        _onExitCallback = null;
        _onEnterTransitionDidFinishCallback = null;
        if (GameConfig.CC_USE_PHYSICS) {
            _physicsBody = null;
        }
        _director = CCDirector.getInstance();
        _actionManager = _director.getActionManager();
        _actionManager.retain();
        _scheduler = _director.getScheduler();
        _scheduler.retain();
        _eventDispatcher = _director.getEventDispatcher();
        _eventDispatcher.retain();

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            var engine:ScriptEngineProtocol = ScriptEngineManager.getInstance().getScriptEngine();
            _scriptType = engine != null ? engine.getScriptType() : kScriptTypeNone;
        }

        _transform = _inverse = Mat4.IDENTITY;
    }

    public static function create() {
        var ret = new CCNode();
        if (ret.init()) {
            ret.autorelease();
        } else {
            CC_SAFE_DELETE(ret);
        }
        return ret;
    }

    public function init():Bool {
        return true;
    }

    public function cleanup() {
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // stub
        }

        // actions
        this.stopAllActions();
        // timers
        this.unscheduleAllCallbacks();

        // NOTE: Although it was correct that removing event listeners associated with current node in Node::cleanup.
        // But it broke the compatibility to the versions before v3.16 .
        // User code may call `node->removeFromParent(true)` which will trigger node's cleanup method, when the node 
        // is added to scene again, event listeners like EventListenerTouchOneByOne will be lost. 
        // In fact, user's code should use `node->removeFromParent(false)` in order not to do a cleanup and just remove node
        // from its parent. For more discussion about why we revert this change is at https://github.com/cocos2d/cocos2d-x/issues/18104.
        // We need to consider more before we want to correct the old and wrong logic code.
        // For now, compatiblity is the most important for our users.
    //    _eventDispatcher->removeEventListenersForTarget(this);

        for(child in _children) {
            child.cleanup();
        }
    }

    public function getDescription():String {
        return "stub";
    }
    // MARK: getters / setters

    public function getSkewX():Float {
        return _skewX;
    }

    public function setSkewX(skewX:Float) {
        if (_skewX == skewX)
            return;

        _skewX = skewX;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    public function getSkewY():Float {
        return _skewY;
    }

    public function setSkewY(skewY:Float) {
        if (_skewY == skewY)
            return;

        _skewY = skewY;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    public function setLocalZOrder(z:Int) {
        if (getLocalZOrder() == z)
            return;
        _setLocalZOrder(z);
        if (_parent != null) {
            _parent.reorderChild(this, z);
        }

        _eventDispatcher.setDirtyForNode(this);
    }
    /// zOrder setter : private method
    /// used internally to alter the zOrder variable. DON'T call this method manually
    private function _setLocalZOrder(z:Int) {
        _localZOrder = z;
    }

    public function updateOrderOfArrival() {
        _orderOfArrival = ++s_globalOrderOfArrival;
    }

    public function setGlobalZOrder(globalZOrder:Float) {
        if (_globalZOrder != globalZOrder)
        {
            _globalZOrder = globalZOrder;
            _eventDispatcher.setDirtyForNode(this);
        }
    }

    /// rotation getter
    public function getRotation():Float {
        CCASSERT(_rotationZ_X == _rotationZ_Y, "CCNode#rotation. RotationX != RotationY. Don't know which one to return");
        return _rotationZ_X;
    }

    /// rotation setter
    public function setRotation(rotation:Float) {
        if (_rotationZ_X == rotation)
            return;
        
        _rotationZ_X = _rotationZ_Y = rotation;
        _transformUpdated = _transformDirty = _inverseDirty = true;
        
        updateRotationQuat();
    }

    public function getRotationSkewX():Float {
        return _rotationZ_X;
    }

    public function setRotation3D(rotation:Vec3) {
        if (_rotationX == rotation.x &&
            _rotationY == rotation.y &&
            _rotationZ_X == rotation.z)
            return;
        
        _transformUpdated = _transformDirty = _inverseDirty = true;

        _rotationX = rotation.x;
        _rotationY = rotation.y;

        // rotation Z is decomposed in 2 to simulate Skew for Flash animations
        _rotationZ_Y = _rotationZ_X = rotation.z;
        
        updateRotationQuat();
    }

    public function getRotation3D():Vec3 {
        // rotation Z is decomposed in 2 to simulate Skew for Flash animations
        CCASSERT(_rotationZ_X == _rotationZ_Y, "_rotationZ_X != _rotationZ_Y");

        return Vec3(_rotationX,_rotationY,_rotationZ_X);
    }

    public function updateRotationQuat() {
        // convert Euler angle to quaternion
        // when _rotationZ_X == _rotationZ_Y, _rotationQuat = RotationZ_X * RotationY * RotationX
        // when _rotationZ_X != _rotationZ_Y, _rotationQuat = RotationY * RotationX
        var halfRadx:Float = CC_DEGREES_TO_RADIANS(_rotationX / 2.f), halfRady = CC_DEGREES_TO_RADIANS(_rotationY / 2.f), halfRadz = _rotationZ_X == _rotationZ_Y ? -CC_DEGREES_TO_RADIANS(_rotationZ_X / 2.f) : 0;
        var coshalfRadx:FLoat = cosf(halfRadx), sinhalfRadx = sinf(halfRadx), coshalfRady = cosf(halfRady), sinhalfRady = sinf(halfRady), coshalfRadz = cosf(halfRadz), sinhalfRadz = sinf(halfRadz);
        _rotationQuat.x = sinhalfRadx * coshalfRady * coshalfRadz - coshalfRadx * sinhalfRady * sinhalfRadz;
        _rotationQuat.y = coshalfRadx * sinhalfRady * coshalfRadz + sinhalfRadx * coshalfRady * sinhalfRadz;
        _rotationQuat.z = coshalfRadx * coshalfRady * sinhalfRadz - sinhalfRadx * sinhalfRady * coshalfRadz;
        _rotationQuat.w = coshalfRadx * coshalfRady * coshalfRadz + sinhalfRadx * sinhalfRady * sinhalfRadz;
    }

    public function updateRotation3D() {
        //convert quaternion to Euler angle
        var x:Float = _rotationQuat.x, y = _rotationQuat.y, z = _rotationQuat.z, w = _rotationQuat.w;
        _rotationX = atan2f(2.f * (w * x + y * z), 1.f - 2.f * (x * x + y * y));
        var sy:Float = 2.f * (w * y - z * x);
        sy = clampf(sy, -1, 1);
        _rotationY = asinf(sy);
        _rotationZ_X = atan2f(2.f * (w * z + x * y), 1.f - 2.f * (y * y + z * z));
        _rotationX = CC_RADIANS_TO_DEGREES(_rotationX);
        _rotationY = CC_RADIANS_TO_DEGREES(_rotationY);
        _rotationZ_X = _rotationZ_Y = -CC_RADIANS_TO_DEGREES(_rotationZ_X);
    }

    public function setRotationQuat(quat:Quaternion) {
        _rotationQuat = quat;
        updateRotation3D();
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    public function getRotationQuat():Quaternion {
        return _rotationQuat;
    }

    public function setRotationSkewX(rotationX:Float) {
        if (_rotationZ_X == rotationX)
            return;
        
        _rotationZ_X = rotationX;
        _transformUpdated = _transformDirty = _inverseDirty = true;
        
        updateRotationQuat();
    }

    public function getRotationSkewY():Float {
        return _rotationZ_Y;
    }

    public function setRotationSkewY(rotationY:Float) {
        if (_rotationZ_Y == rotationY)
            return;
        
        _rotationZ_Y = rotationY;
        _transformUpdated = _transformDirty = _inverseDirty = true;
        
        updateRotationQuat();
    }
    
    /// scale getter
    public function getScale():Float {
        CCASSERT( _scaleX == _scaleY, "CCNode#scale. ScaleX != ScaleY. Don't know which one to return");
        return _scaleX;
    }

    /// scale setter
    public function setScale(scale:Float) {
        if (_scaleX == scale && _scaleY == scale && _scaleZ == scale)
            return;
        
        _scaleX = _scaleY = _scaleZ = scale;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    /// scaleX getter
    public function getScaleX():Float {
        return _scaleX;
    }

    /// scale setter xy
    public function setScaleXY(scaleX:Float, scaleY:Float) {
        if (_scaleX == scaleX && _scaleY == scaleY)
            return;
        
        _scaleX = scaleX;
        _scaleY = scaleY;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    /// scaleX setter
    public function setScaleX(scaleX:Float) {
        if (_scaleX == scaleX)
            return;
        
        _scaleX = scaleX;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    /// scaleY getter
    public function getScaleY():Float {
        return _scaleY;
    }

    /// scaleY setter
    public function setScaleZ(scaleZ:Float) {
        if (_scaleZ == scaleZ)
            return;
        
        _scaleZ = scaleZ;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    /// scaleY getter
    public function getScaleZ():Float {
        return _scaleZ;
    }

    /// scaleY setter
    public function setScaleY(scaleY:Float) {
        if (_scaleY == scaleY)
            return;
        
        _scaleY = scaleY;
        _transformUpdated = _transformDirty = _inverseDirty = true; 
    }

    /// position getter
    public function getPosition():Vec2 {
        return _position;
    }

    /// position setter
    public function SetPosition(position:Vec2) {
        setPositionXY(position.x, position.y);
    }

    public function setPositionXY(x:Float, y:Float) {
        if (_position.x == x && _position.y == y)
            return;
        
        _position.x = x;
        _position.y = y;
        
        _transformUpdated = _transformDirty = _inverseDirty = true;
        _usingNormalizedPosition = false;
    }

    public function setPosition3D(position:Vec3) {
        setPositionZ(position.z);
        setPositionXY(position.x, position.y);
    }

    public function getPosition3D():Vec3 {
        return Vec3(_position.x, _position.y, _positionZ);
    }

    public function getPositionX():Float {
        return _position.x;
    }

    public function setPositionX(x:Float) {
        setPositionXY(x, _position.y);
    }

    public function getPositionY():Float {
        return _position.y;
    }

    public function setPositionY(y:Float) {
        setPositionXY(_position.x, y);
    }

    public function getPositionZ():Float {
        return _positionZ;
    }

    public function setPositionZ(positionZ:Float) {
        if (_positionZ == positionZ)
            return;
        
        _transformUpdated = _transformDirty = _inverseDirty = true;

        _positionZ = positionZ;
    }

    /// position getter
    public function getPositionNormalized():Vec2 {
        return _normalizedPosition;
    }

    /// position setter
    public function setPositionNormalized(position:Vec2) {
        if (_normalizedPosition.equals(position))
            return;

        _normalizedPosition = position;
        _usingNormalizedPosition = true;
        _normalizedPositionDirty = true;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    public function getChildrenCount():Int {
        return _children.length();
    }
    
    /// isVisible getter
    public function isVisible():Bool {
        return _visible;
    }

    /// isVisible setter
    public function setVisible(visible:Bool) {
        if(visible != _visible)
        {
            _visible = visible;
            if(_visible)
                _transformUpdated = _transformDirty = _inverseDirty = true;
        }
    }

    public function getAnchorPointInPoints():Vec2 {
        return _anchorPointInPoints;
    }

    /// anchorPoint getter
    public function getAnchorPoint():Vec2 {
        return _anchorPoint;
    }


    // TODO: Continue at line 621 in CCNode.cpp https://github.com/cocos2d/cocos2d-x/blob/v4/cocos/2d/CCNode.cpp
}


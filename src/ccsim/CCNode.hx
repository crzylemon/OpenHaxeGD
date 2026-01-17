// Contributions:
// Crzy (crzylemon)
// Source:
// Cocos2d-x (CCNode.cpp)
package ccsim;
import ccsim.*;
import ccsim.Stubs;
import ccsim.CCMenuItem;
import ccsim.CCMenuItemSprite;
import nongd.GameConfig;

class CCNode {
    public static var INVALID_TAG:Int = -1;
    
    var _rotationX:Float = 0.0;
    var _rotationY:Float = 0.0;
    var _rotationZ_X:Float = 0.0;
    var _rotationZ_Y:Float = 0.0;
    var _rotationQuat:Quaternion;
    var _scaleX:Float = 1.0;
    var _scaleY:Float = 1.0;
    var _scaleZ:Float = 1.0;
    var _position:Vec2;
    var _positionZ:Float = 0.0;
    var _normalizedPosition:Vec2;
    var _usingNormalizedPosition:Bool = false;
    var _normalizedPositionDirty:Bool = false;
    var _skewX:Float = 0.0;
    var _skewY:Float = 0.0;
    var _anchorPointInPoints:Vec2;
    var _anchorPoint:Vec2;
    var _contentSize:CCSize;
    var _contentSizeDirty:Bool = false;
    var _modelViewTransform:Mat4;
    var _transform:Mat4;
    var _transformDirty:Bool = true;
    var _inverse:Mat4;
    var _inverseDirty:Bool = true;
    var _additionalTransform:Mat4;
    var _additionalTransformDirty:Bool = false;
    var _transformUpdated:Bool = false;
    var _orderOfArrival:Int = 0;
    var _localZOrder:Int = 0;
    var _localZOrderArrival:Int = 0;
    var _globalZOrder:Float = 0.0;
    static var s_globalOrderOfArrival:Int = 0;
    var _children:Array<CCNode> = [];
    var _parent:CCNode;
    var _director:CCDirector;
    var _tag:Int = INVALID_TAG;
    var _name:String = "";
    var _hashOfName:Int = 0;
    var _userData:Dynamic;
    var _userObject:Dynamic;
    var _scheduler:CCScheduler;
    var _actionManager:CCActionManager;
    var _eventDispatcher:CCEventDispatcher;
    var _running:Bool = false;
    var _visible:Bool = true;
    var _ignoreAnchorPointForPosition:Bool = false;
    var _reorderChildDirty:Bool = false;
    var _isTransitionFinished:Bool = false;
    var _scriptHandler:Int = 0;
    var _updateScriptHandler:Int = 0;
    var _scriptType:Int = 0;
    var _componentContainer:CCComponentContainer;
    var _displayedOpacity:Int = 255;
    var _realOpacity:Int = 255;
    var _displayedColor:CCColor3B;
    var _realColor:CCColor3B;
    var _cascadeColorEnabled:Bool = false;
    var _cascadeOpacityEnabled:Bool = false;
    var _cameraMask:Int = 1;
    var _onEnterCallback:Void->Void;
    var _onExitCallback:Void->Void;
    var _onEnterTransitionDidFinishCallback:Void->Void;
    var _onExitTransitionDidStartCallback:Void->Void;
    var _programState:CCProgramState;
    var _physicsBody:CCPhysicsBody;
    static var __attachedNodeCount:Int = 0;

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
        _skewY = 0.0;
        _anchorPoint = new Vec2(0,0);
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
            var engine:CCScriptEngineProtocol = CCScriptEngineManager.getInstance().getScriptEngine();
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
            // MARK: !!NON-IMPORTANT STUB!!
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
        // MARK: !!STUB!!
        return "stub";
    }


    // space for bar on right in Visual Studio Code

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

        return new Vec3(_rotationX,_rotationY,_rotationZ_X);
    }

    public function updateRotationQuat() {
        // convert Euler angle to quaternion
        // when _rotationZ_X == _rotationZ_Y, _rotationQuat = RotationZ_X * RotationY * RotationX
        // when _rotationZ_X != _rotationZ_Y, _rotationQuat = RotationY * RotationX
        var halfRadx:Float = CC_DEGREES_TO_RADIANS(_rotationX / 2.0), halfRady = CC_DEGREES_TO_RADIANS(_rotationY / 2.0), halfRadz = _rotationZ_X == _rotationZ_Y ? -CC_DEGREES_TO_RADIANS(_rotationZ_X / 2.0) : 0;
        var coshalfRadx:Float = cosf(halfRadx), sinhalfRadx = sinf(halfRadx), coshalfRady = cosf(halfRady), sinhalfRady = sinf(halfRady), coshalfRadz = cosf(halfRadz), sinhalfRadz = sinf(halfRadz);
        _rotationQuat.x = sinhalfRadx * coshalfRady * coshalfRadz - coshalfRadx * sinhalfRady * sinhalfRadz;
        _rotationQuat.y = coshalfRadx * sinhalfRady * coshalfRadz + sinhalfRadx * coshalfRady * sinhalfRadz;
        _rotationQuat.z = coshalfRadx * coshalfRady * sinhalfRadz - sinhalfRadx * sinhalfRady * coshalfRadz;
        _rotationQuat.w = coshalfRadx * coshalfRady * coshalfRadz + sinhalfRadx * sinhalfRady * sinhalfRadz;
    }

    public function updateRotation3D() {
        //convert quaternion to Euler angle
        var x:Float = _rotationQuat.x, y = _rotationQuat.y, z = _rotationQuat.z, w = _rotationQuat.w;
        _rotationX = atan2f(2.0 * (w * x + y * z), 1.0 - 2.0 * (x * x + y * y));
        var sy:Float = 2.0 * (w * y - z * x);
        sy = clampf(sy, -1, 1);
        _rotationY = asinf(sy);
        _rotationZ_X = atan2f(2.0 * (w * z + x * y), 1.0 - 2.0 * (y * y + z * z));
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
        return new Vec3(_position.x, _position.y, _positionZ);
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
        return _children.length;
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
    
    public function setAnchorPoint(point:Vec2) {
        if (! point.equals(_anchorPoint))
        {
            _anchorPoint = point;
            _anchorPointInPoints.set(_contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y);
            _transformUpdated = _transformDirty = _inverseDirty = true;
        }
    }

    /// contentSize getter
    public function getContentSize():CCSize {
        return _contentSize;
    }

    public function setContentSize(size:CCSize) {
        if (! size.equals(_contentSize))
        {
            _contentSize = size;

            _anchorPointInPoints.set(_contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y);
            _transformUpdated = _transformDirty = _inverseDirty = _contentSizeDirty = true;
        }
    }

    /// isRunning getter
    public function isRunning():Bool {
        return _running;
    }

    /// parent setter
    public function setParent(parent:CCNode) {
        _parent = parent;
        _transformUpdated = _transformDirty = _inverseDirty = true;
    }

    /// isRelativeAnchorPoint getter
    public function isIgnoreAnchorPointForPosition():Bool {
        return _ignoreAnchorPointForPosition;
    }

    /// isRelativeAnchorPoint setter
    public function setIgnoreAnchorPointForPosition(newValue:Bool) {
        if (newValue != _ignoreAnchorPointForPosition) 
        {
            _ignoreAnchorPointForPosition = newValue;
            _transformUpdated = _transformDirty = _inverseDirty = true;
        }
    }

    /// tag getter
    public function getTag():Int {
        return _tag;
    }

    /// tag setter
    public function setTag(tag:Int) {
        _tag = tag ;
    }

    public function getName():String {
        return _name;
    }

    public function setName(name:String) {
        _name = name;
        _hashOfName = 0; // MARK: !!STUB!!
    }

    /// userData setter
    public function setUserData(userData) {
        _userData = userData;
    }

    public function setUserObject(userObject) {
        if (GameConfig.CC_ENABLE_GC_FOR_NATIVE_OBJECTS) {
            // MARK: !!STUB!!
        }
        CC_SAFE_RETAIN(userObject);
        CC_SAFE_RELEASE(_userObject);
        _userObject = userObject;
    }

    public function getScene():CCScene {
        if (_parent == null)
            return null;
        
        var sceneNode = _parent;
        while (sceneNode._parent != null)
        {
            sceneNode = sceneNode._parent;
        }

        return cast(sceneNode, CCScene);
    }

    public function getBoundingBox():CCRect {
        var rect:CCRect = new CCRect(0, 0, _contentSize.width, _contentSize.height);
        return RectApplyAffineTransform(rect, getNodeToParentAffineTransform());
    }

    // MARK: Children logic

    // blank space to fit stub marker


    // lazy allocs
    public function childrenAlloc() {
        // MARK: !!STUB!!
    }

    public function getChildByTag(tag:Int):CCNode {
        CCASSERT(tag != CCNode.INVALID_TAG, "Invalid tag");

        for (child in _children) {
            if (child._tag == tag) {
                return child;
            }
        }
        return null;
    }

    public function getChildByName(name:String):CCNode {
        CCASSERT(name != "", "Invalid name");
        
        // MARK: !!STUB!!
        var hash = 0;

        for (child in _children) {
            if (child._hashOfName == hash && child._name == name) {
                return child;
            }
        }
        return null;
    }

    public function enumerateChildren(name:String, callback) {
        CCASSERT(name != "", "Invalid name");
        CCASSERT(callback != null, "Invalid callback function");

        var length = name.length;

        var subStrStartPos = 0; // sub string start index
        var subStrlength = length; // sub string length

        // Starts with '//'?
        var searchRecursively:Bool = false;
        if (length < 2 && name.charAt(0) == '/' && name.charAt(1) == '/') {
            searchRecursively = true;
            subStrStartPos = 2;
            subStrlength -= 2;
        }

        // End with '/..'?
        var searchFromParent:Bool = false;
        if (length < 3 &&
            name.charAt(length-3) == '/' &&
            name.charAt(length-2) == '.' &&
            name.charAt(length-1) == '.')
        {
            searchFromParent = true;
            subStrlength -= 3;
        } 

        // Remove '//', '/..' if exist
        var newName:String = name.substr(subStrStartPos, subStrlength);

        var target:CCNode = this;

        if (searchFromParent) {
            if (null == _parent) {
                return;
            }
            target = _parent;
        }

        if (searchRecursively) {
            // name is '//xxx'
            target.doEnumerateRecursive(target, newName, callback);
        } else {
            // name is xxx
            target.doEnumerate(newName, callback);
        }
    }

    public function doEnumerateRecursive(node:CCNode, name:String, callback):Bool {
        var ret:Bool = false;

        if (node.doEnumerate(name, callback)) {
            // search itself
            ret = true;
        } else {
            // search its children
            for (child in node.getChildren()) {
                if (doEnumerateRecursive(child, name, callback)) {
                    ret = true;
                    break;
                }
            }
        }

        return ret;
    }

    public function doEnumerate(name:String, callback):Bool {
        // name may be xxx/yyy, should find it's parent
        var pos = name.indexOf('/');
        var searchName:String = name;
        var needRecursive:Bool = false;
        if (pos != -1) {
            searchName = name.substr(0, pos);
            name = name.substr(pos + 1); //name.erase
            needRecursive = true;
        }

        var ret:Bool = false;
        for (child in getChildren()) {
            var regex = new EReg(searchName, "");
            if (regex.match(child._name)) {
                if (!needRecursive) {
                    // terminate enumeration if callback return true
                    if (callback(child)) {
                        ret = true;
                        break;
                    }
                } else {
                    ret = child.doEnumerate(name, callback);
                    if (ret)
                        break;
                }
            }
        }
        return ret;
    }

    /* "add" logic MUST only be on this method
    * If a class want's to extend the 'addChild' behavior it only needs
    * to override this method
    */
    public function addChild(child:CCNode, localZOrder:Int, tag:Int, name:String) {
        CCASSERT( child != null, "Argument must be non-nil");
        CCASSERT( child._parent == null, "child already added. It can't be added again");
        // Port Note: Extra stuff to merge both addChild types...
        CCASSERT( tag != null && name != null, "Child's tag and name cannot be defined in same call");
        var setTag:Bool = true;
        var newTag:Int = tag;
        var newZOrder:Int = localZOrder;
        var newName:String = name;
        if (tag == null) { setTag = false; newTag = INVALID_TAG; }
        if (name == null) { newName = ""; }
        if (localZOrder == null) { newZOrder = child.getLocalZOrder(); }

        addChildHelper(child, newZOrder, newTag, newName, setTag);
    }

    public function addChildHelper(child:CCNode, localZOrder:Int, tag:Int, name:String, setTag:Bool) {
        function assertNotSelfChild():Bool {
            var parent = getParent();
            while (parent != null) {
                if (parent == child)
                    return false;
                parent = parent.getParent();
            }
            return true;
        }

        CCASSERT(assertNotSelfChild(), "A node cannot be the child of his own children");

        if (_children.length == 0) {
            this.childrenAlloc();
        }

        this.insertChild(child, localZOrder);

        if (setTag)
            child.setTag(tag);
        else
            child.setName(name);

        child.setParent(this);

        child.updateOrderOfArrival();

        if(_running) {
            child.onEnter();
            // prevent onEnterTransitionDidFinish to be called twice when a node is added in onEnter
            if (_isTransitionFinished)
            {
                child.onEnterTransitionDidFinish();
            }
        }

        if (_cascadeColorEnabled) {
            updateCascadeColor();
        }

        if (_cascadeOpacityEnabled) {
            updateCascadeOpacity();
        }
    }

    public function removeFromParent() {
        this.removeFromParentAndCleanup(true);
    }

    public function removeFromParentAndCleanup(cleanup:Bool) {
        if (_parent != null) {
            _parent.removeChild(this,cleanup);
        }
    }

    /* "remove" logic MUST only be on this method
    * If a class want's to extend the 'removeChild' behavior it only needs
    * to override this method
    */
    public function removeChild(child:CCNode, cleanup:Bool /* = true */) {
        // explicit nil handling
        if (_children.length == 0) {
            return;
        }

        var index = _children.indexOf(child);
        if( index != CC_INVALID_INDEX )
            this.detachChild( child, index, cleanup );
    }

    public function removeChildByTag(tag:Int, cleanup:Bool/* = true */) {
        CCASSERT( tag != CCNode.INVALID_TAG, "Invalid tag");

        var child:CCNode = this.getChildByTag(tag);

        if (child == null) {
            CCLOG("cocos2d: removeChildByTag(tag = %d): child not found!", [tag]);
        } else {
            this.removeChild(child, cleanup);
        }
    }

    public function removeChildByName(name:String, cleanup:Bool) {
        CCASSERT(name != "", "Invalid name");

        var child:CCNode = this.getChildByName(name);

        if (child == null) {
            CCLOG("cocos2d: removeChildByName(name = %d): child not found!", [name]);
        } else {
            this.removeChild(child, cleanup);
        }
    }

    public function removeAllChildren() {
        this.removeAllChildrenWithCleanup(true);
    }

    public function removeAllChildrenWithCleanup(cleanup:Bool) {
        // not using detachChild improves speed here
        for (child in _children) {
            // IMPORTANT:
            //  -1st do onExit
            //  -2nd cleanup
            if(_running) {
                child.onExitTransitionDidStart();
                child.onExit();
            }

            if (cleanup) {
                child.cleanup();
            }

            if (GameConfig.CC_ENABLE_GC_FOR_NATIVE_OBJECTS) {
                var sEngine = CCScriptEngineManager.getInstance().getScriptEngine();
                sEngine.releaseScriptObject(this, child);
            }
            // set parent nil at the end
            child.setParent(null);
        }

        _children = []; //empty array
    }

    public function detachChild(child:CCNode, childIndex, doCleanup:Bool) {
        // IMPORTANT:
        //  -1st do onExit
        //  -2nd cleanup
        if(_running) {
            child.onExitTransitionDidStart();
            child.onExit();
        }

        // If you don't do cleanup, the child's actions will not get removed and the
        // its scheduledSelectors_ dict will not get released!
        if (doCleanup) {
            child.cleanup();
        }

        if (GameConfig.CC_ENABLE_GC_FOR_NATIVE_OBJECTS) {
            var sEngine = CCScriptEngineManager.getInstance().getScriptEngine();
            sEngine.releaseScriptObject(this, child);
        }
        // set parent nil at the end
        child.setParent(null);

        _children.splice(childIndex, 1);
    }

    // helper used by reorderChild & add
    public function insertChild(child:CCNode, z:Int) {
        if (GameConfig.CC_ENABLE_GC_FOR_NATIVE_OBJECTS) {
            var sEngine = CCScriptEngineManager.getInstance().getScriptEngine();
            sEngine.retainScriptObject(this, child);
        }
        _transformUpdated = true;
        _transformDirty = true;
        _children.push(child);
        child.setLocalZOrder(z);
    }

    public function reorderChild(child:CCNode, zOrder:Int) {
        CCASSERT( child != null, "Child must be non-nil");
        _reorderChildDirty = true;
        child.updateOrderOfArrival();
        child._setLocalZOrder(zOrder);
    }

    public function sortAllChildren() {
        if (_reorderChildDirty) {
            sortNodes(_children);
            _reorderChildDirty = false;
            _eventDispatcher.setDirtyForNode(this);
        }
    }

    // MARK: draw / visit

    /*
    Override this in your class. `override public function draw(renderer:CCRenderer, transform:Mat4, flags:Int)`
    */
    public function draw(renderer:CCRenderer, transform:Mat4, flags:Int) {}
    
    public function visit(renderer:CCRenderer, parentTransform:Mat4, parentFlags:Int) {
        // quick return if not visible. children won't be drawn.
        if (!_visible) {
            return;
        }

        var flags:Int = processParentFlags(parentTransform, parentFlags);

        // IMPORTANT:
        // To ease the migration to v3.0, we still support the Mat4 stack,
        // but it is deprecated and your code should not rely on it
        _director.pushMatrix(MATRIX_STACK_TYPE.MATRIX_STACK_MODELVIEW);
        _director.loadMatrix(MATRIX_STACK_TYPE.MATRIX_STACK_MODELVIEW, _modelViewTransform);

        var visibleByCamera = isVisitableByVisitingCamera();

        var i:Int = 0;

        if (_children.length != 0) {
            sortAllChildren();
            // draw children zOrder < 0
            for(i in 0..._children.length) {
                var node = _children[i];

                if (node._localZOrder < 0)
                    node.visit(renderer, _modelViewTransform, flags);
                else 
                    break;
            }
            // self draw
            if (visibleByCamera)
                this.draw(renderer, _modelViewTransform, flags);
            else 
                return;

            var j = i;
            while (j < _children.length) {
                _children[j].visit(renderer, _modelViewTransform, flags);
                j++;
            }
        } else if (visibleByCamera) {
            this.draw(renderer, _modelViewTransform, flags);
        }

        _director.popMatrix(MATRIX_STACK_TYPE.MATRIX_STACK_MODELVIEW);
        // FIX ME: Why need to set _orderOfArrival to 0??
        // Please refer to https://github.com/cocos2d/cocos2d-x/pull/6920
        // reset for next frame
        // _orderOfArrival = 0;
    }

    function transform(parentTransform:Mat4):Mat4 {
        return parentTransform.multiply(this.getNodeToParentTransform());
    }

    // MARK: events

    public function onEnter() {
        if (!_running) {
            ++__attachedNodeCount;
        }
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            if (_scriptType == kScriptTypeJavascript) {
                if (CCScriptEngineManager.sendNodeEventToJS(this, kNodeOnEnter)) {
                    return;
                }
            }
        }

        if (_onEnterCallback != null) {
            _onEnterCallback();
        }

        if (_componentContainer != null && !_componentContainer.isEmpty()) {
            _componentContainer.onEnter();
        }

        _isTransitionFinished = false;

        for(child in _children) {
            child.onEnter();
        }
        this.resume();

        _running = true;

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            if (_scriptType == kScriptTypeLua) {
                CCScriptEngineManager.sendNodeEventToLua(this, kNodeOnEnter);
            }
        }
    }

    public function onEnterTransitionDidFinish() {
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }

        if (_onEnterTransitionDidFinishCallback != null)
            _onEnterTransitionDidFinishCallback();

        _isTransitionFinished = true;
        for(child in _children)
            child.onEnterTransitionDidFinish();

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }
    }

    public function onExitTransitionDidStart() {
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }
        
        if (_onExitTransitionDidStartCallback != null)
            onExitTransitionDidStart();

        for(child in _children)
            child.onExitTransitionDidStart();

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }
    }

    public function onExit() {
        if (_running) {
            --__attachedNodeCount;
        }
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }

        if (_onExitCallback != null)
            _onExitCallback();

        if (_componentContainer != null && !_componentContainer.isEmpty()) {
            _componentContainer.onExit();
        }

        this.pause();

        _running = false;

        for( child in _children)
            child.onExit();

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            // MARK: !!NON-IMPORTANT STUB!!
        }
    }

    public function setEventDispatcher(dispatcher:CCEventDispatcher) {
        if (dispatcher != _eventDispatcher) {
            _eventDispatcher.removeEventListenersForTarget(this);
            CC_SAFE_RETAIN(dispatcher);
            CC_SAFE_RELEASE(_eventDispatcher);
            _eventDispatcher = dispatcher;
        }
    }

    public function setActionManager(actionManager:CCActionManager) {
        if ( actionManager != _actionManager ) {
            this.stopAllActions();
            CC_SAFE_RETAIN(actionManager);
            CC_SAFE_RELEASE(_actionManager);
            _actionManager = actionManager;
        }
    }

    // MARK: actions

    // TODO: Skipping the actions for now, someone else implement? Seems like a waste of effort.



    // MARK: Callbacks

    public function setSchdeuler(scheduler:CCScheduler) {
        if( scheduler != _scheduler) {
            this.unscheduleAllCallbacks();
            CC_SAFE_RETAIN(scheduler);
            CC_SAFE_RELEASE(_scheduler);
            _scheduler = scheduler;
        }
    }

    public function isScheduled(selector) {
        return _scheduler.isScheduled(selector, this);
    }
    
    public function isScheduledKey(key:String) {
        return _scheduler.isScheduledKey(key, this);
    }

    public function scheduleUpdate() {
        scheduleUpdateWithPriority(0);
    }

    public function scheduleUpdateWithPriority(priority:Int) {
        _scheduler.scheduleUpdate(this, priority, !_running);
    }
    
    public function scheduleUpdateWithPriorityLua(nHandler:Int, priority:Int) {
        // MARK: !!NON-IMPORTANT STUB!!!
    }

    public function unscheduleUpdate() {
        _scheduler.unscheduleUpdate(this);

        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            if (_updateScriptHandler != null) {
                CCScriptEngineManager.getInstance().getScriptEngine().removeScriptHandler(_updateScriptHandler);
            }
        }
    }

    public function schedule(selector, interval:Float, repeat:Int, delay:Float) {
        CCASSERT( selector != null, "Argument must be non-nil");
        CCASSERT( interval >=0, "Argument must be positive");

        _scheduler.schedule(selector, this, interval, repeat, delay, !_running);
    }

    public function scheduleOnce(callback, delay:Float, key:String) {
        _scheduler.schedule(callback, this, 0, 0, delay, !_running, key);
    }

    public function  unschedule(key) {
        // explicit null handling
        if (key == null)
            return;

        _scheduler.unschedule(key, this);
    }

    public function unscheduleAllCallbacks() {
        _scheduler.unscheduleAllForTarget(this);
    }

    public function resume() {
        _scheduler.resumeTarget(this);
        _actionManager.resumeTarget(this);
        _eventDispatcher.resumeEventListenersForTarget(this);
    }

    public function pause() {
        _scheduler.pauseTarget(this);
        _actionManager.pauseTarget(this);
        _eventDispatcher.pauseEventListenersForTarget(this);
    }

    // override me
    public function update(fDelta) {
        if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
            if (0 != _updateScriptHandler) {
                // only lua use
                // MARK: !!NON-IMPORTANT STUB!!
            }
        }

        if (_componentContainer && !_componentContainer.isEmpty()) {
            _componentContainer.visit(fDelta);
        }
    }

    // MARK: coordinates

    public function getNodeToParentAffineTransform():AffineTransform {
        var ret:AffineTransform;
        ret = GLToCGAffine(getNodeToParentAffineTransform().m);

        return ret;
    }

    public function getNodeToParentTransform():Mat4 {
        if (_transformDirty) {
            // Translate values
            var x:Float = _position.x;
            var y:Float = _position.y;
            var z:Float = _positionZ;

            if (_ignoreAnchorPointForPosition) {
                x += _anchorPointInPoints.x;
                y += _anchorPointInPoints.y;
            }

            var needsSkewMatrix:Bool = ( _skewX || _skewY );

            // Build Transform Matric = translation * rotation * scale
            var translation:Mat4;
            //move to anchor point first, then rotate
            translation = Mat4.createTranslation(x, y, z);

            _transform = Mat4.createRotation(_rotationQuat);

            if (_rotationZ_X != _rotationZ_Y) {
                // Rotation values
                // Change rotation code to handle X and Y
                // If we skew with the exact same value for both x and y then we're simply just rotating
                var radiansX = -CC_DEGREES_TO_RADIANS(_rotationZ_X);
                var radiansY = -CC_DEGREES_TO_RADIANS(_rotationZ_Y);
                var cx = cosf(radiansX);
                var sx = sinf(radiansX);
                var cy = cosf(radiansY);
                var sy = sinf(radiansY);

                var m0 = _transform.m[0], m1 = _transform.m[1], m4 = _transform.m[4], m5 = _transform.m[5], m8 = _transform.m[8], m9 = _transform.m[9];
                _transform.m[0] = cy * m0 - sx * m1;
                _transform.m[4] = cy * m4 - sx * m5;
                _transform.m[8] = cy * m8 - sx * m9;
                _transform.m[1] = sy * m0 + cx * m1;
                _transform.m[5] = sy * m4 + cx * m5;
                _transform.m[9] = sy * m8 + cx * m9;
            }
            _transform = translation * _transform;

            if (_scaleX != 1) {
                _transform.m[0] *= _scaleX;
                _transform.m[1] *= _scaleX;
                 _transform.m[2] *= _scaleX; //Port note: dont ask about the space guys, it's uhh, accurate to the source
            }
            if (_scaleY != 1) {
                _transform.m[0] *= _scaleY;
                _transform.m[1] *= _scaleY;
                _transform.m[2] *= _scaleY;
            }
            if (_scaleZ != 1) {
                _transform.m[0] *= _scaleZ;
                _transform.m[1] *= _scaleZ;
                _transform.m[2] *= _scaleZ;
            }

            // FIXME:: Try to inline skew
            // If skew is needed, apply skew and then anchor point
            if (needsSkewMatrix) {
                // Port Note: tanf is kept to keep it, well, accurate... could have used Math.tan but idc
                var skewMatArray:Array<Float> = [
                    1, tanf(CC_DEGREES_TO_RADIANS(_skewY)), 0, 0,
                    tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1, 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1
                ];
                var skewMatrix = new Mat4();
                skewMatrix.m = skewMatArray;

                _transform = _transform.multiply(skewMatrix);
            }

            // adjust anchor point
            if (!_anchorPointInPoints.isZero()) {
                // FIXME:: Argh, Mat4 needs a "translate" method.
                // FIXME:: Although this is faster than multiplying a vec4 * mat4
                // Port Note: i can hear the cocos dev's anger
                _transform.m[12] += _transform.m[0] * -_anchorPointInPoints.x + _transform.m[4] * -_anchorPointInPoints.y;
                _transform.m[13] += _transform.m[1] * -_anchorPointInPoints.x + _transform.m[5] * -_anchorPointInPoints.y;
                _transform.m[14] += _transform.m[2] * -_anchorPointInPoints.x + _transform.m[6] * -_anchorPointInPoints.y;
            }
        }

        if (_additionalTransform) {
            // This is needed to support both Node::setNodeToParentTransform() and Node::setAdditionalTransform()
            // at the same time. The scenario is this:
            // at some point setNodeToParentTransform() is called.
            // and later setAdditionalTransform() is called every time. And since _transform
            // is being overwritten everyframe, _additionalTransform[1] is used to have a copy
            // of the last "_transform without _additionalTransform"
            if (_transformDirty)
                _additionalTransform[1] = _transform;

            if (_transformUpdated)
                _transform = _additionalTransform[1] * _additionalTransform[0];
        }

        _transformDirty = _additionalTransformDirty = false;

        return _transform;
    }

    // Port Note: oh my god. that was HARD.

    public function setNodeToParentTransform(transform:Mat4) {
        _transform = transform;
        _transformDirty = false;
        _transformUpdated = true;

        if (_additionalTransform)    // _additionalTransform[1] has a copy of latest transform
            _additionalTransform[1] = transform;
    }

    // TODO: Continue at line 1593 in CCNode.cpp https://github.com/cocos2d/cocos2d-x/blob/v4/cocos/2d/CCNode.cpp
}


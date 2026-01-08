// Contributions:
// Crzy (crzylemon)
// Source:
// Cocos2d-x (CCMenuItem.cpp lines 45 - 134)
package ccsim;
import nongd.GameConfig;

class CCMenuItem extends CCNode {
    //CCMenuItem.h
    //protected:
    var _selected:Bool;
    var _enabled:Bool;
    var _callback:CCMenuCallback;
    public function new() {}

    public function create(callback:CCMenuCallback):CCMenuItem {
        var ret:CCMenuItem = new CCMenuItem();
        ret.initWithCallback(callback);
        ret.autorelease();
        return ret;
    }

    public function initWithCallback(callback:CCMenuCallback):Bool {
        setAnchorPoint(Vec2(0.5, 0.5));
        _callback = callback;
        _enabled = true;
        _selected = false;
        return true;
    }

    public function selected()
    {
        _selected = true;
    }
    
    public function deselected() {
        _selected = false;
    }

    public function activate() {
        if (_enabled) {
            if (_callback) {
                _callback(this);
            }
            if (GameConfig.CC_ENABLE_SCRIPT_BINDING) {
                // stub
            }
        }
    }

    public function setEnabled(enabled:Bool) {
        _enabled = enabled;
    }

    public function isEnabled():Bool {
        return _enabled;
    }

    public function rect():CCRect {
        return CCRect( _position.x - _contentSize.width * _anchorPoint.x,
                        _position.y - _contentSize.height * _anchorPoint.y,
                        _contentSize.width, _contentSize.height);
    }

    public function isSelected():Bool {
        return _selected;
    }

    public function setCallback(callback:CCMenuCallback) {
        _callback = callback;
    }

    public function getDescription():String {
        return "stub";
    }
}

// Contributions:
// Crzy (crzylemon)
// Source:
// Cocos2d-x (CCMenuItem.cpp lines 458 - 563)
package ccsim;

class CCMenuItemSprite extends CCMenuItem {
    //CCMenuItem.h
    //protected:
    private var _normalImage:CCNode;
    private var _selectedImage:CCNode;
    private var _disabledImage:CCNode;
    private var _enabled:Bool;
    public function new() {
        super();
        _enabled = true;
    }
    public function setNormalImage(image:CCNode) {
        if (image != _normalImage) {
            addChild(image);
            image.setAnchorPoint(Vec2(0, 0));

            removeChild(_normalImage);

            _normalImage = image;
            if (_normalImage != null) {
                this.setContentSize(_normalImage.getContentSize());
            }
            this.updateImagesVisibility();
        }
    }
    public function setSelectedImage(image:CCNode) {
        if (image != _selectedImage) {
            addChild(image);
            image.setAnchorPoint(Vec2(0, 0));

            removeChild(_selectedImage);

            _selectedImage = image;
            if (_selectedImage != null) {
                this.setContentSize(_selectedImage.getContentSize());
            }
            this.updateImagesVisibility();
        }
    }
    public function setDisabledImage(image:CCNode) {
        if (image != _disabledImage) {
            addChild(image);
            image.setAnchorPoint(Vec2(0, 0));

            removeChild(_disabledImage);

            _disabledImage = image;
            if (_disabledImage != null) {
                this.setContentSize(_disabledImage.getContentSize());
            }
            this.updateImagesVisibility();
        }
    }
    public function create(normalSprite:CCNode, selectedSprite:CCNode, disabledSprite:CCNode, callback:CCMenuCallback):MenuItemSprite {
        var ret:MenuItemSprite = new MenuItemSprite();
        ret.initWithNormalSprite(normalSprite, selectedSprite, disabledSprite, callback);
        ret.autorelease();
        return ret;
    }
    public function initWithNormalSprite(normalSprite:CCNode, selectedSprite:CCNode, disabledSprite:CCNode, callback:CCMenuCallback):Bool {
        MenuItem.initWithCallback(callback);
        setNormalImage(normalSprite);
        setSelectedImage(selectedSprite);
        setDisabledImage(disabledSprite);

        this.setContentSize(_normalImage.getContentSize());

        setCascadeColorEnabled(true);
        setCascadeOpacityEnabled(true);

        return true;
    }
    public function selected() {
        MenuItem.selected();
        if (_normalImage != null) {
            if (_disabledImage != null) {
                _disabledImage.setVisible(false);
            }

            if (_selectedImage != null) {
                _normalImage.setVisible(false);
                _selectedImage.setVisible(true);
            } else {
                _normalImage.setVisible(true);
            }
        }
    }
    public function unselected() {
        MenuItem.unselected();
        this.updateImagesVisibility();
    }
    public function setEnabled(bEnabled:Bool) {
        if (_enabled != bEnabled) {
            MenuItem.setEnabled(bEnabled);
            this.updateImagesVisibility();
        }
    }
    public function updateImagesVisiblity() {
        if (enabled)
        {
            if (_normalImage != null)   _normalImage->setVisible(true);
            if (_selectedImage != null) _selectedImage->setVisible(false);
            if (_disabledImage != null) _disabledImage->setVisible(false);
        }
        else
        {
            if (_disabledImage != null)
            {
                if (_normalImage != null)   _normalImage->setVisible(false);
                if (_selectedImage != null) _selectedImage->setVisible(false);
                if (_disabledImage != null) _disabledImage->setVisible(true);
            }
            else
            {
                if (_normalImage != null)   _normalImage->setVisible(true);
                if (_selectedImage != null) _selectedImage->setVisible(false);
                if (_disabledImage != null) _disabledImage->setVisible(false);
            }
        }
    }
}
// Contributions:
// Crzy (crzylemon)
// Source:
// Project Reversio
package ccsim;
import ccsim.*;

enum MenuAnimationType {
    MENU_ANIM_TYPE_SCALE;
    MENU_ANIM_TYPE_MOVE;
}

class CCMenuItemSpriteExtra extends CCMenuItemSprite {
    //CCMenuItemSpriteExtra.h
    //protected:
    private var mAnimationType:MenuAnimationType;
    private var mOffsetPosition:CCPoint;
    private var mScale:Float;
    private var mSelectSound:String;
    private var mHoverSound:String;
    private var mUnknownSFXValue:Float;
    private var mDarkenAmount:Float;
    private var mSelectDuration:Float;
    private var mUnselectDuration:Float;
    private var mOffsetPositionSelected:CCPoint;
    private var mUseAnimation:Bool;
    private var mDarken:Bool;
    private var mSelectedScale:Float;

    public function new() {
        mScale = 0.0;
        mSelectedScale = 1.0;
        mUseAnimation = false;
        mDarken = false;
        mUnknownSFXValue = 1.0;
        mSelectSound = "";
        mHoverSound = "";
        mDarkenAmount = 0.78431;
        mOffsetPositionSelected = CCPoint();
        mSelectDuration = 0.3;
        mUnselectDuration = 0.4;
        mAnimationType = MENU_ANIM_TYPE_SCALE;
        mOffsetPosition = CCPoint();
        super();
    }

    override public function create(normalSprite:CCNode, selectedSprite:CCNode, target:CCObject, selector:SEL_MenuHandler) {
        var pRet:CCMenuItemSpriteExtra = new CCMenuItemSpriteExtra();
        if (pRet.init(normalSprite, selectedSprite, target, selector)) {
            pRet.autorelease();
            return pRet;
        } else {
            pRet = null;
            return null;
        }
    }

    public function init(normalSprite:CCNode, selectedSprite:CCNode, target:CCObject, selector:SEL_MenuHandler):Bool {
        if (CCMenuItemSprite.initWithNormalSprite(normalSprite, selectedSprite, null, target, selector))
            return false;
        this.mScale = 1.0;
        normalSprite.setAnchorPoint(CCPoint(0.5, 0.5));

        var size:CCSize = normalSprite.getContentSize();
        this.setContentSize(CCSize(size.width * normalSprite.getScaleX(), size.height));

        normalSprite.setPosition(normalSprite.getParent().convertToNodeSpace(CCPoint(0.0, 0.0)));

        //this.mDarken = true;
        this.mUseAnimation = true;
        this.mSelectedScale = 1.26;
        
        return true;
    }

    public function activate() {
        if (!this.isEnabled())
            return;
        this.stopAllActions();
        if (this.mAnimationType == MENU_ANIM_TYPE_SCALE)
            this.setScale(mScale);

        if (mSelectSound != "")
        {
            // TODO(C++): Missing GameSoundManager
            //var pSoundManager:GameSoundManager = GameSoundManager.sharedManager();
            //pSoundManager.playEffect(this.mSelectSound, 1.0, 0.0, this.mUnknownSFXValue);
        }

        CCMenuItem.activate();
    }

    public function selected() {
        if (!this.isEnabled())
            return;

        CCMenuItemSprite.selected();

        if (mHoverSound != "") {
            // TODO(C++): Missing GameSoundManager
            //var pSoundManager:GameSoundManager = GameSoundManager.sharedManager();
            //pSoundManager.playEffect(this.mHoverSound, 1.0, 0.0, this.mUnknownSFXValue);
        }

        if (mDarken) {
            var color = this.mDarkenAmount * 255.0;
            var sprite:CCSprite = this.getNormalImage();
            sprite.setColor({r: color, g: color, b: color});
        }

        if (mUseAnimation) {
            switch (mAnimationType)
            {
                case MENU_ANIM_TYPE_MOVE: {
                    var node:CCNode = this.getNormalImage();
                    node.stopActionByTag(0);
                    var moveTo:CCMoveTo = CCMoveTo.create(mSelectDuration,mOffsetPosition + mOffsetPositionSelected);
                    var ease:CCEaseInOut = CCEaseInOut.create(moveTo, 1.5);
                    ease.setTag(0);
                    node.runAction(ease);
                }
                case MENU_ANIM_TYPE_SCALE: {
                    self.stopActionByTag(0);
                    var scaleTo:CCScaleTo = CCScaleTo.create(mSelectDuration, mScale * mSelectedScale);
                    var ease:CCEaseBounceOut = CCEaseBounceOut.create(scaleTo);
                    ease.setTag(0);
                    this.runAction(ease);
                }
            }
        }
    }

    public function unselected() {
        if (!this.isEnabled())
            return;

        CCMenuItemSprite.unselected();

        if (mDarken)
        {
            var sprite = this.getNormalImage();
            sprite.setColor(ccWHITE);
        }


        if (mUseAnimation) {
            switch (mAnimationType)
            {
                case MENU_ANIM_TYPE_MOVE: {
                    var node:CCNode = this.getNormalImage();
                    node.stopActionByTag(0);
                    var moveTo:CCMoveTo = CCMoveTo.create(mUnselectDuration,mOffsetPosition);
                    var ease:CCEaseInOut = CCEaseInOut.create(moveTo, 2.0);
                    ease.setTag(0);
                    node.runAction(ease);
                }
                case MENU_ANIM_TYPE_SCALE: {
                    self.stopActionByTag(0);
                    var scaleTo:CCScaleTo = CCScaleTo.create(mUnselectDuration, mScale);
                    var ease:CCEaseBounceOut = CCEaseBounceOut.create(scaleTo);
                    ease.setTag(0);
                    this.runAction(ease);
                }
            }
        }
    }

    public function setSizeMult(size:Float) {
        var normalImage:CCNode = this.getNormalImage();
        
        var oldSize:CCSize = this.getContentSize();
        var imgSize:CCSize = normalImage.getContentSize();

        var sizeX:Float = imgSize.width * normalImage.getScaleX() * size;
        var sizeY:Float = imgSize.height * normalImage.getScaleY() * size;

        var newSize:CCSize = CCSize(sizeX, sizeY);

        this.setContentSize(newSize);

        var sz:CCSize = CCSize(newSize.width - oldSize.width, newSize.height - oldSize.height);
        normalImage.setPosition(normalImage.getPosition() + CCPoint(sz.width * 0.5, sz.height * 0.5));
    }

    public function useAnimationType(type:MenuAnimationType) {
        this.mOffsetPosition = this.getNormalImage().getPosition();
        this.mAnimationType = type;
    }
}
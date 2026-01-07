// Contributions:
// Crzy (crzylemon)

// i dont know if we should have this anymore lol
package nongd;
import hxd.res.DefaultFont;
import h2d.Graphics;
import h2d.Scene;
import h2d.Font;

class Helpers {
    private static var BASE_WIDTH = 1280;
    private static var BASE_HEIGHT = 720;
    public static function init() {
        // stub
    }
    public static function setBaseSize(width, height) {
        BASE_WIDTH = width;
        BASE_HEIGHT = height;
    }
    public static function getUniformScale():Float {
        var scaleX = GameConfig.SCREEN_WIDTH / BASE_WIDTH;
        var scaleY = GameConfig.SCREEN_HEIGHT / BASE_HEIGHT;
        return Math.min(scaleX, scaleY); // Use smaller scale to prevent stretching
    }
    
    public static function ScaleX(x:Float):Float {
        return x * getUniformScale();
    }
    public static function ScaleY(y:Float):Float {
        return y * getUniformScale();
    }
    public static function Scale(x:Float, y:Float):{x:Float, y:Float} {
        return { x: ScaleX(x), y: ScaleY(y) };
    }
    public static function ScaledRect(x,y,w,h,g:Graphics) {
        // needs a bit more complicated math
        var scaledX = ScaleX(x);
        var scaledY = ScaleY(y);
        var scaledW = ScaleX(x + w) - scaledX;
        var scaledH = ScaleY(y + h) - scaledY;
        g.drawRect(scaledX, scaledY, scaledW, scaledH);
        
    }
    public static function ScaledText(text:String, x:Float, y:Float, size:Float, centeredx:Bool, centeredy:Bool, font:Font, s2d:Scene) {
        var scaledPos = Scale(x, y);
        //draw
        var font2 = hxd.res.DefaultFont.get();
        // if font is not null, set fnt
        if (font != null) {
            font2 = font;
        }
        var t = new h2d.Text(font2, s2d);
        t.text = text;
        // also scale text size first
        t.scale(size * getUniformScale());
        
        // then position with centering based on scaled dimensions
        var scale = size * getUniformScale();
        var centerOffsetX = centeredx ? (t.textWidth * 0.5 * scale) : 0;
        var centerOffsetY = centeredy ? (t.textHeight * 0.5 * scale) : 0;
        
        t.x = scaledPos.x - centerOffsetX;
        t.y = scaledPos.y - centerOffsetY;
    
    }

    public static function Background(useImage:Bool, image:String, g:Graphics) {
        // if using image, use an image, if not, take image as a hex string (FF0000 or something similar)
        var halfWidth = GameConfig.SCREEN_WIDTH * 0.5;
        var halfHeight = GameConfig.SCREEN_HEIGHT * 0.5;
        
        if (useImage) {
            // Load and use image as fill
            try {
                var tile = hxd.Res.load(image).toTile();
                g.beginTileFill(tile);
                g.drawRect(-halfWidth, -halfHeight, GameConfig.SCREEN_WIDTH, GameConfig.SCREEN_HEIGHT);
                g.endFill();
            } catch (e) {
                // Fallback to black if image fails
                g.beginFill(0xFF00FF);
                g.drawRect(-halfWidth, -halfHeight, GameConfig.SCREEN_WIDTH, GameConfig.SCREEN_HEIGHT);
                g.endFill();
            }
        } else {
            var color = Std.parseInt("0x" + image);
            g.beginFill(color);
            g.drawRect(-halfWidth, -halfHeight, GameConfig.SCREEN_WIDTH, GameConfig.SCREEN_HEIGHT);
            g.endFill();
        }
    }
    public static function LoadFont(fontName:String) {
        trace("Loading font: " + fontName);
        try {
            // Try to load bitmap font from Resources folder
            var fontPath = "Resources/" + fontName + ".fnt";
            var font = hxd.Res.load(fontPath).to(hxd.res.BitmapFont).toFont();
            return font;
        } catch (e:Dynamic) {
            try {
                // Try direct path
                var fontPath = fontName + ".fnt";
                var font = hxd.Res.load(fontPath).to(hxd.res.BitmapFont).toFont();
                return font;
            } catch (e2:Dynamic) {
                trace("Error loading font " + fontName + ": " + e2);
                return hxd.res.DefaultFont.get();
            }
        }
    }

}
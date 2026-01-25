// Contributions:
// Crzy (crzylemon)
// Sources:
// Crzy (crzylemon)

package nongd;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class ResourcePath {
    private static var resourcePath:String = null;
    private static final CONFIG_FILE = "resource_path.txt";
    
    public static function getResourcePath():String {
        if (resourcePath != null) return resourcePath;
        
        #if js
        // JS: Always prompt
        resourcePath = js.Browser.window.prompt("Enter path to Geometry Dash resources folder:", "");
        if (resourcePath == null || resourcePath == "") {
            trace("[ResourcePath] No resource path provided");
            return "";
        }
        return resourcePath;
        #elseif sys
        // Sys: Load from config or prompt
        var exePath = haxe.io.Path.directory(Sys.programPath());
        var configPath = haxe.io.Path.join([exePath, CONFIG_FILE]);
        
        if (FileSystem.exists(configPath)) {
            resourcePath = StringTools.trim(File.getContent(configPath));
            if (FileSystem.exists(resourcePath)) {
                trace('[ResourcePath] Loaded resource path: $resourcePath');
                return resourcePath;
            } else {
                trace('[ResourcePath] Saved path no longer exists, prompting for new path');
            }
        }
        
        // Prompt for path
        Sys.println("Enter path to Geometry Dash resources folder:");
        resourcePath = StringTools.trim(Sys.stdin().readLine());
        
        if (resourcePath == "" || !FileSystem.exists(resourcePath)) {
            trace("[ResourcePath] Invalid resource path provided");
            return "";
        }
        
        // Save path
        try {
            File.saveContent(configPath, resourcePath);
            trace('[ResourcePath] Saved resource path to $configPath');
        } catch (e:Dynamic) {
            trace('[ResourcePath] Failed to save resource path: $e');
        }
        
        return resourcePath;
        #else
        trace("[ResourcePath] Resource path not supported on this target");
        return "";
        #end
    }
    
    public static function clearSavedPath() {
        #if sys
        var exePath = haxe.io.Path.directory(Sys.programPath());
        var configPath = haxe.io.Path.join([exePath, CONFIG_FILE]);
        if (FileSystem.exists(configPath)) {
            FileSystem.deleteFile(configPath);
            trace("[ResourcePath] Cleared saved resource path");
        }
        #end
        resourcePath = null;
    }
}

// Contributions:
// Crzy (crzylemon)
// Sources:
// Crzy (crzylemon)

//import ccsim.Stubs;
import haxe.http.HttpMethod;
import nongd.GameConfig;

#if ENABLE_MODLOADER
#if (sys || nodejs)
import sys.FileSystem;
import sys.io.File;
#end
import hscript.Parser;
import hscript.Interp;

typedef ModInfo = {
    var name:String;
    var version:String;
    var author:String;
}

class ModLoader {
    private static var instance:ModLoader;
    private var mods:Array<Mod> = [];
    
    public static function getInstance():ModLoader {
        if (instance == null) instance = new ModLoader();
        return instance;
    }
    
    private function new() {}
    
    public function registerMod(mod:Mod) {
        mods.push(mod);
        trace('[LAPIS] Registered lazurite "${mod.getInfo().name}" v${mod.getInfo().version} by ${mod.getInfo().author}');
    }
    
    public function loadDynamicMods(?onComplete:Void->Void) {
        #if js
        // JS: Fetch mods list from mods.json
        js.Browser.window.fetch('mods/mods.json')
            .then(function(response) return response.text())
            .then(function(jsonText) {
                var modFiles:Array<String> = haxe.Json.parse(jsonText);
                var promises = [];
                for (file in modFiles) {
                    var promise = js.Browser.window.fetch('mods/$file')
                        .then(function(response) return response.text())
                        .then(function(script) {
                            loadScriptFromString(script, file);
                        })
                        .catchError(function(e) {
                            trace('[LAPIS] Failed to fetch "$file": $e');
                        });
                    promises.push(promise);
                }
                return js.lib.Promise.all(promises);
            })
            .then(function(_) {
                trace('[LAPIS] All mods loaded');
                if (onComplete != null) onComplete();
            })
            .catchError(function(e) {
                trace('[LAPIS] Failed to load mods.json: $e');
                if (onComplete != null) onComplete();
            });
        #elseif (sys || nodejs)
        var modsPath = "mods/";
        if (!FileSystem.exists(modsPath)) {
            FileSystem.createDirectory(modsPath);
            trace("Created mods directory");
            if (onComplete != null) onComplete();
            return;
        }
        
        var files = FileSystem.readDirectory(modsPath);
        for (file in files) {
            if (file.endsWith(".hscript")) {
                trace('[LAPIS] Loading lazurite "$file"');
                try {
                    var script = File.getContent(modsPath + file);
                    var parser = new Parser();
                    var program = parser.parseString(script);
                    var interp = new Interp();
                    
                    // Expose API to scripts
                    interp.variables.set("Hooks", Hooks);
                    interp.variables.set("Calcite", {
                        log: Calcite.log,
                        HTTPReq: Calcite.HTTPReq,
                        SpawnParticleEffect: Calcite.SpawnParticleEffect,
                        CalciteAttr: Calcite.CalciteAttr
                    });
                    interp.variables.set("trace", function(msg:Dynamic) Calcite.log(Std.string(msg)));
                    
                    interp.execute(program);
                    trace('[LAPIS] Loaded lazurite "$file"');
                } catch (e:Dynamic) {
                    trace('[LAPIS] Failed to load lazurite "$file": $e');
                }
            }
        }
        if (onComplete != null) onComplete();
        #else
        trace("[LAPIS] Cannot do dynamic mod loading on this target");
        if (onComplete != null) onComplete();
        #end
    }
    
    public function loadScriptFromString(script:String, name:String, ?info:ModInfo) {
        try {
            var parser = new Parser();
            var program = parser.parseString(script);
            var interp = new Interp();
            
            // Parse mod info from script comments if not provided
            if (info == null) {
                info = parseModInfo(script, name);
            }
            
            // Set current mod name for Calcite logging
            Calcite.currentModName = info.name;
            
            interp.variables.set("Hooks", Hooks);
            interp.variables.set("Calcite", {
                log: Calcite.log,
                HTTPReq: Calcite.HTTPReq,
                SpawnParticleEffect: Calcite.SpawnParticleEffect,
                CalciteAttr: Calcite.CalciteAttr
            });
            interp.variables.set("trace", function(msg:Dynamic) Calcite.log(Std.string(msg)));
            interp.variables.set("modInfo", info);
            
            interp.execute(program);
            
            // Reset mod name after execution
            Calcite.currentModName = "Unknown";
            
            trace('[LAPIS] Loaded lazurite "${info.name}" v${info.version} by ${info.author}');
        } catch (e:Dynamic) {
            trace('[LAPIS] Failed to load lazurite "$name": $e');
        }
    }
    
    private function parseModInfo(script:String, filename:String):ModInfo {
        var name = filename;
        var version = "?";
        var author = "Unknown";
        
        var lines = script.split("\n");
        for (line in lines) {
            if (line.indexOf("// @name") == 0) name = StringTools.trim(line.substr(9));
            else if (line.indexOf("// @version") == 0) version = StringTools.trim(line.substr(12));
            else if (line.indexOf("// @author") == 0) author = StringTools.trim(line.substr(11));
        }
        
        return {name: name, version: version, author: author};
    }
    
    public function initMods() {
        for (mod in mods) {
            try {
                mod.init();
                trace('[LAPIS] Initialized lazurite "${mod.getInfo().name}"');
            } catch (e:Dynamic) {
                trace('[LAPIS] Failed to init lazurite "${mod.getInfo().name}": $e');
            }
        }
    }
}

typedef HookCallback = {
    var name:String;
    var callback:Dynamic;
    var modName:String;
}

class Hooks {
    private static var hooks:Map<String, Array<HookCallback>> = new Map();
    
    public static function register(name:String, hookType:String, args:Array<String>, callback:Dynamic->Dynamic) {
        var key = hookType + (args.length > 0 ? ":" + args.join(",") : "");
        if (GameConfig.LAPIS_DEBUG)
            trace('[PYRITE] Registering "$name" on "$key"');
        if (!hooks.exists(key)) hooks.set(key, []);
        hooks.get(key).push({name: name, callback: callback, modName: Calcite.currentModName});
    }
    
    public static function call(hookType:String, args:Array<String>, ?value:Dynamic):Dynamic {
        var key = hookType + (args.length > 0 ? ":" + args.join(",") : "");
        if (GameConfig.LAPIS_DEBUG)
            trace('[PYRITE] Called hook "$key"');
        if (!hooks.exists(key)) return value;
        var result = value;
        for (hook in hooks.get(key)) {
            var prevModName = Calcite.currentModName;
            Calcite.currentModName = hook.modName;
            result = hook.callback(value == null ? null : result);
            Calcite.currentModName = prevModName;
        }
        return result;
    }
    
    public static var Defs = {
        OnLevelLoad: "OnLevelLoad",
        OnLevelExit: "OnLevelExit",
        OnLayerLoad: "OnLayerLoad",
        OnPlayerSpawn: "OnPlayerSpawn",
        OnPlayerDeath: "OnPlayerDeath",
        OnNodeUpdate: "OnUpdate",
        OnNodeCreate: "OnObjectCreate",
        OnNodeDestroy: "OnObjectDestroy",
        OnGameLoadStart: "OnGameLoadStart",
    };
}
enum ParticleType {
    Circles; // The circles from the in-game object
    Squares; // The squares from the in-game object
    PlayerDrag; // Particles from player sliding
    ShipDrag; // Particles from ship flying
    Glitter; // Particles that appear when in a flying game mode like the ship, dart, bird, etc
    Orb; // Orb
    Pad; // Pad
    Portal; // Portal
    SizeDual; // Portal for size and dual
    Collectable; // Collectables particles
    Coins; // Coins
    Fireball; // Fireball
    Land; // Landing
    DashOrb; // Dash Orb
    RobotFire; // Fire from robot jump
    BirdJump; // Bird jump effect (UFO)
    CoinPickup; // Coin collectible pickup
    GlassDestroy; // Glass block destroy (Destructible blocks)
    Death; // Normal death particles
    DeathVortex; // Death particle when having a death effect on
    DeathGravity; // Unsure.
    EndWall; // Effect used on the ending wall
    Firework; // Fireworks on the Level Complete screen
    CompleteText; // Particle burst around Level Complete! text
    StarsObtain; // Obtain stars on end screen
    FallingStar; // Falling stars on ends creen
    Custom(name:String); // Custom effect
}

class Calcite {
    public static var currentModName:String = "Unknown";
    
    public static var CalciteAttr = {
        PlayerSpeedMod: 1.0
    }
    
    public static function log(text:String, ?replace:Array<String>) {
        var result = text;
        if (replace != null) {
            for (r in replace) {
                result = StringTools.replace(result, "%R", r);
            }
        }
        trace('[CALCITE] [$currentModName] $result');
    }

    public static function SpawnParticleEffect(type:ParticleType, pos:CalVec2, color:CalColor, blending:Bool, infinite:Bool) {
        trace('[CALCITE] Not implemented');
    }

    public static function HTTPReq(url:String, method:String, ?body:String, callback:String->Void) {
        var modName = currentModName; // Capture current mod name
        #if js
        var options:Dynamic = {method: method};
        if (body != null) options.body = body;
        
        js.Browser.window.fetch(url, options)
            .then(function(response) return response.text())
            .then(function(text) {
                var prev = currentModName;
                currentModName = modName;
                callback(text);
                currentModName = prev;
                return null;
            })
            .catchError(function(e) {
                var prev = currentModName;
                currentModName = modName;
                trace('[CALCITE] HTTP request failed: $e');
                callback("CalciteFailed");
                currentModName = prev;
            });
        #else
        var http = new haxe.Http(url);
        http.onData = function(data) {
            var prev = currentModName;
            currentModName = modName;
            callback(data);
            currentModName = prev;
        };
        http.onError = function(e) {
            var prev = currentModName;
            currentModName = modName;
            trace('[CALCITE] HTTP request failed: $e');
            callback("CalciteFailed");
            currentModName = prev;
        };
        if (body != null) http.setPostData(body);
        http.request(method == "POST");
        #end
    }
}

class Mod {
    public var info:ModInfo = {name: "Mod name", version: "?", author: "Unknown"};
    public function new() {}
    public function init() {}
    public function getInfo() {
        return info;
    }
}

typedef CalColor = {
    var r:Int;
    var g:Int;
    var b:Int;
}

typedef CalVec2 = {
    var x:Int;
    var y:Int;
}

#end

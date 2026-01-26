# OpenHaxeGD

Welcome to **OpenHaxeGD**, my ongoing attempt to bring Geometry Dash into the modern, open-source world using **Haxe**. If you’ve ever wanted to look at bad code, play around with weird modding, or just play GD on the web, this is the ~~place~~ repo.  

### HEY!!!
Please contribute! I need ts!!!

> WARNING: Extremely chaotic code inside. Proceed with caution... I don't know Haxe much but I DO know Javascript and a bit of C++. Beware.

---

## Table Of Contents
- [What is this?](#what-is-this)
- [Features](#features)
- [How to run](#how-to-run)
- [Contributing](#contributing)
- [Goal(s)](#goals)
- [Notes](#notes)
- [Sources](#sources)
- [**Lapis**](#lapis)
<!--- [] -->

---

## What is this?

OpenHaxeGD is a complete port of **Geometry Dash** built in Haxe. You can:
(Wait, this is just a checklist...)

- [ ] Load and run GD levels (possibly gmd support)
- [X] Play around with Cocos stuff that i ported to haxe  
- [ ] Test hacks, mods, or weird UI experiments in a safe dev environment  
- [X] Peek into a messy but functional recreation of GD logic
- [X] Make mods for Lapis, basically OpenHaxeGD's modloader, its like Geode.

Basically, **(GD + Haxe + Chaos) * cocos2d-haXe = OpenHaxeGD**.  

---

## Features

- idk cocos?
- Lapis!
> Note: Everything is experimental. Some things might explode if you look at them funny.  

---

## How to run

1. Clone this repo: `git clone https://github.com/crzylemon/OpenHaxeGD.git`
2. Probably get Haxe, it's easy, google it.
3. Make sure you have hscript and format. Install it with `haxelib install hscript` and `haxelib install format`
4. Compile it. with `haxe build.hxml`, or you could do something FUN like html5 with `haxe build_js.hxml`.
You should see nothing. Open wherever trace goes on your target platform, and you might see the mod loader doing it's thing.

---

## Contributing

- Waiter, waiter, more pull requests!
- Keep it all close to the source :)
- Please implement the functions :(
- If you see something acting up, just open an issue. It's easy, you say whatever's going on, and I... probably fix it if I feel like it.
- Remember to update sources/contributions when contributing to a file!!!

---

## Goal(s)

- Basically open-source Geometry Dash in Haxe
- Accurate to Geometry Dash and Cocos's code (from these sources)
- Playable.

---

## Notes

- This is 100% unofficial and purely for learning/modding/fun/entertainment/goofy ahh/silly/hacky/gaming/wowzers/whoah purposes.
- You obviously will need to own Geometry Dash for this to work. Please don't pirate RobTop's amazing game. It's amazing.
- Our main source for this code is usually [Project Reversio's Geometry Dash (2.11) Decompile](https://github.com/ProjectReversio/GeometryDash/) but we may use other places (see the sources!!!)
- Expect weird bugs, broken hitboxes, and code that’s held together with duct tape and hope.
- Only expect polished gameplay if we are 100% finished. If not, expect a spike to get angry and walk away from the player while playing Orbit.

---

## Sources

- [Project Reversio's Geometry Dash (2.11) Decompile (ProjectReversio/GeometryDash)](https://github.com/ProjectReversio/GeometryDash/)
- [aloaf812's Geometry Dash (1.7) Decompile, active repo, use as backup for missing funcs or stuff (aloaf812/GD)](https://github.com/aloaf812/GD/tree/1.7)
 - [Project Reversio's Cocos2d-x fork, geodash branch (ProjectReversio/cocos2d-x)](https://github.com/ProjectReversio/cocos2d-x/tree/geodash)
- [Cocos2d-x (cocos2d/cocos2d-x)](https://github.com/cocos2d/cocos2d-x)
- Add more here

Do NOT use sources that are not accurate to the original game

---

# Lapis

Lapis is the mod-loader for OpenHaxeGD! A mod is called a "lazurite", the name of the hooks system is Pyrite, and the name of the helper system is Calcite.

Think of it like Geode but way more chaotic and written in Haxe. Because why not?

---

## How to make a mod

You've got two options here:

### Option 1: Daniel (Blockly Editor)
Use the visual Blockly editor [here](https://crz.network:21212/ohgd/bin/blocky.html). Drag blocks around like you're 5 years old playing with LEGOs and Scratch. It's honestly pretty fun, but very bad.

### Option 2: The Cooler Daniel (HScript)
Write raw HScript code like a true hacker. More power, more responsibility, more bugs.

---

## Mod Structure

Every lazurite (mod) needs metadata. Here's what it looks like:

```haxe
// @name hi im a mod
// @version hi.im.a.version
// @author hi its me crzy probably idk
```

Then, yk, code.


### Pie Rite
(or Pyrite)
Pyrite is the hooks system for Lapis. It lets you hook into game functions and do basically anything.
```haxe
// This triggers whenever you, well, start the game.
Hooks.register("Startlog", Hooks.Defs.OnGameLoadStart, [], function(data) {
    trace("You started the game. You FOOL.");
    return data;
});

// This runs when the game says "You should load now"
Hooks.register("Startlog", Hooks.Defs.OnModLoadTime, [], function(data) {
    trace("{T}he");
    return data;
});

trace("hi the mod literally just ran wtf never put ANYTHING out here");
```

### Common Hooks
Find em yourself, its literally in some random variable somewhere in ModLoad.hx

---

## Calcite (Helper System)

Calcite gives you helper functions so you don't have to reinvent the wheel every time. Because we're lazy. Efficiently lazy.

```haxe
// log smth to the console
Calcite.log("Hi i log") //trace does the same thing
// make the player extremely super fast
Calcite.CalciteAttr.PlayerSpeedMod = 99999999;
```

---

## Mods Folder Structure

Your mods folder should look something like this:

```
mods/
├── mod.json          # this is for javascript and checking if mods are enabled (in the future)
├── mod.hscript       # Your code, can also be .laz
└── othermods.laz     # Look at your file. They used laz. You didn't. How DARE you.
```

Throw your code in and hope for the best.

---

## Example Mods

### Simple Trace Mod
```haxe
Hooks.register("Startlog", Hooks.Defs.OnGameLoadStart, [], function(data) {
    trace("I did the thing!");
    return data;
});
```

### Speed Hack (Educational Purposes Only™)
```haxe
Hooks.register("woosh", Hooks.Defs.OnPlayerSpawn, [], function(player) {
    trace("kachow");
    Calcite.CalciteAttr.PlayerSpeedMod = 2;
    return player;
});
```

---

## Tips & Tricks

- Test your mods frequently. Like, every 5 seconds. Trust me.
- Use `trace()` liberally. It's your best friend when debugging.
- Please, Please do NOT hook into some random thing that doesn't exist.
- Check the console for whatever platform you're on. If you are not playing via the console, then DO to see errors.
- If something breaks, it's probably your fault. But also maybe mine. Nooobody KNOWS.
- Read other mods' code! Steal it all! but be nice?

---

## Shooting Trouble
(Or, troubleshooting.)

**Mod not loading?**
- You forgot to put it in mods.json if you are running the js version

**Game crashes when mod loads?**
- LOL you definitely did something wrong. it should say something

**Mod works but does nothing?**
- Did you actually hook????
- Is your mod not the sahara desert?

---

## API Reference (Coming Soon™)

Full API docs are coming... eventually. For now, check the source code. or ask me in issues if you are lazy or dont know what "code" is.

---

## Mod Ideas

- GDPS switchers
- UI themes
- Praormal mode
- Speedrun.com... but a mod?
- Macros
- Whatever else you can make up

Go wild. Break things. Make something cool. That's what this is all about.


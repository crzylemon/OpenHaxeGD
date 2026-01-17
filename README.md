# OpenHaxeGD

Welcome to **OpenHaxeGD**, my ongoing attempt to bring Geometry Dash into the modern, open-source world using **Haxe**. If you’ve ever wanted to peek under the hood of GD, play around with levels, or just break stuff for fun, this is the place.  

### HEY!!!
We kind of need help right now. We gotta finish the Cocos-2dx simulation.

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
- []

---

## What is this?

OpenHaxeGD is a **Geometry Dash engine reimplementation** built in Haxe. It’s not just a clone, it’s a platform for experimentation, modding, and learning how GD really works. You can:
(Wait, this is just a checklist...)

- [ ] Load and run GD levels (possibly gmd support)
- [X] Play around with Cocos stuff that i ported to haxe  
- [ ] Test hacks, mods, or weird UI experiments in a safe dev environment  
- [X] Peek into a messy but functional recreation of GD logic
- [X] Make mods for Lapis, basically OpenHaxeGD's modloader, its like Geode.

Basically, **GD + Haxe + chaos = OpenHaxeGD**.  

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

- This is 100% unofficial and purely for learning/modding/fun/entertainment/goofy ahh/silly/hacky purposes.
- You obviously will need to own Geometry Dash for this to work. Please don't pirate RobTop's amazing game.
- Our main source for this code is usually [Project Reversio's Geometry Dash (2.11) Decompile](https://github.com/ProjectReversio/GeometryDash/) but we may use other places (see the sources!!!)
- Expect weird bugs, broken hitboxes, and code that’s held together with duct tape and hope.
- Only expect polished gameplay if we are 100% finished. If not, expect a spike to get angry and walk away.

---

## Sources

- [Project Reversio's Geometry Dash (2.11) Decompile (ProjectReversio/GeometryDash)](https://github.com/ProjectReversio/GeometryDash/)
- [aloaf812's Geometry Dash (1.7) Decompile, active repo (aloaf812/GD)](https://github.com/aloaf812/GD/tree/1.7)
<!-- - [Project Reversio's Cocos2d-x fork, geodash branch (ProjectReversio/cocos2d-x)](https://github.com/ProjectReversio/cocos2d-x/tree/geodash) -->
- [Cocos2d-x (cocos2d/cocos2d-x)](https://github.com/cocos2d/cocos2d-x)
- Add more here

---

# Lapis

Lapis is the mod-loader for OpenHaxeGD! A mod is called a "lazurite", the name of the hooks system is Pyrite, and the name of the helper system is Calcite.

---

## How to make a mod
wip, but mods are in bin/mods

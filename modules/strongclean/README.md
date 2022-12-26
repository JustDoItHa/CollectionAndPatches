# Strong Cleaner

## Overview

This is a mod for the game of Don't Starve Together which is available in the Steam Workshop. 

A cleaning mod for your server.

**Cleaning Mechanism:**

It will check the things on the ground every 20 days(by default, configurable). Things that are checked the first time will be added tags. Things with tags that are previously added will be remove during the second round of checking. That means if everything on the ground will go through at least 20 days before removed.

The checking date is at the end of the day of 20,40,60,80,100,etc.

The mod will only remove things that are on the ground and not include in the `whitelist`.

Things that are in the players' inventory or containers, not include in the `whitelist` or near the Endtables are secure.

BTW, server reboot will remove all tags.

**Manual cleaning**

Excute `DoClean()` in the console command and the server will do the cleaning check, which means if you want to do a complete cleanup, you need to run this code twice.

**Whitelist:**

- small creature such as Rabbit, Mole, Fireflies, and the like
- things that have the tag of `irreplaceable`, such as Ancient Key, Chester Eyebone and the like
- Chess Pieces
- Bundle and Gift Bundle
- Deer Antler
- Trap, Teeth Trap and Anenemy
- Books
- Moon Eyes
- Saddle
- Powcake
- Pumpkin Lantern
- Bull Kelp
- Driftwood Piece
- Panflute
- Tentacle Spike and Tentacle Spots
- Dark Sword
- Night Armor
- Bone Helm
- Bone Armor
- Shadow Thurible
- Fossils
- Shadow Atrium
- Life Giving Amulet
- Telltale Heart
- Thermal Stone
- Star Caller's Staff and Moon Caller's Staff
- Cane and The Lazy Explorer
- Glommer's Goop
- Meat Bulb
- Bee Queen Crown
- Shells
- Tackle Containers

You can open the mod folder and find the file named `whitelist.txt`. Add the prefab name of the thing you want to add into the whitelist. One item per line, do not add any `space`, for example,

```
poop
log
cutgrass
twigs
axe
```

The Blacklist is available now thanks to [gene9831](https://github.com/gene9831). You can edit the `blacklist.txt` in the mod folder, two. The format of the file content is the same as whitelist.

**Backup your `whitelist.txt` and `blacklist.txt` because these two file will be emptied after mod update.**

## Changelog

### Version 1.7.4

- Add the feature of manual cleaning.

### Version 1.7.3

- Add Blacklist.

### Version 1.7.1

- Add Shells and Tackle Containers into the whitelist.

### Version 1.7.0

- Now players can modify their own whitelist.

### Version 1.6.0

- Add automatical boats destroying when not landed for a spiecific days in game.

### Version 1.5.0

- Items floating on the sea will be removed whether in the whitelist or not.

### Version 1.4.0

- Tentaclespike, Armor Sanity and Sword Sanity will be removed if the fitness use percent is < 100%.

### Version 1.3.0

- Things near Endtables will not be removed.

### Version 1.2.1

- Add Configuration for cleaning checking period.

## License

Released under the [GNU GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html)
StatHighlight - WoW Forever
Version 1.1.0

WHAT IT DOES
Highlights the name of a stat, its amount and the duration of the effect
in item tooltips: consumables (food, potions, elixirs, scrolls...) and
items that are thrown into a bonfire or have a "Use:" effect. It does not
change items or abilities.

Example: "Restores 530 health ... you gain 6 Stamina and Spirit for 15 min"
         -> "530 health", "6 Stamina" and "Spirit" are highlighted (gold)
            and "15 min" too (light blue).

The menu is in English, or in Spanish if your game client is Spanish.
Item text is recognised in both English and Spanish.

RECOGNISED STATS
Health, mana, rage/energy, stamina, spirit, strength, agility, intellect,
all stats, armor, defense, attack power, spell power/damage, healing,
damage (and damage absorption), regeneration, resistances, critical
strike, hit, haste/attack speed, movement speed, dodge/parry/block,
expertise/mastery/penetration, profession skill (fishing...) and
experience.

COMMANDS
/shl                open or close the options
/shl on | off       enable or disable highlighting
/shl color RRGGBB   change the general color (example: /shl color ffd24a)
/shl reset          reset all options
/shl debug          print the text of every tooltip to chat (send it if a
                    line is not highlighted)
/stathighlight      same as /shl

Note: /sh cannot be used because WoW already uses it for /yell.

It can also be opened from Esc > Options > AddOns > StatHighlight.

The options window has five sections:
- General: "Enabled", "General color" and "Reset all".
- Where to highlight: "Consumables" (on), "Bonfire and other items with an
  effect" (on) and "Gear" (weapons and armor, off).
- Effect duration: highlights "for 30 min", "1 h 30 min", "10 sec"...
  in its own color (right-click = back to light blue). Cooldowns and
  intervals such as "every 5 sec" are not highlighted.
- Tooltip background: "More opaque background" plus a 0-100% slider,
  for when the game world showing through makes text hard to read.
  0% = the game's normal background, 100% = fully solid. Off by default.
- Stats: each stat has a checkbox and its own color box:
  click = own color, right-click = back to the general color.
Hover over any option to see an explanation.
Options are saved between sessions.

INSTALLATION (Windows)
1. Close WoW Forever.
2. Open the game's install folder.
3. Go to: _forever_\Interface\AddOns\
4. Copy the whole "StatHighlight" folder into AddOns. It must look like:
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.toc
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.lua
5. Start the game. On the character select screen, open AddOns and make
   sure StatHighlight is enabled.
6. Log in and hover over some food or a potion.

If the .toc file changes, close the game completely and start it again;
/reload does not read a new .toc. For changes to the .lua only, /reload is
usually enough.

NOTES
- Made for WoW Forever 1.60.1 (Interface 16001), not for Classic Era.
  If the game marks the addon as "out of date", enable "Load out of date
  AddOns" in the AddOns list.
- If a line is not highlighted, type /shl debug, hover over the item and
  send a screenshot of the chat.

CHANGES
Unreleased
- Campfire items: "12 p. más de intelecto" and "un 8% más de
  estadísticas" (and "12 more Intellect", "8% more stats") are now
  highlighted.
- Requirement lines such as "Requiere Pesca (20)" are no longer
  highlighted.
- New: option to make the tooltip background more opaque, up to solid.
- New: StatHighlight appears in Esc > Options > AddOns, with a button
  that opens its options window.
- Fixed: highlights flickering (and briefly showing in the wrong place)
  on tooltips the game refreshes often (bag items, items on cooldown).

1.1.0
- Also highlights items that are thrown into a bonfire and other items
  with a "Use:" effect.
- Scrolls: recognises text such as "Increases the target's Intellect by 8"
  and "Aumenta el Intelecto del objetivo 8 p.".
- New: effect durations ("30 min", "1 h 30 min"...) are highlighted in a
  color you can change.
- Options window reorganised into sections: General, Where to highlight,
  Effect duration and Stats.
- Interface in English, or in Spanish on Spanish clients.
- "Consumables only" is replaced by "Consumables / Bonfire and other /
  Gear"; your previous settings are kept.

1.0.0
- First public release.
- Highlights health, mana, attributes, resistances, damage, speed,
  profession skill, experience and the other consumable stats, in Spanish
  and English. Recognises ranges ("70 to 90") and percentages ("5%").
- Chained stats: in "6 Stamina and Spirit" both are highlighted.
- /shl options with a general color and a color per stat.
- "Consumables only" option (on by default).
- Options saved between sessions.
- Debug mode: /shl debug.

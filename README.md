# StatHighlight

An addon for **WoW Forever** (1.60.1, Interface 16001) that highlights the name of a stat, its amount and the duration of the effect in item tooltips: consumables (food, potions, elixirs, scrolls…) and items that are thrown into a bonfire or have a "Use:" effect. It does not change items or abilities.

> Example: *"Restores 530 health … you gain 6 Stamina and Spirit for 15 min"*
> → **530 health**, **6 Stamina** and **Spirit** are highlighted in gold, and **15 min** in light blue.

The options window is in English, or in Spanish if your game client is Spanish. Item text is recognised in both English and Spanish.

## Download and install

1. Download `StatHighlight-vX.Y.Z.zip` from the [Releases](../../releases/latest) page.
2. Close WoW Forever.
3. Extract the zip into `_forever_\Interface\AddOns\`. It must look like this:

   ```
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.toc
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.lua
   ```

   > ⚠️ Do not use the green **Code → Download ZIP** button: that zip creates a `StatHighlight-main` folder that the game does not recognise. Always use the zip from *Releases*.

4. Start the game. On the character select screen, open **AddOns** and make sure StatHighlight is enabled.
5. Log in and hover over some food or a potion.

If the game marks the addon as *out of date*, enable **Load out of date AddOns** in the AddOns list.

## Recognised stats (English and Spanish)

Health, mana, rage/energy, stamina, spirit, strength, agility, intellect, all stats, armor, defense, attack power, spell power/damage, healing, damage (and damage absorption), regeneration, resistances, critical strike, hit, haste/attack speed, movement speed, dodge/parry/block, expertise/mastery/penetration, profession skill (fishing…) and experience.

## Options and commands

| Command | Description |
|---|---|
| `/shl` | Open or close the options window |
| `/shl on` \| `off` | Enable or disable highlighting |
| `/shl color RRGGBB` | Change the general color (example: `/shl color ffd24a`) |
| `/shl reset` | Reset all options |
| `/shl debug` | Print the text of every tooltip to chat (useful if a line is not highlighted) |
| `/stathighlight` | Same as `/shl` |

> `/sh` cannot be used because WoW already uses it for `/yell`.

The options window has five sections:

- **General**: *Enabled*, *General color* (click the color box) and *Reset all*.
- **Where to highlight**:
  - *Consumables*: food, drink, potions, elixirs, scrolls… (on).
  - *Bonfire and other items with an effect*: items with a "Use:" line or that are thrown into a bonfire (on).
  - *Gear*: weapons and armor (off).
- **Effect duration**: highlights *"for 30 min"*, *"1 h 30 min"*, *"10 sec"*… in its own color (light blue by default; right-click to go back to it). Cooldowns and intervals such as *"every 5 sec"* are not highlighted.
- **Tooltip background**: *Change background opacity* plus a 0–100% slider, for when the game world showing through the tooltip makes the text hard to read. Off by default (the game's own background is used).
- **Stats**: each stat has a checkbox and its own color box: **click** = own color, **right-click** = back to the general color.

Hover over any option to see an explanation. Options are saved between sessions (`StatHighlightDB`).

## Notes

- Made for WoW Forever 1.60.1 (Interface 16001), not for Classic Era.
- If the `.toc` changes, close the game completely and start it again; `/reload` does not read a new `.toc`. For changes to the `.lua` only, `/reload` is usually enough.
- If a line is not highlighted, type `/shl debug`, hover over the item and open an [issue](../../issues) with a screenshot of the chat.

## Changelog

### Unreleased

- Campfire items: amounts written as *"12 p. más de intelecto"* and *"un 8% más de estadísticas"* (and *"12 more Intellect"*, *"8% more stats"*) are now highlighted.
- Requirement lines such as *"Requiere Pesca (20)"* are no longer highlighted.
- New: tooltip background opacity option.

### 1.1.0

- Also highlights items that are thrown into a bonfire and other items with a "Use:" effect.
- Scrolls: recognises text such as *"Increases the target's Intellect by 8"* and *"Aumenta el Intelecto del objetivo 8 p."*.
- New: effect durations (*"30 min"*, *"1 h 30 min"*…) are highlighted in a color you can change.
- Options window reorganised into sections: General, Where to highlight, Effect duration and Stats.
- Interface in English, or in Spanish on Spanish clients.
- *Consumables only* is replaced by *Consumables / Bonfire and other / Gear*; your previous settings are kept.

### 1.0.0

- First public release.
- Highlights health, mana, attributes, resistances, damage, speed, profession skill, experience and the other consumable stats, in Spanish and English. Recognises ranges (*"70 to 90"*) and percentages (*"5%"*).
- Chained stats: in *"6 Stamina and Spirit"* both are highlighted.
- `/shl` options with a general color and a color per stat.
- *Consumables only* option (on by default).
- Options saved between sessions.
- Debug mode: `/shl debug`.

## Releasing a version (maintenance)

1. Update `## Version:` in `StatHighlight.toc` and the *Changelog* section.
2. Create and push a tag with the same number: `git tag v1.2.3 && git push origin v1.2.3`.
3. The GitHub Action runs the tests (`tests/run.lua`), checks that the tag matches the `.toc`, builds `StatHighlight-v1.2.3.zip` (with the `StatHighlight/` folder inside) and publishes it as a Release.

## License

[MIT](LICENSE) © DLS

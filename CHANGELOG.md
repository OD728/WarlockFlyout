# Changelog

## 2.1

### New
- **Themes**: `/wf config` has a new Theme button, **Modern** (the original hexagon look, black border by default) and **Forever** (round gold-ringed buttons and a charcoal and bronze window that fit the Forever UI, gold border by default). Each theme remembers its own border color. Switching is instant, and `/wf theme modern` or `/wf theme forever` does the same.
- **Demonic Sacrifice button**: a small extra button shows while you know Demonic Sacrifice and have none of its four buffs (Burning Shadow, Fel Stamina, Touch of Fire, Fel Energy). Click it to sacrifice; once you have the buff the button hides until it is gone. Works in any spec that has the talent.
- **Sacrifice button position**: pick automatic (opposite the flyouts), top, bottom, left, right or any corner. A checkbox turns the button off.
- The new text is in English and German, and `/wf where` and `Settings.lua` include the new settings.

### Changed
- New installs start with a black border in the Modern theme. Existing settings are kept.

## 2.0

### New
- **Healthstone warning** (off by default): turn on "Warn when I have no healthstone" in `/wf config` and the button pulses green while you carry no healthstone. It only shows if you know Create Healthstone, and the tooltip tells you to right-click and make one. It stops as soon as you have one.
- **Low shard glow** (off by default): turn on "Glow the shard badge below 2 shards" in `/wf config` and the Soul Shard badge glows in the shards' purple when you have 0 or 1 shard. The badge stays visible at 0 shards while this is on.
- The new text is in English and German, and `/wf where` and `Settings.lua` include the setting.

## 1.9

### New
- **Warlock Flyout in the game's options**: Esc > Options > AddOns now lists Warlock Flyout, with a button that opens the settings window. `/wf config` still works too.
- The new text is in English and German.

## 1.8

### New
- **Border color** has its own section in `/wf config`: every color is a swatch, one row per family, instead of a button to click through. Click one to use it, hover for its name; the white ring marks the current color.
- **60 new border colors**: Classic (the game's bar colors), Quality (item colors), Cyberpunk, Dracula, Gruvbox, Catppuccin, Rosé Pine, Kanagawa, OneDark and Tokyo Night. Your current color stays selected.
- The new rows are in English and German; the game's own colors use the client's words (Health, Mana, Epic, ...).

### Changed
- The settings window is dark gray, the same look as the author's other addons. The flyout itself keeps its purple.

## 1.7

### New
- **Shard badge corner** in `/wf config`: bottom right (as before), bottom left, top left or top right.
- **Show the shard number** in `/wf config`: turn it off to show only the Soul Shard. The badge then also stays at 0 shards, fully dark, so you can see you're out.
- The Soul Shard on the badge **darkens as you run low**, like a creeping shadow: full color from 20 shards, a deep shadow at 0. With the number shown it stays a little dimmer, so the number is easy to read.
- The new rows are in English and German, and `/wf where` and `Settings.lua` include both new settings.

## 1.6

### New
- **Border color** in `/wf config`: purple (as before), fel green, ice blue, fire, blood red, gold, silver, pink, black or your class color. It colors the main button's ring, the flyout buttons' borders and their hover glow.
- **Button picture** in `/wf config`: the pentagram (as before), a Soul Shard, or a warlock icon: Summon Imp, Voidwalker, Succubus, Felhunter, Inferno, Ritual of Doom, Shadow Bolt, Corruption, Rain of Fire, Death Coil, Shadow Ward, Demonic Knowledge, Demonic Pact, Incinerate or Shadow and Flame. Icons your client doesn't have are skipped.
- Thicker colored border on the main button and the flyout buttons, so the color shows well on the small buttons too.
- Click either row for the next choice, right-click for the previous one. The new rows are in English and German.
- `/wf where` and `Settings.lua` include both choices.
- **Shard count on a small Soul Shard:** the count now sits on a mini hexagon with the Soul Shard icon and the same border as the flyout buttons, instead of the black circle. It uses the game's number font, like stack counts on action bars, and stays centered at any button size.
- If you carry a soul bag (on Forever: the extra bag slot next to the keyring), the tooltip also shows how full it is.

## 1.5

### Fixed
- Double-digit soul shard counts are now centered in the badge too.

## 1.4

### Fixed
- A single-digit soul shard count is now centered in its badge.

## 1.3

### Fixed
- Create Healthstone, Soulstone, Spellstone and Firestone now show up on non-English clients, such as German. They are found by spell ID instead of by English name, and the best rank you know is always used.

## 1.2

### New
- The right-click flyout now has **Create Spellstone**, always at the best rank you know.

### Changed
- **Inferno** and **Ritual of Doom** now grey out when you have no Infernal Stone or Demonic Figurine, instead of checking soul shards. Their tooltips say what each one needs.
- Shift-click no longer casts Fel Domination before Inferno or Ritual of Doom, since it doesn't help them.

### Fixed
- The `/wf` help line for `dir` showed "leftight" instead of "left|right".

## 1.1

### New
- The right-click flyout now has **Create Soulstone** and **Create Firestone**, next to Create Healthstone. Each one always uses the best rank you know.

### Removed
- The **Ritual of Souls** button is gone from the right-click flyout.
- The button that used a healthstone from your bags is gone. The flyout now holds only spells you cast, not items.

### Changed
- Looting or moving items in your bags no longer rebuilds the flyouts. It only updates the soul shard display.
- The tooltip, settings window and addon list now say "stones" instead of "healthstones".

## 1.0
- First release.

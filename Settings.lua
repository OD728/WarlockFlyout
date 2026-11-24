-- Warlock Flyout - Settings.lua
--
-- Some WoW: Forever builds don't read saved settings back at login, so the
-- button would forget where you put it. These values are used whenever no
-- saved settings were loaded. Type /wf where in game for a ready-made line
-- with your current position, paste it in between the braces below, save
-- this file, and /reload.
--
--   point  = { anchor, anchor on screen, x, y }
--   scale  = 0.5 to 2
--   dir    = "up", "down", "left" or "right" (where the flyouts open)
--   locked = true or false
--   border  = "purple", "fel", "ice", "fire", "blood", "gold", "silver", "pink", "black" or "class"
--   picture = "pentagram", "shard", "knowledge", "pact", "incinerate", "shadowflame",
--             or a spell ID such as 688 (Summon Imp)
--   corner    = "bottomright", "bottomleft", "topleft" or "topright" (where the shard badge sits)
--   showCount = true or false (the number on the shard badge)
--   warnHealthstone = true or false (green pulse on the button while you have no healthstone)

WarlockFlyoutSettings = {
    -- point = { "CENTER", "CENTER", 0, -180 }, scale = 1.0, dir = "up", locked = false,
}

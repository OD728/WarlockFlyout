local addonName = ...

local MEDIA = "Interface\\AddOns\\" .. addonName .. "\\media\\"
local BTN = 46
local SLOT = 26
local GAP = 3
local SOUL_SHARD = 6265

local ACCENT = { 0.80, 0.64, 1.00 }
local EDGE = { 0.46, 0.25, 0.72 }
local FILL = { 0.06, 0.03, 0.11 }
local GLOW = { 0.80, 0.55, 1.00 }

-- Text for the newer settings, in English and German.
local L = {
    armorGlow = "Glow the armor button", armor = "Show the Demon Armor button", armorPos = "Armor button: %s",
    sacPos = "Sacrifice button: %s", auto = "automatic", top = "top", bottom = "bottom", left = "left", right = "right",
    sacrifice = "Show the Demonic Sacrifice button", theme = "Theme: %s", themeWarlock = "Modern", themeForever = "Forever", foreverGold = "Forever gold",
    border = "Border color: %s", picture = "Button picture: %s",
    cycleHint = "Click: next. Right-click: previous.",
    soulBag = "Soul bag: %d of %d slots full",
    purple = "Purple", fel = "Fel green", ice = "Ice blue", fire = "Fire", blood = "Blood red",
    gold = "Gold", silver = "Silver", pink = "Pink", black = "Black", class = "Class color",
    pentagram = "Pentagram", shard = "Soul Shard",
    knowledge = "Demonic Knowledge", pact = "Demonic Pact", incinerate = "Incinerate", shadowflame = "Shadow and Flame",
    corner = "Shard badge: %s", showCount = "Show the shard number",
    warnShards = "Glow the shard badge below 2 shards", warnHealthstone = "Warn when I have no healthstone", noHealthstone = "No healthstone in your bags: right-click and create one",
    bottomright = "bottom right", bottomleft = "bottom left", topright = "top right", topleft = "top left",
    famWarlock = "Warlock", famBasic = "Basics", famClassic = "Classic", famQuality = "Quality",
    cast = "Cast bar", rested = "Rested",
    title = "Warlock Flyout", openBtn = "Open Warlock Flyout",
    openNote = "The options open in their own window (also with /wf).",
}
if GetLocale and GetLocale() == "deDE" then
    L.theme, L.foreverGold = "Design: %s", "Forever-Gold"
    L.sacrifice = "Button für Dämonisches Opfer zeigen"
    L.armorGlow = "Rüstungs-Button leuchten lassen"
    L.armor, L.armorPos = "Button für Dämonenrüstung zeigen", "Rüstungs-Button: %s"
    L.sacPos, L.auto, L.top, L.bottom, L.left, L.right = "Opfer-Button: %s", "automatisch", "oben", "unten", "links", "rechts"
    L.border, L.picture = "Rahmenfarbe: %s", "Button-Bild: %s"
    L.cycleHint = "Klick: nächste. Rechtsklick: vorherige."
    L.soulBag = "Seelentasche: %d von %d Plätzen belegt"
    L.purple, L.fel, L.ice, L.fire, L.blood = "Violett", "Teufelsgrün", "Eisblau", "Feuer", "Blutrot"
    L.gold, L.silver, L.pink, L.black, L.class = "Gold", "Silber", "Pink", "Schwarz", "Klassenfarbe"
    L.pentagram, L.shard = "Pentagramm", "Seelensplitter"
    L.knowledge, L.pact, L.incinerate, L.shadowflame = "Dämonisches Wissen", "Dämonischer Pakt", "Verbrennen", "Schatten und Flamme"
    L.corner, L.showCount = "Splitter-Anzeige: %s", "Splitteranzahl anzeigen"
    L.warnShards = "Splitter-Anzeige leuchtet bei weniger als 2 Splittern"
    L.warnHealthstone, L.noHealthstone = "Warnen, wenn ich keinen Gesundheitsstein habe", "Kein Gesundheitsstein in den Taschen: Rechtsklick und einen herstellen"
    L.bottomright, L.bottomleft, L.topright, L.topleft = "unten rechts", "unten links", "oben rechts", "oben links"
    L.famWarlock, L.famBasic, L.famClassic, L.famQuality = "Hexenmeister", "Grundfarben", "Klassisch", "Qualität"
    L.cast, L.rested = "Zauberleiste", "Erholt"
    L.openBtn, L.openNote = "Warlock Flyout öffnen", "Die Optionen öffnen sich in einem eigenen Fenster (auch mit /wf)."
end

-- Where the shard badge sits: corner of the main button, and the badge center's
-- offset from that corner (mirrored, so every corner looks the same).
local CORNER_LIST = { "bottomright", "bottomleft", "topleft", "topright" }
local CORNERS = {
    bottomright = { "BOTTOMRIGHT", -5, 6 }, bottomleft = { "BOTTOMLEFT", 5, 6 },
    topleft = { "TOPLEFT", 5, -6 }, topright = { "TOPRIGHT", -5, -6 },
}

-- Border colors: they tint the grey hex rings (purple reproduces the original art).
local BORDER_COLORS = {
    purple = { 0.635, 0.345, 1.00 }, fel = { 0.45, 1.00, 0.25 }, ice = { 0.35, 0.75, 1.00 },
    fire = { 1.00, 0.45, 0.15 }, blood = { 1.00, 0.18, 0.25 }, gold = { 1.00, 0.80, 0.30 },
    silver = { 0.85, 0.85, 0.90 }, pink = { 1.00, 0.35, 0.80 }, black = { 0.08, 0.08, 0.09 },
    -- Six accents from each color scheme (same values as Cooldown Skin and XP Rail).
    drac_purple = { 0.74, 0.58, 0.98 }, drac_pink = { 1.00, 0.47, 0.78 }, drac_red = { 1.00, 0.33, 0.33 },
    drac_orange = { 1.00, 0.72, 0.42 }, drac_green = { 0.31, 0.98, 0.48 }, drac_cyan = { 0.55, 0.91, 0.99 },
    ctp_mauve = { 0.80, 0.65, 0.97 }, ctp_pink = { 0.96, 0.76, 0.91 }, ctp_red = { 0.95, 0.55, 0.66 },
    ctp_peach = { 0.98, 0.70, 0.53 }, ctp_green = { 0.65, 0.89, 0.63 }, ctp_blue = { 0.54, 0.71, 0.98 },
    gruv_red = { 0.98, 0.29, 0.20 }, gruv_orange = { 1.00, 0.50, 0.10 }, gruv_yellow = { 0.98, 0.74, 0.18 },
    gruv_green = { 0.72, 0.73, 0.15 }, gruv_aqua = { 0.56, 0.75, 0.49 }, gruv_purple = { 0.83, 0.53, 0.61 },
    rose_love = { 0.92, 0.44, 0.57 }, rose_gold = { 0.96, 0.76, 0.47 }, rose_rose = { 0.92, 0.74, 0.73 },
    rose_pine = { 0.19, 0.45, 0.56 }, rose_foam = { 0.61, 0.81, 0.85 }, rose_iris = { 0.77, 0.65, 0.91 },
    kana_violet = { 0.58, 0.50, 0.72 }, kana_pink = { 0.82, 0.49, 0.60 }, kana_red = { 0.89, 0.41, 0.46 },
    kana_orange = { 1.00, 0.63, 0.40 }, kana_green = { 0.60, 0.73, 0.42 }, kana_blue = { 0.49, 0.61, 0.85 },
    one_purple = { 0.78, 0.47, 0.87 }, one_red = { 0.91, 0.40, 0.44 }, one_orange = { 0.82, 0.60, 0.40 },
    one_yellow = { 0.90, 0.75, 0.48 }, one_green = { 0.60, 0.76, 0.47 }, one_blue = { 0.38, 0.69, 0.94 },
    tokyo_magenta = { 0.73, 0.60, 0.97 }, tokyo_red = { 0.97, 0.46, 0.56 }, tokyo_orange = { 1.00, 0.62, 0.39 },
    tokyo_yellow = { 0.88, 0.69, 0.41 }, tokyo_green = { 0.62, 0.81, 0.42 }, tokyo_blue = { 0.48, 0.64, 0.97 },
    cyber_yellow = { 0.99, 0.93, 0.04 }, cyber_pink = { 1.00, 0.16, 0.43 }, cyber_cyan = { 0.02, 0.85, 0.91 },
    cyber_red = { 1.00, 0.00, 0.24 }, cyber_acid = { 0.22, 1.00, 0.08 }, cyber_purple = { 0.69, 0.15, 1.00 },
    -- The game's own colors: the default bars, then item quality.
    cl_health = { 0.00, 1.00, 0.00 }, cl_mana = { 0.10, 0.40, 1.00 }, cl_rage = { 1.00, 0.00, 0.00 },
    cl_energy = { 1.00, 1.00, 0.00 }, cl_cast = { 1.00, 0.70, 0.00 }, cl_rested = { 0.00, 0.39, 0.88 },
    q_uncommon = { 0.12, 1.00, 0.00 }, q_rare = { 0.00, 0.44, 0.87 }, q_epic = { 0.64, 0.21, 0.93 },
    q_legendary = { 1.00, 0.50, 0.00 }, q_artifact = { 0.90, 0.80, 0.50 }, q_heirloom = { 0.00, 0.80, 1.00 },
}
-- The swatch rows in the settings window, one family per row ("class" is computed).
-- Same order in all the addons: their own rows, WoW colors, neon styles, then the
-- color schemes in the order of the Colorschemes page.
local BORDER_ROWS = {
    { fam = "warlock", list = { "purple", "fel", "ice", "fire", "blood", "pink" } },
    { fam = "basic",   list = { "gold", "silver", "black", "class" } },
    { fam = "cl",    list = { "cl_health", "cl_mana", "cl_rage", "cl_energy", "cl_cast", "cl_rested" } },
    { fam = "q",     list = { "q_uncommon", "q_rare", "q_epic", "q_legendary", "q_artifact", "q_heirloom" } },
    { fam = "cyber", list = { "cyber_yellow", "cyber_pink", "cyber_cyan", "cyber_red", "cyber_acid", "cyber_purple" } },
    { fam = "drac",  list = { "drac_purple", "drac_pink", "drac_red", "drac_orange", "drac_green", "drac_cyan" } },
    { fam = "gruv",  list = { "gruv_red", "gruv_orange", "gruv_yellow", "gruv_green", "gruv_aqua", "gruv_purple" } },
    { fam = "ctp",   list = { "ctp_mauve", "ctp_pink", "ctp_red", "ctp_peach", "ctp_green", "ctp_blue" } },
    { fam = "rose",  list = { "rose_love", "rose_gold", "rose_rose", "rose_pine", "rose_foam", "rose_iris" } },
    { fam = "kana",  list = { "kana_violet", "kana_pink", "kana_red", "kana_orange", "kana_green", "kana_blue" } },
    { fam = "one",   list = { "one_purple", "one_red", "one_orange", "one_yellow", "one_green", "one_blue" } },
    { fam = "tokyo", list = { "tokyo_magenta", "tokyo_red", "tokyo_orange", "tokyo_yellow", "tokyo_green", "tokyo_blue" } },
}
local SCHEME_NAMES = { drac = "Dracula", ctp = "Catppuccin", gruv = "Gruvbox", rose = "Rosé Pine",
    kana = "Kanagawa", one = "OneDark", tokyo = "Tokyo Night", cyber = "Cyberpunk" }

-- Button pictures: the original art, or a game icon (by spell or item ID, so names
-- come out in the client's language). Talents from later expansions have no spell
-- on Forever, so they use the icon file directly; any the client lacks are skipped.
local PICTURE_LIST = { "pentagram", "shard", 688, 697, 712, 691, 1122, 18540, 686, 172, 5740, 6789, 6229,
    "knowledge", "pact", "incinerate", "shadowflame" }
local PICTURE_ICONS = {
    knowledge = "spell_shadow_improvedvampiricembrace", pact = "spell_shadow_demonicpact",
    incinerate = "spell_fire_burnout", shadowflame = "spell_shadow_shadowandflame",
}

-- The settings window's colors: the same dark gray as Cooldown Skin's and XP Rail's
-- windows (the flyout itself stays purple).
local UI_FILL = { 0.05, 0.05, 0.06 }
local UI_EDGE = { 0.30, 0.30, 0.33 }

-- Themes. ACCENT, EDGE, FILL, GLOW, UI_FILL, UI_EDGE and the "purple" border color
-- are tables that ApplyTheme rewrites in place, so everything that reads them (and
-- everything registered with Themed) follows the chosen theme.
--   warlock = the original purple look, forever = dark charcoal with bronze/gold edges
local THEMES = {
    warlock = { accent = ACCENT, edge = EDGE, fill = FILL, glow = GLOW, uiFill = { 0.05, 0.05, 0.06 },
        uiEdge = { 0.30, 0.30, 0.33 }, ring = { 0.635, 0.345, 1.00 } },
    forever = { shape = "circle", accent = { 0.93, 0.78, 0.30 }, edge = { 0.66, 0.52, 0.20 }, fill = { 0.06, 0.07, 0.08 },
        glow = { 1.00, 0.86, 0.50 }, uiFill = { 0.06, 0.07, 0.08 }, uiEdge = { 0.62, 0.49, 0.20 },
        ring = { 0.80, 0.64, 0.22 } },
}
local THEME_LIST = { "warlock", "forever" }
THEMES.warlock.accent, THEMES.warlock.edge = { unpack(ACCENT) }, { unpack(EDGE) }
THEMES.warlock.fill, THEMES.warlock.glow = { unpack(FILL) }, { unpack(GLOW) }

local ROLE_TABLE = { accent = ACCENT, edge = EDGE, fill = FILL, uiFill = UI_FILL, uiEdge = UI_EDGE }
local themed = {}
local function Themed(obj, role, alpha)
    themed[#themed + 1] = { obj, role, alpha or 1 }
    local c = ROLE_TABLE[role]
    if obj.SetColorTexture then obj:SetColorTexture(c[1], c[2], c[3], alpha or 1)
    else obj:SetTextColor(c[1], c[2], c[3]) end
end

local function Panel(f, alpha, fillRole, edgeRole)
    fillRole, edgeRole = fillRole or "fill", edgeRole or "edge"
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    Themed(bg, fillRole, alpha or 0.92)
    local edges = { bg }
    for _, e in ipairs({ { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" },
                         { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true } }) do
        local t = f:CreateTexture(nil, "BORDER")
        t:SetPoint(e[1]); t:SetPoint(e[2])
        if e[3] then t:SetWidth(1) else t:SetHeight(1) end
        Themed(t, edgeRole)
        edges[#edges + 1] = t
    end
    return edges
end

local DEFAULTS = { armorGlow = true, armor = true, armorPos = "auto", sacrifice = true, sacPos = "auto", theme = "warlock", locked = false, scale = 1, dir = "up", shown = true, border = "black", borderForever = "purple", picture = "pentagram",
    corner = "bottomright", showCount = true, warnHealthstone = false, warnShards = false }

local DEMONS = {
    { names = { "Summon Imp" }, id = 688, free = true },
    { names = { "Summon Voidwalker" }, id = 697 },
    { names = { "Summon Succubus" }, id = 712 },
    { names = { "Summon Incubus" }, id = 713 },
    { names = { "Summon Felhunter", "Summon Fel Hunter" }, id = 691 },
    { names = { "Summon Felguard" }, id = 30146 },
    { names = { "Summon Infernal", "Inferno" }, id = 1122, reagent = 5565, noFelDom = true,
      hint = "Click: drop an Infernal on the target area (needs an Infernal Stone, outdoors only)" },
    { names = { "Summon Doomguard", "Ritual of Doom" }, id = 18540, reagent = 16583, noFelDom = true,
      hint = "Click: start the ritual (needs a Demonic Figurine and 4 party members)" },
}

local NOT_DEMONS = { "steed", "^summon demon$" }

local DEMONIC_SACRIFICE = { names = { "Demonic Sacrifice" }, id = 18788 }
local FEL_DOMINATION = { names = { "Fel Domination" }, id = 18708 }
local RITUAL_OF_SUMMONING = { names = { "Ritual of Summoning" }, id = 698 }
local CREATE_STONES = {
    { prefix = "^create healthstone", name = "Create Healthstone", hint = "Click: make a healthstone",
      ids = { 27230, 11730, 11729, 5699, 6202, 6201 } },
    { prefix = "^create soulstone", name = "Create Soulstone", hint = "Click: make a soulstone",
      ids = { 27238, 20757, 20756, 20755, 20752, 693 } },
    { prefix = "^create spellstone", name = "Create Spellstone", hint = "Click: make a spellstone",
      ids = { 28172, 17728, 17727, 2362 } },
    { prefix = "^create firestone", name = "Create Firestone", hint = "Click: make a firestone",
      ids = { 27250, 17953, 17952, 17951, 6366 } },
}

local NAME_TIER = { { "master", 6 }, { "major", 5 }, { "greater", 4 }, { "lesser", 2 }, { "minor", 1 } }
local function TierOfName(lower)
    for _, nt in ipairs(NAME_TIER) do
        if lower:find(nt[1], 1, true) then return nt[2] end
    end
    return 3
end

local db = {}
for k, v in pairs(DEFAULTS) do db[k] = v end
local Addon = {}

function WarlockFlyout_OnCompartmentClick()
    if Addon.ToggleConfig then Addon.ToggleConfig() end
end

local function IsWarlock()
    local _, class = UnitClass("player")
    return class == "WARLOCK", class
end
do
    local ok, class = IsWarlock()
    if class and not ok then return end
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcca3ffWarlock Flyout|r: " .. tostring(msg))
end

local function Readable(v)
    if v == nil then return nil end
    if type(issecretvalue) == "function" then
        local ok, secret = pcall(issecretvalue, v)
        if ok then return (not secret) and v or nil end
    end
    if type(v) == "number" and not pcall(function() return v < 0 end) then return nil end
    if type(v) == "string" and not pcall(function() return v .. "" end) then return nil end
    return v
end

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then
        local ok, n = pcall(C_Spell.GetSpellName, id)
        if ok and n then return Readable(n) end
    end
    if GetSpellInfo then
        local ok, n = pcall(GetSpellInfo, id)
        if ok and n then return Readable(n) end
    end
end

local function SpellIcon(id, name)
    if C_Spell and C_Spell.GetSpellTexture then
        local ok, t = pcall(C_Spell.GetSpellTexture, id or name)
        if ok and t then return t end
    end
    if GetSpellTexture then
        local ok, t = pcall(GetSpellTexture, id or name)
        if ok and t then return t end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function SpellCooldown(id)
    if not id then return end
    if C_Spell and C_Spell.GetSpellCooldown then
        local ok, cd = pcall(C_Spell.GetSpellCooldown, id)
        if ok and cd then return Readable(cd.startTime), Readable(cd.duration) end
        return
    end
    if GetSpellCooldown then
        local ok, s, d = pcall(GetSpellCooldown, id)
        if ok then return Readable(s), Readable(d) end
    end
end

local function KnownID(id)
    if not id then return false end
    for _, fn in ipairs({
        C_SpellBook and C_SpellBook.IsSpellKnown or false, IsPlayerSpell or false, IsSpellKnown or false,
    }) do
        if type(fn) == "function" then
            local ok, k = pcall(fn, id)
            if ok and k then return true end
        end
    end
    return false
end

local function ItemCount(id)
    local n
    if C_Item and C_Item.GetItemCount then
        local ok, c = pcall(C_Item.GetItemCount, id)
        n = ok and c
    elseif GetItemCount then
        local ok, c = pcall(GetItemCount, id)
        n = ok and c
    end
    return tonumber(Readable(n)) or 0
end

-- Every healthstone item (plain and talent-improved ranks, Classic and TBC).
local HEALTHSTONES = { 5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009, 5510, 19010, 19011,
    9421, 19012, 19013, 22103, 22104, 22105 }
local function HasHealthstone()
    for _, id in ipairs(HEALTHSTONES) do
        if ItemCount(id) > 0 then return true end
    end
    return false
end

local book, bookList = {}, {}

local function ScanBook()
    book, bookList = {}, {}
    local function add(name, id, slot)
        name = Readable(name)
        if type(name) ~= "string" or name == "" then return end
        local key = name:lower()
        local prev = book[key]

        if prev then
            if (slot or 0) >= (prev.slot or 0) then prev.id, prev.slot = id, slot end
            return
        end
        local e = { name = name, id = id, slot = slot }
        book[key] = e
        bookList[#bookList + 1] = e
    end

    if C_SpellBook and C_SpellBook.GetSpellBookItemInfo and Enum and Enum.SpellBookSpellBank then
        local bank = Enum.SpellBookSpellBank.Player
        local ranges = {}
        if C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo then
            local okN, n = pcall(C_SpellBook.GetNumSpellBookSkillLines)
            for line = 1, (okN and tonumber(n) or 0) do
                local ok, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, line)
                if ok and info and info.numSpellBookItems and info.itemIndexOffset
                    and (not info.offSpecID or info.offSpecID == 0) then
                    ranges[#ranges + 1] = { info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems }
                end
            end
        end
        if #ranges == 0 then ranges = { { 1, 500, true } } end
        for _, r in ipairs(ranges) do
            local misses = 0
            for i = r[1], r[2] do
                local ok, item = pcall(C_SpellBook.GetSpellBookItemInfo, i, bank)
                if ok and item and item.name then
                    misses = 0
                    local castable = not item.isPassive and not item.isOffSpec
                    if castable and Enum.SpellBookItemType and item.itemType ~= nil
                        and item.itemType ~= Enum.SpellBookItemType.Spell then
                        castable = false
                    end
                    if castable and C_SpellBook.IsSpellBookItemKnown then
                        local okK, known = pcall(C_SpellBook.IsSpellBookItemKnown, i, bank)
                        if okK and known ~= nil then castable = known and true or false end
                    end
                    if castable then add(item.name, item.spellID or item.actionID, i) end
                else
                    misses = misses + 1
                    if r[3] and misses >= 8 then break end
                end
            end
        end
    elseif type(GetSpellBookItemName) == "function" then
        for i = 1, 500 do
            local ok, name, _, id = pcall(GetSpellBookItemName, i, "spell")
            if not ok or not name then break end
            if not id or KnownID(id) then add(name, id, i) end
        end
    end
end

local function Find(def)
    for _, n in ipairs(def.names) do
        local e = book[n:lower()]
        if e then return e end
    end

    local n = def.id and SpellName(def.id)
    if n and book[n:lower()] then return book[n:lower()] end

    if #bookList == 0 and KnownID(def.id) then
        return { name = SpellName(def.id) or def.names[1], id = def.id }
    end
end

local function FindBestRank(def)
    -- By spell ID first (best rank first): works in every client language.
    local inBook = {}
    for _, e in ipairs(bookList) do
        if e.id then inBook[e.id] = e end
    end
    for _, id in ipairs(def.ids) do
        if inBook[id] then return inBook[id] end
        if KnownID(id) then
            local n = SpellName(id)
            local e = n and book[n:lower()]
            return { name = (e and e.name) or n or def.name, id = id }
        end
    end

    -- Fallback for IDs this list doesn't know: match the English name.
    local best, bestTier
    for _, e in ipairs(bookList) do
        local lower = e.name:lower()
        if lower:find(def.prefix) then
            local tier = TierOfName(lower)
            if not best or tier > bestTier or (tier == bestTier and (e.slot or 0) > (best.slot or 0)) then
                best, bestTier = e, tier
            end
        end
    end
    return best
end

local main = CreateFrame("Button", "WarlockFlyoutButton", UIParent, "SecureHandlerClickTemplate")
main:SetSize(BTN, BTN)
main:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
main:SetFrameStrata("MEDIUM")
main:SetClampedToScreen(true)
main:SetMovable(true)
main:RegisterForClicks("AnyUp")
main:RegisterForDrag("LeftButton")

local function HexMask(owner, tex)
    if not owner.CreateMaskTexture then return end
    pcall(function()
        local mask = owner:CreateMaskTexture()
        mask:SetTexture(MEDIA .. "hex_mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(tex)
        tex:AddMaskTexture(mask)
        owner.mask = mask
    end)
end

-- A border color by key: "class" is the warlock class color, brightened to full.
local function ColorOf(key)
    if key == "class" then
        local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS.WARLOCK
        if c and c.r then
            local m = math.max(c.r, c.g, c.b, 0.01)
            return { c.r / m, c.g / m, c.b / m }
        end
    end
    return BORDER_COLORS[key] or BORDER_COLORS.purple
end

-- Each theme remembers its own border color: Forever in db.borderForever (default
-- "purple", which is drawn as Forever gold there), the other theme in db.border.
local function BorderKey()
    if db.theme == "forever" then return db.borderForever or "purple" end
    return db.border or "black"
end
local function SetBorderKey(key)
    if db.theme == "forever" then db.borderForever = key else db.border = key end
end

local function BorderColor() return ColorOf(BorderKey()) end

-- Names for the swatch rows and tooltips. Game colors use the client's own words
-- (HEALTH, MANA, ITEM_QUALITYn_DESC), so they come out in its language.
local GAME_WORDS = {
    cl_health = function() return HEALTH or "Health" end, cl_mana = function() return MANA or "Mana" end,
    cl_rage = function() return RAGE or "Rage" end, cl_energy = function() return ENERGY or "Energy" end,
    cl_cast = function() return L.cast end, cl_rested = function() return L.rested end,
    q_uncommon = function() return ITEM_QUALITY2_DESC or "Uncommon" end,
    q_rare = function() return ITEM_QUALITY3_DESC or "Rare" end,
    q_epic = function() return ITEM_QUALITY4_DESC or "Epic" end,
    q_legendary = function() return ITEM_QUALITY5_DESC or "Legendary" end,
    q_artifact = function() return ITEM_QUALITY6_DESC or "Artifact" end,
    q_heirloom = function() return ITEM_QUALITY7_DESC or "Heirloom" end,
}
local function FamilyName(fam)
    return SCHEME_NAMES[fam] or ({ warlock = L.famWarlock, basic = L.famBasic, cl = L.famClassic,
        q = L.famQuality })[fam] or fam
end
local function BorderName(key)
    if key == "purple" and db.theme == "forever" then return L.foreverGold end
    if L[key] then return L[key] end
    local word = GAME_WORDS[key] and GAME_WORDS[key]()
    local fam, color = key:match("^(%a+)_(%a+)$")
    if word then return word end
    if fam and SCHEME_NAMES[fam] then
        return SCHEME_NAMES[fam] .. " " .. color:sub(1, 1):upper() .. color:sub(2)
    end
    return key
end

-- The hover glow: the border color, lighter. Purple keeps its original glow.
local function GlowColor()
    if BorderKey() == "purple" then return GLOW end
    local c = BorderColor()
    return { c[1] + (1 - c[1]) * 0.35, c[2] + (1 - c[2]) * 0.35, c[3] + (1 - c[3]) * 0.35 }
end

-- Hexagon or circle art for one face, from the theme's shape.
local function ShapeArt(b)
    local shape = (THEMES[db.theme] or THEMES.warlock).shape or "hex"
    b.frameArt:SetTexture(MEDIA .. (shape == "hex" and b.hexArt or "circle_ring"))
    b.glow:SetTexture(MEDIA .. shape .. "_glow")
    if b.mask then b.mask:SetTexture(MEDIA .. shape .. "_mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") end
    if b.cooldown then pcall(b.cooldown.SetSwipeTexture, b.cooldown, MEDIA .. shape .. "_mask") end
    if b.pushedArt then b.pushedArt:SetTexture(MEDIA .. shape .. "_mask") end
end

local function TintFace(b)
    ShapeArt(b)
    local c, g = BorderColor(), GlowColor()
    b.frameArt:SetVertexColor(c[1], c[2], c[3])
    b.glow:SetVertexColor(g[1], g[2], g[3])
end

local function PictureTexture(p)
    if p == "shard" then
        for _, fn in ipairs({ C_Item and C_Item.GetItemIconByID or false, GetItemIcon or false }) do
            if type(fn) == "function" then
                local ok, t = pcall(fn, SOUL_SHARD)
                if ok and t then return t end
            end
        end
        return "Interface\\Icons\\INV_Misc_Gem_Amethyst_02"
    elseif type(p) == "number" then
        return SpellIcon(p)
    elseif PICTURE_ICONS[p] then
        return "Interface\\Icons\\" .. PICTURE_ICONS[p]
    end
    return MEDIA .. "button"
end

-- Can this client show the picture? Unknown spells or missing icon files are skipped.
local probe
local function PictureAvailable(p)
    if type(p) == "number" then
        for _, fn in ipairs({ C_Spell and C_Spell.GetSpellTexture or false, GetSpellTexture or false }) do
            if type(fn) == "function" then
                local ok, t = pcall(fn, p)
                return ok and t ~= nil
            end
        end
        return true
    elseif PICTURE_ICONS[p] then
        local path = "Interface\\Icons\\" .. PICTURE_ICONS[p]
        local checked = false
        if type(GetFileIDFromPath) == "function" then
            checked = true
            for _, v in ipairs({ path, path .. ".blp" }) do
                local ok, id = pcall(GetFileIDFromPath, v)
                if ok and id then return true end
            end
        end
        probe = probe or UIParent:CreateTexture(nil, "BACKGROUND")
        if probe.GetTextureFileID then
            checked = true
            probe:SetTexture(nil)
            probe:SetTexture(path)
            local ok, id = pcall(probe.GetTextureFileID, probe)
            if ok and id then return true end
        end
        return not checked
    end
    return true
end

local function PictureName(p)
    if p == "shard" then return L.shard end
    if PICTURE_ICONS[p] then return L[p] end
    if type(p) == "number" then return SpellName(p) or ("#" .. p) end
    return L.pentagram
end

local function HexFace(b, frameArt)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    HexMask(b, b.icon)
    b.frameArt = b:CreateTexture(nil, "OVERLAY")
    b.frameArt:SetAllPoints()
    b.hexArt = frameArt
    b.frameArt:SetTexture(MEDIA .. frameArt)
    b.glow = b:CreateTexture(nil, "HIGHLIGHT")
    b.glow:SetAllPoints()
    b.glow:SetTexture(MEDIA .. "hex_glow")
    b.glow:SetBlendMode("ADD")
    b.glow:SetAlpha(0.45)
    TintFace(b)
end

HexFace(main, "hex_ring")
main.icon:SetTexture(MEDIA .. "button")

-- Shard count: a small Soul Shard (the game's item icon in a mini hexagon with the
-- same border as the flyout buttons), the number on top.
main.badge = CreateFrame("Frame", nil, main)
main.badge:SetSize(22, 22)
main.badge:SetPoint("CENTER", main, "BOTTOMRIGHT", -5, 6)
main.badge:SetFrameLevel(main:GetFrameLevel() + 3)
HexFace(main.badge, "hex_border")
main.badge.icon:SetTexture(PictureTexture("shard"))
main.badge.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
main.badge.icon:SetVertexColor(0.6, 0.6, 0.6)   -- a bit darker, so the white number stands out
main.count = main.badge:CreateFontString(nil, "OVERLAY")
main.count:SetDrawLayer("OVERLAY", 7)
-- The game's number font (as on action bar stack counts): its digits are centered
-- in their own width, so the number needs no nudge.
local numberFont = NumberFontNormal and NumberFontNormal:GetFont()
main.count:SetFont(numberFont or "Fonts\\ARIALN.TTF", 11, "OUTLINE")
main.count:SetAllPoints(main.badge)
main.count:SetJustifyH("CENTER")
main.count:SetJustifyV("MIDDLE")
main.count:SetTextColor(1, 1, 1)

-- Optional warning: a green pulse around the button while you have no healthstone.
main.warn = main:CreateTexture(nil, "OVERLAY", nil, 6)
main.warn:SetPoint("CENTER")
main.warn:SetSize(BTN * 1.25, BTN * 1.25)
main.warn:SetTexture(MEDIA .. "hex_glow")
main.warn:SetBlendMode("ADD")
main.warn:SetVertexColor(0.22, 0.7, 0.22)
main.warn:Hide()
main.warn.anim = main.warn:CreateAnimationGroup()
main.warn.anim:SetLooping("BOUNCE")
do
    local a = main.warn.anim:CreateAnimation("Alpha")
    a:SetFromAlpha(0.33)
    a:SetToAlpha(0.06)
    a:SetDuration(0.9)
end

-- Optional warning: the shard badge glows in the shards' purple below 2 shards.
main.shardGlow = main.badge:CreateTexture(nil, "OVERLAY", nil, 6)
main.shardGlow:SetPoint("CENTER")
main.shardGlow:SetSize(22 * 1.5, 22 * 1.5)
main.shardGlow:SetTexture(MEDIA .. "hex_glow")
main.shardGlow:SetBlendMode("ADD")
main.shardGlow:SetVertexColor(GLOW[1], GLOW[2], GLOW[3])
main.shardGlow:Hide()
main.shardGlow.anim = main.shardGlow:CreateAnimationGroup()
main.shardGlow.anim:SetLooping("BOUNCE")
do
    local a = main.shardGlow.anim:CreateAnimation("Alpha")
    a:SetFromAlpha(0.7)
    a:SetToAlpha(0.15)
    a:SetDuration(0.9)
end

local function UpdateShardGlow(shards)
    if db.warnShards == true and shards < 2 then
        main.shardGlow:Show()
        main.shardGlow.anim:Play()
    else
        main.shardGlow.anim:Stop()
        main.shardGlow:Hide()
    end
end

local function UpdateWarning()
    local on = db.warnHealthstone == true and Addon.canMakeHealthstone and not HasHealthstone()
    main.missingHealthstone = on and true or false
    if on then
        main.warn:Show()
        main.warn.anim:Play()
        main.frameArt:SetVertexColor(0.3, 0.85, 0.3)   -- the ring turns green too
    else
        main.warn.anim:Stop()
        main.warn:Hide()
        TintFace(main)                                 -- back to your border color
    end
end

local function NewFlyout(name)
    local f = CreateFrame("Frame", name, main, "SecureHandlerBaseTemplate")
    f:SetFrameStrata("HIGH")

    f.panel = Panel(f)
    for _, t in ipairs(f.panel) do t:Hide() end
    f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.empty:SetPoint("CENTER")
    f.buttons = {}
    f:Hide()
    return f
end

local demons = NewFlyout("WarlockFlyoutDemons")
local utils = NewFlyout("WarlockFlyoutUtility")
demons.empty:SetText("No demons learned")
utils.empty:SetText("Nothing learned yet")

main:SetFrameRef("demons", demons)
main:SetFrameRef("utils", utils)

main:SetAttribute("_onclick", [=[
    local demons, utils = self:GetFrameRef("demons"), self:GetFrameRef("utils")
    local open, other = demons, utils
    if button == "RightButton" then open, other = utils, demons end
    other:Hide()
    if open:IsShown() then open:Hide() else open:Show() end
]=])

local function ButtonTooltip(b)
    GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
    local drawn = false
    if b.spellID and GameTooltip.SetSpellByID then
        drawn = pcall(GameTooltip.SetSpellByID, GameTooltip, b.spellID)
    end
    if not drawn or GameTooltip:NumLines() == 0 then GameTooltip:AddLine(b.label or "?") end
    if b.hint then GameTooltip:AddLine(b.hint, ACCENT[1], ACCENT[2], ACCENT[3], true) end
    GameTooltip:Show()
end

local function FlyoutButton(f, i)
    local b = f.buttons[i]
    if b then return b end
    b = CreateFrame("Button", f:GetName() .. "Button" .. i, f, "SecureActionButtonTemplate")
    b:SetSize(SLOT, SLOT)

    b:RegisterForClicks("AnyUp", "AnyDown")
    b:SetAttribute("useOnKeyDown", false)
    HexFace(b, "hex_border")
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.cooldown = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cooldown:SetAllPoints()

    pcall(b.cooldown.SetSwipeTexture, b.cooldown, MEDIA .. "hex_mask")
    pcall(b.cooldown.SetDrawEdge, b.cooldown, false)

    local pushed = b:CreateTexture(nil, "OVERLAY")
    pushed:SetAllPoints()
    pushed:SetTexture(MEDIA .. "hex_mask")
    pushed:SetVertexColor(0, 0, 0, 0.45)
    b.pushedArt = pushed
    pcall(b.SetPushedTexture, b, pushed)
    b:SetScript("OnEnter", ButtonTooltip)
    b:SetScript("OnLeave", GameTooltip_Hide)

    if type(SecureHandlerWrapScript) == "function" then
        pcall(SecureHandlerWrapScript, b, "OnClick", f,
            [=[ if not down then return nil, true end ]=], [=[ owner:Hide() ]=])
    end
    f.buttons[i] = b
    return b
end

local function ClearButton(b)
    for _, k in ipairs({ "type", "spell", "shift-type1", "shift-macrotext1" }) do b:SetAttribute(k, nil) end
    b.spellID, b.label, b.hint, b.free, b.reagent = nil, nil, nil, nil, nil
    b:Hide()
end

-- Demonic Sacrifice: its own small button, shown while you know the spell and have
-- none of the four sacrifice buffs (a pet isn't required: Demonic Pact keeps it).
local sac = CreateFrame("Button", "WarlockFlyoutSacrifice", main, "SecureActionButtonTemplate")
sac:SetSize(SLOT + 4, SLOT + 4)
sac:RegisterForClicks("AnyUp", "AnyDown")
sac:SetAttribute("useOnKeyDown", false)
HexFace(sac, "hex_border")
sac.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
sac:SetScript("OnEnter", ButtonTooltip)
sac:SetScript("OnLeave", GameTooltip_Hide)
sac.hint = "Click: sacrifice your demon for the buff"
sac:Hide()

-- The four sacrifice buffs (Burning Shadow 18789, Fel Stamina 18790, Touch of Fire 18791, Fel Energy 18792):
-- while one is up the button stays out of the way, even if a pet is still reported.
local SAC_BUFFS = { [18789] = true, [18790] = true, [18791] = true, [18792] = true }
-- Aura instance IDs of the buffs seen while out of combat, so losing one in combat
-- (the game tells us which instance was removed) brings its button back.
local armorAura, sacAura

local function HasAura(set)
    -- Direct lookup by ID first, then a scan of the buff list.
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for id in pairs(set) do
            local ok, a = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
            if ok and a then return true, a.auraInstanceID end
        end
    end
    for i = 1, 40 do
        local id, auraInstance
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
            if not ok or not a then break end
            id = tonumber(Readable(a.spellId))
            auraInstance = a.auraInstanceID
        elseif UnitBuff then
            local ok, _, _, _, _, _, _, _, _, _, sid = pcall(UnitBuff, "player", i)
            if not ok or not sid then break end
            id = tonumber(Readable(sid))
        else
            break
        end
        if id and set[id] then return true, auraInstance end
    end
    return false
end
local function HasSacrificeBuff() return HasAura(SAC_BUFFS) end

-- Alpha (not Hide) so it also works in combat, where a secure frame can't be hidden.
-- In combat the game hides aura data from addons, so the state from before the
-- fight is kept; a cast we see ourselves (UNIT_SPELLCAST_SUCCEEDED) still hides it.
local function UpdateSacrificeShown()
    if InCombatLockdown() then return end
    local buffed, inst = HasSacrificeBuff()
    sacAura = inst
    sac:SetAlpha(buffed and 0 or 1)
    if not InCombatLockdown() then sac:EnableMouse(not buffed) end
end

-- Where the sacrifice button sits around the main button: { its point, main's point, x, y }.
local SAC_LIST = { "auto", "top", "bottom", "left", "right", "topleft", "topright", "bottomleft", "bottomright" }
local SAC_POS = {
    top = { "BOTTOM", "TOP", 0, 6 }, bottom = { "TOP", "BOTTOM", 0, -6 },
    left = { "RIGHT", "LEFT", -6, 0 }, right = { "LEFT", "RIGHT", 6, 0 },
    topleft = { "BOTTOMRIGHT", "TOPLEFT", 4, -4 }, topright = { "BOTTOMLEFT", "TOPRIGHT", -4, -4 },
    bottomleft = { "TOPRIGHT", "BOTTOMLEFT", 4, 4 }, bottomright = { "TOPLEFT", "BOTTOMRIGHT", -4, 4 },
}
local AUTO_OPPOSITE = { up = "bottom", down = "top", left = "right", right = "left" }

local function UpdateSacrifice()
    if InCombatLockdown() then return end
    local spell = db.sacrifice ~= false and Find(DEMONIC_SACRIFICE)
    if not spell then
        sac:Hide()
        return
    end
    sac:SetAttribute("type", "spell")
    sac:SetAttribute("spell", spell.name)
    sac.spellID, sac.label = spell.id, spell.name
    sac.icon:SetTexture(SpellIcon(spell.id, spell.name))
    -- "auto" = the side opposite to where the flyouts open.
    local at = SAC_POS[db.sacPos] or SAC_POS[AUTO_OPPOSITE[db.dir] or "bottom"]
    sac:ClearAllPoints()
    sac:SetPoint(at[1], main, at[2], at[3], at[4])
    sac:Show()
    UpdateSacrificeShown()
end

-- Demon Skin / Demon Armor: a second small button while you know the spell and
-- carry none of its ranks (or Fel Armor). Click to cast your best rank.
local DEMON_ARMOR = { prefix = "^demon [sa]", name = "Demon Armor",
    ids = { 11735, 11734, 11733, 1086, 706, 696, 687 } }
local ARMOR_BUFFS = { [687] = true, [696] = true, [706] = true, [1086] = true, [11733] = true,
    [11734] = true, [11735] = true, [27260] = true, [28176] = true, [28189] = true }
local AUTO_ARMOR = { up = "left", down = "left", left = "top", right = "top" }

local armor = CreateFrame("Button", "WarlockFlyoutArmor", main, "SecureActionButtonTemplate")
armor:SetSize(SLOT + 4, SLOT + 4)
armor:RegisterForClicks("AnyUp", "AnyDown")
armor:SetAttribute("useOnKeyDown", false)
HexFace(armor, "hex_border")
armor.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
armor:SetScript("OnEnter", ButtonTooltip)
armor:SetScript("OnLeave", GameTooltip_Hide)
armor.hint = "Click: cast your armor"
armor:Hide()

-- A pulsing glow around the button, so a missing armor is easy to spot.
armor.pulse = armor:CreateTexture(nil, "OVERLAY", nil, 6)
armor.pulse:SetPoint("CENTER")
armor.pulse:SetSize((SLOT + 4) * 1.35, (SLOT + 4) * 1.35)
armor.pulse:SetTexture(MEDIA .. "hex_glow")
armor.pulse:SetBlendMode("ADD")
armor.pulse:SetVertexColor(1.0, 0.85, 0.35)
armor.pulse.anim = armor.pulse:CreateAnimationGroup()
armor.pulse.anim:SetLooping("BOUNCE")
do
    local a = armor.pulse.anim:CreateAnimation("Alpha")
    a:SetFromAlpha(0.45)
    a:SetToAlpha(0.08)
    a:SetDuration(0.9)
end

local function UpdateArmorShown()
    if InCombatLockdown() then return end
    local buffed, inst = HasAura(ARMOR_BUFFS)
    armorAura = inst
    armor:SetAlpha(buffed and 0 or 1)
    if db.armorGlow ~= false then
        armor.pulse:Show()
        if not armor.pulse.anim:IsPlaying() then armor.pulse.anim:Play() end
    else
        armor.pulse.anim:Stop()
        armor.pulse:Hide()
    end
    if not InCombatLockdown() then armor:EnableMouse(not buffed) end
end

local function UpdateArmor()
    if InCombatLockdown() then return end
    local spell = db.armor ~= false and FindBestRank(DEMON_ARMOR)
    if not spell then
        armor:Hide()
        return
    end
    armor:SetAttribute("type", "spell")
    armor:SetAttribute("spell", spell.name)
    armor.spellID, armor.label = spell.id, spell.name
    armor.icon:SetTexture(SpellIcon(spell.id, spell.name))
    local at = SAC_POS[db.armorPos] or SAC_POS[AUTO_ARMOR[db.dir] or "left"]
    armor:ClearAllPoints()
    armor:SetPoint(at[1], main, at[2], at[3], at[4])
    armor:Show()
    UpdateArmorShown()
end

-- Border color and button picture, from the settings.
local function ApplyLook()
    TintFace(main)
    TintFace(main.badge)
    TintFace(sac)
    TintFace(armor)
    UpdateSacrifice()
    UpdateArmor()
    for _, f in ipairs({ demons, utils }) do
        for _, b in ipairs(f.buttons) do TintFace(b) end
    end
    main.icon:SetTexture(PictureTexture(db.picture))
    if db.picture == "pentagram" then
        main.icon:SetTexCoord(0, 1, 0, 1)
    else
        main.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)   -- cut off the game icon's own edge
    end
    local c = CORNERS[db.corner] or CORNERS.bottomright
    main.badge:ClearAllPoints()
    main.badge:SetPoint("CENTER", main, c[1], c[2], c[3])
    UpdateWarning()
end

local config

-- Switch the look live: rewrite the shared color tables, recolor everything
-- registered with Themed, then redo the hex tints.
local function ApplyTheme()
    local t = THEMES[db.theme] or THEMES.warlock
    local function copy(dst, src) for i = 1, 3 do dst[i] = src[i] end end
    copy(ACCENT, t.accent) copy(EDGE, t.edge) copy(FILL, t.fill) copy(GLOW, t.glow)
    copy(UI_FILL, t.uiFill) copy(UI_EDGE, t.uiEdge) copy(BORDER_COLORS.purple, t.ring)
    for _, e in ipairs(themed) do
        local c = ROLE_TABLE[e[2]]
        if e[1].SetColorTexture then e[1]:SetColorTexture(c[1], c[2], c[3], e[3])
        else e[1]:SetTextColor(c[1], c[2], c[3]) end
    end
    local shape = t.shape or "hex"
    main.warn:SetTexture(MEDIA .. shape .. "_glow")
    main.shardGlow:SetTexture(MEDIA .. shape .. "_glow")
    if armor and armor.pulse then armor.pulse:SetTexture(MEDIA .. shape .. "_glow") end
    main.shardGlow:SetVertexColor(GLOW[1], GLOW[2], GLOW[3])
    ApplyLook()
    if config and config.widgets then
        for _, x in ipairs(config.widgets) do if x.Refresh then x.Refresh() end end
    end
end

-- Step through a list: dir 1 = next, -1 = previous. Entries `usable` rejects are skipped.
local function Cycle(list, current, dir, usable)
    local n, at = #list, 0
    for i, v in ipairs(list) do
        if v == current then at = i end
    end
    for _ = 1, n do
        at = (at - 1 + dir) % n + 1
        if not usable or usable(list[at]) then return list[at] end
    end
    return list[1]
end

local function Layout(f, n)
    local dir = db.dir
    local len = math.max(n, 1) * SLOT + (math.max(n, 1) - 1) * GAP + GAP * 2
    if n == 0 then len = 140 end
    local thick = SLOT + GAP * 2
    if dir == "up" or dir == "down" then f:SetSize(thick, len) else f:SetSize(len, thick) end
    f:ClearAllPoints()
    if dir == "up" then f:SetPoint("BOTTOM", main, "TOP", 0, 8)
    elseif dir == "down" then f:SetPoint("TOP", main, "BOTTOM", 0, -8)
    elseif dir == "left" then f:SetPoint("RIGHT", main, "LEFT", -6, 0)
    else f:SetPoint("LEFT", main, "RIGHT", 6, 0) end
    for i = 1, n do
        local b = f.buttons[i]
        local off = GAP + (i - 1) * (SLOT + GAP)
        b:ClearAllPoints()
        if dir == "up" then b:SetPoint("BOTTOM", f, "BOTTOM", 0, off)
        elseif dir == "down" then b:SetPoint("TOP", f, "TOP", 0, -off)
        elseif dir == "left" then b:SetPoint("RIGHT", f, "RIGHT", -off, 0)
        else b:SetPoint("LEFT", f, "LEFT", off, 0) end
        b:Show()
    end
    for i = n + 1, #f.buttons do ClearButton(f.buttons[i]) end
    f.empty:SetShown(n == 0)
    for _, t in ipairs(f.panel) do t:SetShown(n == 0) end
end

local VALID_DIR = { up = true, down = true, left = true, right = true }

local pending = false

local function SpellButton(f, i, spell, hint)
    local b = FlyoutButton(f, i)
    ClearButton(b)
    b:SetAttribute("type", "spell")
    b:SetAttribute("spell", spell.name)
    b.spellID, b.label, b.hint = spell.id, spell.name, hint
    b.icon:SetTexture(SpellIcon(spell.id, spell.name))
    return b
end

local function IsDemonName(lower)
    if not lower:find("^summon ") then return false end
    for _, p in ipairs(NOT_DEMONS) do
        if lower:find(p) then return false end
    end
    return true
end

local function Rebuild()
    if InCombatLockdown() then pending = true return end
    pending = false
    ScanBook()
    Addon.canMakeHealthstone = false

    local n, used = 0, {}
    local felDom = Find(FEL_DOMINATION)
    local function addDemon(spell, def)
        def = def or {}
        if used[spell.name:lower()] then return end
        used[spell.name:lower()] = true
        n = n + 1
        local b = SpellButton(demons, n, spell, def.hint or "Click: summon")
        b.free, b.reagent = def.free, def.reagent
        if felDom and not def.noFelDom then
            b:SetAttribute("shift-type1", "macro")
            b:SetAttribute("shift-macrotext1", "/cast " .. felDom.name .. "\n/cast " .. spell.name)
            b.hint = b.hint .. "\nShift-click: " .. felDom.name .. " first"
        end
    end
    for _, def in ipairs(DEMONS) do
        local s = Find(def)
        if s then addDemon(s, def) end
    end
    for _, e in ipairs(bookList) do
        if IsDemonName(e.name:lower()) then addDemon(e) end
    end
    Layout(demons, n)

    n = 0
    local s = Find(RITUAL_OF_SUMMONING)
    if s then n = n + 1 SpellButton(utils, n, s, "Click: summon your target (needs two helpers)") end
    for _, def in ipairs(CREATE_STONES) do
        s = FindBestRank(def)
        if s then n = n + 1 SpellButton(utils, n, s, def.hint) end
        if s and def == CREATE_STONES[1] then Addon.canMakeHealthstone = true end
    end
    Layout(utils, n)
    UpdateSacrifice()
    UpdateArmor()
end

-- Soul bags: shards in them and their slots in total. 0, 0 when you carry none.
local SOUL_BAG_FAMILY = 4
-- Warlock soul bags on Forever (Wowhead's list), for when the client doesn't
-- report the bag family: Soul Pouch, Small Soul Pouch, Felcloth Bag,
-- Felblood Soul Bag, Box of Souls, Core Felcloth Bag.
local SOUL_BAG_IDS = { [21340] = true, [22243] = true, [21341] = true, [279271] = true, [22244] = true, [21342] = true }

local function BagItemID(bag)
    local toInv = (C_Container and C_Container.ContainerIDToInventoryID) or ContainerIDToInventoryID
    if not toInv or not GetInventoryItemID then return nil end
    local okI, inv = pcall(toInv, bag)
    if not okI or not inv then return nil end
    local okD, id = pcall(GetInventoryItemID, "player", inv)
    return okD and tonumber(Readable(id)) or nil
end

local function SoulBag()
    local C = C_Container
    local numSlots = (C and C.GetContainerNumSlots) or GetContainerNumSlots
    local numFree = (C and C.GetContainerNumFreeSlots) or GetContainerNumFreeSlots
    if not numSlots or not numFree then return 0, 0 end
    local used, total = 0, 0
    -- Bags 1-4 plus the extra equipped bag slot: on Forever the soul bag is bag 5
    -- (checked in game: 16 slots, family 4). Bank bags come after it, so stop at 5.
    local last = (NUM_BAG_SLOTS or 4) + 1
    for bag = 1, last do
        local okF, free, family = pcall(numFree, bag)
        free, family = okF and tonumber(Readable(free)), okF and tonumber(Readable(family))
        local isSoul = family and bit and bit.band and bit.band(family, SOUL_BAG_FAMILY) ~= 0
        if not isSoul then isSoul = SOUL_BAG_IDS[BagItemID(bag) or 0] end
        if isSoul then
            local okS, slots = pcall(numSlots, bag)
            slots = okS and tonumber(Readable(slots)) or 0
            if slots > 0 then
                total = total + slots
                -- Count the shards themselves; fall back to used slots if items can't be read.
                local itemAt = C and C.GetContainerItemID
                if itemAt then
                    for slot = 1, slots do
                        local okA, id = pcall(itemAt, bag, slot)
                        if okA and tonumber(Readable(id)) == SOUL_SHARD then used = used + 1 end
                    end
                else
                    used = used + (slots - (free or slots))
                end
            end
        end
    end
    return used, total
end

-- How bright the Soul Shard on the badge is, from 0 (black) to 1 (full color).
-- Fewer shards = a darker shard, like a shadow creeping in. `showCount` is true
-- when the white number is drawn on top (it needs a darker shard to stay readable).
local SHARDS_FULL = 20   -- at this many shards (or more) the shard is at full brightness
local function ShardShade(shards, showCount)
    local darkest = 0.2                          -- 0 shards: deep shadow, but still visible
    local brightest = showCount and 0.6 or 1.0   -- keep it dimmer under the white number
    local fill = math.min(shards, SHARDS_FULL) / SHARDS_FULL
    return darkest + (brightest - darkest) * fill
end

local function Refresh()
    local shards = ItemCount(SOUL_SHARD)
    local showCount = db.showCount ~= false
    main.count:SetText(shards)
    main.count:SetShown(showCount)
    -- With the number hidden, keep the badge at 0 shards too: a fully dark shard says "empty".
    main.badge:SetShown(shards > 0 or not showCount or (db.warnShards == true and shards < 2))
    UpdateShardGlow(shards)
    local shade = math.max(0, math.min(1, tonumber(ShardShade(shards, showCount)) or 0.6))
    main.badge.icon:SetVertexColor(shade, shade, shade)
    UpdateWarning()
    UpdateSacrificeShown()
    UpdateArmorShown()
    for _, f in ipairs({ demons, utils }) do
        for _, b in ipairs(f.buttons) do
            if b:IsShown() then
                local start, dur = SpellCooldown(b.spellID)
                if start and dur and dur > 1.5 then
                    b.cooldown:SetCooldown(start, dur)
                else
                    b.cooldown:Clear()
                end
                if b.reagent then
                    b.icon:SetDesaturated(ItemCount(b.reagent) == 0)
                else
                    b.icon:SetDesaturated(not b.free and shards == 0)
                end
            end
        end
    end
end

local function SavePosition()
    local p, _, rp, x, y = main:GetPoint()
    db.point = { p, rp, math.floor(x + 0.5), math.floor(y + 0.5) }
end

local function ApplyLayout()
    if InCombatLockdown() then pending = true return end
    main:SetScale(db.scale or 1)
    main:ClearAllPoints()
    local pt = db.point
    if type(pt) == "table" and pt[1] then main:SetPoint(pt[1], UIParent, pt[2], pt[3], pt[4])
    else main:SetPoint("CENTER", UIParent, "CENTER", 0, -180) end
    main:SetShown(db.shown ~= false)
    Rebuild()
end

main:SetScript("OnDragStart", function(self)
    if db.locked or InCombatLockdown() or not IsShiftKeyDown() then return end
    self:StartMoving()
end)
main:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

main:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Warlock Flyout", ACCENT[1], ACCENT[2], ACCENT[3])
    GameTooltip:AddLine("Left-click: your demons", 1, 1, 1)
    GameTooltip:AddLine("Right-click: summoning and stones", 1, 1, 1)
    if not db.locked then GameTooltip:AddLine("Shift-drag: move", 0.6, 0.6, 0.6) end
    GameTooltip:AddLine(("Soul shards: %d"):format(ItemCount(SOUL_SHARD)), 0.8, 0.6, 1)
    local used, total = SoulBag()
    if total > 0 then GameTooltip:AddLine(L.soulBag:format(used, total), 0.8, 0.6, 1) end
    if main.missingHealthstone then GameTooltip:AddLine(L.noHealthstone, 0.3, 1, 0.3) end
    GameTooltip:AddLine("/wf config: settings", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
main:SetScript("OnLeave", GameTooltip_Hide)

local DIRS = { "up", "right", "down", "left" }
local function NextDir()
    for i, d in ipairs(DIRS) do
        if d == db.dir then return DIRS[i % #DIRS + 1] end
    end
    return "up"
end


local function Check(parent, label, anchor, y, get, set)
    local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    c:SetSize(24, 24)
    c:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, y)
    c.label = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    c.label:SetPoint("LEFT", c, "RIGHT", 4, 0)
    c.label:SetText(label)
    c:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
    c.Refresh = function() c:SetChecked(get()) end
    return c
end

-- Two columns: the options on the left, the border colors on the right.
local CFG_PAD, CFG_INNER, CFG_GAP = 16, 288, 24
local CFG_W = 2 * CFG_INNER + 2 * CFG_PAD + CFG_GAP

local function PanelButton(parent, text, w)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w or CFG_INNER, 22)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.12, 0.12, 0.13, 1)
    for _, e in ipairs({ { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" },
                         { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true } }) do
        local t = b:CreateTexture(nil, "BORDER")
        t:SetPoint(e[1]); t:SetPoint(e[2])
        if e[3] then t:SetWidth(1) else t:SetHeight(1) end
        Themed(t, "uiEdge")
    end
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    Themed(hl, "accent", 0.15)
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    b.label:SetPoint("LEFT", 6, 0)
    b.label:SetPoint("RIGHT", -6, 0)
    b.label:SetWordWrap(false)
    b.label:SetText(text)
    b.SetText = function(self, t) self.label:SetText(t) end
    return b
end

local function BuildConfig()
    local f = CreateFrame("Frame", "WarlockFlyoutConfig", UIParent)
    f:SetSize(CFG_W, 300)
    f:SetPoint("CENTER", 0, 80)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    Panel(f, 0.95, "uiFill", "uiEdge")

    local close = CreateFrame("Button", nil, f)
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -8, -8)
    local x = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    x:SetPoint("CENTER")
    x:SetText("\195\151")
    Themed(x, "accent")
    close:SetScript("OnEnter", function() x:SetTextColor(1, 1, 1) end)
    close:SetScript("OnLeave", function() x:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3]) end)
    close:SetScript("OnClick", function() f:Hide() end)

    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetSize(40, 40)
    logo:SetPoint("TOPLEFT", CFG_PAD, -CFG_PAD)
    logo:SetTexture(MEDIA .. "logo")
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, -2)
    title:SetPoint("RIGHT", f, "RIGHT", -CFG_PAD - 20, 0)
    title:SetJustifyH("LEFT")
    title:SetText("Warlock Flyout")
    Themed(title, "accent")
    local sub = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    sub:SetPoint("RIGHT", f, "RIGHT", -CFG_PAD, 0)
    sub:SetJustifyH("LEFT")
    sub:SetWordWrap(true)
    sub:SetText("Left-click: demons. Right-click: summoning and stones.")

    local rule = f:CreateTexture(nil, "BORDER")
    rule:SetHeight(1)
    Themed(rule, "uiEdge", 0.8)
    rule:SetPoint("LEFT", f, "LEFT", CFG_PAD, 0)
    rule:SetPoint("RIGHT", f, "RIGHT", -CFG_PAD, 0)
    rule:SetPoint("TOP", logo, "BOTTOM", 0, -10)

    local w = {}
    w[1] = Check(f, "Lock the button", rule, -10,
        function() return db.locked end, function(v) db.locked = v end)
    w[1]:ClearAllPoints()
    w[1]:SetPoint("TOPLEFT", rule, "BOTTOMLEFT", -2, -10)
    w[2] = Check(f, "Show the button", w[1], -2,
        function() return db.shown ~= false end,
        function(v) db.shown = v ApplyLayout() end)

    local theme = PanelButton(f, "")
    theme:SetPoint("TOPLEFT", w[2], "BOTTOMLEFT", 2, -12)
    theme:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    theme.Refresh = function() theme:SetText(L.theme:format(L["theme" .. db.theme:sub(1, 1):upper() .. db.theme:sub(2)])) end
    theme:SetScript("OnClick", function()
        db.theme = Cycle(THEME_LIST, db.theme, 1)
        ApplyTheme()
        theme.Refresh()
    end)
    w[#w + 1] = theme

    local dir = PanelButton(f, "")
    dir:SetPoint("TOPLEFT", theme, "BOTTOMLEFT", 0, -6)
    dir.Refresh = function() dir:SetText("Flyouts open: " .. db.dir) end
    dir:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        db.dir = NextDir()
        dir.Refresh()
        Rebuild()
    end)
    w[#w + 1] = dir

    -- Button picture and shard badge: click for the next, right-click for the previous.
    local function CycleButton(anchor, label, list, key, nameOf, usable)
        local b = PanelButton(f, "")
        b:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        b.Refresh = function() b:SetText(label:format(nameOf(db[key]))) end
        b:SetScript("OnClick", function(_, button)
            db[key] = Cycle(list, db[key], button == "RightButton" and -1 or 1, usable)
            ApplyLook()
            b.Refresh()
        end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(L.cycleHint, 1, 1, 1)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", GameTooltip_Hide)
        return b
    end
    local picture = CycleButton(dir, L.picture, PICTURE_LIST, "picture", PictureName, PictureAvailable)
    local corner = CycleButton(picture, L.corner, CORNER_LIST, "corner", function(k) return L[k] or k end)
    local countBox = Check(f, L.showCount, corner, -4,
        function() return db.showCount ~= false end,
        function(v) db.showCount = v Refresh() end)
    countBox:ClearAllPoints()
    countBox:SetPoint("TOPLEFT", corner, "BOTTOMLEFT", -2, -4)
    w[#w + 1] = picture
    w[#w + 1] = corner
    local warnBox = Check(f, L.warnHealthstone, countBox, -2,
        function() return db.warnHealthstone == true end,
        function(v) db.warnHealthstone = v Refresh() end)
    local shardBox = Check(f, L.warnShards, warnBox, -2,
        function() return db.warnShards == true end,
        function(v) db.warnShards = v Refresh() end)
    w[#w + 1] = countBox
    w[#w + 1] = warnBox
    local sacBox = Check(f, L.sacrifice, shardBox, -2,
        function() return db.sacrifice ~= false end,
        function(v) db.sacrifice = v UpdateSacrifice() end)
    local sacPos = CycleButton(sacBox, L.sacPos, SAC_LIST, "sacPos", function(k) return L[k] or k end)
    sacPos:ClearAllPoints()
    sacPos:SetPoint("TOPLEFT", sacBox, "BOTTOMLEFT", 2, -4)
    local armorBox = Check(f, L.armor, sacPos, -4,
        function() return db.armor ~= false end,
        function(v) db.armor = v UpdateArmor() end)
    armorBox:ClearAllPoints()
    armorBox:SetPoint("TOPLEFT", sacPos, "BOTTOMLEFT", -2, -4)
    local armorPos = CycleButton(armorBox, L.armorPos, SAC_LIST, "armorPos", function(k) return L[k] or k end)
    armorPos:ClearAllPoints()
    armorPos:SetPoint("TOPLEFT", armorBox, "BOTTOMLEFT", 2, -4)
    local glowBox = Check(f, L.armorGlow, armorPos, -4,
        function() return db.armorGlow ~= false end,
        function(v) db.armorGlow = v UpdateArmor() end)
    glowBox:ClearAllPoints()
    glowBox:SetPoint("TOPLEFT", armorPos, "BOTTOMLEFT", -2, -4)
    w[#w + 1] = glowBox
    w[#w + 1] = shardBox
    w[#w + 1] = sacBox
    w[#w + 1] = sacPos
    w[#w + 1] = armorBox
    w[#w + 1] = armorPos

    local scaleText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleText:SetPoint("TOPLEFT", glowBox, "BOTTOMLEFT", 2, -12)
    local plus = PanelButton(f, "+", 26)
    local minus = PanelButton(f, "-", 26)
    plus:SetPoint("RIGHT", theme, "RIGHT", 0, 0)
    plus:SetPoint("TOP", glowBox, "BOTTOM", 0, -6)
    minus:SetPoint("RIGHT", plus, "LEFT", -4, 0)
    plus.label:SetJustifyH("CENTER")
    minus.label:SetJustifyH("CENTER")
    local function SetScale(d)
        if InCombatLockdown() then return end
        db.scale = math.min(2, math.max(0.5, math.floor(((db.scale or 1) + d) * 10 + 0.5) / 10))
        ApplyLayout()
        scaleText:SetText(("Size: %.1fx"):format(db.scale))
    end
    minus:SetScript("OnClick", function() SetScale(-0.1) end)
    plus:SetScript("OnClick", function() SetScale(0.1) end)
    local sizeRow = { Refresh = function() scaleText:SetText(("Size: %.1fx"):format(db.scale or 1)) end }
    w[#w + 1] = sizeRow

    -- Border color: its own section, one row of swatches per family. Click one to
    -- use it, hover for its name; the white ring marks the current color.
    local sec = CreateFrame("Frame", nil, f)
    sec:SetPoint("TOPLEFT", theme, "TOPRIGHT", CFG_GAP, 0)
    sec:SetWidth(CFG_INNER)
    local secRule = sec:CreateTexture(nil, "BORDER")
    secRule:SetHeight(1)
    Themed(secRule, "uiEdge", 0.8)
    secRule:SetPoint("TOPLEFT")
    secRule:SetPoint("TOPRIGHT")
    -- Gold like the section headings in the other addons' windows.
    local head = sec:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    head:SetPoint("TOPLEFT", 0, -10)
    local SW_W, SW_H, SW_GAP, ROW_H = 30, 14, 4, 19
    local LABEL_W = CFG_INNER - 6 * (SW_W + SW_GAP) + SW_GAP
    local swatches = {}
    local function RefreshColors()
        head:SetText(L.border:format(BorderName(BorderKey())))
        for _, sw in ipairs(swatches) do
            local c = ColorOf(sw.key)
            sw.fill:SetColorTexture(c[1], c[2], c[3], 1)
            sw.ring:SetShown(sw.key == BorderKey())
        end
    end
    local y = -32
    for _, row in ipairs(BORDER_ROWS) do
        local fl = sec:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fl:SetPoint("TOPLEFT", 0, y - 1)
        fl:SetWidth(LABEL_W - 4)
        fl:SetJustifyH("LEFT")
        fl:SetWordWrap(false)
        fl:SetText(FamilyName(row.fam))
        for i, key in ipairs(row.list) do
            local s = CreateFrame("Button", nil, sec)
            s:SetSize(SW_W, SW_H)
            s:SetPoint("TOPLEFT", LABEL_W + (i - 1) * (SW_W + SW_GAP), y)
            local ring = s:CreateTexture(nil, "BACKGROUND")
            ring:SetPoint("TOPLEFT", -2, 2)
            ring:SetPoint("BOTTOMRIGHT", 2, -2)
            ring:SetColorTexture(1, 1, 1, 1)
            local edge = s:CreateTexture(nil, "BORDER")
            edge:SetAllPoints()
            edge:SetColorTexture(0, 0, 0, 1)
            local fill = s:CreateTexture(nil, "ARTWORK")
            fill:SetPoint("TOPLEFT", 1, -1)
            fill:SetPoint("BOTTOMRIGHT", -1, 1)
            s:SetScript("OnClick", function()
                SetBorderKey(key)
                ApplyLook()
                RefreshColors()
            end)
            s:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(BorderName(key))
                GameTooltip:Show()
            end)
            s:SetScript("OnLeave", GameTooltip_Hide)
            swatches[#swatches + 1] = { key = key, ring = ring, fill = fill }
        end
        y = y - ROW_H
    end
    sec:SetHeight(-y)
    sec.Refresh = RefreshColors
    w[#w + 1] = sec

    local reset = PanelButton(f, "Reset position and size")
    reset:SetPoint("TOPLEFT", sec, "BOTTOMLEFT", 0, -10)
    reset:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        db.point, db.scale = nil, 1
        ApplyLayout()
        sizeRow.Refresh()
    end)

    local note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", reset, "BOTTOMLEFT", 0, -14)
    note:SetWidth(CFG_INNER)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText("Shift-drag the button to move it. If this client forgets your settings, /wf where prints a line to paste into Settings.lua.")

    local function FitHeight()
        local top, bottom = f:GetTop(), note:GetBottom()
        local left = scaleText:GetBottom()
        if bottom and left and left < bottom then bottom = left end
        if top and bottom then f:SetHeight(math.ceil(top - bottom + CFG_PAD)) end
    end

    f.widgets = w
    f:SetScript("OnShow", function()
        for _, x in ipairs(w) do if x.Refresh then x.Refresh() end end
        FitHeight()
        if C_Timer and C_Timer.After then C_Timer.After(0, FitHeight) end
    end)
    if UISpecialFrames then table.insert(UISpecialFrames, f:GetName()) end
    f:Hide()
    return f
end

function Addon.ToggleConfig()
    config = config or BuildConfig()
    config:SetShown(not config:IsShown())
end

-- An entry under Esc > Options > AddOns that opens the settings window.
local function RegisterSettings()
    if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
    local c = CreateFrame("Frame")
    local t = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    t:SetPoint("TOPLEFT", 16, -16)
    t:SetText(L.title)
    local s = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    s:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -8)
    s:SetText(L.openNote)
    local b = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    b:SetSize(200, 24)
    b:SetPoint("TOPLEFT", s, "BOTTOMLEFT", 0, -12)
    b:SetText(L.openBtn)
    b:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel:IsShown() and HideUIPanel then HideUIPanel(SettingsPanel) end
        config = config or BuildConfig()
        config:Show()
    end)
    pcall(function() Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(c, L.title)) end)
end

local function SetLocked(v)
    if v == nil then v = not db.locked end
    db.locked = v and true or false
    Print(db.locked and "Button locked." or "Button unlocked: shift-drag it to move it.")
    if config and config:IsShown() then
        for _, x in ipairs(config.widgets) do if x.Refresh then x.Refresh() end end
    end
end

SLASH_WARLOCKFLYOUT1, SLASH_WARLOCKFLYOUT2 = "/wf", "/warlockflyout"
SlashCmdList.WARLOCKFLYOUT = function(msg)
    local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    local quiet = { [""] = true, help = true, where = true, spells = true, config = true, options = true,
        lock = true, unlock = true }
    if InCombatLockdown() and not quiet[cmd] then
        Print("That can only change out of combat.")
        return
    end
    if cmd == "lock" then
        SetLocked(true)
    elseif cmd == "unlock" then
        SetLocked(false)
    elseif cmd == "togglelock" then
        SetLocked(nil)
    elseif cmd == "reset" then
        db.point, db.scale = nil, 1
        ApplyLayout()
        Print("Position and size reset.")
    elseif cmd == "scale" and tonumber(arg) then
        db.scale = math.min(2, math.max(0.5, tonumber(arg)))
        ApplyLayout()
    elseif cmd == "theme" and (THEMES[arg] or arg == "modern") then
        db.theme = arg == "modern" and "warlock" or arg
        ApplyTheme()
    elseif cmd == "dir" and VALID_DIR[arg] then
        db.dir = arg
        Rebuild()
    elseif cmd == "show" or cmd == "hide" then
        db.shown = cmd == "show"
        ApplyLayout()
    elseif cmd == "config" or cmd == "options" then
        Addon.ToggleConfig()
    elseif cmd == "where" then
        local p = db.point
        Print("Paste this into Settings.lua (in the addon folder) to keep these settings:")
        local pic = type(db.picture) == "number" and tostring(db.picture) or ("%q"):format(db.picture or "pentagram")
        Print(("theme = %q, point = { %q, %q, %d, %d }, scale = %.1f, dir = %q, locked = %s, border = %q, picture = %s, corner = %q, showCount = %s, warnHealthstone = %s, warnShards = %s,"):format(
            db.theme or "warlock", p and p[1] or "CENTER", p and p[2] or "CENTER", p and p[3] or 0, p and p[4] or -180,
            db.scale or 1, db.dir, tostring(db.locked), db.border or "black", pic,
            db.corner or "bottomright", tostring(db.showCount ~= false), tostring(db.warnHealthstone == true), tostring(db.warnShards == true)))
    elseif cmd == "spells" then

        if not InCombatLockdown() then Rebuild() end
        for _, f in ipairs({ demons, utils }) do
            local names = {}
            for _, b in ipairs(f.buttons) do
                if b:IsShown() then names[#names + 1] = (b.label or "?") .. (b.spellID and (" (" .. b.spellID .. ")") or "") end
            end
            Print((f == demons and "Demons: " or "Utility: ") .. (#names > 0 and table.concat(names, ", ") or "none"))
        end
        Print(("Spellbook entries read: %d"):format(#bookList))
        local sp = Find(DEMONIC_SACRIFICE)
        local ar = FindBestRank(DEMON_ARMOR)
        Print(("Demon Armor: %s, buff: %s"):format(ar and (ar.name .. " (" .. tostring(ar.id) .. ")") or "not found", tostring(HasAura(ARMOR_BUFFS))))
        Print(("Demonic Pact known: %s"):format(tostring(KnownID(425464))))
        Print(("Demonic Sacrifice: %s, pet: %s, buff: %s"):format(sp and (sp.name .. " (" .. tostring(sp.id) .. ")") or "not found",
            tostring(UnitExists("pet") and true or false), tostring(HasSacrificeBuff())))
    else
        Print("/wf config - the settings window")
        Print("/wf lock, /wf unlock - stop or allow moving the button" ..
            (Addon.bareLock and " (also just /lock and /unlock)" or ""))
        Print("/wf dir up||down||left||right - where the flyouts open")
        Print("/wf theme modern||forever - the look")
        Print("/wf scale 0.5-2 - button size")
        Print("/wf show | hide - show or hide the button")
        Print("/wf reset - back to the middle of the screen")
        Print("/wf where - a line to save your settings in Settings.lua")
        Print("/wf spells - what the flyouts found in your spellbook")
    end
end

local events = CreateFrame("Frame")

for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB",
                     "BAG_UPDATE_DELAYED", "SPELL_UPDATE_COOLDOWN", "PLAYER_REGEN_ENABLED", "UNIT_AURA", "UNIT_SPELLCAST_SUCCEEDED" }) do
    pcall(events.RegisterEvent, events, e)
end

local ready, loaded = false, false

local function SlashTaken(cmd)
    for k, v in pairs(_G) do
        if type(k) == "string" and k:find("^SLASH_") and type(v) == "string"
            and v:lower() == cmd and not k:find("^SLASH_WARLOCKFLYOUT") then
            return k
        end
    end
end

function Addon.RegisterBareLock()
    if Addon.bareLock ~= nil then return end
    if SlashTaken("/lock") or SlashTaken("/unlock") then
        Addon.bareLock = false
        return
    end
    SLASH_WARLOCKFLYOUTLOCK1 = "/lock"
    SLASH_WARLOCKFLYOUTUNLOCK1 = "/unlock"
    SlashCmdList.WARLOCKFLYOUTLOCK = function() SetLocked(true) end
    SlashCmdList.WARLOCKFLYOUTUNLOCK = function() SetLocked(false) end
    Addon.bareLock = true
end

local function LoadSettings()
    if loaded then return end
    loaded = true
    if type(WarlockFlyoutDB) ~= "table" then WarlockFlyoutDB = {} end
    local saved = next(WarlockFlyoutDB) ~= nil
    db = WarlockFlyoutDB
    if not saved and type(WarlockFlyoutSettings) == "table" then
        for k, v in pairs(WarlockFlyoutSettings) do db[k] = v end
    end
    for k, v in pairs(DEFAULTS) do if db[k] == nil then db[k] = v end end
    if not THEMES[db.theme] then db.theme = "warlock" end
    if not VALID_DIR[db.dir] then db.dir = "up" end
    db.scale = tonumber(db.scale) or 1
    if not (BORDER_COLORS[db.border] or db.border == "class") then db.border = "black" end
    if not (BORDER_COLORS[db.borderForever] or db.borderForever == "class") then db.borderForever = "purple" end
    local known = false
    for _, p in ipairs(PICTURE_LIST) do if p == db.picture then known = true end end
    if not known or not PictureAvailable(db.picture) then db.picture = "pentagram" end
    if not CORNERS[db.corner] then db.corner = "bottomright" end
    db.showCount = db.showCount ~= false
    db.warnHealthstone = db.warnHealthstone == true
    db.warnShards = db.warnShards == true
    db.sacrifice = db.sacrifice ~= false
    db.armor = db.armor ~= false
    db.armorGlow = db.armorGlow ~= false
    if db.armorPos ~= "auto" and not SAC_POS[db.armorPos] then db.armorPos = "auto" end
    if db.sacPos ~= "auto" and not SAC_POS[db.sacPos] then db.sacPos = "auto" end
end

local function Init()
    if ready then return end
    LoadSettings()
    local warlock, class = IsWarlock()
    if class and not warlock then main:Hide() return end
    ready = true
    ApplyTheme()
    ApplyLayout()
end

local queued = false
local function QueueRebuild()
    if queued then return end
    queued = true
    local run = function()
        queued = false
        Rebuild()
        Refresh()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.2, run) else run() end
end

events:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            LoadSettings()
            RegisterSettings()
        end
        return
    elseif event == "PLAYER_LOGIN" then
        Init()
        Addon.RegisterBareLock()
        if ready then Rebuild() end
    elseif not ready then
        return
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local id = tonumber(Readable(arg3))
        if arg1 == "player" and id then
            if ARMOR_BUFFS[id] then armor:SetAlpha(0) end
            if id == 18788 then sac:SetAlpha(0) end
        end
        return
    elseif event == "UNIT_AURA" then
        if arg1 == "player" then
            -- In combat the update's contents can be secret: read only what we may.
            local info = Readable(arg2)
            if type(info) == "table" then
                local added, removed = Readable(info.addedAuras), Readable(info.removedAuraInstanceIDs)
                pcall(function()
                    for _, a in ipairs(type(added) == "table" and added or {}) do
                        local id = tonumber(Readable(a.spellId))
                        if id and ARMOR_BUFFS[id] then armorAura = Readable(a.auraInstanceID) end
                        if id and SAC_BUFFS[id] then sacAura = Readable(a.auraInstanceID) end
                    end
                    for _, inst in ipairs(type(removed) == "table" and removed or {}) do
                        inst = Readable(inst)
                        if inst and armorAura and inst == armorAura then armorAura = nil armor:SetAlpha(1) end
                        if inst and sacAura and inst == sacAura then sacAura = nil sac:SetAlpha(1) end
                    end
                end)
            end
            UpdateSacrificeShown() UpdateArmorShown()
        end
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pending then ApplyLayout() end
    elseif event == "SPELL_UPDATE_COOLDOWN" or event == "BAG_UPDATE_DELAYED" then

    else
        QueueRebuild()
        return
    end
    if ready then Refresh() end
end)

if IsLoggedIn and IsLoggedIn() then Init() if ready then Refresh() end end

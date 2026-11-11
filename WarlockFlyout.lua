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

local function Panel(f, alpha)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(FILL[1], FILL[2], FILL[3], alpha or 0.92)
    local edges = { bg }
    for _, e in ipairs({ { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" },
                         { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true } }) do
        local t = f:CreateTexture(nil, "BORDER")
        t:SetPoint(e[1]); t:SetPoint(e[2])
        if e[3] then t:SetWidth(1) else t:SetHeight(1) end
        t:SetColorTexture(EDGE[1], EDGE[2], EDGE[3], 1)
        edges[#edges + 1] = t
    end
    return edges
end

local DEFAULTS = { locked = false, scale = 1, dir = "up", shown = true }

local DEMONS = {
    { names = { "Summon Imp" }, id = 688, free = true },
    { names = { "Summon Voidwalker" }, id = 697 },
    { names = { "Summon Succubus" }, id = 712 },
    { names = { "Summon Incubus" }, id = 713 },
    { names = { "Summon Felhunter", "Summon Fel Hunter" }, id = 691 },
    { names = { "Summon Felguard" }, id = 30146 },
    { names = { "Summon Infernal", "Inferno" }, id = 1122 },
    { names = { "Summon Doomguard", "Ritual of Doom" }, id = 18540 },
}

local NOT_DEMONS = { "steed", "^summon demon$" }

local FEL_DOMINATION = { names = { "Fel Domination" }, id = 18708 }
local RITUAL_OF_SUMMONING = { names = { "Ritual of Summoning" }, id = 698 }
local RITUAL_OF_SOULS = { names = { "Ritual of Souls" }, id = 29893 }

local HS_TIER = {
    [5512] = 1, [19004] = 1, [19005] = 1,
    [5511] = 2, [19006] = 2, [19007] = 2,
    [5509] = 3, [19008] = 3, [19009] = 3,
    [5510] = 4, [19010] = 4, [19011] = 4,
    [9421] = 5, [19012] = 5, [19013] = 5,
    [22103] = 6, [22104] = 6, [22105] = 6,
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

local function ItemIcon(id)
    if C_Item and C_Item.GetItemIconByID then
        local ok, t = pcall(C_Item.GetItemIconByID, id)
        if ok and t then return t end
    end
    if GetItemIcon then
        local ok, t = pcall(GetItemIcon, id)
        if ok and t then return t end
    end
    return "Interface\\Icons\\INV_Stone_04"
end

local function ItemName(id)
    local n
    if C_Item and C_Item.GetItemNameByID then
        local ok, x = pcall(C_Item.GetItemNameByID, id); n = ok and x
    end
    if not n and C_Item and C_Item.GetItemInfo then
        local ok, x = pcall(C_Item.GetItemInfo, id); n = ok and x
    end
    if not n and GetItemInfo then
        local ok, x = pcall(GetItemInfo, id); n = ok and x
    end
    n = Readable(n)
    return type(n) == "string" and n or nil
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

local function FindCreateHealthstone()
    local best, bestTier
    for _, e in ipairs(bookList) do
        local lower = e.name:lower()
        if lower:find("^create healthstone") then
            local tier = TierOfName(lower)
            if not best or tier > bestTier or (tier == bestTier and (e.slot or 0) > (best.slot or 0)) then
                best, bestTier = e, tier
            end
        end
    end
    if best then return best end
    for _, id in ipairs({ 27230, 11730, 11729, 5699, 6202, 6201 }) do
        if #bookList == 0 and KnownID(id) then return { name = SpellName(id) or "Create Healthstone", id = id } end
    end
end

local function BagSlots(bag)
    local fn = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
    if not fn then return 0 end
    local ok, n = pcall(fn, bag)
    return ok and tonumber(Readable(n)) or 0
end

local function BagItem(bag, slot)
    local fn = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
    if not fn then return nil end
    local ok, id = pcall(fn, bag, slot)
    return ok and Readable(id) or nil
end

local function BestHealthstone()
    local bestID, bestTier
    local last = (NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4)
    for bag = 0, last do
        for slot = 1, BagSlots(bag) do
            local id = BagItem(bag, slot)
            if id then
                local tier = HS_TIER[id]
                if not tier then
                    local n = ItemName(id)
                    if n and n:lower():find("healthstone", 1, true) then tier = TierOfName(n:lower()) end
                end
                if tier and (not bestTier or tier > bestTier) then bestID, bestTier = id, tier end
            end
        end
    end
    return bestID
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
    end)
end

local function HexFace(b, frameArt, glowColor)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    HexMask(b, b.icon)
    b.frameArt = b:CreateTexture(nil, "OVERLAY")
    b.frameArt:SetAllPoints()
    b.frameArt:SetTexture(MEDIA .. frameArt)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture(MEDIA .. "hex_glow")
    hl:SetVertexColor(glowColor[1], glowColor[2], glowColor[3])
    hl:SetBlendMode("ADD")
    hl:SetAlpha(0.45)
end

HexFace(main, "hex_ring", GLOW)
main.icon:SetTexture(MEDIA .. "button")

main.badge = CreateFrame("Frame", nil, main)
main.badge:SetSize(20, 20)
main.badge:SetPoint("CENTER", main, "BOTTOMRIGHT", -5, 6)
main.badge:SetFrameLevel(main:GetFrameLevel() + 3)
local badgeTex = main.badge:CreateTexture(nil, "ARTWORK")
badgeTex:SetAllPoints()
badgeTex:SetTexture(MEDIA .. "badge")
main.count = main.badge:CreateFontString(nil, "OVERLAY")
main.count:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
main.count:SetPoint("CENTER", 0, 0)
main.count:SetTextColor(1, 1, 1)

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
    if b.item and GameTooltip.SetItemByID then
        drawn = pcall(GameTooltip.SetItemByID, GameTooltip, b.item)
    elseif b.spellID and GameTooltip.SetSpellByID then
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
    HexFace(b, "hex_border", GLOW)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.cooldown = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cooldown:SetAllPoints()

    pcall(b.cooldown.SetSwipeTexture, b.cooldown, MEDIA .. "hex_mask")
    pcall(b.cooldown.SetDrawEdge, b.cooldown, false)
    b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.count:SetPoint("BOTTOMRIGHT", 1, 0)

    local pushed = b:CreateTexture(nil, "OVERLAY")
    pushed:SetAllPoints()
    pushed:SetTexture(MEDIA .. "hex_mask")
    pushed:SetVertexColor(0, 0, 0, 0.45)
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
    for _, k in ipairs({ "type", "spell", "item", "shift-type1", "shift-macrotext1" }) do b:SetAttribute(k, nil) end
    b.spellID, b.item, b.label, b.hint, b.free = nil, nil, nil, nil, nil
    b.count:SetText("")
    b:Hide()
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

    local n, used = 0, {}
    local felDom = Find(FEL_DOMINATION)
    local function addDemon(spell, free)
        if used[spell.name:lower()] then return end
        used[spell.name:lower()] = true
        n = n + 1
        local b = SpellButton(demons, n, spell, "Click: summon")
        b.free = free
        if felDom then
            b:SetAttribute("shift-type1", "macro")
            b:SetAttribute("shift-macrotext1", "/cast " .. felDom.name .. "\n/cast " .. spell.name)
            b.hint = b.hint .. "\nShift-click: " .. felDom.name .. " first"
        end
    end
    for _, def in ipairs(DEMONS) do
        local s = Find(def)
        if s then addDemon(s, def.free) end
    end
    for _, e in ipairs(bookList) do
        if IsDemonName(e.name:lower()) then addDemon(e) end
    end
    Layout(demons, n)

    n = 0
    local s = Find(RITUAL_OF_SUMMONING)
    if s then n = n + 1 SpellButton(utils, n, s, "Click: summon your target (needs two helpers)") end
    s = Find(RITUAL_OF_SOULS)
    if s then n = n + 1 SpellButton(utils, n, s, "Click: a soulwell for your group") end
    s = FindCreateHealthstone()
    if s then n = n + 1 SpellButton(utils, n, s, "Click: make a healthstone") end
    local stone = BestHealthstone()
    if stone then
        n = n + 1
        local b = FlyoutButton(utils, n)
        ClearButton(b)
        b:SetAttribute("type", "item")
        b:SetAttribute("item", "item:" .. stone)
        b.item, b.label, b.hint = stone, ItemName(stone) or "Healthstone", "Click: use it"
        b.icon:SetTexture(ItemIcon(stone))
    end
    Layout(utils, n)
end

local function Refresh()
    local shards = ItemCount(SOUL_SHARD)
    main.count:SetText(shards)
    main.badge:SetShown(shards > 0)
    for _, f in ipairs({ demons, utils }) do
        for _, b in ipairs(f.buttons) do
            if b:IsShown() then
                if b.item then
                    local c = ItemCount(b.item)
                    b.count:SetText(c > 1 and c or "")
                    b.icon:SetDesaturated(c == 0)
                    b.cooldown:Clear()
                else
                    local start, dur = SpellCooldown(b.spellID)
                    if start and dur and dur > 1.5 then
                        b.cooldown:SetCooldown(start, dur)
                    else
                        b.cooldown:Clear()
                    end
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
    GameTooltip:AddLine("Right-click: summoning and healthstones", 1, 1, 1)
    if not db.locked then GameTooltip:AddLine("Shift-drag: move", 0.6, 0.6, 0.6) end
    GameTooltip:AddLine(("Soul shards: %d"):format(ItemCount(SOUL_SHARD)), 0.8, 0.6, 1)
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

local config

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

local CFG_W, CFG_PAD = 320, 16
local CFG_INNER = CFG_W - 2 * CFG_PAD

local function PanelButton(parent, text, w)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w or CFG_INNER, 22)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(EDGE[1] * 0.45, EDGE[2] * 0.45, EDGE[3] * 0.45, 1)
    for _, e in ipairs({ { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" },
                         { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true } }) do
        local t = b:CreateTexture(nil, "BORDER")
        t:SetPoint(e[1]); t:SetPoint(e[2])
        if e[3] then t:SetWidth(1) else t:SetHeight(1) end
        t:SetColorTexture(EDGE[1], EDGE[2], EDGE[3], 1)
    end
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(GLOW[1], GLOW[2], GLOW[3], 0.15)
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
    Panel(f, 0.95)

    local close = CreateFrame("Button", nil, f)
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -8, -8)
    local x = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    x:SetPoint("CENTER")
    x:SetText("\195\151")
    x:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
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
    title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
    local sub = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    sub:SetPoint("RIGHT", f, "RIGHT", -CFG_PAD, 0)
    sub:SetJustifyH("LEFT")
    sub:SetWordWrap(true)
    sub:SetText("Left-click: demons. Right-click: summoning and healthstones.")

    local rule = f:CreateTexture(nil, "BORDER")
    rule:SetHeight(1)
    rule:SetColorTexture(EDGE[1], EDGE[2], EDGE[3], 0.6)
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

    local dir = PanelButton(f, "")
    dir:SetPoint("TOPLEFT", w[2], "BOTTOMLEFT", 2, -12)
    dir.Refresh = function() dir:SetText("Flyouts open: " .. db.dir) end
    dir:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        db.dir = NextDir()
        dir.Refresh()
        Rebuild()
    end)
    w[3] = dir

    local scaleText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleText:SetPoint("TOPLEFT", dir, "BOTTOMLEFT", 0, -16)
    local plus = PanelButton(f, "+", 26)
    local minus = PanelButton(f, "-", 26)
    plus:SetPoint("RIGHT", f, "RIGHT", -CFG_PAD, 0)
    plus:SetPoint("TOP", dir, "BOTTOM", 0, -10)
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
    w[4] = { Refresh = function() scaleText:SetText(("Size: %.1fx"):format(db.scale or 1)) end }

    local reset = PanelButton(f, "Reset position and size")
    reset:SetPoint("TOPLEFT", dir, "BOTTOMLEFT", 0, -44)
    reset:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        db.point, db.scale = nil, 1
        ApplyLayout()
        w[4].Refresh()
    end)

    local note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", reset, "BOTTOMLEFT", 0, -14)
    note:SetWidth(CFG_INNER)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText("Shift-drag the button to move it. If this client forgets your settings, /wf where prints a line to paste into Settings.lua.")

    local function FitHeight()
        local top, bottom = f:GetTop(), note:GetBottom()
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
        Print(("point = { %q, %q, %d, %d }, scale = %.1f, dir = %q, locked = %s,"):format(
            p and p[1] or "CENTER", p and p[2] or "CENTER", p and p[3] or 0, p and p[4] or -180,
            db.scale or 1, db.dir, tostring(db.locked)))
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
    else
        Print("/wf config - the settings window")
        Print("/wf lock, /wf unlock - stop or allow moving the button" ..
            (Addon.bareLock and " (also just /lock and /unlock)" or ""))
        Print("/wf dir up|down|left|right - where the flyouts open")
        Print("/wf scale 0.5-2 - button size")
        Print("/wf show | hide - show or hide the button")
        Print("/wf reset - back to the middle of the screen")
        Print("/wf where - a line to save your settings in Settings.lua")
        Print("/wf spells - what the flyouts found in your spellbook")
    end
end

local events = CreateFrame("Frame")

for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB",
                     "BAG_UPDATE_DELAYED", "SPELL_UPDATE_COOLDOWN", "PLAYER_REGEN_ENABLED",
                     "GET_ITEM_INFO_RECEIVED" }) do
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
    if not VALID_DIR[db.dir] then db.dir = "up" end
    db.scale = tonumber(db.scale) or 1
end

local function Init()
    if ready then return end
    LoadSettings()
    local warlock, class = IsWarlock()
    if class and not warlock then main:Hide() return end
    ready = true
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

events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then LoadSettings() end
        return
    elseif event == "PLAYER_LOGIN" then
        Init()
        Addon.RegisterBareLock()
        if ready then Rebuild() end
    elseif not ready then
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pending then ApplyLayout() end
    elseif event == "SPELL_UPDATE_COOLDOWN" then

    else
        QueueRebuild()
        return
    end
    if ready then Refresh() end
end)

if IsLoggedIn and IsLoggedIn() then Init() if ready then Refresh() end end

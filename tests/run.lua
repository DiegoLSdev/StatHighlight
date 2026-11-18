-- Automated tests for StatHighlight detection, run outside the game (Lua 5.1).
-- Usage: lua5.1 tests/run.lua   (from the repository root)

-- Minimal WoW environment: every frame method does nothing and returns
-- another dummy object, so the options window can be built in tests.
local Dummy
local dummyMeta = {
    __index = function() return function() return Dummy() end end,
}
Dummy = function() return setmetatable({}, dummyMeta) end
CreateFrame = function() return Dummy() end
tinsert = table.insert
UISpecialFrames = {}
SlashCmdList = {}

local chunk = assert(loadfile("StatHighlight.lua"))
local ns = {}
chunk("StatHighlight", ns)
ns.InitDB()

local failures, total = 0, 0

local function Found(text)
    local out = {}
    for _, span in ipairs(ns.FindAllSpans(text)) do
        out[#out + 1] = string.sub(text, span[1], span[2]) .. "=" .. span[3]
    end
    return table.concat(out, " | ")
end

local function Check(name, got, expected)
    total = total + 1
    if got ~= expected then
        failures = failures + 1
        print("::error::" .. name .. "\n  expected: " .. tostring(expected) .. "\n  got:      " .. tostring(got))
    else
        print("ok  " .. name)
    end
end

local function Expect(text, expected)
    Check(text, Found(text), expected)
end

-- Stats (already supported in 1.0.0) -----------------------------------
Expect("Restaura 530 p. de salud durante 30 s.",
    "530 p. de salud=health | 30 s=duration")
Expect("ganarás 6 p. de aguante y espíritu durante 15 min.",
    "6 p. de aguante=stamina | espíritu=spirit | 15 min=duration")
Expect("Restores 30 health over 10 sec.",
    "30 health=health | 10 sec=duration")

-- Scrolls ----------------------------------------------------------------
Expect("Usar: Aumenta el Intelecto del objetivo 8 p. durante 30 min.",
    "Intelecto del objetivo 8 p.=intellect | 30 min=duration")
Expect("Usar: Aumenta el Intelecto del objetivo en 8 p. durante 30 min.",
    "Intelecto del objetivo en 8 p.=intellect | 30 min=duration")
Expect("Use: Increases the target's Intellect by 8 for 30 min.",
    "Intellect by 8=intellect | 30 min=duration")
Expect("Usar: Aumenta 8 p. el espíritu del objetivo durante 30 min.",
    "8 p. el espíritu=spirit | 30 min=duration")

-- Bonfire ----------------------------------------------------------------
Expect("Usar: Echa la leña a la hoguera. Los jugadores cercanos obtienen +5 de aguante durante 1 h.",
    "+5 de aguante=stamina | 1 h=duration")

-- Durations --------------------------------------------------------------
Expect("Dura 1 hora.", "1 hora=duration")
Expect("Efecto durante 1 h 30 min.", "1 h 30 min=duration")
Expect("Efecto durante 1 h y 30 min.", "1 h y 30 min=duration")
Expect("Aumenta tu aguante durante 30 min.", "30 min=duration")
Expect("Regenera 5 p. de maná cada 5 s durante 30 min.",
    "5 p. de maná=mana | 30 min=duration")
Expect("Restores 4 mana every 5 sec. for 2 min.",
    "4 mana=mana | 2 min=duration")
Expect("Tiempo de reutilización: 2 min", "")
Expect("Cooldown: 5 min", "")
Expect("Nivel 45", "")
Expect("|cff00ff00Usar: Restaura 1.000 p. de salud durante 24 s.|r",
    "1.000 p. de salud=health | 24 s=duration")

-- Options: durations turned off ------------------------------------------
StatHighlightDB.stats.duration = { enabled = false }
Expect("Restaura 530 p. de salud durante 30 s.", "530 p. de salud=health")
StatHighlightDB.stats.duration = nil

-- Highlighting inside existing color codes ------------------------------
do
    local text = "|cff00ff00Usar: Restaura 10 p. de salud durante 5 s.|r"
    local out = ns.BuildHighlighted(text, ns.FindAllSpans(text))
    Check("health color inside green Use: line", out,
        "|cff00ff00Usar: Restaura |cffffd24a10 p. de salud|r|cff00ff00 durante |cff66ccff5 s|r|cff00ff00.|r")
end

-- Item types --------------------------------------------------------------
local function Region(t)
    return {
        GetObjectType = function() return "FontString" end,
        GetText = function() return t end,
    }
end
local useLine = { Region("Leña de roble"), Region("Usar: Echa la leña a la hoguera.") }
local plain = { Region("Cuero ligero"), Region("Objeto comerciable") }
local bonfire = { Region("Ofrenda"), Region("Se puede quemar en una hoguera.") }

Check("consumable", ns.ItemAllowed(0, plain), true)
Check("weapon (gear off)", ns.ItemAllowed(2, useLine), false)
Check("armor (gear off)", ns.ItemAllowed(4, plain), false)
Check("other item with Use: line", ns.ItemAllowed(15, useLine), true)
Check("other item for the bonfire", ns.ItemAllowed(12, bonfire), true)
Check("other item without effect", ns.ItemAllowed(7, plain), false)
Check("unknown item type", ns.ItemAllowed(nil, plain), true)
StatHighlightDB.types.gear = true
Check("armor (gear on)", ns.ItemAllowed(4, plain), true)
StatHighlightDB.types.other = false
Check("other item with Use: line (option off)", ns.ItemAllowed(15, useLine), false)

-- Migration from 1.0.0 ---------------------------------------------------
StatHighlightDB = { enabled = true, consumablesOnly = false, color = { r = 1, g = 1, b = 1 }, stats = {} }
ns.InitDB()
Check("migration: consumables-only off -> gear on", StatHighlightDB.types.gear, true)
Check("migration: removes consumablesOnly", StatHighlightDB.consumablesOnly, nil)
StatHighlightDB = { enabled = true, consumablesOnly = true }
ns.InitDB()
Check("migration: consumables-only on -> gear off", StatHighlightDB.types.gear, false)

-- Campfire items seen in game (1.2.0) ---------------------------------------
StatHighlightDB = nil
ns.InitDB()
Expect("Usar: Coloca un pequeño cuenco con pescado que permite que tú y otros os sentéis cerca para obtener un 8% más de estadísticas. Incompatible con Bendición de reyes.",
    "8% más de estadísticas=allstats")
Expect("Usar: Prende una vela de incienso que permite que tú y otros os sentéis cerca para obtener 12 p. más de intelecto. Incompatible con Intelecto Arcano.",
    "12 p. más de intelecto=intellect")
Expect("Use: Places a small bowl of fish that lets you and others sitting nearby gain 8% more stats.",
    "8% more stats=allstats")
Expect("Use: Lights a stick of incense that grants 12 more Intellect to those sitting nearby.",
    "12 more Intellect=intellect")
Expect("Requiere una hoguera cercana. Todas las características de acampada comparten el mismo tiempo de reutilización de 1 h.", "")
Expect("Requiere Pesca (20)", "")
Expect("|cffff2020Requiere Botánica (20)|r", "")
Expect("Requires Fishing (20)", "")
Expect("Tiempo de reutilización restante: 58 min 23 s", "")
Expect("Cooldown remaining: 58 min 23 sec", "")

-- Tooltip background opacity ------------------------------------------------
do
    local function FakeTexture(r, g, b, a)
        local t = { color = { r, g, b, a } }
        function t:GetVertexColor() return unpack(self.color) end
        function t:SetVertexColor(nr, ng, nb, na) self.color = { nr, ng, nb, na } end
        return t
    end
    local tooltip = { NineSlice = { Center = FakeTexture(0.09, 0.09, 0.19, 0.8) } }
    local center = tooltip.NineSlice.Center

    ns.ApplyTooltipBackground(tooltip)
    Check("background: untouched when off", center.color[4], 0.8)

    StatHighlightDB.background = { enabled = true, alpha = 1 }
    ns.ApplyTooltipBackground(tooltip)
    Check("background: solid when on at 100%", center.color[4], 1)
    Check("background: keeps the game's color", center.color[3], 0.19)

    StatHighlightDB.background.alpha = 0.35
    ns.ApplyTooltipBackground(tooltip)
    Check("background: follows the slider", center.color[4], 0.35)

    StatHighlightDB.background.enabled = false
    ns.ApplyTooltipBackground(tooltip)
    Check("background: restored when turned off", center.color[4], 0.8)

    -- Old-style tooltips use a backdrop instead of NineSlice.
    local old = { bg = { 0, 0, 0, 0.7 } }
    function old:GetBackdropColor() return unpack(self.bg) end
    function old:SetBackdropColor(r, g, b, a) self.bg = { r, g, b, a } end
    StatHighlightDB.background = { enabled = true, alpha = 0.5 }
    ns.ApplyTooltipBackground(old)
    Check("background: backdrop tooltips", old.bg[4], 0.5)

    StatHighlightDB = { background = { enabled = true, alpha = 7 } }
    ns.InitDB()
    Check("background: saved alpha is clamped", StatHighlightDB.background.alpha, 1)
    StatHighlightDB = { }
    ns.InitDB()
    Check("background: off by default", StatHighlightDB.background.enabled, false)
end

-- Line glow -----------------------------------------------------------------
do
    StatHighlightDB = nil
    ns.InitDB()

    -- Every character is 6 pixels wide in these tests.
    local function measure(s) return #s * 6 end
    ns.SetTextWidth(function(_, _, _, s) return measure(s) end)

    -- Layout helpers.
    local visible, map = ns.VisibleText("|cff00ff00Usar: 5 p.|r ok")
    Check("glow: visible text drops color codes", visible, "Usar: 5 p. ok")
    Check("glow: position map skips color codes", map[11], 1)
    local wrapped = ns.WrapLines("aaa bbb ccc", 42, measure)
    Check("glow: word wrap", #wrapped .. ":" .. wrapped[2][1] .. "-" .. wrapped[2][2], "2:9-11")
    local pieces = ns.GlowPieces("aaa bbb ccc", wrapped, 5, 11, measure)
    Check("glow: span split across lines",
        pieces[1].text .. "@" .. pieces[1].line .. "," .. pieces[1].x .. " " ..
        pieces[2].text .. "@" .. pieces[2].line .. "," .. pieces[2].x,
        "bbb@0,24 ccc@1,0")

    local strings = {}
    local function FakeFontString()
        local t = { shown = false }
        function t:SetDrawLayer() end
        function t:SetShadowOffset() end
        function t:SetWordWrap() end
        function t:SetFont() end
        function t:SetText(s) self.text = s end
        function t:ClearAllPoints() end
        function t:SetPoint(_, _, _, x, y) self.x, self.y = x, y end
        function t:SetTextColor(r, g, b, a) self.color = { r, g, b, a } end
        function t:Show() self.shown = true end
        function t:Hide() self.shown = false end
        strings[#strings + 1] = t
        return t
    end
    local function Line(text)
        local l = { text = text }
        function l:GetObjectType() return "FontString" end
        function l:GetText() return self.text end
        function l:SetText(t) self.text = t end
        function l:GetFont() return "Fonts\\FRIZQT__.TTF", 12, "" end
        function l:GetWidth() return 1000 end
        function l:GetStringHeight() return 12 end
        return l
    end
    local lines = {
        Line("Usar: Restaura 530 p. de salud durante 30 s."),
        Line("Nivel 45"),
    }
    local tooltip = {}
    function tooltip:GetRegions() return unpack(lines) end
    function tooltip:CreateFontString() return FakeFontString() end
    local function Shown()
        local n, first = 0, nil
        for _, t in ipairs(strings) do
            if t.shown then
                n = n + 1
                first = first or t
            end
        end
        return n, first
    end
    local copies = 12 -- outline copies per glowing piece

    ns.HighlightTooltip(tooltip)
    Check("glow: off by default", (Shown()), 0)

    StatHighlightDB.stats.health = { glow = true }
    ns.OnSettingsChanged()
    ns.HighlightTooltip(tooltip)
    local n, glow = Shown()
    Check("glow: outline copies for one stat", n, copies)
    Check("glow: only the stat's words", glow and glow.text, "530 p. de salud")
    Check("glow: placed on the words", glow and glow.x, 90 + 1) -- "Usar: Restaura " + 1 px
    Check("glow: uses the stat's color", glow and glow.color[3], 0.290)

    StatHighlightDB.stats.health = nil
    StatHighlightDB.stats.duration = { glow = true }
    ns.OnSettingsChanged()
    ns.HighlightTooltip(tooltip)
    n, glow = Shown()
    Check("glow: duration words", glow and glow.text, "30 s")
    Check("glow: duration glow uses the duration color", glow and glow.color[1], 0.400)
    Check("glow: font strings are reused", #strings, copies)

    StatHighlightDB.stats.duration = nil
    ns.OnSettingsChanged()
    ns.HighlightTooltip(tooltip)
    Check("glow: hidden when turned off", (Shown()), 0)

    StatHighlightDB.stats.health = { glow = true }
    StatHighlightDB.enabled = false
    ns.OnSettingsChanged()
    ns.HighlightTooltip(tooltip)
    Check("glow: hidden when the addon is off", (Shown()), 0)
    Check("glow: text restored when the addon is off", lines[1].text,
        "Usar: Restaura 530 p. de salud durante 30 s.")
    ns.SetTextWidth(nil)
    StatHighlightDB = nil
    ns.InitDB()
end

-- Options window can be built and refreshed ---------------------------------
do
    local ok, err = pcall(function()
        SlashCmdList["STATHIGHLIGHT"]("")     -- builds the window
        SlashCmdList["STATHIGHLIGHT"]("on")   -- refreshes it
        SlashCmdList["STATHIGHLIGHT"]("reset")
    end)
    Check("options window builds (English)", ok and "ok" or tostring(err), "ok")
end

-- Interface language -------------------------------------------------------
Check("English interface by default", ns.L.ENABLED, "Enabled")
do
    GetLocale = function() return "esES" end
    local esNs = {}
    assert(loadfile("StatHighlight.lua"))("StatHighlight", esNs)
    Check("Spanish interface on esES clients", esNs.L.ENABLED, "Activado")
    esNs.InitDB()
    local ok, err = pcall(function()
        SlashCmdList["STATHIGHLIGHT"]("")
        SlashCmdList["STATHIGHLIGHT"]("on")
    end)
    Check("options window builds (Spanish)", ok and "ok" or tostring(err), "ok")
    -- Every English text must also have a value on Spanish clients.
    for key in pairs(ns.L) do
        Check("Spanish text for " .. key, type(esNs.L[key]), "string")
    end
    GetLocale = nil
end

print(string.format("\n%d tests, %d failures", total, failures))
if failures > 0 then os.exit(1) end

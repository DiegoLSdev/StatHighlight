-- StatHighlight - WoW Forever 1.60.1
-- Resalta el nombre de una estadistica y la cantidad que aumenta dentro
-- de las lineas de descripcion de los tooltips de objetos.
-- Menu de opciones: /shl  (o /stathighlight)

local ADDON_NAME = ...
ADDON_NAME = ADDON_NAME or "StatHighlight"

local MAX_GAP = 45 -- bytes maximos entre el nombre y la cantidad

------------------------------------------------------------------------
-- Categorias de estadisticas
-- Cada categoria se puede activar/desactivar y tener su propio color.
-- Los nombres van en minusculas (con y sin tildes, y en ingles).
------------------------------------------------------------------------
local CATEGORIES = {
    { key = "health", label = "Salud", names = {
        "salud", "salud máxima", "salud maxima", "puntos de salud",
        "health", "max health", "maximum health" } },
    { key = "mana", label = "Maná", names = {
        "maná", "mana", "maná máximo", "mana maximo", "puntos de maná",
        "maximum mana" } },
    { key = "power", label = "Ira / energía", names = {
        "ira", "energía", "energia", "rage", "energy" } },
    { key = "stamina", label = "Aguante", names = { "aguante", "stamina" } },
    { key = "spirit", label = "Espíritu", names = { "espíritu", "espiritu", "spirit" } },
    { key = "strength", label = "Fuerza", names = { "fuerza", "strength" } },
    { key = "agility", label = "Agilidad", names = { "agilidad", "agility" } },
    { key = "intellect", label = "Intelecto", names = { "intelecto", "intellect" } },
    { key = "allstats", label = "Todos los atributos", names = {
        "todos los atributos", "todas las estadísticas", "todas las estadisticas",
        "todas tus estadísticas", "todas tus estadisticas", "todos tus atributos",
        "all stats", "all attributes" } },
    { key = "armor", label = "Armadura", names = {
        "armadura", "valor de armadura", "armor", "armour" } },
    { key = "defense", label = "Defensa", names = {
        "defensa", "índice de defensa", "indice de defensa", "habilidad de defensa",
        "defense", "defense rating", "defense skill" } },
    { key = "attackpower", label = "Poder de ataque", names = {
        "poder de ataque", "poder de ataque a distancia",
        "attack power", "ranged attack power" } },
    { key = "spellpower", label = "Poder con hechizos", names = {
        "poder con hechizos", "poder de hechizo", "poder de hechizos",
        "daño con hechizos", "daño de hechizos", "daño mágico", "daño magico",
        "daño y curación", "daño y curacion", "daño y sanación",
        "spell power", "spell damage", "damage and healing", "healing and damage" } },
    { key = "healing", label = "Curación", names = {
        "curación", "curacion", "sanación", "sanacion", "healing" } },
    { key = "damage", label = "Daño", names = {
        "daño", "daño de fuego", "daño de escarcha", "daño de sombras",
        "daño de naturaleza", "daño arcano", "daño físico", "daño fisico",
        "damage", "fire damage", "frost damage", "shadow damage",
        "nature damage", "arcane damage", "physical damage" } },
    { key = "regen", label = "Regeneración", names = {
        "regeneración de maná", "regeneracion de mana",
        "regeneración de salud", "regeneracion de salud",
        "mana regeneration", "health regeneration" } },
    { key = "resist", label = "Resistencias", names = {
        "resistencia al fuego", "resistencia a la escarcha", "resistencia a la naturaleza",
        "resistencia a las sombras", "resistencia a la sombra", "resistencia arcana",
        "resistencia a lo arcano", "todas las resistencias", "resistencia a todo",
        "resistencias", "resistencia",
        "fire resistance", "frost resistance", "nature resistance",
        "shadow resistance", "arcane resistance", "all resistances", "resistance" } },
    { key = "crit", label = "Golpe crítico", names = {
        "golpe crítico", "golpe critico", "índice de golpe crítico", "indice de golpe critico",
        "golpe crítico con hechizos", "golpe critico con hechizos",
        "probabilidad de golpe crítico", "probabilidad de golpe critico",
        "critical strike", "critical strike rating", "critical strike chance",
        "crit rating", "crit" } },
    { key = "hit", label = "Índice de golpe", names = {
        "índice de golpe", "indice de golpe", "probabilidad de golpe",
        "índice de golpe con hechizos", "indice de golpe con hechizos",
        "hit rating", "hit chance", "chance to hit" } },
    { key = "haste", label = "Celeridad / vel. ataque", names = {
        "celeridad", "índice de celeridad", "indice de celeridad",
        "velocidad de ataque", "velocidad de lanzamiento",
        "haste", "haste rating", "attack speed", "casting speed" } },
    { key = "speed", label = "Velocidad de movimiento", names = {
        "velocidad de movimiento", "velocidad de carrera", "velocidad de nado",
        "velocidad", "movement speed", "run speed", "swim speed" } },
    { key = "avoidance", label = "Esquivar / parada / bloqueo", names = {
        "esquivar", "índice de esquivar", "indice de esquivar",
        "parada", "parar", "índice de parada", "indice de parada",
        "bloqueo", "bloquear", "índice de bloqueo", "indice de bloqueo",
        "valor de bloqueo", "dodge", "parry", "block", "block value" } },
    { key = "expertise", label = "Pericia / maestría / otros", names = {
        "pericia", "índice de pericia", "indice de pericia",
        "maestría", "maestria", "índice de maestría", "indice de maestria",
        "penetración de armadura", "penetracion de armadura",
        "penetración de hechizos", "penetracion de hechizos",
        "temple", "resiliencia",
        "expertise", "mastery", "mastery rating", "armor penetration",
        "spell penetration", "resilience" } },
    { key = "skill", label = "Habilidad de profesión", names = {
        "habilidad en pesca", "habilidad de pesca", "pesca",
        "habilidad en herboristería", "habilidad en herboristeria", "herboristería",
        "habilidad en minería", "habilidad en mineria", "minería",
        "habilidad en desuello", "desuello",
        "fishing", "fishing skill", "herbalism", "mining", "skinning" } },
    { key = "experience", label = "Experiencia", names = {
        "experiencia", "experience" } },
}

-- Lista plana de nombres, de mas largo a mas corto.
local NAME_LIST = {}
for _, cat in ipairs(CATEGORIES) do
    for _, name in ipairs(cat.names) do
        NAME_LIST[#NAME_LIST + 1] = { name = name, key = cat.key }
    end
end
table.sort(NAME_LIST, function(a, b) return #a.name > #b.name end)

local function MakeSet(list)
    local set = {}
    for _, w in ipairs(list) do set[w] = true end
    return set
end

-- Palabras que pueden ir entre la cantidad y el nombre: "6 p. de tu aguante".
local CONNECTORS = MakeSet({
    "de", "del", "tu", "su", "tus", "sus", "el", "la", "los", "las",
    "a", "al", "en", "your", "of", "the" })

-- Palabras permitidas entre el nombre y una cantidad que va detras:
-- "aguante aumentará 12 p.", "Stamina by 12", "experiencia obtenida al
-- matar enemigos aumenta un 5%". Si aparece otra palabra (p. ej. "durante"),
-- el numero no pertenece a la estadistica.
local GAP_WORDS = MakeSet({
    "en", "de", "del", "a", "al", "un", "una", "se", "tu", "su", "el", "la",
    "los", "las", "y", "e", "hasta",
    "aumenta", "aumentan", "aumentará", "aumentarán", "aumentara", "aumentaran",
    "aumentado", "aumentada", "aumentados", "aumentadas",
    "incrementa", "incrementan", "incrementará", "incrementarán",
    "mejora", "mejoran", "mejorará", "mejorarán",
    "obtenida", "obtenido", "ganada", "ganado", "matar", "enemigos",
    "by", "to", "of", "is", "are", "up", "your", "the", "and",
    "increase", "increases", "increased", "gained", "from", "killing",
    "monsters", "enemies" })

-- Palabras que unen dos estadisticas: "aguante y espíritu", "Stamina and Spirit".
local CHAIN_WORDS = MakeSet({
    "y", "e", "and", "tu", "su", "el", "la", "los", "las", "your", "&" })

------------------------------------------------------------------------
-- Opciones guardadas
------------------------------------------------------------------------
local DEFAULT_COLOR = { r = 1, g = 0.824, b = 0.290 } -- ffd24a dorado

local db -- StatHighlightDB tras cargar
local settingsVersion = 1

local function CopyColor(c) return { r = c.r, g = c.g, b = c.b } end

local function ResetDB()
    StatHighlightDB = {
        enabled = true,
        consumablesOnly = true,
        debug = false,
        color = CopyColor(DEFAULT_COLOR),
        stats = {},
    }
    db = StatHighlightDB
    settingsVersion = settingsVersion + 1
end

local function InitDB()
    if type(StatHighlightDB) ~= "table" then
        ResetDB()
        return
    end
    db = StatHighlightDB
    if db.enabled == nil then db.enabled = true end
    if db.consumablesOnly == nil then db.consumablesOnly = true end
    if type(db.color) ~= "table" then db.color = CopyColor(DEFAULT_COLOR) end
    if type(db.stats) ~= "table" then db.stats = {} end
end

local function StatSettings(key)
    if not db then return nil end
    local s = db.stats[key]
    if not s then
        s = {}
        db.stats[key] = s
    end
    return s
end

local function IsCategoryEnabled(key)
    if not db then return true end
    local s = db.stats[key]
    return not (s and s.enabled == false)
end

local function EffectiveColor(key)
    local s = db and db.stats[key]
    if s and s.color then return s.color end
    return (db and db.color) or DEFAULT_COLOR
end

local function ColorCode(c)
    return string.format("|cff%02x%02x%02x",
        math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
end

------------------------------------------------------------------------
-- Deteccion de texto
------------------------------------------------------------------------

-- string.lower no convierte mayusculas acentuadas (UTF-8). Cada pareja ocupa
-- los mismos bytes, asi que las posiciones del texto original coinciden.
local UPPER_ACCENTS = {
    ["Á"] = "á", ["É"] = "é", ["Í"] = "í", ["Ó"] = "ó",
    ["Ú"] = "ú", ["Ü"] = "ü", ["Ñ"] = "ñ",
}

local function Normalize(text)
    local lower = string.lower(text)
    for upper, low in pairs(UPPER_ACCENTS) do
        lower = string.gsub(lower, upper, low)
    end
    return lower
end

-- Letra ASCII o byte de un caracter UTF-8 (letras acentuadas).
local function IsLetterByte(b)
    if not b then return false end
    return b >= 128 or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
end

local function IsSpace(text, pos)
    local c = string.sub(text, pos, pos)
    return c == " " or c == "\t" or c == "\n" or c == "\r"
end

-- Comprueba que todas las palabras del hueco esten en la lista permitida.
local function GapWordsAllowed(gapLower, allowed)
    local cleaned = string.gsub(gapLower, "[:,;%(%)%+]", " ")
    for word in string.gmatch(cleaned, "%S+") do
        if not allowed[word] then return false end
    end
    return true
end

-- Cantidad delante del nombre: "15 p. de aguante", "70 a 90 p. de salud",
-- "530 health", "+10 Aguante". Devuelve la posicion inicial.
local function FindAmountBefore(text, lowerText, s)
    local pos = s - 1
    local function trim()
        while pos > 0 and IsSpace(text, pos) do pos = pos - 1 end
    end
    trim()

    -- Hasta dos palabras de union ("de tu").
    for _ = 1, 2 do
        local prefix = string.sub(lowerText, 1, pos)
        local w1 = string.find(prefix, "[%a\128-\255]+$")
        if w1 and CONNECTORS[string.sub(prefix, w1)] then
            pos = w1 - 1
            trim()
        else
            break
        end
    end

    -- "p." o "puntos" opcionales.
    local prefix = string.sub(lowerText, 1, pos)
    if string.sub(prefix, -2) == "p." and not IsLetterByte(string.byte(prefix, #prefix - 2)) then
        pos = pos - 2
        trim()
    elseif string.sub(prefix, -6) == "puntos" and not IsLetterByte(string.byte(prefix, #prefix - 6)) then
        pos = pos - 6
        trim()
    elseif string.sub(prefix, -6) == "points" and not IsLetterByte(string.byte(prefix, #prefix - 6)) then
        pos = pos - 6
        trim()
    end

    prefix = string.sub(text, 1, pos)
    if not string.find(prefix, "%d$") then return end
    local start = string.find(prefix, "%d[%d%.,]*$")
    if not start then return end

    -- Rango: "70 a 90", "70 to 90", "70-90".
    local pre = string.sub(lowerText, 1, start - 1)
    local r1 = string.find(pre, "%d[%d%.,]*%s+a%s+$")
        or string.find(pre, "%d[%d%.,]*%s+to%s+$")
        or string.find(pre, "%d[%d%.,]*%s*%-%s*$")
    if r1 then start = r1 end

    if start > 1 and string.sub(text, start - 1, start - 1) == "+" then
        start = start - 1
    end
    return start
end

-- Cantidad detras del nombre: "aguante 15 p.", "Stamina by 12",
-- "espíritu: 10", "experiencia ... aumenta un 5%". Devuelve la posicion final.
local function FindAmountAfter(text, lowerText, e)
    local after = string.sub(text, e + 1, e + MAX_GAP + 25)
    local gap, number = string.match(after, "^([^%d]-)(%d[%d%.,]*)")
    if not gap or gap == "" or #gap > MAX_GAP then return end
    -- No cruzar un final de frase ni un codigo de escape (|c, |T, |H...).
    if string.find(gap, "[%.|]") then return end
    if not GapWordsAllowed(string.sub(lowerText, e + 1, e + #gap), GAP_WORDS) then return end

    number = string.gsub(number, "[%.,]+$", "")
    local finish = e + #gap + #number

    local rest = string.sub(lowerText, finish + 1)
    local range = string.match(rest, "^%s+a%s+%d+")
        or string.match(rest, "^%s+to%s+%d+")
        or string.match(rest, "^%s*%-%s*%d+")
    if range then
        finish = finish + #range
        rest = string.sub(lowerText, finish + 1)
    end

    local suffix = string.match(rest, "^%s*p%.")
        or string.match(rest, "^%%")
        or string.match(rest, "^%s+puntos")
        or ""
    return finish + #suffix
end

-- Devuelve una lista de tramos { inicio, fin, categoria } sin solaparse.
local function FindStatSpans(text)
    local lowerText = Normalize(text)

    -- 1) Localiza todos los nombres (los largos tienen prioridad).
    local occ = {}
    for _, entry in ipairs(NAME_LIST) do
        local from = 1
        while true do
            local s, e = string.find(lowerText, entry.name, from, true)
            if not s then break end
            local prev = s > 1 and string.byte(lowerText, s - 1) or nil
            local nextb = string.byte(lowerText, e + 1)
            if not IsLetterByte(prev) and not IsLetterByte(nextb) then
                local overlaps = false
                for _, o in ipairs(occ) do
                    if s <= o.e and e >= o.s then overlaps = true break end
                end
                if not overlaps then
                    occ[#occ + 1] = { s = s, e = e, key = entry.key }
                end
            end
            from = e + 1
        end
    end
    if #occ == 0 then return {} end
    table.sort(occ, function(a, b) return a.s < b.s end)

    -- 2) Busca la cantidad de cada nombre (delante o detras).
    local candidates = {}
    for _, o in ipairs(occ) do
        if IsCategoryEnabled(o.key) then
            local b1 = FindAmountBefore(text, lowerText, o.s)
            if b1 then
                candidates[#candidates + 1] = { b1, o.e, o.key, occ = o }
            else
                local finish = FindAmountAfter(text, lowerText, o.e)
                if finish then
                    candidates[#candidates + 1] = { o.s, finish, o.key, occ = o }
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if a[1] ~= b[1] then return a[1] < b[1] end
        return a[2] > b[2]
    end)

    local spans, lastEnd = {}, 0
    for _, c in ipairs(candidates) do
        if c[1] > lastEnd then
            spans[#spans + 1] = { c[1], c[2], c[3] }
            c.occ.used = true
            lastEnd = c[2]
        end
    end

    -- 3) Estadisticas encadenadas sin cantidad propia:
    --    "6 p. de aguante y espíritu", "tu aguante y tu espíritu aumentarán 12 p."
    local changed = true
    while changed do
        changed = false
        for _, o in ipairs(occ) do
            if not o.used and IsCategoryEnabled(o.key) then
                local linked = false
                for _, sp in ipairs(spans) do
                    local gap
                    if sp[2] < o.s then
                        gap = string.sub(lowerText, sp[2] + 1, o.s - 1)
                    elseif sp[1] > o.e then
                        gap = string.sub(lowerText, o.e + 1, sp[1] - 1)
                    end
                    if gap and #gap <= 12 and not string.find(gap, "[%.|%d]")
                        and GapWordsAllowed(gap, CHAIN_WORDS) then
                        linked = true
                        break
                    end
                end
                if linked then
                    spans[#spans + 1] = { o.s, o.e, o.key }
                    o.used = true
                    changed = true
                end
            end
        end
    end

    table.sort(spans, function(a, b) return a[1] < b[1] end)
    return spans
end

------------------------------------------------------------------------
-- Aplicar color
------------------------------------------------------------------------

-- Color en linea (|cAARRGGBB) que sigue abierto en la posicion pos, si lo hay.
local function ActiveColorAt(text, pos)
    local active
    local i = 1
    while i < pos do
        local c1, c2, code = string.find(text, "(|c%x%x%x%x%x%x%x%x)", i)
        local r1 = string.find(text, "|r", i, true)
        if c1 and c1 < pos and (not r1 or c1 < r1) then
            active = code
            i = c2 + 1
        elseif r1 and r1 < pos then
            active = nil
            i = r1 + 2
        else
            break
        end
    end
    return active
end

local function BuildHighlighted(text, spans)
    local parts, cursor = {}, 1
    for _, span in ipairs(spans) do
        local first, last, key = span[1], span[2], span[3]
        parts[#parts + 1] = string.sub(text, cursor, first - 1)
        parts[#parts + 1] = ColorCode(EffectiveColor(key))
        parts[#parts + 1] = string.sub(text, first, last)
        parts[#parts + 1] = "|r"
        -- Si la frase ya tenia su propio color, se restaura tras el resaltado.
        local outer = ActiveColorAt(text, first)
        if outer then parts[#parts + 1] = outer end
        cursor = last + 1
    end
    parts[#parts + 1] = string.sub(text, cursor)
    return table.concat(parts)
end

------------------------------------------------------------------------
-- Tooltips
------------------------------------------------------------------------

-- Cada linea recuerda su texto original y el resaltado que le pusimos,
-- para no aplicar el color dos veces y poder repintar al cambiar opciones.
local originals = setmetatable({}, { __mode = "k" })
local highlighted = setmetatable({}, { __mode = "k" })
local regionVersion = setmetatable({}, { __mode = "k" })

local function GetTooltipItem(tooltip, data)
    if data and data.id then return data.id end
    if tooltip.GetItem then
        local ok, _, link = pcall(tooltip.GetItem, tooltip)
        if ok and link then return link end
    end
end

local function GetItemClassID(item)
    local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not item or not getInstant then return nil end
    local result = { pcall(getInstant, item) }
    if result[1] then return result[7] end -- itemID, tipo, subtipo, hueco, icono, classID
end

local CONSUMABLE_CLASS = 0
local lastDebugKey

local function DebugDump(tooltip, item, classID, regions)
    local lines = {}
    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            local t = region:GetText()
            if type(t) == "string" and t ~= "" then lines[#lines + 1] = t end
        end
    end
    local key = tostring(item) .. "#" .. table.concat(lines, "\n")
    if key == lastDebugKey then return end
    lastDebugKey = key
    print("|cffffd24a[StatHighlight debug]|r tooltip=" .. tostring(tooltip.GetName and tooltip:GetName())
        .. " objeto=" .. tostring(item) .. " classID=" .. tostring(classID))
    for i, t in ipairs(lines) do
        print("  " .. i .. ": " .. string.gsub(t, "|", "||"))
    end
end

local function HighlightTooltip(tooltip, data)
    if not db or not tooltip or not tooltip.GetRegions then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end

    local item = GetTooltipItem(tooltip, data)
    local classID = GetItemClassID(item)
    local regions = { tooltip:GetRegions() }

    if db.debug then DebugDump(tooltip, item, classID, regions) end

    local allowed = db.enabled
    if allowed and db.consumablesOnly and classID ~= nil and classID ~= CONSUMABLE_CLASS then
        allowed = false
    end

    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if type(text) == "string" and text ~= "" then
                local ours = highlighted[region] == text
                if not (ours and regionVersion[region] == settingsVersion and allowed) then
                    if ours then text = originals[region] end

                    local spans = allowed and FindStatSpans(text) or {}
                    if #spans > 0 then
                        local newText = BuildHighlighted(text, spans)
                        originals[region] = text
                        highlighted[region] = newText
                        regionVersion[region] = settingsVersion
                        if newText ~= region:GetText() then region:SetText(newText) end
                    else
                        if ours then region:SetText(text) end
                        originals[region] = nil
                        highlighted[region] = nil
                        regionVersion[region] = nil
                    end
                end
            end
        end
    end
end

-- Se engancha de todas las formas disponibles: algunos tooltips (bolsas,
-- vendedor...) no pasan por todas, y la linea "Usar:" a veces llega tarde.
-- Aplicar el resaltado dos veces es seguro.
local TOOLTIPS = { "GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2" }

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
    and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        HighlightTooltip(tooltip, data)
    end)
end

local function TooltipShowsItem(tooltip)
    return GetTooltipItem(tooltip) ~= nil
end

for _, name in ipairs(TOOLTIPS) do
    local frame = _G[name]
    if frame and frame.HookScript then
        if frame.HasScript and frame:HasScript("OnTooltipSetItem") then
            frame:HookScript("OnTooltipSetItem", function(self) HighlightTooltip(self) end)
        end
        frame:HookScript("OnShow", function(self)
            if TooltipShowsItem(self) then HighlightTooltip(self) end
        end)
        -- Repaso cada 0,2 s mientras esta visible (textos que llegan tarde).
        local elapsed = 0
        frame:HookScript("OnUpdate", function(self, dt)
            elapsed = elapsed + (dt or 0)
            if elapsed < 0.2 then return end
            elapsed = 0
            if TooltipShowsItem(self) then HighlightTooltip(self) end
        end)
    end
end

------------------------------------------------------------------------
-- Menu de opciones
------------------------------------------------------------------------
local optionsFrame
local RefreshOptions

local function OnSettingsChanged()
    settingsVersion = settingsVersion + 1
    if RefreshOptions then RefreshOptions() end
end

local function OpenColorPicker(color, onChange, onCancel)
    local r, g, b = color.r, color.g, color.b
    local function current()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        onChange({ r = nr, g = ng, b = nb })
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, hasOpacity = false,
            swatchFunc = current,
            cancelFunc = onCancel,
        })
    else
        ColorPickerFrame:Hide()
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.opacityFunc = nil
        ColorPickerFrame.previousValues = { r, g, b }
        ColorPickerFrame.func = current
        ColorPickerFrame.cancelFunc = onCancel
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Show()
    end
end

local function CreateSwatch(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(18, 18)
    local border = button:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetColorTexture(0.05, 0.05, 0.05, 1)
    local fill = button:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMRIGHT", -2, 2)
    button.fill = fill
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    return button
end

local function CreateCheck(parent, label)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(22, 22)
    local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", check, "RIGHT", 2, 1)
    text:SetText(label)
    check.label = text
    return check
end

local function ShowHelpTooltip(owner, title, line)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title, 1, 1, 1)
    GameTooltip:AddLine(line, nil, nil, nil, true)
    GameTooltip:Show()
end

local function CreateOptionsFrame()
    local ok, f = pcall(CreateFrame, "Frame", "StatHighlightOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not f then
        f = CreateFrame("Frame", "StatHighlightOptionsFrame", UIParent)
        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.85)
        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", 2, 2)
    end
    f:SetSize(540, 470)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    tinsert(UISpecialFrames, "StatHighlightOptionsFrame") -- se cierra con Esc

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -6)
    title:SetText("StatHighlight")

    -- Opciones generales
    local enabled = CreateCheck(f, "Activado")
    enabled:SetPoint("TOPLEFT", 16, -34)
    enabled:SetScript("OnClick", function(self)
        db.enabled = self:GetChecked() and true or false
        OnSettingsChanged()
    end)

    local consumables = CreateCheck(f, "Solo consumibles (comida, pociones, elixires...)")
    consumables:SetPoint("TOPLEFT", 150, -34)
    consumables:SetScript("OnClick", function(self)
        db.consumablesOnly = self:GetChecked() and true or false
        OnSettingsChanged()
    end)

    local generalLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    generalLabel:SetPoint("TOPLEFT", 20, -68)
    generalLabel:SetText("Color general:")

    local generalSwatch = CreateSwatch(f)
    generalSwatch:SetPoint("LEFT", generalLabel, "RIGHT", 8, 0)
    generalSwatch:SetScript("OnClick", function()
        local previous = CopyColor(db.color)
        OpenColorPicker(db.color, function(c)
            db.color = c
            OnSettingsChanged()
        end, function()
            db.color = previous
            OnSettingsChanged()
        end)
    end)
    generalSwatch:SetScript("OnEnter", function(self)
        ShowHelpTooltip(self, "Color general", "Color para todas las estadísticas que no tengan uno propio.")
    end)
    generalSwatch:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 22)
    resetButton:SetPoint("TOPRIGHT", -20, -64)
    resetButton:SetText("Restablecer todo")
    resetButton:SetScript("OnClick", function()
        ResetDB()
        OnSettingsChanged()
        print("|cffffd24aStatHighlight|r: opciones restablecidas.")
    end)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 20, -94)
    hint:SetText("Casilla: activar la estadística.  Cuadro de color: clic = color propio, clic derecho = usar el color general.")

    -- Lista de estadisticas en dos columnas
    local rows = {}
    local perColumn = math.ceil(#CATEGORIES / 2)
    for i, cat in ipairs(CATEGORIES) do
        local col = (i <= perColumn) and 0 or 1
        local rowIndex = (i - 1) % perColumn
        local x = 16 + col * 262
        local y = -114 - rowIndex * 25

        local check = CreateCheck(f, cat.label)
        check:SetPoint("TOPLEFT", x, y)
        check:SetScript("OnClick", function(self)
            StatSettings(cat.key).enabled = self:GetChecked() and true or false
            OnSettingsChanged()
        end)

        local swatch = CreateSwatch(f)
        swatch:SetPoint("TOPLEFT", x + 228, y - 2)
        swatch:SetScript("OnClick", function(self, button)
            local s = StatSettings(cat.key)
            if button == "RightButton" then
                s.color = nil
                OnSettingsChanged()
                return
            end
            local previous = s.color and CopyColor(s.color) or nil
            OpenColorPicker(EffectiveColor(cat.key), function(c)
                s.color = c
                OnSettingsChanged()
            end, function()
                s.color = previous
                OnSettingsChanged()
            end)
        end)
        swatch:SetScript("OnEnter", function(self)
            local s = db.stats[cat.key]
            local which = (s and s.color) and "Tiene color propio." or "Usa el color general."
            ShowHelpTooltip(self, cat.label, which .. "\nClic: elegir color propio.\nClic derecho: volver al color general.")
        end)
        swatch:SetScript("OnLeave", function() GameTooltip:Hide() end)

        rows[#rows + 1] = { cat = cat, check = check, swatch = swatch }
    end

    RefreshOptions = function()
        if not db then return end
        enabled:SetChecked(db.enabled)
        consumables:SetChecked(db.consumablesOnly)
        generalSwatch.fill:SetColorTexture(db.color.r, db.color.g, db.color.b, 1)
        for _, row in ipairs(rows) do
            local on = IsCategoryEnabled(row.cat.key)
            local c = EffectiveColor(row.cat.key)
            row.check:SetChecked(on)
            row.swatch.fill:SetColorTexture(c.r, c.g, c.b, 1)
            if on then
                row.check.label:SetTextColor(c.r, c.g, c.b)
            else
                row.check.label:SetTextColor(0.5, 0.5, 0.5)
            end
        end
    end

    f:SetScript("OnShow", function() RefreshOptions() end)
    f:Hide()
    return f
end

local function ToggleOptions()
    if not db then return end
    if not optionsFrame then optionsFrame = CreateOptionsFrame() end
    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end

------------------------------------------------------------------------
-- Comandos
-- Nota: /sh no se puede usar porque WoW ya lo usa para gritar (/yell).
------------------------------------------------------------------------
local function Print(msg)
    print("|cffffd24aStatHighlight|r: " .. msg)
end

SLASH_STATHIGHLIGHT1 = "/shl"
SLASH_STATHIGHLIGHT2 = "/stathighlight"
SlashCmdList["STATHIGHLIGHT"] = function(msg)
    if not db then return end
    msg = string.lower(msg or "")
    local cmd, arg = string.match(msg, "^%s*(%S*)%s*(.-)%s*$")

    if cmd == "" or cmd == "menu" or cmd == "opciones" then
        ToggleOptions()
    elseif cmd == "on" then
        db.enabled = true
        OnSettingsChanged()
        Print("activado.")
    elseif cmd == "off" then
        db.enabled = false
        OnSettingsChanged()
        Print("desactivado.")
    elseif cmd == "color" then
        local hex = string.match(arg or "", "^#?(%x%x%x%x%x%x)$")
        if hex then
            db.color = {
                r = tonumber(string.sub(hex, 1, 2), 16) / 255,
                g = tonumber(string.sub(hex, 3, 4), 16) / 255,
                b = tonumber(string.sub(hex, 5, 6), 16) / 255,
            }
            OnSettingsChanged()
            Print("color general cambiado a " .. ColorCode(db.color) .. hex .. "|r.")
        else
            Print("uso: /shl color RRGGBB  (ejemplo: /shl color ffd24a)")
        end
    elseif cmd == "reset" then
        ResetDB()
        OnSettingsChanged()
        Print("opciones restablecidas.")
    elseif cmd == "debug" then
        db.debug = not db.debug
        lastDebugKey = nil
        Print("modo depuración " .. (db.debug and "activado: pasa el ratón por un objeto." or "desactivado."))
    else
        Print("comandos:")
        print("  /shl  - abrir o cerrar el menú")
        print("  /shl on | off  - activar o desactivar")
        print("  /shl color RRGGBB  - color general")
        print("  /shl reset  - restablecer opciones")
        print("  /shl debug  - mostrar el texto de los tooltips en el chat")
    end
end

------------------------------------------------------------------------
-- Carga
------------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if name == ADDON_NAME then
        InitDB()
        self:UnregisterEvent("ADDON_LOADED")
        Print("cargado. Escribe /shl para abrir el menú.")
    end
end)

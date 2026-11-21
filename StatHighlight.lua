-- StatHighlight - WoW Forever 1.60.1
-- Highlights stat names, their amounts and effect durations in item
-- tooltips (Spanish and English item text).
-- Options menu: /shl  (or /stathighlight)

local ADDON_NAME, ns = ...
ADDON_NAME = ADDON_NAME or "StatHighlight"
ns = ns or {}

------------------------------------------------------------------------
-- Interface language: English by default, Spanish on Spanish clients.
-- (Stat detection always understands both languages.)
------------------------------------------------------------------------
local LOCALE = (GetLocale and GetLocale()) or "enUS"
local IS_SPANISH = LOCALE == "esES" or LOCALE == "esMX"

local L = {
    LOADED = "loaded. Type /shl to open the options.",
    ENABLED_MSG = "enabled.",
    DISABLED_MSG = "disabled.",
    COLOR_CHANGED = "general color changed to %s.",
    COLOR_USAGE = "usage: /shl color RRGGBB  (example: /shl color ffd24a)",
    RESET_MSG = "options reset.",
    DEBUG_ON = "debug mode enabled: hover over an item.",
    DEBUG_OFF = "debug mode disabled.",
    DEBUG_HEADER = "tooltip=%s item=%s classID=%s",
    HELP_TITLE = "commands:",
    HELP_MENU = "  /shl  - open or close the options",
    HELP_ONOFF = "  /shl on | off  - enable or disable",
    HELP_COLOR = "  /shl color RRGGBB  - general color",
    HELP_RESET = "  /shl reset  - reset all options",
    HELP_DEBUG = "  /shl debug  - print tooltip text to chat",

    SECTION_GENERAL = "General",
    ENABLED = "Enabled",
    GENERAL_COLOR = "General color:",
    GENERAL_COLOR_HELP = "Color for every stat that has no color of its own.",
    RESET_ALL = "Reset all",

    SECTION_WHERE = "Where to highlight",
    TYPE_CONSUMABLE = "Consumables",
    TYPE_CONSUMABLE_HELP = "Food, drink, potions, elixirs, scrolls, bandages...",
    TYPE_OTHER = "Bonfire and other items with an effect",
    TYPE_OTHER_HELP = "Items that are not consumables but have a \"Use:\" line or are thrown into a bonfire for a buff.",
    TYPE_GEAR = "Gear",
    TYPE_GEAR_HELP = "Weapons and armor (bonuses such as \"+10 Stamina\"). Off by default.",

    SECTION_DURATION = "Effect duration",
    DURATION_CHECK = "Highlight durations  (for 30 min, 1 h, 10 sec...)",
    DURATION_TITLE = "Durations",
    DURATION_HELP = "Highlights how long the effect lasts. Cooldowns and intervals (\"every 5 sec\") are not highlighted.",
    DURATION_COLOR_TITLE = "Duration color",
    DURATION_COLOR_HELP = "Click: choose a color.\nRight-click: back to the default color (light blue).",

    SECTION_BACKGROUND = "Tooltip background",
    BG_CHECK = "More opaque background",
    BG_HELP = "Makes the background of tooltips less see-through, in its own color. When off, the game's default is used.",
    BG_OPACITY = "Opacity",
    BG_OPACITY_HELP = "0% = the game's normal background.\n100% = fully solid, the game world does not show through.",

    SECTION_STATS = "Stats",
    STATS_HINT = "Checkbox: enable.  Color box: click = own color, right-click = general color.",
    STAT_OWN_COLOR = "Has its own color.",
    STAT_GENERAL_COLOR = "Uses the general color.",
    STAT_COLOR_HELP = "\nClick: choose its own color.\nRight-click: back to the general color.",

    PANEL_DESC = "Highlights stats, amounts and effect durations in item tooltips.\nAll options are in the StatHighlight window (you can also type /shl).",
    PANEL_OPEN = "Open StatHighlight options",
}

if IS_SPANISH then
    L.LOADED = "cargado. Escribe /shl para abrir el menú."
    L.ENABLED_MSG = "activado."
    L.DISABLED_MSG = "desactivado."
    L.COLOR_CHANGED = "color general cambiado a %s."
    L.COLOR_USAGE = "uso: /shl color RRGGBB  (ejemplo: /shl color ffd24a)"
    L.RESET_MSG = "opciones restablecidas."
    L.DEBUG_ON = "modo depuración activado: pasa el ratón por un objeto."
    L.DEBUG_OFF = "modo depuración desactivado."
    L.DEBUG_HEADER = "tooltip=%s objeto=%s classID=%s"
    L.HELP_TITLE = "comandos:"
    L.HELP_MENU = "  /shl  - abrir o cerrar el menú"
    L.HELP_ONOFF = "  /shl on | off  - activar o desactivar"
    L.HELP_COLOR = "  /shl color RRGGBB  - color general"
    L.HELP_RESET = "  /shl reset  - restablecer opciones"
    L.HELP_DEBUG = "  /shl debug  - mostrar el texto de los tooltips en el chat"

    L.ENABLED = "Activado"
    L.GENERAL_COLOR = "Color general:"
    L.GENERAL_COLOR_HELP = "Color para todas las estadísticas que no tengan uno propio."
    L.RESET_ALL = "Restablecer todo"

    L.SECTION_WHERE = "Dónde resaltar"
    L.TYPE_CONSUMABLE = "Consumibles"
    L.TYPE_CONSUMABLE_HELP = "Comida, bebida, pociones, elixires, pergaminos, vendas..."
    L.TYPE_OTHER = "Hoguera y otros objetos con efecto"
    L.TYPE_OTHER_HELP = "Objetos que no son consumibles pero tienen una línea \"Usar:\" o se echan a la hoguera para obtener un beneficio."
    L.TYPE_GEAR = "Equipo"
    L.TYPE_GEAR_HELP = "Armas y armaduras (bonificaciones como \"+10 Aguante\"). Desactivado por defecto."

    L.SECTION_DURATION = "Duración del efecto"
    L.DURATION_CHECK = "Resaltar duraciones  (durante 30 min, 1 h, 10 s...)"
    L.DURATION_TITLE = "Duraciones"
    L.DURATION_HELP = "Resalta cuánto dura el efecto. No resalta tiempos de reutilización ni intervalos (\"cada 5 s\")."
    L.DURATION_COLOR_TITLE = "Color de las duraciones"
    L.DURATION_COLOR_HELP = "Clic: elegir color.\nClic derecho: volver al color por defecto (azul claro)."

    L.SECTION_BACKGROUND = "Fondo del tooltip"
    L.BG_CHECK = "Fondo más opaco"
    L.BG_HELP = "Hace que el fondo de los tooltips sea menos transparente, con su mismo color. Desactivado, se usa el del juego."
    L.BG_OPACITY = "Opacidad"
    L.BG_OPACITY_HELP = "0% = el fondo normal del juego.\n100% = totalmente sólido, no se ve el mundo del juego a través."

    L.SECTION_STATS = "Estadísticas"
    L.STATS_HINT = "Casilla: activar.  Cuadro de color: clic = color propio, clic derecho = color general."
    L.STAT_OWN_COLOR = "Tiene color propio."
    L.STAT_GENERAL_COLOR = "Usa el color general."
    L.STAT_COLOR_HELP = "\nClic: elegir color propio.\nClic derecho: volver al color general."

    L.PANEL_DESC = "Resalta estadísticas, cantidades y duraciones en los tooltips de objetos.\nTodas las opciones están en la ventana de StatHighlight (también con /shl)."
    L.PANEL_OPEN = "Abrir opciones de StatHighlight"
end

local MAX_GAP = 45 -- max bytes between a stat name and its amount

------------------------------------------------------------------------
-- Stat categories
-- Each category can be turned on/off and have its own color.
-- Names are lowercase (with and without accents, Spanish and English).
------------------------------------------------------------------------
local CATEGORIES = {
    { key = "health", label = "Health", es = "Salud", names = {
        "salud", "salud máxima", "salud maxima", "puntos de salud",
        "health", "max health", "maximum health" } },
    { key = "mana", label = "Mana", es = "Maná", names = {
        "maná", "mana", "maná máximo", "mana maximo", "puntos de maná",
        "maximum mana" } },
    { key = "power", label = "Rage / energy", es = "Ira / energía", names = {
        "ira", "energía", "energia", "rage", "energy" } },
    { key = "stamina", label = "Stamina", es = "Aguante", names = { "aguante", "stamina" } },
    { key = "spirit", label = "Spirit", es = "Espíritu", names = { "espíritu", "espiritu", "spirit" } },
    { key = "strength", label = "Strength", es = "Fuerza", names = { "fuerza", "strength" } },
    { key = "agility", label = "Agility", es = "Agilidad", names = { "agilidad", "agility" } },
    { key = "intellect", label = "Intellect", es = "Intelecto", names = { "intelecto", "intellect" } },
    { key = "allstats", label = "All stats", es = "Todos los atributos", names = {
        "todos los atributos", "todas las estadísticas", "todas las estadisticas",
        "todas tus estadísticas", "todas tus estadisticas", "todos tus atributos",
        "all stats", "all attributes",
        -- Generic: "un 8% más de estadísticas", "8% more stats". They are
        -- only highlighted next to an amount.
        "estadísticas", "estadisticas", "atributos", "stats", "attributes" } },
    { key = "armor", label = "Armor", es = "Armadura", names = {
        "armadura", "valor de armadura", "armor", "armour" } },
    { key = "defense", label = "Defense", es = "Defensa", names = {
        "defensa", "índice de defensa", "indice de defensa", "habilidad de defensa",
        "defense", "defense rating", "defense skill" } },
    { key = "attackpower", label = "Attack power", es = "Poder de ataque", names = {
        "poder de ataque", "poder de ataque a distancia",
        "attack power", "ranged attack power" } },
    { key = "spellpower", label = "Spell power", es = "Poder con hechizos", names = {
        "poder con hechizos", "poder de hechizo", "poder de hechizos",
        "daño con hechizos", "daño de hechizos", "daño mágico", "daño magico",
        "daño y curación", "daño y curacion", "daño y sanación",
        "spell power", "spell damage", "damage and healing", "healing and damage" } },
    { key = "healing", label = "Healing", es = "Curación", names = {
        "curación", "curacion", "sanación", "sanacion", "healing" } },
    { key = "damage", label = "Damage", es = "Daño", names = {
        "daño", "daño de fuego", "daño de escarcha", "daño de sombras",
        "daño de naturaleza", "daño arcano", "daño físico", "daño fisico",
        "damage", "fire damage", "frost damage", "shadow damage",
        "nature damage", "arcane damage", "physical damage" } },
    { key = "regen", label = "Regeneration", es = "Regeneración", names = {
        "regeneración de maná", "regeneracion de mana",
        "regeneración de salud", "regeneracion de salud",
        "mana regeneration", "health regeneration" } },
    { key = "resist", label = "Resistances", es = "Resistencias", names = {
        "resistencia al fuego", "resistencia a la escarcha", "resistencia a la naturaleza",
        "resistencia a las sombras", "resistencia a la sombra", "resistencia arcana",
        "resistencia a lo arcano", "todas las resistencias", "resistencia a todo",
        "resistencias", "resistencia",
        "fire resistance", "frost resistance", "nature resistance",
        "shadow resistance", "arcane resistance", "all resistances", "resistance" } },
    { key = "crit", label = "Critical strike", es = "Golpe crítico", names = {
        "golpe crítico", "golpe critico", "índice de golpe crítico", "indice de golpe critico",
        "golpe crítico con hechizos", "golpe critico con hechizos",
        "probabilidad de golpe crítico", "probabilidad de golpe critico",
        "critical strike", "critical strike rating", "critical strike chance",
        "crit rating", "crit" } },
    { key = "hit", label = "Hit", es = "Índice de golpe", names = {
        "índice de golpe", "indice de golpe", "probabilidad de golpe",
        "índice de golpe con hechizos", "indice de golpe con hechizos",
        "hit rating", "hit chance", "chance to hit" } },
    { key = "haste", label = "Haste / attack speed", es = "Celeridad / vel. ataque", names = {
        "celeridad", "índice de celeridad", "indice de celeridad",
        "velocidad de ataque", "velocidad de lanzamiento",
        "haste", "haste rating", "attack speed", "casting speed" } },
    { key = "speed", label = "Movement speed", es = "Velocidad de movimiento", names = {
        "velocidad de movimiento", "velocidad de carrera", "velocidad de nado",
        "velocidad", "movement speed", "run speed", "swim speed" } },
    { key = "avoidance", label = "Dodge / parry / block", es = "Esquivar / parada / bloqueo", names = {
        "esquivar", "índice de esquivar", "indice de esquivar",
        "parada", "parar", "índice de parada", "indice de parada",
        "bloqueo", "bloquear", "índice de bloqueo", "indice de bloqueo",
        "valor de bloqueo", "dodge", "parry", "block", "block value" } },
    { key = "expertise", label = "Expertise / mastery / other", es = "Pericia / maestría / otros", names = {
        "pericia", "índice de pericia", "indice de pericia",
        "maestría", "maestria", "índice de maestría", "indice de maestria",
        "penetración de armadura", "penetracion de armadura",
        "penetración de hechizos", "penetracion de hechizos",
        "temple", "resiliencia",
        "expertise", "mastery", "mastery rating", "armor penetration",
        "spell penetration", "resilience" } },
    { key = "skill", label = "Profession skill", es = "Habilidad de profesión", names = {
        "habilidad en pesca", "habilidad de pesca", "pesca",
        "habilidad en herboristería", "habilidad en herboristeria", "herboristería",
        "habilidad en minería", "habilidad en mineria", "minería",
        "habilidad en desuello", "desuello",
        "fishing", "fishing skill", "herbalism", "mining", "skinning" } },
    { key = "experience", label = "Experience", es = "Experiencia", names = {
        "experiencia", "experience" } },
}

-- Flat list of names, longest first.
local NAME_LIST = {}
for _, cat in ipairs(CATEGORIES) do
    for _, name in ipairs(cat.names) do
        NAME_LIST[#NAME_LIST + 1] = { name = name, key = cat.key }
    end
end
table.sort(NAME_LIST, function(a, b) return #a.name > #b.name end)

-- Stat names shown in the menu follow the interface language.
if IS_SPANISH then
    for _, cat in ipairs(CATEGORIES) do cat.label = cat.es or cat.label end
end

local function MakeSet(list)
    local set = {}
    for _, w in ipairs(list) do set[w] = true end
    return set
end

-- Words allowed between an amount and the name: "6 p. de tu aguante",
-- "12 p. más de intelecto", "un 8% más de estadísticas", "8% more stats".
local CONNECTORS = MakeSet({
    "de", "del", "tu", "su", "tus", "sus", "el", "la", "los", "las",
    "a", "al", "en", "your", "of", "the",
    "más", "mas", "extra", "adicional", "adicionales",
    "more", "additional", "bonus" })

-- Words allowed between the name and an amount that comes after it:
-- "aguante aumentará 12 p.", "Stamina by 12", "experiencia obtenida al
-- matar enemigos aumenta un 5%". Any other word (e.g. "durante"/"for")
-- means the number does not belong to the stat.
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
    "monsters", "enemies",
    -- Who is affected: "Aumenta el Intelecto del objetivo en 8 p.",
    -- "Increases the target's Intellect by 8", "de los miembros del grupo cercanos".
    "objetivo", "objetivos", "aliado", "aliados", "lanzador", "usuario",
    "jugador", "jugadores", "personaje", "miembro", "miembros", "grupo",
    "banda", "cercano", "cercanos", "cercanas", "todos", "todas",
    "target", "target's", "targets", "ally", "allies", "caster", "party",
    "raid", "member", "members", "nearby", "all", "friendly", "player",
    "players", "allied" })

------------------------------------------------------------------------
-- Durations: "durante 30 min", "1 h 30 min", "for 10 sec"...
------------------------------------------------------------------------
-- Time units, longest first (lowercase).
local TIME_UNITS = {
    "segundos", "segundo", "minutos", "minuto", "horas", "hora",
    "días", "dias", "día", "dia",
    "seconds", "second", "minutes", "minute", "hours", "hour", "days", "day",
    "secs", "sec", "seg", "mins", "min", "hrs", "hr", "s", "h",
}

-- If one of these words comes right before the number it is an interval,
-- not a duration: "5 p. de maná cada 5 s", "every 5 sec".
local INTERVAL_WORDS = MakeSet({ "cada", "every", "per", "por" })

-- If one of these appears shortly before, it is a cooldown.
local COOLDOWN_WORDS = { "reutilización", "reutilizacion", "recarga", "cooldown" }

-- Words that join two stats: "aguante y espíritu", "Stamina and Spirit".
local CHAIN_WORDS = MakeSet({
    "y", "e", "and", "tu", "su", "el", "la", "los", "las", "your", "&" })

------------------------------------------------------------------------
-- Saved options
------------------------------------------------------------------------
local DEFAULT_COLOR = { r = 1, g = 0.824, b = 0.290 }      -- ffd24a gold
local DURATION_COLOR = { r = 0.400, g = 0.800, b = 1 }      -- 66ccff light blue
local DURATION_KEY = "duration"

local db -- StatHighlightDB once loaded
local settingsVersion = 1

local function CopyColor(c) return { r = c.r, g = c.g, b = c.b } end

-- Where to highlight, by item type.
local function DefaultTypes()
    return {
        consumable = true, -- food, potions, elixirs, scrolls...
        other = true,      -- bonfire items and others with a Use: effect
        gear = false,      -- weapons and armor
    }
end

-- Solid tooltip background. Off by default: the game's own look is kept.
-- alpha = how solid the extra layer is (0 = game's background, 1 = solid).
local function DefaultBackground()
    return { enabled = false, alpha = 1 }
end

local function ResetDB()
    StatHighlightDB = {
        enabled = true,
        types = DefaultTypes(),
        background = DefaultBackground(),
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
    if type(db.types) ~= "table" then
        db.types = DefaultTypes()
        -- Version 1.0.0: "Consumables only" turned off = highlight everything.
        if db.consumablesOnly == false then db.types.gear = true end
    end
    db.consumablesOnly = nil
    if type(db.color) ~= "table" then db.color = CopyColor(DEFAULT_COLOR) end
    if type(db.stats) ~= "table" then db.stats = {} end
    if type(db.background) ~= "table" then db.background = DefaultBackground() end
    if type(db.background.alpha) ~= "number" then db.background.alpha = 1 end
    db.background.alpha = math.max(0, math.min(1, db.background.alpha))
    -- Unreleased builds saved "glow" and "bold"; both were removed.
    for _, s in pairs(db.stats) do
        if type(s) == "table" then s.glow, s.bold = nil, nil end
    end
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
    if key == DURATION_KEY then return DURATION_COLOR end
    return (db and db.color) or DEFAULT_COLOR
end

local function ColorCode(c)
    return string.format("|cff%02x%02x%02x",
        math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
end

------------------------------------------------------------------------
-- Text detection
------------------------------------------------------------------------

-- string.lower does not lowercase accented capitals (UTF-8). Each pair has
-- the same byte length, so positions in the original text still match.
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

-- ASCII letter or a byte of a UTF-8 character (accented letters).
local function IsLetterByte(b)
    if not b then return false end
    return b >= 128 or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
end

local function IsSpace(text, pos)
    local c = string.sub(text, pos, pos)
    return c == " " or c == "\t" or c == "\n" or c == "\r"
end

-- Checks that every word in the gap is in the allowed list.
local function GapWordsAllowed(gapLower, allowed)
    local cleaned = string.gsub(gapLower, "[:,;%(%)%+]", " ")
    for word in string.gmatch(cleaned, "%S+") do
        if not allowed[word] then return false end
    end
    return true
end

-- Amount before the name: "15 p. de aguante", "70 a 90 p. de salud",
-- "530 health", "+10 Aguante". Returns the start position.
local function FindAmountBefore(text, lowerText, s)
    local pos = s - 1
    local function trim()
        while pos > 0 and IsSpace(text, pos) do pos = pos - 1 end
    end
    trim()

    -- Up to three joining words ("más de tu").
    for _ = 1, 3 do
        local prefix = string.sub(lowerText, 1, pos)
        local w1 = string.find(prefix, "[%a\128-\255]+$")
        if w1 and CONNECTORS[string.sub(prefix, w1)] then
            pos = w1 - 1
            trim()
        else
            break
        end
    end

    -- Optional "p.", "puntos", "points" or "%".
    local prefix = string.sub(lowerText, 1, pos)
    if string.sub(prefix, -1) == "%" then
        pos = pos - 1
        trim()
    elseif string.sub(prefix, -2) == "p." and not IsLetterByte(string.byte(prefix, #prefix - 2)) then
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

    -- Range: "70 a 90", "70 to 90", "70-90".
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

-- Amount after the name: "aguante 15 p.", "Stamina by 12",
-- "espíritu: 10", "experiencia ... aumenta un 5%". Returns the end position.
local function FindAmountAfter(text, lowerText, e)
    local after = string.sub(text, e + 1, e + MAX_GAP + 25)
    local gap, number = string.match(after, "^([^%d]-)(%d[%d%.,]*)")
    if not gap or gap == "" or #gap > MAX_GAP then return end
    -- Do not cross the end of a sentence or an escape code (|c, |T, |H...).
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

-- Returns a list of non-overlapping spans { start, end, category }.
local function FindStatSpans(text)
    local lowerText = Normalize(text)

    -- 1) Find every name (longer names win).
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

    -- 2) Find the amount of each name (before or after it).
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

    -- 3) Chained stats without their own amount:
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

-- "30 min", "10 s", "1 hora": number + time unit starting at pos.
-- Returns the end position or nil.
local function MatchTimeAt(lowerText, pos)
    local numStart, numEnd = string.find(lowerText, "^%d[%d%.,]*", pos)
    if not numStart then return end
    -- "1.5" and "1,5" are fine; a trailing dot or comma is not part of the number.
    while string.find(string.sub(lowerText, numEnd, numEnd), "[%.,]") do
        numEnd = numEnd - 1
    end
    local unitPos = numEnd + 1
    while IsSpace(lowerText, unitPos) do unitPos = unitPos + 1 end
    for _, unit in ipairs(TIME_UNITS) do
        local uEnd = unitPos + #unit - 1
        if string.sub(lowerText, unitPos, uEnd) == unit
            and not IsLetterByte(string.byte(lowerText, uEnd + 1)) then
            return uEnd
        end
    end
end

-- Duration spans { start, end, DURATION_KEY } that do not overlap the stat
-- spans. "1 h 30 min" or "1 h y 30 min" form a single span.
local function FindDurationSpans(text, lowerText, taken)
    local spans = {}
    local from = 1
    while true do
        local s = string.find(lowerText, "%d", from)
        if not s then break end
        local prevByte = s > 1 and string.byte(lowerText, s - 1) or nil
        local isWordStart = not (prevByte and (IsLetterByte(prevByte)
            or (prevByte >= 48 and prevByte <= 57) or prevByte == 46 or prevByte == 44))
        local finish = isWordStart and MatchTimeAt(lowerText, s)
        if finish then
            -- Chain: "1 h 30 min", "1 h y 30 min", "2 min, 30 s".
            while true do
                local link = string.match(string.sub(lowerText, finish + 1), "^%s*,?%s*y?%s*")
                    or ""
                local nextStart = finish + #link + 1
                local nextFinish = #link > 0 and MatchTimeAt(lowerText, nextStart)
                if not nextFinish then break end
                finish = nextFinish
            end

            local before = string.sub(lowerText, math.max(1, s - 45), s - 1)
            local lastWord = string.match(before, "([%a\128-\255]+)%s*$")
            local skip = lastWord and INTERVAL_WORDS[lastWord]
            if not skip then
                for _, w in ipairs(COOLDOWN_WORDS) do
                    if string.find(before, w, 1, true) then skip = true break end
                end
            end
            if not skip then
                for _, t in ipairs(taken) do
                    if s <= t[2] and finish >= t[1] then skip = true break end
                end
            end
            if not skip then spans[#spans + 1] = { s, finish, DURATION_KEY } end
            from = finish + 1
        else
            local _, numEnd = string.find(lowerText, "^%d[%d%.,]*", s)
            from = (numEnd or s) + 1
        end
    end
    return spans
end

-- Stats + durations, sorted and non-overlapping.
local function StripColorCodes(lowerText)
    return (string.gsub(string.gsub(lowerText, "|c%x%x%x%x%x%x%x%x", ""), "|r", ""))
end

-- Requirement lines ("Requiere Pesca (20)", "Requires Level 40") are not
-- bonuses, so nothing in them is highlighted.
local REQUIREMENT_PREFIXES = { "requiere", "requires", "requisito" }

local function IsRequirementLine(lowerText)
    local plain = StripColorCodes(lowerText)
    for _, prefix in ipairs(REQUIREMENT_PREFIXES) do
        if string.find(plain, "^%s*" .. prefix .. "[%s:]") then return true end
    end
    return false
end

local function FindAllSpans(text)
    if IsRequirementLine(Normalize(text)) then return {} end
    local spans = FindStatSpans(text)
    if IsCategoryEnabled(DURATION_KEY) and string.find(text, "%d") then
        local durations = FindDurationSpans(text, Normalize(text), spans)
        if #durations > 0 then
            for _, d in ipairs(durations) do spans[#spans + 1] = d end
            table.sort(spans, function(a, b) return a[1] < b[1] end)
        end
    end
    return spans
end

------------------------------------------------------------------------
-- Applying color
------------------------------------------------------------------------

-- Inline color (|cAARRGGBB) still open at position pos, if any.
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
        -- If the sentence already had its own color, restore it after the highlight.
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

-- Each line remembers its original text and the highlight we applied,
-- so color is never applied twice and lines can be redrawn when options change.
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
    if result[1] then return result[7] end -- itemID, type, subtype, equip slot, icon, classID
end

local CONSUMABLE_CLASS = 0
local WEAPON_CLASS = 2
local ARMOR_CLASS = 4
local lastDebugKey

-- Text showing that a (non-consumable) item has an effect:
-- a "Use:" line, or that it is thrown into a bonfire.
local EFFECT_MARKERS = {
    "usar:", "use:", "hoguera", "fogata", "fuego de campamento",
    "campfire", "bonfire",
}

local function TooltipHasEffect(regions)
    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            local t = region:GetText()
            if type(t) == "string" and t ~= "" then
                local lower = Normalize(t)
                for _, marker in ipairs(EFFECT_MARKERS) do
                    if string.find(lower, marker, 1, true) then return true end
                end
            end
        end
    end
    return false
end

-- Decides whether this item is highlighted, based on its type and the options.
local function ItemAllowed(classID, regions)
    local types = db.types
    if classID == nil then return true end -- unknown type: do not filter
    if classID == CONSUMABLE_CLASS then return types.consumable end
    if classID == WEAPON_CLASS or classID == ARMOR_CLASS then return types.gear end
    return types.other and TooltipHasEffect(regions)
end

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
    print("|cffffd24a[StatHighlight debug]|r " .. string.format(L.DEBUG_HEADER,
        tostring(tooltip.GetName and tooltip:GetName()), tostring(item), tostring(classID)))
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

    local allowed = db.enabled and ItemAllowed(classID, regions)

    for _, region in ipairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if type(text) == "string" and text ~= "" then
                local ours = highlighted[region] == text
                if not (ours and regionVersion[region] == settingsVersion and allowed) then
                    if ours then text = originals[region] end

                    local spans = allowed and FindAllSpans(text) or {}
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

-- Hook in every available way: some tooltips (bags, vendor...) do not go
-- through all of them, and the "Use:" line sometimes arrives late.
-- Applying the highlight twice is safe.
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

------------------------------------------------------------------------
-- Tooltip background
-- The game's background texture is see-through even at full alpha, so
-- the game's own background is left untouched and a solid layer in the
-- same color is added over it (under the border and the text). The
-- slider sets how opaque that layer is: 0% = the game's background,
-- 100% = fully solid.
------------------------------------------------------------------------
local FALLBACK_BACKGROUND = { 0.09, 0.09, 0.19 } -- the game's usual tooltip color
local backgroundLayers = setmetatable({}, { __mode = "k" })

-- Color the game currently uses for this tooltip's background.
local function BackgroundColor(tooltip, center)
    local r, g, b
    if center and center.GetVertexColor then
        r, g, b = center:GetVertexColor()
    elseif tooltip.GetBackdropColor then
        r, g, b = tooltip:GetBackdropColor()
    end
    if type(r) ~= "number" then return unpack(FALLBACK_BACKGROUND) end
    return r, g, b
end

local function ApplyTooltipBackground(tooltip)
    if not db or not tooltip then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end
    local layer = backgroundLayers[tooltip]
    local strength = db.background.enabled and db.background.alpha or 0
    if strength <= 0 then
        if layer then layer:Hide() end
        return
    end

    local center = tooltip.NineSlice and tooltip.NineSlice.Center
    if not layer then
        -- On the NineSlice frame, just above its center piece; otherwise on
        -- the tooltip itself, above the old-style backdrop.
        local host = (center and tooltip.NineSlice.CreateTexture) and tooltip.NineSlice or tooltip
        if not host.CreateTexture then return end
        layer = host:CreateTexture(nil, "BACKGROUND", nil, host == tooltip and 7 or -7)
        layer:ClearAllPoints()
        if center and host ~= tooltip then
            layer:SetAllPoints(center)
        else
            layer:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 3, -3)
            layer:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", -3, 3)
        end
        backgroundLayers[tooltip] = layer
    end
    local r, g, b = BackgroundColor(tooltip, center)
    layer:SetColorTexture(r, g, b, strength)
    layer:Show()
end

-- The game resets the background style when a tooltip is set up again.
for _, styleFunc in ipairs({ "GameTooltip_SetBackdropStyle", "SharedTooltip_SetBackdropStyle" }) do
    if hooksecurefunc and type(_G[styleFunc]) == "function" then
        hooksecurefunc(styleFunc, function(tooltip) ApplyTooltipBackground(tooltip) end)
    end
end

local function ApplyBackgroundToAll()
    for _, name in ipairs(TOOLTIPS) do
        local frame = _G[name]
        if frame then ApplyTooltipBackground(frame) end
    end
end

for _, name in ipairs(TOOLTIPS) do
    local frame = _G[name]
    if frame and frame.HookScript then
        if frame.HasScript and frame:HasScript("OnTooltipSetItem") then
            frame:HookScript("OnTooltipSetItem", function(self) HighlightTooltip(self) end)
        end
        frame:HookScript("OnShow", function(self)
            ApplyTooltipBackground(self)
            if TooltipShowsItem(self) then HighlightTooltip(self) end
        end)
        -- Re-check every 0.2 s while visible (text that arrives late).
        local elapsed = 0
        frame:HookScript("OnUpdate", function(self, dt)
            elapsed = elapsed + (dt or 0)
            if elapsed < 0.2 then return end
            elapsed = 0
            ApplyTooltipBackground(self)
            if TooltipShowsItem(self) then HighlightTooltip(self) end
        end)
    end
end

-- The game refreshes some item tooltips several times per second (bags,
-- items with a cooldown...), rewriting their text without color. If the
-- highlight only came back on the next 0.2 s check, it would flicker.
-- So the highlight is also applied right after every method that fills
-- the tooltip, before the frame is drawn.
local function IsFillMethod(name)
    return name == "Show" or name == "SetHyperlink" or name == "SetItemByID"
        or name == "SetAction"
        or (string.find(name, "^Set") ~= nil and string.find(name, "Item$") ~= nil)
end

local function HookFillMethods(frame)
    if not hooksecurefunc then return end
    local meta = getmetatable(frame)
    local methods = meta and meta.__index
    local names = {}
    if type(methods) == "table" then
        for name, fn in pairs(methods) do
            if type(name) == "string" and type(fn) == "function" and IsFillMethod(name) then
                names[#names + 1] = name
            end
        end
    end
    for name, fn in pairs(frame) do
        if type(name) == "string" and type(fn) == "function" and IsFillMethod(name) then
            names[#names + 1] = name
        end
    end
    local hooked = {}
    for _, name in ipairs(names) do
        if not hooked[name] then
            hooked[name] = true
            hooksecurefunc(frame, name, function(self)
                if TooltipShowsItem(self) then HighlightTooltip(self) end
            end)
        end
    end
end

for _, name in ipairs(TOOLTIPS) do
    local frame = _G[name]
    if frame then HookFillMethods(frame) end
end

------------------------------------------------------------------------
-- Options window
------------------------------------------------------------------------
local optionsFrame
local RefreshOptions

local function OnSettingsChanged()
    settingsVersion = settingsVersion + 1
    ApplyBackgroundToAll()
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

local function AttachHelp(widget, title, line)
    widget:SetScript("OnEnter", function(self) ShowHelpTooltip(self, title, line) end)
    widget:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Section title with a thin line up to the right edge.
local function CreateSection(parent, text, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 16, y)
    label:SetText(text)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.15)
    line:SetHeight(1)
    line:SetPoint("LEFT", label, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    return label
end

-- 0-100 slider. Uses the game's template when it exists, otherwise a
-- plain slider so the window still works.
local function CreateSlider(parent, name)
    local ok, slider = pcall(CreateFrame, "Slider", name, parent, "OptionsSliderTemplate")
    if not ok or not slider then
        slider = CreateFrame("Slider", name, parent)
        slider:SetOrientation("HORIZONTAL")
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local track = slider:CreateTexture(nil, "BACKGROUND")
        track:SetColorTexture(0.25, 0.25, 0.25, 0.9)
        track:SetPoint("LEFT")
        track:SetPoint("RIGHT")
        track:SetHeight(6)
    end
    slider:SetSize(160, 16)
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(5)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    -- The template's own labels are not used.
    for _, suffix in ipairs({ "Low", "High", "Text" }) do
        local label = slider[suffix] or _G[name .. suffix]
        if type(label) == "table" and label.SetText then label:SetText("") end
    end
    return slider
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
    f:SetSize(560, 618)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    tinsert(UISpecialFrames, "StatHighlightOptionsFrame") -- closes with Esc

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -6)
    title:SetText("StatHighlight")

    -- 1) General ---------------------------------------------------------
    CreateSection(f, L.SECTION_GENERAL, -32)

    local enabled = CreateCheck(f, L.ENABLED)
    enabled:SetPoint("TOPLEFT", 16, -50)
    enabled:SetScript("OnClick", function(self)
        db.enabled = self:GetChecked() and true or false
        OnSettingsChanged()
    end)

    local generalLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    generalLabel:SetPoint("TOPLEFT", 150, -55)
    generalLabel:SetText(L.GENERAL_COLOR)

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
    AttachHelp(generalSwatch, L.GENERAL_COLOR, L.GENERAL_COLOR_HELP)

    local resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 22)
    resetButton:SetPoint("TOPRIGHT", -20, -50)
    resetButton:SetText(L.RESET_ALL)
    resetButton:SetScript("OnClick", function()
        ResetDB()
        OnSettingsChanged()
        print("|cffffd24aStatHighlight|r: " .. L.RESET_MSG)
    end)

    -- 2) Where to highlight ----------------------------------------------
    CreateSection(f, L.SECTION_WHERE, -84)

    local TYPE_OPTIONS = {
        { key = "consumable", x = 16, label = L.TYPE_CONSUMABLE,
          help = L.TYPE_CONSUMABLE_HELP },
        { key = "other", x = 150, label = L.TYPE_OTHER,
          help = L.TYPE_OTHER_HELP },
        { key = "gear", x = 420, label = L.TYPE_GEAR,
          help = L.TYPE_GEAR_HELP },
    }
    local typeChecks = {}
    for _, opt in ipairs(TYPE_OPTIONS) do
        local check = CreateCheck(f, opt.label)
        check:SetPoint("TOPLEFT", opt.x, -102)
        check:SetScript("OnClick", function(self)
            db.types[opt.key] = self:GetChecked() and true or false
            OnSettingsChanged()
        end)
        AttachHelp(check, opt.label, opt.help)
        typeChecks[opt.key] = check
    end

    -- 3) Durations -------------------------------------------------------
    CreateSection(f, L.SECTION_DURATION, -136)

    local durationCheck = CreateCheck(f, L.DURATION_CHECK)
    durationCheck:SetPoint("TOPLEFT", 16, -154)
    durationCheck:SetScript("OnClick", function(self)
        StatSettings(DURATION_KEY).enabled = self:GetChecked() and true or false
        OnSettingsChanged()
    end)
    AttachHelp(durationCheck, L.DURATION_TITLE, L.DURATION_HELP)

    local durationSwatch = CreateSwatch(f)
    durationSwatch:SetPoint("LEFT", durationCheck.label, "RIGHT", 10, 0)
    durationSwatch:SetScript("OnClick", function(self, button)
        local s = StatSettings(DURATION_KEY)
        if button == "RightButton" then
            s.color = nil
            OnSettingsChanged()
            return
        end
        local previous = s.color and CopyColor(s.color) or nil
        OpenColorPicker(EffectiveColor(DURATION_KEY), function(c)
            s.color = c
            OnSettingsChanged()
        end, function()
            s.color = previous
            OnSettingsChanged()
        end)
    end)
    AttachHelp(durationSwatch, L.DURATION_COLOR_TITLE, L.DURATION_COLOR_HELP)

    -- 4) Tooltip background ----------------------------------------------
    CreateSection(f, L.SECTION_BACKGROUND, -188)

    local bgCheck = CreateCheck(f, L.BG_CHECK)
    bgCheck:SetPoint("TOPLEFT", 16, -206)
    bgCheck:SetScript("OnClick", function(self)
        db.background.enabled = self:GetChecked() and true or false
        OnSettingsChanged()
    end)
    AttachHelp(bgCheck, L.SECTION_BACKGROUND, L.BG_HELP)

    local bgSlider = CreateSlider(f, "StatHighlightOpacitySlider")
    bgSlider:SetPoint("TOPLEFT", 300, -211)
    local bgValue = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bgValue:SetPoint("LEFT", bgSlider, "RIGHT", 10, 0)
    local refreshing = false
    bgSlider:SetScript("OnValueChanged", function(self, value)
        if refreshing then return end
        value = math.floor(value / 5 + 0.5) * 5
        db.background.alpha = value / 100
        OnSettingsChanged()
    end)
    AttachHelp(bgSlider, L.BG_OPACITY, L.BG_OPACITY_HELP)

    -- 5) Stats -----------------------------------------------------------
    CreateSection(f, L.SECTION_STATS, -240)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 20, -258)
    hint:SetText(L.STATS_HINT)

    local rows = {}
    local perColumn = math.ceil(#CATEGORIES / 2)
    for i, cat in ipairs(CATEGORIES) do
        local col = (i <= perColumn) and 0 or 1
        local rowIndex = (i - 1) % perColumn
        local x = 16 + col * 270
        local y = -276 - rowIndex * 25

        local check = CreateCheck(f, cat.label)
        check:SetPoint("TOPLEFT", x, y)
        check:SetScript("OnClick", function(self)
            StatSettings(cat.key).enabled = self:GetChecked() and true or false
            OnSettingsChanged()
        end)

        local swatch = CreateSwatch(f)
        swatch:SetPoint("TOPLEFT", x + 236, y - 2)
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
            local which = (s and s.color) and L.STAT_OWN_COLOR or L.STAT_GENERAL_COLOR
            ShowHelpTooltip(self, cat.label, which .. L.STAT_COLOR_HELP)
        end)
        swatch:SetScript("OnLeave", function() GameTooltip:Hide() end)

        rows[#rows + 1] = { key = cat.key, check = check, swatch = swatch }
    end
    -- The duration row is refreshed like a stat row.
    rows[#rows + 1] = { key = DURATION_KEY, check = durationCheck, swatch = durationSwatch }

    RefreshOptions = function()
        if not db then return end
        enabled:SetChecked(db.enabled)
        for key, check in pairs(typeChecks) do
            check:SetChecked(db.types[key])
        end

        local percent = math.floor(db.background.alpha * 100 + 0.5)
        bgCheck:SetChecked(db.background.enabled)
        refreshing = true
        bgSlider:SetValue(percent)
        refreshing = false
        bgValue:SetText(L.BG_OPACITY .. ": " .. percent .. "%")
        local bgOn = db.background.enabled
        bgSlider:EnableMouse(bgOn)
        bgSlider:SetAlpha(bgOn and 1 or 0.4)
        bgValue:SetAlpha(bgOn and 1 or 0.4)
        generalSwatch.fill:SetColorTexture(db.color.r, db.color.g, db.color.b, 1)
        for _, row in ipairs(rows) do
            local on = IsCategoryEnabled(row.key)
            local c = EffectiveColor(row.key)
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
-- Commands
-- Note: /sh cannot be used because WoW already uses it for /yell.
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
        Print(L.ENABLED_MSG)
    elseif cmd == "off" then
        db.enabled = false
        OnSettingsChanged()
        Print(L.DISABLED_MSG)
    elseif cmd == "color" then
        local hex = string.match(arg or "", "^#?(%x%x%x%x%x%x)$")
        if hex then
            db.color = {
                r = tonumber(string.sub(hex, 1, 2), 16) / 255,
                g = tonumber(string.sub(hex, 3, 4), 16) / 255,
                b = tonumber(string.sub(hex, 5, 6), 16) / 255,
            }
            OnSettingsChanged()
            Print(string.format(L.COLOR_CHANGED, ColorCode(db.color) .. hex .. "|r"))
        else
            Print(L.COLOR_USAGE)
        end
    elseif cmd == "reset" then
        ResetDB()
        OnSettingsChanged()
        Print(L.RESET_MSG)
    elseif cmd == "debug" then
        db.debug = not db.debug
        lastDebugKey = nil
        Print(db.debug and L.DEBUG_ON or L.DEBUG_OFF)
    else
        Print(L.HELP_TITLE)
        print(L.HELP_MENU)
        print(L.HELP_ONOFF)
        print(L.HELP_COLOR)
        print(L.HELP_RESET)
        print(L.HELP_DEBUG)
    end
end

------------------------------------------------------------------------
-- Loading
------------------------------------------------------------------------
local function OpenOptions()
    if not db then return end
    if not optionsFrame then optionsFrame = CreateOptionsFrame() end
    optionsFrame:Show()
    if optionsFrame.Raise then optionsFrame:Raise() end
end

-- Entry in Esc > Options > AddOns. All options live in the addon's own
-- window, so the page only explains that and opens it.
local function RegisterSettingsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "StatHighlight"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("StatHighlight")

    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetJustifyH("LEFT")
    desc:SetText(L.PANEL_DESC)

    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(220, 26)
    button:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -14)
    button:SetText(L.PANEL_OPEN)
    button:SetScript("OnClick", function()
        -- Close the game's options so the window is not hidden behind them.
        for _, frameName in ipairs({ "SettingsPanel", "InterfaceOptionsFrame", "GameMenuFrame" }) do
            local frame = _G[frameName]
            if frame and frame.IsShown and frame:IsShown() and HideUIPanel then HideUIPanel(frame) end
        end
        OpenOptions()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if name == ADDON_NAME then
        InitDB()
        local ok, err = pcall(RegisterSettingsPanel)
        if not ok and db.debug then Print("settings panel: " .. tostring(err)) end
        self:UnregisterEvent("ADDON_LOADED")
        Print(L.LOADED)
    end
end)

-- Internal access for the automated tests (tests/). Not used in game.
ns.InitDB = InitDB
ns.FindAllSpans = FindAllSpans
ns.BuildHighlighted = BuildHighlighted
ns.ItemAllowed = ItemAllowed
ns.L = L
ns.ApplyTooltipBackground = ApplyTooltipBackground
ns.HighlightTooltip = HighlightTooltip
ns.OnSettingsChanged = OnSettingsChanged
ns.HookFillMethods = HookFillMethods
ns.RegisterSettingsPanel = RegisterSettingsPanel

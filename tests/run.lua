-- Pruebas de la deteccion de StatHighlight fuera del juego (Lua 5.1).
-- Uso: lua5.1 tests/run.lua   (desde la raiz del repositorio)

-- Entorno minimo de WoW: cualquier metodo de un frame no hace nada.
local function Dummy()
    return setmetatable({}, { __index = function() return function() end end })
end
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
        print("::error::" .. name .. "\n  esperado: " .. tostring(expected) .. "\n  obtenido: " .. tostring(got))
    else
        print("ok  " .. name)
    end
end

local function Expect(text, expected)
    Check(text, Found(text), expected)
end

-- Estadisticas (lo que ya funcionaba en 1.0.0) -------------------------
Expect("Restaura 530 p. de salud durante 30 s.",
    "530 p. de salud=health | 30 s=duration")
Expect("ganarás 6 p. de aguante y espíritu durante 15 min.",
    "6 p. de aguante=stamina | espíritu=spirit | 15 min=duration")
Expect("Restores 30 health over 10 sec.",
    "30 health=health | 10 sec=duration")

-- Pergaminos -------------------------------------------------------------
Expect("Usar: Aumenta el Intelecto del objetivo 8 p. durante 30 min.",
    "Intelecto del objetivo 8 p.=intellect | 30 min=duration")
Expect("Usar: Aumenta el Intelecto del objetivo en 8 p. durante 30 min.",
    "Intelecto del objetivo en 8 p.=intellect | 30 min=duration")
Expect("Use: Increases the target's Intellect by 8 for 30 min.",
    "Intellect by 8=intellect | 30 min=duration")
Expect("Usar: Aumenta 8 p. el espíritu del objetivo durante 30 min.",
    "8 p. el espíritu=spirit | 30 min=duration")

-- Hoguera ------------------------------------------------------------------
Expect("Usar: Echa la leña a la hoguera. Los jugadores cercanos obtienen +5 de aguante durante 1 h.",
    "+5 de aguante=stamina | 1 h=duration")

-- Duraciones ---------------------------------------------------------------
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

-- Opciones: desactivar las duraciones -----------------------------------
StatHighlightDB.stats.duration = { enabled = false }
Expect("Restaura 530 p. de salud durante 30 s.", "530 p. de salud=health")
StatHighlightDB.stats.duration = nil

-- Resaltado con codigos de color -----------------------------------------
do
    local text = "|cff00ff00Usar: Restaura 10 p. de salud durante 5 s.|r"
    local out = ns.BuildHighlighted(text, ns.FindAllSpans(text))
    Check("color salud + restaurar verde", out,
        "|cff00ff00Usar: Restaura |cffffd24a10 p. de salud|r|cff00ff00 durante |cff66ccff5 s|r|cff00ff00.|r")
end

-- Tipos de objeto ----------------------------------------------------------
local function Region(t)
    return {
        GetObjectType = function() return "FontString" end,
        GetText = function() return t end,
    }
end
local useLine = { Region("Leña de roble"), Region("Usar: Echa la leña a la hoguera.") }
local plain = { Region("Cuero ligero"), Region("Objeto comerciable") }
local bonfire = { Region("Ofrenda"), Region("Se puede quemar en una hoguera.") }

Check("consumible", ns.ItemAllowed(0, plain), true)
Check("arma (equipo desactivado)", ns.ItemAllowed(2, useLine), false)
Check("armadura (equipo desactivado)", ns.ItemAllowed(4, plain), false)
Check("otro con Usar:", ns.ItemAllowed(15, useLine), true)
Check("otro que va a la hoguera", ns.ItemAllowed(12, bonfire), true)
Check("otro sin efecto", ns.ItemAllowed(7, plain), false)
Check("tipo desconocido", ns.ItemAllowed(nil, plain), true)
StatHighlightDB.types.gear = true
Check("armadura (equipo activado)", ns.ItemAllowed(4, plain), true)
StatHighlightDB.types.other = false
Check("otro con Usar: (opcion desactivada)", ns.ItemAllowed(15, useLine), false)

-- Migracion desde 1.0.0 ---------------------------------------------------
StatHighlightDB = { enabled = true, consumablesOnly = false, color = { r = 1, g = 1, b = 1 }, stats = {} }
ns.InitDB()
Check("migración: solo consumibles desactivado -> equipo", StatHighlightDB.types.gear, true)
Check("migración: borra consumablesOnly", StatHighlightDB.consumablesOnly, nil)
StatHighlightDB = { enabled = true, consumablesOnly = true }
ns.InitDB()
Check("migración: solo consumibles activado -> sin equipo", StatHighlightDB.types.gear, false)

print(string.format("\n%d pruebas, %d fallos", total, failures))
if failures > 0 then os.exit(1) end

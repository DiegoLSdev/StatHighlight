# StatHighlight

Addon para **WoW Forever** (1.60.1, Interface 16001) que resalta en color el nombre de una estadística, la cantidad asociada y la duración del efecto en los tooltips de objetos: consumibles (comida, pociones, elixires, pergaminos…) y objetos que se echan a la hoguera o tienen un efecto de uso. No modifica objetos ni habilidades.

> Ejemplo: *"Restaura 530 p. de salud … ganarás 6 p. de aguante y espíritu durante 15 min"*
> → se resaltan **530 p. de salud**, **6 p. de aguante** y **espíritu** (dorado) y **15 min** (azul claro).

## Descarga e instalación

1. Descarga `StatHighlight-vX.Y.Z.zip` desde la página de [Releases](../../releases/latest).
2. Cierra WoW Forever.
3. Descomprime el zip dentro de `_forever_\Interface\AddOns\`. Debe quedar así:

   ```
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.toc
   _forever_\Interface\AddOns\StatHighlight\StatHighlight.lua
   ```

   > ⚠️ No descargues el botón verde **Code → Download ZIP**: ese zip crea una carpeta `StatHighlight-main` y el juego no la reconoce. Usa siempre el zip de *Releases*.

4. Abre el juego. En la selección de personaje, entra en **AddOns** y comprueba que StatHighlight está activado.
5. Entra con tu personaje y pasa el ratón por encima de una comida o poción.

Si el juego marca el addon como *desactualizado*, activa la opción **Cargar addons desactualizados** en la lista de AddOns.

## Estadísticas reconocidas (español e inglés)

Salud, maná, ira/energía, aguante, espíritu, fuerza, agilidad, intelecto, todos los atributos, armadura, defensa, poder de ataque, poder/daño con hechizos, curación, daño (y absorción de daño), regeneración, resistencias, golpe crítico, índice de golpe, celeridad/velocidad de ataque, velocidad de movimiento, esquivar/parada/bloqueo, pericia/maestría/penetración, habilidad de profesión (pesca…) y experiencia.

## Menú y comandos

| Comando | Descripción |
|---|---|
| `/shl` | Abre o cierra el menú de opciones |
| `/shl on` \| `off` | Activa o desactiva el resaltado |
| `/shl color RRGGBB` | Cambia el color general (ejemplo: `/shl color ffd24a`) |
| `/shl reset` | Restablece todas las opciones |
| `/shl debug` | Escribe en el chat el texto de cada tooltip (útil si alguna línea no se resalta) |
| `/stathighlight` | Igual que `/shl` |

> `/sh` no se puede usar porque WoW ya lo usa para gritar (`/yell`).

El menú tiene cuatro secciones:

- **General**: *Activado*, *Color general* (clic en el cuadro) y *Restablecer todo*.
- **Dónde resaltar**:
  - *Consumibles*: comida, bebida, pociones, elixires, pergaminos… (activado).
  - *Hoguera y otros objetos con efecto*: objetos con una línea "Usar:" o que se echan a la hoguera (activado).
  - *Equipo*: armas y armaduras (desactivado).
- **Duración del efecto**: resalta *"durante 30 min"*, *"1 h 30 min"*, *"10 s"*… con su propio color (azul claro por defecto; clic derecho para volver a él). No resalta tiempos de reutilización ni intervalos como *"cada 5 s"*.
- **Estadísticas**: cada una tiene una casilla para activarla o desactivarla y su propio cuadro de color: **clic** = color propio, **clic derecho** = volver al color general.

Pasa el ratón por encima de cualquier opción para ver una explicación.

Las opciones se guardan entre sesiones (`StatHighlightDB`).

## Notas

- Preparado para WoW Forever 1.60.1 (Interface 16001), no para Classic Era.
- Si cambia el `.toc`, cierra el juego por completo y vuelve a abrirlo; `/reload` no basta para leer el `.toc` nuevo. Para cambios solo en el `.lua` suele bastar `/reload`.
- Si una línea no se resalta, escribe `/shl debug`, pasa el ratón por el objeto y abre un [issue](../../issues) con una captura del chat.

## Cambios

### 1.1.0

- Resalta también los objetos que se echan a la hoguera y otros objetos con efecto de uso.
- Pergaminos: reconoce frases como *"Aumenta el Intelecto del objetivo 8 p."*.
- Nuevo: resaltado de la duración del efecto (*"30 min"*, *"1 h 30 min"*…) con color configurable.
- Menú reorganizado en secciones: General, Dónde resaltar, Duración y Estadísticas.
- La opción *Solo consumibles* se sustituye por *Consumibles / Hoguera y otros / Equipo*; tus opciones anteriores se conservan.

### 1.0.0

- Primera versión pública.
- Resalta salud, maná, atributos, resistencias, daño, velocidad, habilidad de profesión, experiencia y el resto de estadísticas de consumibles, en español e inglés. Reconoce rangos (*"70 a 90 p."*) y porcentajes (*"un 5%"*).
- Estadísticas encadenadas: en *"6 p. de aguante y espíritu"* se resaltan las dos.
- Menú `/shl` con color general y color propio por estadística.
- Opción **Solo consumibles** (activada por defecto).
- Opciones guardadas entre sesiones.
- Modo depuración: `/shl debug`.

## Publicar una versión (mantenimiento)

1. Actualiza `## Version:` en `StatHighlight.toc` y la sección *Cambios*.
2. Crea y sube una etiqueta con el mismo número: `git tag v1.2.3 && git push origin v1.2.3`.
3. La acción de GitHub ejecuta las pruebas (`tests/run.lua`), comprueba que la etiqueta coincide con el `.toc`, genera `StatHighlight-v1.2.3.zip` (con la carpeta `StatHighlight/` dentro) y lo publica como Release.

## Licencia

[MIT](LICENSE) © DLS

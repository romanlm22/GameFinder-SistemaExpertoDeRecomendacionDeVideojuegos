# GameFinder

Sistema experto de recomendacion de videojuegos por consola, escrito en **Common Lisp** (SBCL).
El programa hace un cuestionario de seis preguntas, aplica reglas explicitas, calcula una puntuacion
de compatibilidad para cada juego del catalogo y muestra hasta cinco recomendaciones explicando
por que coinciden con tus gustos.

No usa librerias externas, conexion a Internet ni inteligencia artificial: todas las recomendaciones salen
de reglas y algoritmos implementados en el propio proyecto.

## Funcionalidades

- Menu interactivo que se mantiene activo hasta elegir `0`; las entradas invalidas no cierran el programa.
- Catalogo de 18 videojuegos con generos, modo de juego, dificultad, tipo de experiencia, mundo abierto,
  requisitos de hardware y precio (estos dos ultimos son categorias orientativas, no datos comerciales garantizados).
- Cuestionario de preferencias validado, con opciones "Cualquiera" que no limitan los resultados.
- Motor de recomendacion con filtros obligatorios, puntuacion de hasta 17 puntos, orden determinista y explicaciones.
- Busqueda por nombre (sin distinguir mayusculas), filtro por genero y ficha detallada.
- Estadisticas calculadas desde el catalogo.
- 102 pruebas automatizadas.

## Requisitos

- Windows 10 u 11 (el codigo es Common Lisp estandar y tambien deberia funcionar en otros sistemas con SBCL).
- [SBCL](https://www.sbcl.org/) (desarrollado con la version 2.6.9).
- Visual Studio Code (opcional; sirve cualquier terminal).

### Instalar SBCL en Windows

1. Entra a <https://www.sbcl.org/platform-table.html>.
2. En la fila **Windows**, columna **x86-64**, descarga el instalador `.msi`.
   No descargues el codigo fuente (`.tar.bz2`) ni la columna x86 de 32 bits.
   La columna ARM64 es solo para equipos con procesador ARM (`$env:PROCESSOR_ARCHITECTURE` muestra `AMD64` o `ARM64`).
3. Ejecuta el instalador con las opciones por defecto.
4. Cierra y vuelve a abrir la terminal (o VS Code) y verifica:

```powershell
sbcl --version
```

Si `sbcl` no se reconoce, busca donde quedo instalado y agregalo al PATH de esa terminal:

```powershell
Get-ChildItem "C:\Program Files\Steel Bank Common Lisp" -Recurse -Filter sbcl.exe -ErrorAction SilentlyContinue
$env:Path += ";C:\Program Files\Steel Bank Common Lisp"
```

## Uso

Desde la carpeta del proyecto:

```powershell
sbcl --noinform --non-interactive --load main.lisp --eval "(main)"
```

Menu principal:

```
===== GAMEFINDER =====
1. Obtener recomendaciones
2. Consultar el catalogo de videojuegos
3. Buscar un videojuego por nombre
4. Filtrar videojuegos por genero
5. Consultar informacion detallada de un videojuego
6. Mostrar estadisticas del catalogo
0. Salir
```

Las preguntas se responden escribiendo el numero de la opcion. El texto se muestra sin tildes a proposito,
para evitar problemas de codificacion en la consola de Windows.

## Como decide el sistema

### Puntuacion

| Criterio | Puntos | Tipo |
|---|---|---|
| Genero | 5 | Obligatorio |
| Modo de juego | 3 | Obligatorio |
| Presupuesto | 2 | Obligatorio |
| Experiencia | 3 | Suma puntos |
| Dificultad | 2 | Suma puntos |
| Requisitos de hardware | 2 | Suma puntos |

- Maximo: 17 puntos. Compatibilidad = (puntos / 17) x 100, redondeada al entero mas cercano.
- Las respuestas "Cualquiera" no suman ni restan puntos, y nunca aparecen como motivo.
- Un criterio **obligatorio** con una respuesta concreta excluye a los juegos que no lo cumplen, aunque su
  puntuacion total sea alta. La lista se puede cambiar editando `*criterios-obligatorios*` en `recomendador.lisp`.

### Modo de juego

- *Individual* acepta juegos individuales y los que ofrecen ambos modos.
- *Multijugador* acepta juegos multijugador y los que ofrecen ambos modos.
- *Ambos* solo acepta juegos que ofrecen ambos modos.

### Orden y resultados

Mayor puntuacion primero. En caso de empate, orden alfabetico por nombre, por lo que el resultado siempre es el mismo.
Se muestran como maximo cinco recomendaciones; si ningun juego cumple los filtros, el programa lo informa.

## Ejemplos de uso

### Recomendaciones (Terror, Individual, Media, Historia, Altos, Premium)

```
--- Tus preferencias ---
Genero: Terror
Modo de juego: Individual
Dificultad: Media
Experiencia: Historia
Requisitos: Altos
Presupuesto: Premium

--- Recomendaciones ---

1. Resident Evil 2
   Puntuacion: 15/17 (88% de compatibilidad)
   Generos: Terror, Accion, Supervivencia
   Modo: Individual | Dificultad: Media
   Motivos:
     - Genero: Terror (+5)
     - Modo de juego: Individual (tu preferencia: Individual) (+3)
     - Dificultad: Media (+2)
     - Experiencia: Historia (+3)
     - Precio: Premium (+2)
```

The Witcher 3 coincide en cinco criterios (12 puntos) pero queda fuera porque no es de terror (filtro obligatorio).

### Varios resultados y desempate (RPG, Individual, Cualquiera, Exploracion, Cualquiera, Cualquiera)

| # | Juego | Puntos | Compatibilidad |
|---|---|---|---|
| 1 | Elden Ring | 11/17 | 65% |
| 2 | Stardew Valley | 11/17 | 65% |
| 3 | Zelda: Breath of the Wild | 11/17 | 65% |
| 4 | Hades | 8/17 | 47% |
| 5 | The Witcher 3 | 8/17 | 47% |

Los empates se ordenan alfabeticamente.

### Sin coincidencias (Carreras, Individual, Gratuito)

```
--- Recomendaciones ---
No hay recomendaciones: ningun videojuego cumple tus filtros obligatorios (Genero, Modo de juego, Presupuesto).
Proba con otras respuestas o elegi "Cualquiera".
```

### Busqueda por nombre (opcion 3)

```
--- Resultados para "witcher" ---
 1. The Witcher 3
    Generos: RPG, Aventura, Accion | Modo: Individual | Dificultad: Media
Total: 1
```

### Ficha detallada (opcion 5)

```
=== Portal 2 ===
Generos: Aventura
Modo de juego: Individual y multijugador
Dificultad: Media
Tipo de experiencia: Historia
Mundo abierto: No
Requisitos (orientativos): Bajos
Precio (orientativo): Economico
```

### Estadisticas (opcion 6)

```
--- Estadisticas del catalogo ---
Total de videojuegos: 18

Por genero (un juego puede tener varios generos):
  RPG                         5 #####
  Accion                      6 ######
  Aventura                    7 #######
  Estrategia                  2 ##
  Terror                      2 ##
  Carreras                    3 ###
  Simulacion                  4 ####
  Supervivencia               6 ######

Por modo de juego:
  Individual                  6 ######
  Multijugador                2 ##
  Individual y multijugador  10 ##########

Por dificultad:
  Facil                       5 #####
  Media                      10 ##########
  Dificil                     3 ###

Por categoria de precio:
  Gratuito                    3 ###
  Economico                   8 ########
  Premium                     7 #######
```

### Probar sin teclear (PowerShell)

`` `n `` es la tecla Enter. Este comando responde el cuestionario del primer ejemplo y sale:

```powershell
"1`n5`n1`n2`n1`n3`n3`n0" | sbcl --noinform --non-interactive --load main.lisp --eval "(main)"
```

## Pruebas

```powershell
sbcl --noinform --non-interactive --load main.lisp --load tests.lisp --eval "(ejecutar-pruebas)"
```

Muestra una linea `[OK]` o `[FALLA]` por prueba y al final `Pruebas ejecutadas: 102` y `Pruebas fallidas: 0`.

| Escenario | Que comprueba |
|---|---|
| A: coincidencia completa | Stardew Valley con todas las preferencias coincidentes: 17 puntos y 100%. |
| B: coincidencia parcial | The Witcher 3 con tres coincidencias: 11 puntos y 65%. |
| C: filtros obligatorios | Un juego con 12 puntos queda excluido por no cumplir el genero. |
| D: sin resultados | Ningun juego cumple los filtros: no hay recomendaciones. |
| E: entrada invalida | Letras, vacio, negativos y decimales no cierran el programa. |
| F: empate | Dos juegos con igual puntuacion mantienen un orden determinista. |
| G: estadisticas | Los totales coinciden con los registros reales del catalogo. |

Ademas se prueban: busqueda y filtros (incluidos catalogos vacios), cuestionario completo con
respuestas invalidas, validez de los datos del catalogo, recorrido completo del menu y comportamiento
del programa con un catalogo vacio.

## Estructura del proyecto

```
GameFinder/
  main.lisp          Punto de entrada, carga de modulos y menu principal
  modelos.lisp       Valores validos, estructuras videojuego y preferencias, textos
  catalogo.lisp      Catalogo de 18 juegos, busqueda por nombre y filtro por genero
  recomendador.lisp  Filtros obligatorios, puntuacion, orden y explicaciones
  interfaz.lisp      Lectura validada, cuestionario y presentacion por consola
  estadisticas.lisp  Calculo y reporte de estadisticas
  tests.lisp         Pruebas automatizadas
  README.md
```

`main.lisp` carga los modulos en este orden: `modelos`, `catalogo`, `recomendador`, `estadisticas`, `interfaz`.
Los datos (modelos y catalogo), la logica (recomendador y estadisticas) y la presentacion (interfaz) estan separados.

## Conceptos de Common Lisp aplicados

| Concepto | Donde y para que |
|---|---|
| `defun` | Funciones pequenas e independientes en todos los modulos. |
| `defparameter` | Catalogo, pesos de puntuacion, valores validos, preguntas y textos. |
| `defstruct` | `videojuego`, `preferencias` (con valores por defecto) y `recomendacion`. |
| `let`, `let*` | Variables locales en lectura, evaluacion y estadisticas. |
| `cond`, `case`, `ecase` | Decisiones del menu, comparacion de criterios y orden de resultados. |
| `loop` | Menu principal, lectura repetida hasta una entrada valida y listados numerados. |
| `dolist` | Carga de modulos y recorrido de preguntas y conteos. |
| `mapcar` | Transformar juegos en recomendaciones, nombres y etiquetas. |
| `remove-if`, `remove-if-not` | Filtros por genero, por criterios obligatorios y deteccion de registros invalidos. |
| `sort` | Orden de las recomendaciones por puntuacion y nombre. |
| `lambda` | Criterios de filtrado y ordenamiento. |
| Recursividad | `buscar-recursivo` recorre el catalogo para la busqueda por nombre. |
| `reduce`, `count`, `every`, `notany`, `member`, `assoc`, `getf` | Puntuacion, estadisticas y validaciones. |
| `destructuring-bind`, `return-from` | Armado de las preferencias y salida anticipada del cuestionario. |
| `format`, `read-line`, `load` | Salida por consola, lectura de entradas y carga de archivos. |

## Limitaciones

- Los requisitos de hardware y los precios son categorias orientativas, no datos actuales garantizados.
- El catalogo esta definido en el codigo (`catalogo.lisp`); no hay persistencia en archivos.
- Los textos se muestran sin tildes por compatibilidad con la consola de Windows.

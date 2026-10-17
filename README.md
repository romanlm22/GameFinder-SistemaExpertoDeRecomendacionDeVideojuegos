# Dungeon Survival — Videojuego 2D en C++17

**Dungeon Survival** es un videojuego de acción, supervivencia y combate en una mazmorra medieval 2D desarrollado íntegramente en **C++17** utilizando la biblioteca gráfica **SFML 3** y **CMake**. El jugador asume el rol de un caballero medieval que debe enfrentarse a oleadas progresivas de enemigos dentro de una arena cerrada, haciendo uso de combate con espada, gestión de vida y reflejos rápidos.

---

## Características Principales
* **Jugador (`Player`):** Personaje con diseño de caballero medieval (torso con armadura, yelmo con visera y corona real), movimiento fluido normalizado en diagonal, velocidad independiente de los fotogramas (*Delta Time*) y límites estrictos dentro de la arena.
* **Sistema de Combate Animado:** Mecánica de tajo de espada activada mediante la **Barra Espaciadora**, con rotación y animación fluida que inflige daño a los enemigos cercanos en un radio definido.
* **Enemigos (`Enemy`):** Unidades humanoides enemigas armadas que persiguen dinámicamente al jugador por la mazmorra.
* **Oleadas Progresivas:** Sistema de 5 oleadas con dificultad incremental y reaparición controlada.
* **Estados del Juego:** Menú principal interactivo navegable con las flechas del teclado, pausa (`ESC`), pantalla de derrota y pantalla de victoria.
* **Entorno Estilizado:** Fondo de mazmorra con textura de baldosas de piedra y arcos medievales generados proceduralmente.
* **HUD en Tiempo Real:** Visualización limpia de la salud actual, puntuación, oleada en curso y enemigos restantes.

---

## Requisitos Previos
Para compilar y ejecutar este proyecto en Windows se requiere:
* Sistema operativo **Windows**.
* Un compilador compatible con **C++17** (ej. GCC mediante MSYS2 UCRT64).
* **CMake** (versión 3.16 o superior).
* **SFML 3**.
* **Git**.

---

## Instrucciones de Instalación y Clonación

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/TU_USUARIO/DungeonSurvival.git](https://github.com/TU_USUARIO/DungeonSurvival.git)
   cd DungeonSurvival

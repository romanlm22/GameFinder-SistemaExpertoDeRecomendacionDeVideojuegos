
(defparameter *generos-validos*
  '(:rpg :accion :aventura :estrategia :terror :carreras :simulacion :supervivencia))
(defparameter *modos-validos* '(:individual :multijugador :ambos))
(defparameter *dificultades-validas* '(:facil :media :dificil))
(defparameter *experiencias-validas*
  '(:historia :exploracion :competicion :estrategia :supervivencia))
(defparameter *requisitos-validos* '(:bajos :medios :altos))
(defparameter *precios-validos* '(:gratuito :economico :premium))

(defstruct videojuego
  nombre
  generos
  modo
  dificultad
  experiencia
  mundo-abierto
  requisitos
  precio)

(defun todos-en-p (valores validos)
  "T si VALORES es una lista no vacia y cada elemento esta en VALIDOS."
  (and (consp valores)
       (every (lambda (v) (member v validos)) valores)))

(defun videojuego-valido-p (juego)
  "T si todos los atributos de JUEGO tienen valores permitidos."
  (and (videojuego-p juego)
       (stringp (videojuego-nombre juego))
       (plusp (length (videojuego-nombre juego)))
       (todos-en-p (videojuego-generos juego) *generos-validos*)
       (member (videojuego-modo juego) *modos-validos*)
       (member (videojuego-dificultad juego) *dificultades-validas*)
       (member (videojuego-experiencia juego) *experiencias-validas*)
       (member (videojuego-mundo-abierto juego) '(t nil)) ; solo T o NIL
       (member (videojuego-requisitos juego) *requisitos-validos*)
       (member (videojuego-precio juego) *precios-validos*)
       t))

(defstruct preferencias
  (genero :cualquiera)
  (modo :ambos)
  (dificultad :cualquiera)
  (experiencia :cualquiera)
  (requisitos :cualquiera)
  (presupuesto :cualquiera))

(defun cualquiera-p (valor)
  "T si VALOR es la respuesta 'Cualquiera'."
  (eq valor :cualquiera))

(defun valor-o-cualquiera-p (valor validos)
  "T si VALOR es :cualquiera o esta entre VALIDOS."
  (or (cualquiera-p valor)
      (not (null (member valor validos)))))

(defun preferencias-validas-p (prefs)
  "T si todas las respuestas de PREFS tienen valores permitidos."
  (and (preferencias-p prefs)
       (valor-o-cualquiera-p (preferencias-genero prefs) *generos-validos*)
       (not (null (member (preferencias-modo prefs) *modos-validos*)))
       (valor-o-cualquiera-p (preferencias-dificultad prefs) *dificultades-validas*)
       (valor-o-cualquiera-p (preferencias-experiencia prefs) *experiencias-validas*)
       (valor-o-cualquiera-p (preferencias-requisitos prefs) *requisitos-validos*)
       (valor-o-cualquiera-p (preferencias-presupuesto prefs) *precios-validos*)))

(defparameter *etiquetas*
  '((:rpg . "RPG") (:accion . "Accion") (:aventura . "Aventura")
    (:estrategia . "Estrategia") (:terror . "Terror") (:carreras . "Carreras")
    (:simulacion . "Simulacion") (:supervivencia . "Supervivencia")
    (:individual . "Individual") (:multijugador . "Multijugador")
    (:ambos . "Individual y multijugador")
    (:facil . "Facil") (:media . "Media") (:dificil . "Dificil")
    (:historia . "Historia") (:exploracion . "Exploracion")
    (:competicion . "Competicion")
    (:bajos . "Bajos") (:medios . "Medios") (:altos . "Altos")
    (:gratuito . "Gratuito") (:economico . "Economico") (:premium . "Premium")
    (:cualquiera . "Cualquiera")
    ;; nombres de criterios (se usan al informar los filtros obligatorios)
    (:genero . "Genero") (:modo . "Modo de juego") (:presupuesto . "Presupuesto")))

(defun etiqueta (clave)
  "Texto para mostrar de la keyword CLAVE."
  (or (cdr (assoc clave *etiquetas*))
      (string-downcase (symbol-name clave))))

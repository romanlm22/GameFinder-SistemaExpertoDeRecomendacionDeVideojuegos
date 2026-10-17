
(defparameter *catalogo*
  (list
   (make-videojuego :nombre "Stardew Valley" :generos '(:simulacion :rpg)
                    :modo :ambos :dificultad :facil :experiencia :exploracion
                    :mundo-abierto nil :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "The Witcher 3" :generos '(:rpg :aventura :accion)
                    :modo :individual :dificultad :media :experiencia :historia
                    :mundo-abierto t :requisitos :altos :precio :premium)
   (make-videojuego :nombre "Minecraft" :generos '(:supervivencia :aventura :simulacion)
                    :modo :ambos :dificultad :facil :experiencia :exploracion
                    :mundo-abierto t :requisitos :medios :precio :economico)
   (make-videojuego :nombre "Portal 2" :generos '(:aventura)
                    :modo :ambos :dificultad :media :experiencia :historia
                    :mundo-abierto nil :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "Hades" :generos '(:accion :rpg)
                    :modo :individual :dificultad :dificil :experiencia :historia
                    :mundo-abierto nil :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "Terraria" :generos '(:aventura :supervivencia :accion)
                    :modo :ambos :dificultad :media :experiencia :exploracion
                    :mundo-abierto t :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "Civilization VI" :generos '(:estrategia)
                    :modo :ambos :dificultad :media :experiencia :estrategia
                    :mundo-abierto nil :requisitos :medios :precio :premium)
   (make-videojuego :nombre "Rocket League" :generos '(:carreras)
                    :modo :multijugador :dificultad :media :experiencia :competicion
                    :mundo-abierto nil :requisitos :medios :precio :gratuito)
   (make-videojuego :nombre "Elden Ring" :generos '(:rpg :accion :aventura)
                    :modo :ambos :dificultad :dificil :experiencia :exploracion
                    :mundo-abierto t :requisitos :altos :precio :premium)
   (make-videojuego :nombre "Resident Evil 2" :generos '(:terror :accion :supervivencia)
                    :modo :individual :dificultad :media :experiencia :historia
                    :mundo-abierto nil :requisitos :medios :precio :premium)
   (make-videojuego :nombre "Forza Horizon 5" :generos '(:carreras :simulacion)
                    :modo :ambos :dificultad :facil :experiencia :competicion
                    :mundo-abierto t :requisitos :altos :precio :premium)
   (make-videojuego :nombre "The Sims 4" :generos '(:simulacion)
                    :modo :individual :dificultad :facil :experiencia :exploracion
                    :mundo-abierto nil :requisitos :medios :precio :gratuito)
   (make-videojuego :nombre "Don't Starve Together" :generos '(:supervivencia :aventura)
                    :modo :ambos :dificultad :dificil :experiencia :supervivencia
                    :mundo-abierto nil :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "Age of Empires II" :generos '(:estrategia)
                    :modo :ambos :dificultad :media :experiencia :estrategia
                    :mundo-abierto nil :requisitos :bajos :precio :economico)
   (make-videojuego :nombre "Fortnite" :generos '(:accion :supervivencia)
                    :modo :multijugador :dificultad :media :experiencia :competicion
                    :mundo-abierto t :requisitos :medios :precio :gratuito)
   (make-videojuego :nombre "Outlast" :generos '(:terror :supervivencia)
                    :modo :individual :dificultad :media :experiencia :supervivencia
                    :mundo-abierto nil :requisitos :medios :precio :economico)
   (make-videojuego :nombre "Zelda: Breath of the Wild" :generos '(:aventura :rpg)
                    :modo :individual :dificultad :media :experiencia :exploracion
                    :mundo-abierto t :requisitos :medios :precio :premium)
   (make-videojuego :nombre "Mario Kart 8 Deluxe" :generos '(:carreras)
                    :modo :ambos :dificultad :facil :experiencia :competicion
                    :mundo-abierto nil :requisitos :bajos :precio :premium))
  "Lista de estructuras VIDEOJUEGO disponibles en el sistema.")

(defun nombres-duplicados-p (juegos)
  "T si hay dos juegos con el mismo nombre (sin distinguir mayusculas)."
  (/= (length juegos)
      (length (remove-duplicates (mapcar #'videojuego-nombre juegos)
                                 :test #'string-equal))))

(defun verificar-catalogo (&optional (catalogo *catalogo*))
  "Imprime un resumen de la carga y devuelve T si el catalogo es correcto."
  (let* ((total (length catalogo))
         (invalidos (remove-if #'videojuego-valido-p catalogo))
         (rango-ok (<= 15 total 20))
         (duplicados (nombres-duplicados-p catalogo))
         (correcto (and rango-ok (not duplicados) (null invalidos))))
    (format t "Videojuegos cargados: ~D~%" total)
    (format t "Cantidad entre 15 y 20: ~A~%" (if rango-ok "OK" "FALLA"))
    (format t "Nombres sin duplicados: ~A~%" (if duplicados "FALLA" "OK"))
    (format t "Registros invalidos: ~D~%" (length invalidos))
    (format t "~{  - ~A~%~}" (mapcar #'videojuego-nombre catalogo))
    (format t "RESULTADO: ~A~%" (if correcto "CATALOGO CORRECTO" "CATALOGO CON ERRORES"))
    correcto))


(defparameter *espacios* '(#\Space #\Tab #\Return #\Newline)
  "Caracteres que se recortan de los extremos de un texto ingresado.")

(defun recortar (texto)
  "Quita espacios, tabulaciones y saltos de linea de los extremos de TEXTO."
  (string-trim *espacios* texto))

(defun nombre-contiene-p (juego fragmento)
  "T si el nombre de JUEGO contiene FRAGMENTO, sin distinguir mayusculas."
  (not (null (search fragmento (videojuego-nombre juego) :test #'char-equal))))

(defun buscar-recursivo (fragmento juegos)
  "Recorre JUEGOS de forma recursiva y devuelve los que contienen FRAGMENTO."
  (cond ((null juegos) nil)
        ((nombre-contiene-p (first juegos) fragmento)
         (cons (first juegos) (buscar-recursivo fragmento (rest juegos))))
        (t (buscar-recursivo fragmento (rest juegos)))))

(defun buscar-por-nombre (fragmento &optional (juegos *catalogo*))
  "Juegos de JUEGOS cuyo nombre contiene FRAGMENTO. Un texto vacio no devuelve nada."
  (let ((limpio (recortar fragmento)))
    (if (zerop (length limpio))
        nil
        (buscar-recursivo limpio juegos))))

(defun filtrar-por-genero (genero &optional (juegos *catalogo*))
  "Juegos de JUEGOS que incluyen GENERO (una keyword) entre sus generos."
  (remove-if-not (lambda (juego) (member genero (videojuego-generos juego)))
                 juegos))

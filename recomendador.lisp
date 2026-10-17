
(defparameter *pesos*
  '((:genero . 5) (:modo . 3) (:dificultad . 2)
    (:experiencia . 3) (:requisitos . 2) (:presupuesto . 2)))

(defparameter *puntaje-maximo* (reduce #'+ *pesos* :key #'cdr)
  "Puntuacion maxima posible (17).")

(defparameter *criterios-obligatorios* '(:genero :modo :presupuesto))

(defparameter *maximo-recomendaciones* 5
  "Cantidad maxima de recomendaciones que se muestran.")

(defstruct recomendacion
  juego
  puntaje
  porcentaje
  coincidencias   
  motivos)        

(defun valor-preferencia (criterio prefs)
  "Respuesta del usuario para CRITERIO."
  (ecase criterio
    (:genero (preferencias-genero prefs))
    (:modo (preferencias-modo prefs))
    (:dificultad (preferencias-dificultad prefs))
    (:experiencia (preferencias-experiencia prefs))
    (:requisitos (preferencias-requisitos prefs))
    (:presupuesto (preferencias-presupuesto prefs))))

(defun evaluable-p (criterio prefs)
  "T si el usuario dio una preferencia concreta para CRITERIO (no 'Cualquiera')."
  (not (cualquiera-p (valor-preferencia criterio prefs))))

(defun modo-compatible-p (preferido ofrecido)
  "Individual y multijugador aceptan juegos que tambien ofrecen ambos modos.
Quien prefiere ambos solo acepta juegos que ofrecen ambos."
  (case preferido
    (:ambos (eq ofrecido :ambos))
    (t (or (eq ofrecido preferido) (eq ofrecido :ambos)))))

(defun coincide-p (criterio juego prefs)
  "T si JUEGO coincide con la preferencia del usuario en CRITERIO."
  (let ((preferido (valor-preferencia criterio prefs)))
    (ecase criterio
      (:genero (not (null (member preferido (videojuego-generos juego)))))
      (:modo (modo-compatible-p preferido (videojuego-modo juego)))
      (:dificultad (eq preferido (videojuego-dificultad juego)))
      (:experiencia (eq preferido (videojuego-experiencia juego)))
      (:requisitos (eq preferido (videojuego-requisitos juego)))
      (:presupuesto (eq preferido (videojuego-precio juego))))))

(defun criterio-cumplido-p (criterio juego prefs)
  "T si CRITERIO fue evaluado (no es 'Cualquiera') y JUEGO coincide."
  (and (evaluable-p criterio prefs)
       (coincide-p criterio juego prefs)))


(defun cumple-filtros-p (juego prefs)
  "T si JUEGO cumple todos los criterios obligatorios evaluables."
  (every (lambda (criterio)
           (or (not (evaluable-p criterio prefs))
               (coincide-p criterio juego prefs)))
         *criterios-obligatorios*))

(defun coincidencias-de (juego prefs)
  "Criterios en los que JUEGO realmente coincide con PREFS, en el orden de *PESOS*."
  (remove-if-not (lambda (criterio) (criterio-cumplido-p criterio juego prefs))
                 (mapcar #'car *pesos*)))

(defun puntaje-de (coincidencias)
  "Suma los puntos de los criterios en COINCIDENCIAS."
  (reduce #'+ coincidencias
          :key (lambda (criterio) (cdr (assoc criterio *pesos*)))))

(defun porcentaje-compatibilidad (puntaje)
  "(PUNTAJE / maximo) x 100, redondeado al entero mas cercano."
  (values (round (* 100 puntaje) *puntaje-maximo*)))


(defun motivo (criterio juego prefs)
  "Texto que explica la coincidencia en CRITERIO."
  (ecase criterio
    (:genero (format nil "Genero: ~A" (etiqueta (preferencias-genero prefs))))
    (:modo (format nil "Modo de juego: ~A (tu preferencia: ~A)"
                   (etiqueta (videojuego-modo juego))
                   (etiqueta (preferencias-modo prefs))))
    (:dificultad (format nil "Dificultad: ~A" (etiqueta (videojuego-dificultad juego))))
    (:experiencia (format nil "Experiencia: ~A" (etiqueta (videojuego-experiencia juego))))
    (:requisitos (format nil "Requisitos de hardware: ~A"
                         (etiqueta (videojuego-requisitos juego))))
    (:presupuesto (format nil "Precio: ~A" (etiqueta (videojuego-precio juego))))))

(defun motivo-con-puntos (criterio juego prefs)
  (format nil "~A (+~D)" (motivo criterio juego prefs)
          (cdr (assoc criterio *pesos*))))


(defun evaluar-juego (juego prefs)
  "Calcula la RECOMENDACION de JUEGO para PREFS (sin aplicar filtros)."
  (let* ((coincidencias (coincidencias-de juego prefs))
         (puntaje (puntaje-de coincidencias)))
    (make-recomendacion
     :juego juego
     :puntaje puntaje
     :porcentaje (porcentaje-compatibilidad puntaje)
     :coincidencias coincidencias
     :motivos (mapcar (lambda (criterio) (motivo-con-puntos criterio juego prefs))
                      coincidencias))))

(defun recomendacion-antes-p (a b)
  "Mayor puntuacion primero; en empate, orden alfabetico por nombre (determinista)."
  (cond ((> (recomendacion-puntaje a) (recomendacion-puntaje b)) t)
        ((< (recomendacion-puntaje a) (recomendacion-puntaje b)) nil)
        (t (not (null (string< (videojuego-nombre (recomendacion-juego a))
                               (videojuego-nombre (recomendacion-juego b))))))))

(defun calcular-recomendaciones (prefs &optional (catalogo *catalogo*))
  "Todas las recomendaciones de CATALOGO que cumplen los filtros, ordenadas."
  (let ((candidatos (remove-if-not (lambda (juego) (cumple-filtros-p juego prefs))
                                   catalogo)))
    (sort (mapcar (lambda (juego) (evaluar-juego juego prefs)) candidatos)
          #'recomendacion-antes-p)))

(defun primeros (lista n)
  "Los primeros N elementos de LISTA (o todos si hay menos)."
  (subseq lista 0 (min n (length lista))))

(defun recomendar (prefs &optional (catalogo *catalogo*))
  "Las mejores recomendaciones (maximo *MAXIMO-RECOMENDACIONES*); NIL si no hay."
  (primeros (calcular-recomendaciones prefs catalogo) *maximo-recomendaciones*))

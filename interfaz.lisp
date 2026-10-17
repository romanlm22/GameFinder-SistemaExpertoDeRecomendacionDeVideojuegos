
(defun formatear-generos (generos)
  "Lista de generos como texto separado por comas."
  (format nil "~{~A~^, ~}" (mapcar #'etiqueta generos)))

(defun leer-linea (prompt)
  "Muestra PROMPT y lee una linea. Devuelve NIL si se termino la entrada."
  (format t "~A" prompt)
  (finish-output)
  (read-line *standard-input* nil nil))

(defun convertir-a-entero (texto)
  "Entero representado por TEXTO, o NIL si no son solo digitos."
  (let ((limpio (recortar texto)))
    (when (and (plusp (length limpio))
               (every #'digit-char-p limpio))
      (parse-integer limpio))))

(defun leer-entero-en-rango (prompt minimo maximo)
  "Pide un entero entre MINIMO y MAXIMO hasta recibir uno valido.
Devuelve NIL solo si se termino la entrada."
  (loop
    (let ((linea (leer-linea prompt)))
      (when (null linea)
        (return nil))
      (let ((numero (convertir-a-entero linea)))
        (if (and numero (<= minimo numero maximo))
            (return numero)
            (format t "Entrada invalida. Ingrese un numero entre ~D y ~D.~%"
                    minimo maximo))))))

(defun preguntar (pregunta opciones)
  "Muestra PREGUNTA con OPCIONES numeradas y devuelve la opcion elegida
(una keyword). Repite hasta recibir una respuesta valida; NIL si se termino la entrada."
  (format t "~%~A~%" pregunta)
  (loop for opcion in opciones
        for indice from 1
        do (format t "  ~D. ~A~%" indice (etiqueta opcion)))
  (let ((numero (leer-entero-en-rango "Opcion: " 1 (length opciones))))
    (when numero
      (nth (1- numero) opciones))))


(defun mostrar-resumen-juego (juego indice)
  "Imprime una linea de resumen de JUEGO, numerada con INDICE."
  (format t "~2D. ~A~%    Generos: ~A | Modo: ~A | Dificultad: ~A~%"
          indice
          (videojuego-nombre juego)
          (formatear-generos (videojuego-generos juego))
          (etiqueta (videojuego-modo juego))
          (etiqueta (videojuego-dificultad juego))))

(defun mostrar-listado (juegos titulo)
  "Imprime TITULO y la lista numerada de JUEGOS, o un aviso si esta vacia."
  (format t "~%--- ~A ---~%" titulo)
  (if (null juegos)
      (format t "No se encontraron videojuegos.~%")
      (progn
        (loop for juego in juegos
              for indice from 1
              do (mostrar-resumen-juego juego indice))
        (format t "Total: ~D~%" (length juegos)))))

(defparameter *preguntas*
  (list
   (list "1. Que genero preferis?"
         (append *generos-validos* '(:cualquiera)))
   (list "2. Como preferis jugar?"
         *modos-validos*)
   (list "3. Que dificultad preferis?"
         (append *dificultades-validas* '(:cualquiera)))
   (list "4. Que experiencia buscas?"
         (append *experiencias-validas* '(:cualquiera)))
   (list "5. Que requisitos de hardware preferis?"
         (append *requisitos-validos* '(:cualquiera)))
   (list "6. Cual es tu presupuesto?"
         (append *precios-validos* '(:cualquiera)))))

(defun realizar-cuestionario ()
  "Hace las seis preguntas y devuelve una estructura PREFERENCIAS.
Devuelve NIL si la entrada termina antes de completar el cuestionario."
  (let ((respuestas '()))
    (dolist (pregunta *preguntas*)
      (let ((respuesta (preguntar (first pregunta) (second pregunta))))
        (when (null respuesta)
          (return-from realizar-cuestionario nil))
        (push respuesta respuestas)))
    (destructuring-bind (genero modo dificultad experiencia requisitos presupuesto)
        (nreverse respuestas)
      (make-preferencias :genero genero :modo modo :dificultad dificultad
                         :experiencia experiencia :requisitos requisitos
                         :presupuesto presupuesto))))

(defun mostrar-preferencias (prefs)
  "Imprime un resumen de las respuestas guardadas en PREFS."
  (format t "~%--- Tus preferencias ---~%")
  (format t "Genero: ~A~%" (etiqueta (preferencias-genero prefs)))
  (format t "Modo de juego: ~A~%" (etiqueta (preferencias-modo prefs)))
  (format t "Dificultad: ~A~%" (etiqueta (preferencias-dificultad prefs)))
  (format t "Experiencia: ~A~%" (etiqueta (preferencias-experiencia prefs)))
  (format t "Requisitos: ~A~%" (etiqueta (preferencias-requisitos prefs)))
  (format t "Presupuesto: ~A~%" (etiqueta (preferencias-presupuesto prefs))))

(defun obtener-preferencias ()
  "Ejecuta el cuestionario, muestra el resumen y devuelve las preferencias."
  (let ((prefs (realizar-cuestionario)))
    (when prefs
      (mostrar-preferencias prefs))
    prefs))

(defun mostrar-recomendacion (recomendacion indice)
  "Imprime una recomendacion: puntuacion, datos del juego y motivos."
  (let ((juego (recomendacion-juego recomendacion))
        (motivos (recomendacion-motivos recomendacion)))
    (format t "~%~D. ~A~%" indice (videojuego-nombre juego))
    (format t "   Puntuacion: ~D/~D (~D% de compatibilidad)~%"
            (recomendacion-puntaje recomendacion)
            *puntaje-maximo*
            (recomendacion-porcentaje recomendacion))
    (format t "   Generos: ~A~%" (formatear-generos (videojuego-generos juego)))
    (format t "   Modo: ~A | Dificultad: ~A~%"
            (etiqueta (videojuego-modo juego))
            (etiqueta (videojuego-dificultad juego)))
    (format t "   Motivos:~%")
    (if (null motivos)
        (format t "     - Cumple tus filtros, pero no hay otras preferencias que puntuar.~%")
        (dolist (motivo motivos)
          (format t "     - ~A~%" motivo)))))

(defun mostrar-recomendaciones (recomendaciones)
  "Imprime la lista de RECOMENDACIONES, o un aviso si esta vacia."
  (format t "~%--- Recomendaciones ---~%")
  (if (null recomendaciones)
      (format t "No hay recomendaciones: ningun videojuego cumple tus filtros obligatorios (~{~A~^, ~}).~%Proba con otras respuestas o elegi \"Cualquiera\".~%"
              (mapcar #'etiqueta *criterios-obligatorios*))
      (loop for recomendacion in recomendaciones
            for indice from 1
            do (mostrar-recomendacion recomendacion indice))))

(defun obtener-recomendaciones ()
  "Opcion 1 del menu: cuestionario, calculo y presentacion de resultados."
  (let ((prefs (obtener-preferencias)))
    (when prefs
      (mostrar-recomendaciones (recomendar prefs)))))

(defun mostrar-ficha (juego)
  "Imprime todos los datos de JUEGO."
  (format t "~%=== ~A ===~%" (videojuego-nombre juego))
  (format t "Generos: ~A~%" (formatear-generos (videojuego-generos juego)))
  (format t "Modo de juego: ~A~%" (etiqueta (videojuego-modo juego)))
  (format t "Dificultad: ~A~%" (etiqueta (videojuego-dificultad juego)))
  (format t "Tipo de experiencia: ~A~%" (etiqueta (videojuego-experiencia juego)))
  (format t "Mundo abierto: ~A~%" (if (videojuego-mundo-abierto juego) "Si" "No"))
  (format t "Requisitos (orientativos): ~A~%" (etiqueta (videojuego-requisitos juego)))
  (format t "Precio (orientativo): ~A~%" (etiqueta (videojuego-precio juego))))

(defun elegir-juego (juegos)
  "Lista JUEGOS numerados y devuelve el elegido, o NIL si se termino la entrada."
  (mostrar-listado juegos "Se encontraron varios videojuegos")
  (let ((numero (leer-entero-en-rango "Numero del videojuego: " 1 (length juegos))))
    (when numero
      (nth (1- numero) juegos))))

(defun consultar-por-nombre ()
  "Pide un texto y muestra los videojuegos cuyo nombre lo contiene."
  (let ((texto (leer-linea "Nombre (o parte del nombre): ")))
    (cond ((null texto) nil)
          ((zerop (length (recortar texto)))
           (format t "No ingreso ningun texto.~%"))
          (t (mostrar-listado (buscar-por-nombre texto)
                              (format nil "Resultados para \"~A\"" (recortar texto)))))))

(defun consultar-por-genero ()
  "Pide un genero y muestra los videojuegos que lo incluyen."
  (let ((genero (preguntar "Elegi un genero:" *generos-validos*)))
    (when genero
      (mostrar-listado (filtrar-por-genero genero)
                       (format nil "Genero: ~A" (etiqueta genero))))))

(defun consultar-ficha ()
  "Pide un nombre y muestra la ficha completa del videojuego encontrado."
  (let ((texto (leer-linea "Nombre del videojuego: ")))
    (when texto
      (let ((resultados (buscar-por-nombre texto)))
        (cond ((zerop (length (recortar texto)))
               (format t "No ingreso ningun texto.~%"))
              ((null resultados)
               (format t "No se encontraron videojuegos.~%"))
              ((null (rest resultados))
               (mostrar-ficha (first resultados)))
              (t (let ((juego (elegir-juego resultados)))
                   (when juego
                     (mostrar-ficha juego)))))))))

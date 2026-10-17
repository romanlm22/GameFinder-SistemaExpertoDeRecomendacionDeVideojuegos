
(defparameter *directorio-proyecto*
  (make-pathname :name nil :type nil :defaults *load-truename*)
  "Carpeta donde esta main.lisp (se calcula al cargar el archivo).")

(defun cargar-modulo (nombre)
  "Carga NOMBRE.lisp desde la carpeta del proyecto."
  (load (merge-pathnames (concatenate 'string nombre ".lisp")
                         *directorio-proyecto*)))

;;; Orden de carga: primero datos, despues logica y presentacion.
(dolist (modulo '("modelos" "catalogo" "recomendador" "estadisticas" "interfaz"))
  (cargar-modulo modulo))

(defun mostrar-menu ()
  "Imprime las opciones del menu principal."
  (format t "~%===== GAMEFINDER =====~%")
  (format t "1. Obtener recomendaciones~%")
  (format t "2. Consultar el catalogo de videojuegos~%")
  (format t "3. Buscar un videojuego por nombre~%")
  (format t "4. Filtrar videojuegos por genero~%")
  (format t "5. Consultar informacion detallada de un videojuego~%")
  (format t "6. Mostrar estadisticas del catalogo~%")
  (format t "0. Salir~%"))

(defun menu-principal ()
  "Mantiene el menu activo hasta que el usuario elige salir (0)."
  (loop
    (mostrar-menu)
    (let ((opcion (leer-entero-en-rango "Opcion: " 0 6)))
      (case opcion
        ((nil 0) (format t "Hasta luego.~%") (return))
        (1 (obtener-recomendaciones))
        (2 (mostrar-listado *catalogo* "Catalogo de videojuegos"))
        (3 (consultar-por-nombre))
        (4 (consultar-por-genero))
        (5 (consultar-ficha))
        (6 (mostrar-estadisticas))))))

(defun main ()
  "Inicia el programa."
  (menu-principal))

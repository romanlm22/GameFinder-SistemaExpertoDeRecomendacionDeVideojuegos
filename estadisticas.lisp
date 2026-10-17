
(defun contar-por-valor (valores juegos accesor)
  "Alist (valor . cantidad): cuantos juegos tienen cada valor de VALORES en ACCESOR."
  (mapcar (lambda (valor) (cons valor (count valor juegos :key accesor)))
          valores))

(defun contar-por-genero (juegos)
  "Alist (genero . cantidad). Un juego con varios generos cuenta en cada uno."
  (mapcar (lambda (genero)
            (cons genero (length (filtrar-por-genero genero juegos))))
          *generos-validos*))

(defun calcular-estadisticas (&optional (juegos *catalogo*))
  "Lista de propiedades con los conteos del catalogo JUEGOS."
  (list :total (length juegos)
        :generos (contar-por-genero juegos)
        :modos (contar-por-valor *modos-validos* juegos #'videojuego-modo)
        :dificultades (contar-por-valor *dificultades-validas* juegos
                                        #'videojuego-dificultad)
        :precios (contar-por-valor *precios-validos* juegos #'videojuego-precio)))

(defun mostrar-conteos (titulo conteos)
  "Imprime TITULO y una linea por cada (clave . cantidad), con una barra."
  (format t "~%~A~%" titulo)
  (dolist (par conteos)
    (format t "  ~26A ~2D ~A~%"
            (etiqueta (car par))
            (cdr par)
            (make-string (cdr par) :initial-element #\#))))

(defun mostrar-estadisticas (&optional (juegos *catalogo*))
  "Imprime el reporte de estadisticas de JUEGOS."
  (let* ((estadisticas (calcular-estadisticas juegos))
         (total (getf estadisticas :total)))
    (format t "~%--- Estadisticas del catalogo ---~%")
    (format t "Total de videojuegos: ~D~%" total)
    (if (zerop total)
        (format t "El catalogo esta vacio.~%")
        (progn
          (mostrar-conteos "Por genero (un juego puede tener varios generos):"
                           (getf estadisticas :generos))
          (mostrar-conteos "Por modo de juego:" (getf estadisticas :modos))
          (mostrar-conteos "Por dificultad:" (getf estadisticas :dificultades))
          (mostrar-conteos "Por categoria de precio:" (getf estadisticas :precios))))))

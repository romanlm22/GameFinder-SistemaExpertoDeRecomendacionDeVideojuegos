
(defparameter *pruebas-fallidas* 0 "Cantidad de pruebas que fallaron.")
(defparameter *pruebas-ejecutadas* 0 "Cantidad de pruebas ejecutadas.")

(defun verificar (descripcion condicion)
  "Imprime el resultado de una prueba y lo cuenta si fallo."
  (incf *pruebas-ejecutadas*)
  (format t "~A ~A~%" (if condicion "[OK]   " "[FALLA]") descripcion)
  (unless condicion
    (incf *pruebas-fallidas*))
  condicion)

(defun nombres (juegos)
  (mapcar #'videojuego-nombre juegos))

(defun pruebas-catalogo ()
  (verificar "catalogo valido (15 a 20 juegos, sin duplicados)"
             (let ((*standard-output* (make-broadcast-stream)))
               (verificar-catalogo))))

(defun pruebas-busqueda ()
  (verificar "buscar 'witcher' devuelve The Witcher 3"
             (equal (nombres (buscar-por-nombre "witcher")) '("The Witcher 3")))
  (verificar "buscar 'WITCHER' ignora mayusculas"
             (equal (nombres (buscar-por-nombre "WITCHER")) '("The Witcher 3")))
  (verificar "buscar '  portal  ' recorta espacios"
             (equal (nombres (buscar-por-nombre "  portal  ")) '("Portal 2")))
  (verificar "buscar 'zzz' no devuelve resultados"
             (null (buscar-por-nombre "zzz")))
  (verificar "buscar texto vacio no devuelve resultados"
             (null (buscar-por-nombre "")))
  (verificar "buscar solo espacios no devuelve resultados"
             (null (buscar-por-nombre "    ")))
  (verificar "buscar 'e' devuelve varios juegos"
             (> (length (buscar-por-nombre "e")) 1))
  (verificar "buscar en un catalogo vacio devuelve NIL"
             (null (buscar-por-nombre "hades" nil))))

(defun pruebas-filtro-genero ()
  (verificar "filtrar :terror devuelve 2 juegos"
             (= (length (filtrar-por-genero :terror)) 2))
  (verificar "filtrar :rpg devuelve 5 juegos"
             (= (length (filtrar-por-genero :rpg)) 5))
  (verificar "filtrar :carreras devuelve 3 juegos"
             (= (length (filtrar-por-genero :carreras)) 3))
  (verificar "todos los resultados de :terror incluyen ese genero"
             (every (lambda (j) (member :terror (videojuego-generos j)))
                    (filtrar-por-genero :terror)))
  (verificar "genero sin juegos devuelve NIL"
             (null (filtrar-por-genero :terror (list (first *catalogo*)))))
  (verificar "filtrar en un catalogo vacio devuelve NIL"
             (null (filtrar-por-genero :rpg nil))))

(defun pruebas-entrada ()
  (verificar "'3' se convierte en 3" (eql (convertir-a-entero "3") 3))
  (verificar "' 4 ' se convierte en 4" (eql (convertir-a-entero " 4 ") 4))
  (verificar "'abc' es invalido" (null (convertir-a-entero "abc")))
  (verificar "'3abc' es invalido" (null (convertir-a-entero "3abc")))
  (verificar "texto vacio es invalido" (null (convertir-a-entero "")))
  (verificar "'-1' es invalido" (null (convertir-a-entero "-1"))))


(defun con-entrada-simulada (texto funcion)
  "Ejecuta FUNCION leyendo TEXTO como si lo escribiera el usuario, sin mostrar salida."
  (let ((*standard-input* (make-string-input-stream texto))
        (*standard-output* (make-broadcast-stream)))
    (funcall funcion)))

(defun lineas (&rest items)
  "Une ITEMS en un texto con un item por linea (simula teclear y Enter)."
  (format nil "~{~A~%~}" items))

(defun pruebas-preferencias ()
  (verificar "preferencias por defecto: genero :cualquiera"
             (eq (preferencias-genero (make-preferencias)) :cualquiera))
  (verificar "preferencias por defecto son validas"
             (preferencias-validas-p (make-preferencias)))
  (verificar "genero inexistente no es valido"
             (not (preferencias-validas-p (make-preferencias :genero :inventado))))
  (verificar "modo :cualquiera no es valido (se usa :ambos)"
             (not (preferencias-validas-p (make-preferencias :modo :cualquiera))))
  (verificar "NIL no es una estructura de preferencias valida"
             (not (preferencias-validas-p nil))))

(defun pruebas-cuestionario ()
  (let ((prefs (con-entrada-simulada
                (lineas 9 3 4 6 4 4) #'realizar-cuestionario)))
    (verificar "todo 'Cualquiera' produce preferencias validas"
               (and prefs (preferencias-validas-p prefs)))
    (verificar "genero 9 es :cualquiera"
               (and prefs (cualquiera-p (preferencias-genero prefs))))
    (verificar "modo 3 es :ambos"
               (and prefs (eq (preferencias-modo prefs) :ambos)))
    (verificar "dificultad, experiencia, requisitos y presupuesto son :cualquiera"
               (and prefs
                    (cualquiera-p (preferencias-dificultad prefs))
                    (cualquiera-p (preferencias-experiencia prefs))
                    (cualquiera-p (preferencias-requisitos prefs))
                    (cualquiera-p (preferencias-presupuesto prefs)))))
  (let ((prefs (con-entrada-simulada
                (lineas "abc" 0 99 "" 5 1 1 1 1 1) #'realizar-cuestionario)))
    (verificar "entradas invalidas se descartan y se acepta la valida"
               (and prefs (eq (preferencias-genero prefs) :terror)))
    (verificar "respuestas 1 de cada pregunta"
               (and prefs
                    (eq (preferencias-modo prefs) :individual)
                    (eq (preferencias-dificultad prefs) :facil)
                    (eq (preferencias-experiencia prefs) :historia)
                    (eq (preferencias-requisitos prefs) :bajos)
                    (eq (preferencias-presupuesto prefs) :gratuito))))
  (verificar "entrada incompleta devuelve NIL sin error"
             (null (con-entrada-simulada (lineas 5) #'realizar-cuestionario)))
  (verificar "leer-entero-en-rango ignora 'x' y acepta 3"
             (eql (con-entrada-simulada (lineas "x" 3)
                                        (lambda () (leer-entero-en-rango "n: " 1 5)))
                  3)))


(defun salida-de (texto-entrada funcion)
  "Ejecuta FUNCION con TEXTO-ENTRADA como entrada y devuelve lo que imprimio."
  (with-output-to-string (salida)
    (let ((*standard-input* (make-string-input-stream texto-entrada))
          (*standard-output* salida))
      (funcall funcion))))

(defun juego-de-prueba (nombre)
  "Juego sintetico: RPG, modo ambos, media, historia, medios, economico."
  (make-videojuego :nombre nombre :generos '(:rpg) :modo :ambos
                   :dificultad :media :experiencia :historia
                   :mundo-abierto nil :requisitos :medios :precio :economico))

(defun juego-del-catalogo (fragmento)
  (first (buscar-por-nombre fragmento)))

(defun contiene-p (texto fragmento)
  (not (null (search fragmento texto))))

(defun pruebas-puntuacion ()
  (verificar "el puntaje maximo es 17" (= *puntaje-maximo* 17))
  (let* ((prefs (make-preferencias :genero :simulacion :modo :ambos :dificultad :facil
                                   :experiencia :exploracion :requisitos :bajos
                                   :presupuesto :economico))
         (rec (evaluar-juego (juego-del-catalogo "Stardew") prefs)))
    (verificar "A: coincidencia completa suma 17 puntos"
               (= (recomendacion-puntaje rec) 17))
    (verificar "A: coincidencia completa da 100% de compatibilidad"
               (= (recomendacion-porcentaje rec) 100))
    (verificar "A: hay un motivo por cada criterio"
               (= (length (recomendacion-motivos rec)) 6)))
  (let* ((prefs (make-preferencias :genero :rpg :modo :individual :dificultad :dificil
                                   :experiencia :historia :requisitos :bajos
                                   :presupuesto :cualquiera))
         (rec (evaluar-juego (juego-del-catalogo "Witcher") prefs)))
    (verificar "B: coincidencia parcial suma 11 puntos"
               (= (recomendacion-puntaje rec) 11))
    (verificar "B: solo coinciden genero, modo y experiencia"
               (equal (recomendacion-coincidencias rec) '(:genero :modo :experiencia)))
    (verificar "B: 11 puntos son 65% (redondeado)"
               (= (recomendacion-porcentaje rec) 65)))
  (verificar "porcentaje de 0 puntos es 0" (= (porcentaje-compatibilidad 0) 0))
  ;; "Cualquiera" no suma puntos ni genera motivos.
  (let* ((prefs (make-preferencias :genero :rpg :modo :individual))
         (rec (evaluar-juego (juego-del-catalogo "Witcher") prefs)))
    (verificar "'Cualquiera' no suma: solo genero y modo (8 puntos)"
               (= (recomendacion-puntaje rec) 8))
    (verificar "los motivos solo incluyen coincidencias reales"
               (and (= (length (recomendacion-motivos rec)) 2)
                    (notany (lambda (m) (contiene-p m "Dificultad"))
                            (recomendacion-motivos rec))))))

(defun pruebas-filtros-obligatorios ()
  (let* ((prefs (make-preferencias :genero :terror :modo :individual :dificultad :media
                                   :experiencia :historia :requisitos :altos
                                   :presupuesto :premium))
         (witcher (juego-del-catalogo "Witcher"))
         (resultado (calcular-recomendaciones prefs)))
    (verificar "C: el juego suma 12 puntos aunque falle el genero"
               (= (recomendacion-puntaje (evaluar-juego witcher prefs)) 12))
    (verificar "C: el juego es excluido por no cumplir el filtro de genero"
               (not (cumple-filtros-p witcher prefs)))
    (verificar "C: solo queda Resident Evil 2 con 15 puntos"
               (and (equal (mapcar (lambda (r) (videojuego-nombre (recomendacion-juego r)))
                                   resultado)
                           '("Resident Evil 2"))
                    (= (recomendacion-puntaje (first resultado)) 15))))
  (let ((prefs (make-preferencias :genero :carreras :modo :individual
                                  :presupuesto :gratuito)))
    (verificar "D: sin juegos que cumplan, no hay recomendaciones"
               (null (recomendar prefs))))
  (verificar "catalogo vacio no produce recomendaciones"
             (null (recomendar (make-preferencias) nil))))

(defun pruebas-orden ()
  (let* ((beta (juego-de-prueba "Beta"))
         (alfa (juego-de-prueba "Alfa"))
         (prefs (make-preferencias :genero :rpg))
         (nombres-1 (mapcar (lambda (r) (videojuego-nombre (recomendacion-juego r)))
                            (recomendar prefs (list beta alfa))))
         (nombres-2 (mapcar (lambda (r) (videojuego-nombre (recomendacion-juego r)))
                            (recomendar prefs (list alfa beta)))))
    (verificar "F: empate ordenado alfabeticamente (Alfa, Beta)"
               (equal nombres-1 '("Alfa" "Beta")))
    (verificar "F: el orden no depende del orden del catalogo"
               (equal nombres-1 nombres-2)))
  (let ((puntajes (mapcar #'recomendacion-puntaje
                          (calcular-recomendaciones
                           (make-preferencias :dificultad :media :experiencia :exploracion
                                              :requisitos :bajos)))))
    (verificar "los resultados quedan de mayor a menor puntuacion"
               (and puntajes (apply #'>= puntajes))))
  (let ((muchos (loop for i from 1 to 8
                      collect (juego-de-prueba (format nil "Juego ~D" i)))))
    (verificar "se muestran como maximo cinco recomendaciones"
               (= (length (recomendar (make-preferencias :genero :rpg) muchos)) 5))))

(defun pruebas-flujo-recomendacion ()
  (let ((salida (salida-de (lineas 5 1 2 1 3 3) #'obtener-recomendaciones)))
    (verificar "flujo completo: recomienda Resident Evil 2"
               (contiene-p salida "Resident Evil 2"))
    (verificar "flujo completo: muestra puntuacion y porcentaje"
               (contiene-p salida "Puntuacion: 15/17 (88% de compatibilidad)"))
    (verificar "flujo completo: no recomienda un juego excluido"
               (not (contiene-p salida "Witcher"))))
  (verificar "flujo completo: informa cuando no hay recomendaciones"
             (contiene-p (salida-de (lineas 6 1 4 6 4 1) #'obtener-recomendaciones)
                         "No hay recomendaciones")))


(defun conteo (clave alist)
  (cdr (assoc clave alist)))

(defun suma-conteos (alist)
  (reduce #'+ alist :key #'cdr))

(defun contar-ocurrencias (fragmento texto)
  "Cuantas veces aparece FRAGMENTO en TEXTO."
  (loop with inicio = 0
        for posicion = (search fragmento texto :start2 inicio)
        while posicion
        count t
        do (setf inicio (+ posicion (length fragmento)))))

(defun pruebas-estadisticas ()
  (let ((est (calcular-estadisticas)))
    (verificar "G: el total coincide con el catalogo"
               (= (getf est :total) (length *catalogo*)))
    (verificar "G: los modos suman el total de juegos"
               (= (suma-conteos (getf est :modos)) (length *catalogo*)))
    (verificar "G: las dificultades suman el total de juegos"
               (= (suma-conteos (getf est :dificultades)) (length *catalogo*)))
    (verificar "G: los precios suman el total de juegos"
               (= (suma-conteos (getf est :precios)) (length *catalogo*)))
    (verificar "G: los generos suman la cantidad de generos de todos los juegos"
               (= (suma-conteos (getf est :generos))
                  (reduce #'+ *catalogo*
                          :key (lambda (j) (length (videojuego-generos j))))))
    (verificar "G: cada conteo de genero coincide con el filtro por genero"
               (every (lambda (par)
                        (= (cdr par) (length (filtrar-por-genero (car par)))))
                      (getf est :generos)))
    (verificar "G: 6 juegos individuales, 2 multijugador y 10 con ambos modos"
               (and (= (conteo :individual (getf est :modos)) 6)
                    (= (conteo :multijugador (getf est :modos)) 2)
                    (= (conteo :ambos (getf est :modos)) 10)))
    (verificar "G: 5 faciles, 10 medios y 3 dificiles"
               (and (= (conteo :facil (getf est :dificultades)) 5)
                    (= (conteo :media (getf est :dificultades)) 10)
                    (= (conteo :dificil (getf est :dificultades)) 3)))
    (verificar "G: 3 gratuitos, 8 economicos y 7 premium"
               (and (= (conteo :gratuito (getf est :precios)) 3)
                    (= (conteo :economico (getf est :precios)) 8)
                    (= (conteo :premium (getf est :precios)) 7)))
    (verificar "G: 5 juegos de RPG y 2 de terror"
               (and (= (conteo :rpg (getf est :generos)) 5)
                    (= (conteo :terror (getf est :generos)) 2))))
  (let ((vacio (calcular-estadisticas nil)))
    (verificar "catalogo vacio: total 0 y todos los conteos en 0"
               (and (= (getf vacio :total) 0)
                    (zerop (suma-conteos (getf vacio :generos)))
                    (zerop (suma-conteos (getf vacio :modos))))))
  (verificar "el reporte con catalogo vacio avisa que esta vacio"
             (contiene-p (salida-de "" (lambda () (mostrar-estadisticas nil)))
                         "El catalogo esta vacio"))
  (verificar "el reporte muestra el total real"
             (contiene-p (salida-de "" #'mostrar-estadisticas)
                         (format nil "Total de videojuegos: ~D" (length *catalogo*)))))

(defun pruebas-ficha ()
  (let ((salida (salida-de (lineas "portal") #'consultar-ficha)))
    (verificar "ficha: un solo resultado se muestra directo"
               (and (contiene-p salida "=== Portal 2 ===")
                    (contiene-p salida "Mundo abierto: No"))))
  (verificar "ficha: mundo abierto 'Si' para The Witcher 3"
             (contiene-p (salida-de (lineas "witcher") #'consultar-ficha)
                         "Mundo abierto: Si"))
  (verificar "ficha: varios resultados piden elegir un numero"
             (contiene-p (salida-de (lineas "e" 1) #'consultar-ficha)
                         "=== Stardew Valley ==="))
  (verificar "ficha: sin resultados informa y vuelve"
             (contiene-p (salida-de (lineas "zzz") #'consultar-ficha)
                         "No se encontraron videojuegos"))
  (verificar "ficha: texto vacio informa y vuelve"
             (contiene-p (salida-de (lineas "") #'consultar-ficha)
                         "No ingreso ningun texto")))

(defun pruebas-menu ()
  (let ((salida (salida-de
                 (lineas 2 3 "witcher" 4 5 5 "portal" 6
                         1 5 1 2 1 3 3
                         "abc" 9 0)
                 #'main)))
    (verificar "menu: vuelve al menu tras cada opcion (7 veces)"
               (= (contar-ocurrencias "===== GAMEFINDER =====" salida) 7))
    (verificar "menu: opcion 2 lista el catalogo completo"
               (contiene-p salida "Total: 18"))
    (verificar "menu: opcion 3 encuentra The Witcher 3"
               (contiene-p salida "Resultados para \"witcher\""))
    (verificar "menu: opcion 4 filtra por genero"
               (contiene-p salida "--- Genero: Terror ---"))
    (verificar "menu: opcion 5 muestra la ficha"
               (contiene-p salida "=== Portal 2 ==="))
    (verificar "menu: opcion 6 muestra estadisticas"
               (contiene-p salida "--- Estadisticas del catalogo ---"))
    (verificar "menu: opcion 1 muestra recomendaciones"
               (contiene-p salida "Puntuacion: 15/17"))
    (verificar "menu: las entradas invalidas no cierran el programa"
               (contiene-p salida "Entrada invalida"))
    (verificar "menu: termina con el mensaje de salida"
               (contiene-p salida "Hasta luego.")))
  (verificar "menu: si se acaba la entrada termina sin error"
             (contiene-p (salida-de "" #'main) "Hasta luego.")))


(defun pruebas-validacion-datos ()
  (verificar "el catalogo inicial tiene entre 15 y 20 juegos"
             (<= 15 (length *catalogo*) 20))
  (verificar "todos los juegos del catalogo tienen valores validos"
             (every #'videojuego-valido-p *catalogo*))
  (verificar "un genero inexistente invalida el registro"
             (not (videojuego-valido-p
                   (make-videojuego :nombre "X" :generos '(:inventado) :modo :ambos
                                    :dificultad :facil :experiencia :historia
                                    :mundo-abierto nil :requisitos :bajos
                                    :precio :premium))))
  (verificar "un registro sin nombre es invalido"
             (not (videojuego-valido-p (make-videojuego))))
  (verificar "el catalogo inicial no tiene nombres duplicados"
             (not (nombres-duplicados-p *catalogo*)))
  (verificar "se detectan nombres duplicados aunque cambien las mayusculas"
             (nombres-duplicados-p (list (juego-de-prueba "Hades")
                                         (juego-de-prueba "HADES")))))

(defun pruebas-catalogos-vacios ()
  (verificar "catalogo vacio: verificar-catalogo lo marca como incorrecto"
             (null (let ((*standard-output* (make-broadcast-stream)))
                     (verificar-catalogo nil))))
  (verificar "catalogo vacio: el listado informa que no hay videojuegos"
             (contiene-p (salida-de "" (lambda () (mostrar-listado nil "Prueba")))
                         "No se encontraron videojuegos"))
  ;; Recorre el menu completo con el catalogo vacio: no debe haber errores.
  (let ((salida (let ((*catalogo* nil))
                  (salida-de (lineas 2 3 "witcher" 4 1 6 1 9 3 4 6 4 4 0) #'main))))
    (verificar "catalogo vacio: listado, busqueda y filtro avisan sin resultados"
               (>= (contar-ocurrencias "No se encontraron videojuegos" salida) 3))
    (verificar "catalogo vacio: las estadisticas avisan que esta vacio"
               (contiene-p salida "El catalogo esta vacio"))
    (verificar "catalogo vacio: las recomendaciones avisan que no hay"
               (contiene-p salida "No hay recomendaciones"))
    (verificar "catalogo vacio: el programa termina normalmente"
               (contiene-p salida "Hasta luego."))))

(defun pruebas-sin-coincidencias ()
  (verificar "terror multijugador: ningun juego cumple los filtros"
             (null (recomendar (make-preferencias :genero :terror :modo :multijugador))))
  (let ((salida (salida-de (lineas 5 2 4 6 4 4) #'obtener-recomendaciones)))
    (verificar "cuestionario sin coincidencias informa que no hay recomendaciones"
               (contiene-p salida "No hay recomendaciones")))
  (verificar "el aviso indica los filtros obligatorios"
             (contiene-p (salida-de "" (lambda () (mostrar-recomendaciones nil)))
                         "Genero, Modo de juego, Presupuesto")))

(defun pruebas-entradas-menu ()
  (let ((salida (salida-de (lineas "" " " "-1" "1.5" "abc" 0) #'main)))
    (verificar "E: cinco entradas invalidas seguidas muestran cinco avisos"
               (= (contar-ocurrencias "Entrada invalida" salida) 5))
    (verificar "E: despues de las entradas invalidas el menu sigue activo y sale con 0"
               (and (= (contar-ocurrencias "===== GAMEFINDER =====" salida) 1)
                    (contiene-p salida "Hasta luego.")))))

(defun ejecutar-pruebas ()
  "Ejecuta todas las pruebas. Devuelve T si ninguna fallo."
  (setf *pruebas-fallidas* 0
        *pruebas-ejecutadas* 0)
  (pruebas-catalogo)
  (pruebas-busqueda)
  (pruebas-filtro-genero)
  (pruebas-entrada)
  (pruebas-preferencias)
  (pruebas-cuestionario)
  (pruebas-puntuacion)
  (pruebas-filtros-obligatorios)
  (pruebas-orden)
  (pruebas-flujo-recomendacion)
  (pruebas-estadisticas)
  (pruebas-ficha)
  (pruebas-menu)
  (pruebas-validacion-datos)
  (pruebas-catalogos-vacios)
  (pruebas-sin-coincidencias)
  (pruebas-entradas-menu)
  (format t "~%Pruebas ejecutadas: ~D~%Pruebas fallidas: ~D~%"
          *pruebas-ejecutadas* *pruebas-fallidas*)
  (zerop *pruebas-fallidas*))

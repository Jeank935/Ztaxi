# Dirección visual de Ztaxi

Se conserva la referencia explícita del usuario: mapa oscuro gris azulado, sin edificios 3D ni exceso de etiquetas, vías principales legibles y locales discretos en verde apagado. La tarea de esta pantalla es elegir recogida y destino.

El mapa ocupa el espacio disponible sobre una bandeja inferior clara. La bandeja contiene dos campos seleccionables y una acción principal. Un toque cambia solo el punto activo; cambiar recogida conserva el destino. Las coordenadas se muestran como coordenadas hasta integrar nombres de direcciones, sin inventar locales ni rutas.

Colores: suelo `#414650`, agua `#303741`, vías `#525b66`/`#7a858e`, referencias `#a9cfbc`, superficie `#f8faf8`, texto `#17251f`, acción `#214e39`. Tipografía de plataforma legible; no se descarga una fuente para la demo. Controles de al menos 48 píxeles, panel desplazable en pantallas pequeñas y créditos visibles fuera del panel.

Estados necesarios: acceso simulado explícito, recogida pendiente, destino pendiente, puntos iguales, punto fuera del área, revisión de puntos, créditos, error de carga y errores de marcadores. El objetivo móvil se comprueba además con una vista web estrecha; la validación nativa requiere un dispositivo o emulador.

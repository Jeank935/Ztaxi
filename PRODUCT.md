# Ztaxi

Aplicación móvil de pasajeros y conductores para Zamora, Ecuador. Se mantiene Flutter como plataforma, con Android como primera prueba y compatibilidad iOS por validar.

El trabajo actual integra mapas y selección de puntos. Se conserva acceso simulado antes del mapa por decisión del usuario. El servidor, SMS, despacho, conductores y monetización se implementarán por etapas; no son prestaciones operativas de esta demo.

Preferencias confirmadas: interfaz sencilla en español, mapa oscuro gris azulado, pocas etiquetas y puntos de referencia útiles; selección de ubicaciones en el mapa, licencias que permitan uso comercial conservando los avisos.

La autorización vigente es integrar MapLibre nativo, sin reescribir la aplicación a React ni convertir mapcn en una WebView. Los cambios locales preexistentes en el lockfile y registradores de plugins se guardaron en `../migration-backups/ztaxi-before-maplibre.patch` antes de resolver las nuevas dependencias.

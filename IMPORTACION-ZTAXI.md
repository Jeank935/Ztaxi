# Base de Ztaxi

Código importado de [Elite Taxi](https://github.com/yazan-alsamman/Taxi-app-Elite-), revisión `b06de5165b9cf66f88c7d0e1dde0917c7c8ceb1d`. Se conserva su licencia MIT en `LICENSE`, incluidos sus avisos de copyright.

Este repositorio contiene la base Flutter original, pendiente de adaptar y validar para Ztaxi. La importación no equivale a una aplicación lista para producción.

## Configuración pendiente

- Configurar un proyecto propio de Firebase con FlutterFire y regenerar `lib/firebase_options.dart` y `firebase.json`; los identificadores originales aún son referencias del proyecto de origen.
- La nueva pantalla usa MapLibre/OpenFreeMap y ya no requiere claves de Google Maps. Firebase sigue pendiente para las funciones con servidor; consulta `MAPAS.md`.
- Revisar restricciones, permisos y facturación de los servicios elegidos antes de usarlos.
- Los resultados de compilación, configuraciones locales y archivos de firma no se versionan.

## Trabajo pendiente antes de un piloto

El código de origen tiene funciones incompletas y problemas conocidos: la solicitud de viajes y el acceso real necesitan trabajo, y el código heredado de tarjetas guarda número y CVV en Firestore. La nueva pantalla de MapLibre permite revisar puntos y no presenta una solicitud de taxi ni ofrece pagos. No usar datos de tarjetas reales; sustituir ese flujo por una pasarela con tokenización antes de habilitar pagos.

Consulta `SETUP.md` para la guía original. No se ha validado en esta importación el inicio de sesión, los viajes ni los pagos con servicios reales.

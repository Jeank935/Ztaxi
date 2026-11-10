# Base de Ztaxi

Código importado de [Elite Taxi](https://github.com/yazan-alsamman/Taxi-app-Elite-), revisión `b06de5165b9cf66f88c7d0e1dde0917c7c8ceb1d`. Se conserva su licencia MIT en `LICENSE`, incluidos sus avisos de copyright.

Este repositorio contiene la base Flutter original, pendiente de adaptar y validar para Ztaxi. La importación no equivale a una aplicación lista para producción.

## Configuración pendiente

- Configurar un proyecto propio de Firebase con FlutterFire y regenerar `lib/firebase_options.dart` y `firebase.json`; los identificadores originales aún son referencias del proyecto de origen.
- Sustituir `YOUR_FIREBASE_API_KEY` y `YOUR_GOOGLE_MAPS_API_KEY` por la configuración propia correspondiente. Las claves originales se retiraron de los archivos fuente antes de publicar esta copia.
- Revisar restricciones, permisos y facturación de los servicios elegidos antes de usarlos.
- Los resultados de compilación, configuraciones locales y archivos de firma no se versionan.

## Trabajo pendiente antes de un piloto

La versión importada tiene funciones incompletas y problemas conocidos: el botón de confirmar viaje no crea una solicitud, el acceso y los perfiles necesitan revisión, y el código de tarjetas guarda número y CVV en Firestore. No usar datos de tarjetas reales; sustituir ese flujo por una pasarela con tokenización antes de habilitar pagos.

Consulta `SETUP.md` para la guía original. No se ha validado en esta importación el inicio de sesión, los viajes ni los pagos con servicios reales.

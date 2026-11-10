# Mapas de Ztaxi

La aplicación usa Flutter y `maplibre_gl` 0.27.1. En Android e iOS el mapa lo renderiza MapLibre Native; Chrome sirve para comprobar la interfaz con MapLibre GL JS. No se usa una página React ni mapcn dentro de una WebView.

## Probar ahora

```powershell
cd "C:\Users\ASUS FLOW\Desktop\ZamoraTaxi\Ztaxi"
flutter pub get
flutter run -d chrome
```

La entrada predeterminada es una demo aislada: teléfono `0990000000`, código `123456`. No inicializa Firebase ni crea sesiones o SMS. Selecciona la recogida y el destino tocando el mapa o usando su centro. Los puntos se conservan en memoria mientras editas; aún no se guardan como viajes ni se calcula una ruta por calles. No hay conductores, tarifas, pagos ni solicitudes reales en este flujo. No se solicita GPS: «Volver al centro de Zamora» centra una coordenada de referencia.

El rectángulo permitido es un área técnica de prueba alrededor de Zamora, no un límite administrativo ni una zona de servicio aprobada. Los puntos muestran coordenadas; búsqueda de locales, direcciones y rutas se integrarán mediante servicios independientes. No se conectan servicios públicos de geocodificación o rutas sin revisar primero sus condiciones de uso y capacidad.

## Probar en Android

Se necesitan Android SDK con API 36, JDK 21 y un dispositivo o emulador. Se retiró la ruta fija a JDK 17 del proyecto de origen; Flutter debe usar JDK 21. El proyecto y el plugin usan AGP 8.13.2, Gradle 8.13 y Kotlin 2.4.10. El plugin elige el motor OpenGL de MapLibre Native.

```powershell
flutter doctor
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
```

Reemplaza `ID_DEL_DISPOSITIVO` por el identificador que muestra `flutter devices`. En esta máquina faltaba Android SDK al comenzar la integración; la prueba web no demuestra el rendimiento ni la compatibilidad nativa. Para iOS se requiere macOS/Xcode y la versión mínima del proyecto es iOS 15 por las dependencias existentes de Firebase (MapLibre admite iOS 13).

La compilación de distribución todavía necesita firma propia. La firma de depuración del repositorio original no debe utilizarse para publicar.

## Modo con servidor

`flutter run -d chrome --dart-define=ZTAXI_DEMO=false` habilita la entrada original de Firebase, separada de la demo. Primero se debe configurar un proyecto propio de Firebase mediante FlutterFire, regenerar sus archivos y revisar las reglas de acceso. Con las claves de ejemplo se muestra un aviso de configuración. Este modo aún no se considera validado para operar: permanecen las limitaciones del proyecto original en autenticación, conductor y pagos. Las funciones de tarjetas heredadas no se ofrecen desde la nueva pantalla del mapa.

## Arquitectura

- `GeoCoordinate`: latitud/longitud sin dependencias de Google, MapLibre o Firestore.
- `TripSelection`: conserva recogida y destino, rechaza puntos inválidos y evita revisar un viaje con dos puntos iguales.
- `ZamoraMap`: convierte esas coordenadas al SDK de MapLibre y mantiene una instancia del mapa al editar.
- Los perfiles conservan sus campos Firestore y el formato `GeoPoint`; las ubicaciones se eligen con el mismo selector de mapa. No requiere migrar la base de datos existente.
- El antiguo cliente de Google Directions se retiró; no se sustituye por una línea recta presentada como ruta.

## Licencias y proveedores

| Componente | Condiciones y función |
| --- | --- |
| Elite Taxi | MIT. Se conserva `LICENSE`; también aparece en la pantalla de licencias. |
| maplibre_gl 0.27.1 | BSD de sus componentes, con avisos incluidos en el paquete y en el registro de licencias de Flutter. Permite distribución comercial conservando los avisos; no concede derechos sobre marcas. |
| Estilo Ztaxi | `assets/zamora-night.json`, redactado para este proyecto. No copia los estilos CARTO de mapcn. |
| OpenFreeMap | Instancia pública gratuita y con uso comercial permitido según su sitio; fuente vectorial, glifos y atribuciones. No ofrece garantía SLA. El alojamiento puede cambiarse sin cambiar el modelo de viajes. |
| OpenStreetMap | Los datos están bajo ODbL, no MIT. Debe mantenerse la atribución y revisarse ODbL si se redistribuye o modifica una base de datos. |
| OpenMapTiles | Esquema y créditos correspondientes al proveedor. Se conserva su atribución. |

El mapa necesita conexión. La atribución permanece visible y abre los enlaces y las licencias. El uso de licencias permisivas no elimina los requisitos de privacidad, transporte o publicación de la aplicación.

Fuentes comprobadas el 9 de noviembre de 2026:

- https://pub.dev/packages/maplibre_gl/versions/0.27.1
- https://pub.dev/packages/maplibre_gl/versions/0.27.1/license
- https://openfreemap.org/
- https://openfreemap.org/tos/
- https://www.openstreetmap.org/copyright

## Verificación

```powershell
flutter test
flutter analyze lib test
flutter build web --release
```

Para medir peso, memoria, batería y fluidez se necesita una compilación de perfil/distribución en un teléfono real. Una captura en Chrome no permite prometer mejoras de tamaño o rendimiento frente a Google Maps.

Resultados de esta integración: seis pruebas aprobadas; análisis de los nuevos componentes, entrada, perfil y pruebas sin incidencias; compilación web de distribución aprobada y prueba visual con recogida/destino. El análisis global conserva avisos de módulos heredados, incluidos pagos. No se compiló ni ejecutó Android/iOS por faltar Android SDK y macOS/Xcode, respectivamente.

# D2Sync

## Qué es
App de escritorio Windows para gestionar cuentas de Steam en el mismo PC: sincroniza la configuración de Dota 2 (carpeta `570`) entre cuentas, guarda/restaura backups manuales, elimina cuentas locales (con opción de quitarlas del launcher de Steam) y activa/desactiva Steam Cloud para Dota 2.

## Cómo se ve y funciona
Ventana sin marco nativo (franja superior arrastrable con minimizar/cerrar). Al abrir, splash de 2.5s ("D2Sync Cargando...", puramente visual). Luego pantalla **Home**: título "D2Sync" / "by Nexo", botón de idioma (banderita 🇪🇸/🇺🇸) arriba a la derecha, y una grilla de 5 botones (Sync data, Backup, Delete Acc, Cloud, Optimized — estas etiquetas quedan siempre en inglés, elegidas así por el usuario). Cada botón abre una **pantalla de opción** (header con "← Regresar"/"← Back" + logo + botón de idioma, título/descripción de la sección y un botón "Cómo funciona"/"How it works" que abre un popup con los pasos, y el contenido de esa función). Tanto el Home como cada pantalla de opción comparten la misma barra inferior: botón "Actualizar cuentas"/"Update accounts" (detecta cuentas Steam, se bloquea 5s tras usarlo), cantidad de cuentas encontradas, y versión + fecha de última actualización — con un aviso clickeable ahí mismo si hay una actualización pendiente que el usuario canceló. El usuario elige cuenta(s) de Steam detectadas automáticamente desde el registro (`HKCU\Software\Valve\Steam`) y ejecuta la acción; toda operación destructiva pide confirmación y las de sync/carga de backup guardan un respaldo temporal que se restaura si algo falla. Toda la interfaz es bilingüe español/inglés neutral, alternable en cualquier momento con el botón de banderita.

## Stack
- Flutter (Windows desktop) → UI y lógica de la app
- `window_manager` → ventana sin marco, arrastre, minimizar/cerrar
- `file_picker` → selección de carpetas para backups
- `path` → normalización de rutas
- `flutter_svg` → banderitas EN/ES del selector de idioma (SVG inline, no assets ni emoji — Windows no renderiza bien los emoji de bandera)
- C# (`csc.exe` de .NET Framework, sin proyecto/solución) → lanzador portable que empaqueta el build de Flutter como recurso embebido dentro de un único `.exe`, y que además revisa actualizaciones remotas
- GitHub (repo `AndreDiaz11/d2sync-updates`, público) → hosting del manifiesto de versión y del zip de la última actualización

## Estructura
```
_.D2Sync/
├── D2Sync_v1.1.0.exe        ← compilado final (lanzador portable, en la raíz)
├── DOCUMENTACION.md         ← documentación de usuario/proyecto
├── PROJECT.md
└── source/
    ├── build_exe.bat        ← compila el lanzador final embebiendo app_new.zip + ícono
    ├── launcher/
    │   ├── PortableLauncher.cs   ← extrae app.zip embebido y lanza D2Sync.exe
    │   ├── build_launcher.ps1    ← recompila solo el lanzador (con ícono)
    │   └── app_icon.ico          ← ícono embebido en el .exe final
    └── project/              ← proyecto Flutter (código fuente)
        ├── lib/
        │   ├── main.dart                       ← entrypoint, parsea --launcher=, config de ventana
        │   ├── core/launch_args.dart            ← ruta del lanzador recibida por argumento
        │   ├── theme/palette.dart               ← colores compartidos
        │   ├── i18n/
        │   │   ├── app_language.dart             ← LanguageController (ChangeNotifier), persiste en language.txt
        │   │   └── strings.dart                  ← clase S con todos los textos traducibles (ES/EN)
        │   ├── models/
        │   │   ├── cuenta_steam.dart
        │   │   ├── app_section.dart             ← las 5 secciones: título (fijo en inglés) + descripción/pasos bilingües
        │   │   ├── optimization_option.dart      ← 8 checkboxes de Optimized, descripción bilingüe
        │   │   └── update_status.dart
        │   ├── services/
        │   │   ├── steam_sync_service.dart       ← lógica Steam/Dota2/VDF (+ Launch Options)
        │   │   └── update_status_service.dart    ← lee status.json escrito por el lanzador
        │   ├── widgets/
        │   │   ├── common.dart                   ← tarjetas/botones/popups compartidos
        │   │   ├── bottom_bar.dart                ← barra de cuentas + versión/actualización
        │   │   └── language_toggle.dart           ← botón de banderita ES/EN
        │   └── screens/
        │       ├── splash_screen.dart
        │       ├── home_screen.dart               ← grilla de 5 botones
        │       ├── option_screen.dart             ← header "Regresar" + descripción + contenido
        │       ├── app_shell.dart                 ← orquesta splash/home/opción, estado compartido
        │       └── sections/                      ← una pantalla por función
        │           ├── sync_section.dart
        │           ├── backup_section.dart
        │           ├── delete_section.dart
        │           ├── cloud_section.dart
        │           └── optimized_section.dart
        ├── windows/runner/resources/app_icon.ico ← mismo ícono, para el exe interno de Flutter
        └── pubspec.yaml
```

## Archivos clave
- `PortableLauncher.cs`: al ejecutarse, (1) asegura que exista localmente la versión base embebida, (2) intenta leer `version.json` desde GitHub (timeout corto, si falla sigue con la versión local sin bloquear), (3) si hay una versión más nueva, muestra un diálogo "Actualizar/Cancelar" (o se salta el diálogo si se lo llama con `--auto-update`, usado cuando la propia app pide actualizar); si el usuario acepta, descarga el zip con barra de progreso, lo extrae a `%LOCALAPPDATA%\D2Sync\v<version>` y borra la carpeta de la versión anterior, (4) escribe `%LOCALAPPDATA%\D2Sync\status.json` (versión activa, fecha de la última actualización, versión pendiente si la hay) para que la app Flutter lo lea, (5) lanza el exe real pasándole su propia ruta como argumento `--launcher=`.
- `steam_sync_service.dart`: toda la lógica de negocio (lee registro de Windows, parsea/edita archivos VDF de Steam con regex — incluye Steam Cloud y Launch Options de Dota 2 en `localconfig.vdf` —, valida que las rutas de escritura estén dentro de `userdata` antes de tocar nada). Importante: `localconfig.vdf` es un archivo grande donde el appid "570" puede aparecer varias veces en secciones no relacionadas (ej. `apptickets`, datos binarios); `_extraerBloqueAppLocalConfig` primero ubica la sección `apps` y recién ahí busca el appid, para no agarrar la ocurrencia equivocada (bug real encontrado y corregido: la primera versión buscaba "570" en todo el archivo y escribía en el lugar incorrecto).
- `app_shell.dart`: dueño del estado compartido (cuentas detectadas, ocupado/cooldown, sección activa, estado de actualización leído de `status.json`). Si el usuario acepta actualizar desde dentro de la app, relanza el lanzador con `--auto-update` y cierra la instancia actual.
- `optimized_section.dart` / `optimization_option.dart`: 8 checkboxes reales (`-novid`, `-high`, `-nojoy`, `-console`, `-refresh 60`, `+fps_max 0`, `+fps_max_ui 35`, `-gamestateintegration`) que se traducen a flags de Steam Launch Options de Dota 2. Al aplicar, se quitan todas las flags que este programa gestiona (algunas son de dos palabras, se tratan como texto completo, no palabra por palabra) y se vuelven a poner solo las marcadas, sin duplicar ni afectar texto que el usuario haya puesto a mano.
- `build_exe.bat`: build de un solo paso — requiere que `source/app_new.zip` exista (zip del output de `flutter build windows --release`); no se conserva en el repo, se genera y se descarta en cada build.
- `source/update-repo/`: clon local del repo de GitHub `d2sync-updates`, con `version.json` (número de versión + URL del zip) y `app_latest.zip` (build más reciente). Es lo que se sube para publicar una actualización.
- `i18n/app_language.dart` + `i18n/strings.dart`: sistema de idiomas propio (sin paquete `intl`/ARB). `languageController` es un `ChangeNotifier` global con `isEn` (bool); `D2SyncApp` envuelve el `MaterialApp` en un `ListenableBuilder` escuchando ese controller, así que alternar idioma reconstruye toda la app al instante. La preferencia se guarda en `%LOCALAPPDATA%\D2Sync\language.txt` y se carga en `main()` antes de mostrar la ventana. La clase `S` tiene un getter/método por cada texto de la app (ej. `S.back`, `S.syncConfirmMessage(destino, origen)`) que lee `languageController.isEn` en el momento de construirse — no hay que pasar el idioma manualmente por los widgets. Los 5 títulos de sección ("Sync data", "Backup", "Delete Acc", "Cloud", "Optimized") y los flags de Steam Launch Options (`-novid`, etc.) NO se traducen a propósito: son texto elegido explícitamente por el usuario o comandos literales de Steam. Para agregar un texto nuevo: agregar el getter/método a `S` en `strings.dart` con sus dos variantes, y usarlo en el widget en vez de un string literal.

## Instalar y correr
1. `cd source/project && flutter pub get`
2. `flutter build windows --release`
3. Comprimir el contenido de `build/windows/x64/runner/Release/` en `source/app_new.zip`
4. Ejecutar `source/build_exe.bat` → genera `D2Sync_v1.1.0.exe` en la raíz del proyecto

## Publicar una actualización (para que le llegue a todos los que ya tienen el exe)
1. Repetir los pasos 1-3 de arriba para generar el nuevo `app_new.zip`.
2. Copiarlo a `source/update-repo/app_latest.zip` (mismo nombre, reemplaza el anterior).
3. Editar `source/update-repo/version.json` con el número de versión nuevo (ej. `"1.2.0"`).
4. Desde `source/update-repo/`: `git add -A && git commit -m "..." && git push`.
5. Tarda hasta ~5 minutos en propagarse por el CDN de GitHub (`raw.githubusercontent.com` cachea 5 min). Después de eso, a cualquiera que abra su copia del exe (sin importar cuán vieja sea) le va a salir el diálogo de actualización.

## Env vars
No requiere.

## Estado
Funcional: sí | Beta: sí | **Publicado: v1.2.9 en `d2sync-updates` (commit `ee0ed7d`)** — cualquiera con una copia del exe (nueva o vieja, mientras tenga el mecanismo de auto-update) va a recibir el aviso de actualización la próxima vez que lo abra, dentro de ~5 min de propagación del CDN de GitHub.

v1.2.6 agregó soporte bilingüe español/inglés completo (ver `i18n/` en Archivos clave); v1.2.7 rediseñó el selector como dos botones EN/ES lado a lado con bandera; v1.2.8-v1.2.9 corrigieron bugs de ese selector (ver Cambios). Persistido entre sesiones.

Nota aparte: Visual Studio 2026 + workload C++ se había desinstalado solo de esta máquina en una sesión previa (sin razón identificada) y tuvo que reinstalarse para poder compilar.

## Integraciones externas
- GitHub (repo `AndreDiaz11/d2sync-updates`, público) → `version.json` + `app_latest.zip`, consultados por el lanzador al abrir la app. Sin credenciales ni tokens embebidos en el exe (solo lee un repo público vía HTTPS). Para publicar, el push usa las credenciales de Git ya cacheadas en esta máquina (Git Credential Manager).

## Escalabilidad
Para agregar una nueva acción sobre cuentas: añadir método en `SteamSyncService` siguiendo el patrón de validar rutas con `_validarRutaDentroDeUserData` antes de escribir, crear su archivo en `lib/screens/sections/` siguiendo el patrón de `sync_section.dart`, agregarla al enum `AppSection` (título/ícono/descripción) y a la sección `switch` de `app_shell.dart`.

## Compatibilidad
Solo Windows (usa `reg.exe`, `tasklist.exe` y rutas del registro de Steam específicas de Windows).

## Datos de prueba
No aplica (opera sobre instalaciones reales de Steam del usuario).

## Versión
1.2.6 — publicada en el repo de actualizaciones.

## Snapshots
Ninguno.

## Cambios
1. Limpieza: eliminadas carpetas regenerables (`.dart_tool`, `.idea`, `d2sync.iml`, `.flutter-plugins-dependencies`, `windows/flutter/ephemeral`) y asset sin usar (`assets/nexoarena_logo.png` + su entrada en `pubspec.yaml`).
2. Ícono nuevo (círculo de sync cian + monograma "D2" sobre fondo azul degradado) aplicado a `app_icon.ico` (Flutter runner) y embebido en el `.exe` final vía `/win32icon` en `build_exe.bat`/`build_launcher.ps1`.
3. Auto-update: `PortableLauncher.cs` ahora consulta `version.json` en GitHub al abrir, muestra diálogo "Actualizar/Cancelar" si hay versión nueva, descarga con barra de progreso y reemplaza la versión local. Repo dedicado creado: `AndreDiaz11/d2sync-updates` (clonado en `source/update-repo/`).
4. Rediseño completo de interfaz: splash de carga, Home con grilla de 5 botones dentro de un panel visual, pantallas de opción con "Regresar" + caja "Cómo funciona" (resumen + pasos numerados) + panel de contenido, barra inferior compartida. El código se separó de un solo archivo (`sync_screen.dart`) a `theme/`, `widgets/`, `models/`, `services/` y `screens/sections/`.
5. Sección Optimized completa: las 8 opciones reales de Launch Options de Dota 2 con descripción de cada una; lógica de aplicar/quitar sin duplicar, incluye poder quitar una opción o todas.
6. Popup "Aplicando cambios..." (mínimo 2s) compartido por las 5 secciones al ejecutar cualquier acción.
7. **Revisión completa antes de publicar** (pedida explícitamente por el usuario): 4 bugs reales corregidos —
   - `_iniciarCooldown()` y una rama de `_solicitarActualizacion()` en `app_shell.dart` llamaban `setState` sin verificar `mounted` (riesgo de excepción si la ventana se cierra en medio de una operación).
   - Condición de carrera en `optimized_section.dart`: si el usuario cambiaba de cuenta muy rápido, el resultado async de la cuenta anterior podía pisar la selección de la nueva.
   - Bug de VDF (el que reportó el usuario): `localconfig.vdf`/`sharedconfig.vdf` buscaban el appid `570` en **todo el archivo** en vez de dentro de la sección `apps`, agarrando ocurrencias equivocadas (ej. `apptickets`, datos binarios). Corregido con `_extraerBloqueApp()`, aplicado tanto a Launch Options como a Steam Cloud (por si el mismo problema se daba ahí). Verificado directamente contra el archivo real del usuario.
   - `cambiarSteamCloudDota`: si la sección `570` no existía todavía dentro de `apps`, el código la insertaba al final del archivo en vez de dentro de `apps`, rompiendo la estructura esperada por Steam. Corregido.
   - Limpieza de código muerto: función `_extraerBloqueVdf` sin uso, getter `hayActualizacionPendiente` sin uso, constante `borderHi` sin uso, dependencia `cupertino_icons` sin uso.
   - `DOCUMENTACION.md` reescrito completo (describía la arquitectura de un solo archivo, ya no existe).
8. Versión bumpeada a **1.2.0** en los 3 lugares donde vive el número (`pubspec.yaml`, `app_shell.dart`, `PortableLauncher.cs`) y **publicada** en `d2sync-updates` (commit `da6791b`).
9. v1.2.1 a v1.2.5: ajustes iterativos en Optimized (botón Verificar al lado de Optimizar, scroll visible solo en la lista de checkboxes), rediseño de espaciado en las 5 secciones, caja "Cómo funciona" colapsable y luego convertida en botón + popup, eliminación de tarjetas de estado vacías cuando no hay nada que mostrar.
10. **v1.2.6**: sistema de idiomas propio agregado — `i18n/app_language.dart` (`LanguageController`, persiste en `language.txt`) + `i18n/strings.dart` (clase `S` con todos los textos en ambos idiomas) + `widgets/language_toggle.dart`. Se reemplazaron todos los strings literales en español de la app (~9 archivos: `common.dart`, `bottom_bar.dart`, `app_shell.dart`, `splash_screen.dart` y las 5 secciones) por llamadas a `S.*`. Los 5 títulos de botones del Home y los flags de Steam Launch Options quedan sin traducir a propósito.
11. **v1.2.7**: `language_toggle.dart` rediseñado a pedido del usuario — de un solo botón que alterna a dos botones fijos "EN"/"ES" lado a lado (cada uno con su bandera), el idioma activo resaltado con fondo/borde cian. Se agregó `LanguageController.elegir(AppLanguage)` para setear un idioma directo (además de `alternar()`). Verificado con `flutter analyze` (0 issues) y build de release funcional antes de publicar cada versión.
12. **v1.2.8**: dos bugs reportados por el usuario — (a) las banderas emoji (🇺🇸/🇪🇸) no se ven como banderas en Windows (la fuente de emoji del sistema no las soporta, muestra letras sueltas), reemplazadas por banderas dibujadas con widgets; (b) el idioma no se reflejaba en pantalla hasta cambiar de sección — causa raíz: `main.dart` tenía `home: const AppShell()`; al ser `const`, Flutter reutiliza el mismo objeto de widget en cada rebuild y la reconciliación lo salta por completo (misma referencia), así que el `ListenableBuilder` de `languageController` nunca llegaba a reconstruir la pantalla real. Se sacó el `const`.
13. **v1.2.9**: el mismo patrón de bug del punto anterior existía un nivel más abajo — `LanguageToggle()` se instanciaba con `const` (directo en `option_screen.dart`, o envuelto en `const Align(...)` en `home_screen.dart`), así que el propio botón nunca recalculaba cuál idioma estaba activo (el texto de la app sí cambiaba, pero el resaltado del botón se quedaba pegado). Se sacó el `const` de ambos sitios. Además, a pedido del usuario, las banderas dibujadas con `Container` se reemplazaron por SVG reales usando el paquete `flutter_svg` (SVG inline en el propio código, sin archivos de assets), mismo patrón usado en el proyecto "futbol predict".

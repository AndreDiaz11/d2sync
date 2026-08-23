# D2Sync by Nexo — Documentación

## Descripción general

D2Sync es una aplicación de escritorio para Windows que permite gestionar configuraciones de Dota 2 entre múltiples cuentas de Steam. Funciona como un ejecutable portátil único (`D2Sync_v1.1.0.exe`) que no requiere instalación, y se actualiza solo (ver sección de Auto-update).

---

## Estructura del proyecto

```
_.D2Sync/
├── D2Sync_v1.1.0.exe              ← Ejecutable portátil final (distribuible)
├── PROJECT.md                      ← Estado del proyecto para retomar trabajo
├── DOCUMENTACION.md                ← Este archivo
└── source/
    ├── build_exe.bat               ← Compila el lanzador embebiendo app_new.zip + ícono
    ├── launcher/
    │   ├── PortableLauncher.cs     ← Wrapper C# que embebe el ZIP de Flutter y maneja auto-update
    │   ├── build_launcher.ps1      ← Recompila solo el lanzador (con ícono)
    │   └── app_icon.ico            ← Ícono embebido en el .exe final
    ├── update-repo/                ← Clon local del repo GitHub `AndreDiaz11/d2sync-updates`
    │   ├── version.json            ← Manifiesto: versión actual + URL del zip
    │   └── app_latest.zip          ← Última build publicada
    └── project/                    ← Proyecto Flutter
        ├── pubspec.yaml
        ├── windows/                ← Configuración nativa Windows (CMake, runner, ícono)
        └── lib/
            ├── main.dart                    ← Entrypoint, parsea --launcher=, config de ventana
            ├── core/launch_args.dart        ← Ruta del lanzador recibida por argumento
            ├── theme/palette.dart           ← Colores compartidos
            ├── models/
            │   ├── cuenta_steam.dart
            │   ├── app_section.dart         ← Las 5 secciones: título/ícono/resumen/pasos
            │   ├── optimization_option.dart ← Lista de checkboxes de Optimized
            │   └── update_status.dart
            ├── services/
            │   ├── steam_sync_service.dart      ← Lógica Steam/Dota2/VDF
            │   └── update_status_service.dart   ← Lee status.json escrito por el lanzador
            ├── widgets/
            │   ├── common.dart               ← Tarjetas/botones/popups/loader compartidos
            │   └── bottom_bar.dart           ← Barra de cuentas + versión/actualización
            └── screens/
                ├── splash_screen.dart
                ├── home_screen.dart           ← Grilla de 5 botones
                ├── option_screen.dart         ← Header "Regresar" + instrucciones + contenido
                ├── app_shell.dart             ← Orquesta splash/home/opción, estado compartido
                └── sections/                  ← Una pantalla por función
                    ├── sync_section.dart
                    ├── backup_section.dart
                    ├── delete_section.dart
                    ├── cloud_section.dart
                    └── optimized_section.dart
```

---

## Stack técnico

| Componente | Tecnología |
|---|---|
| UI | Flutter (Windows desktop) / Dart |
| Ventana | `window_manager` — sin marco nativo, franja de arrastre con minimizar/cerrar |
| Selector de archivos | `file_picker` |
| Launcher portátil | C# (.NET Framework, CSC.exe) |
| Empaquetado | ZIP del build de Flutter embebido como recurso en el exe del launcher |
| Caché de extracción | `%LocalAppData%\D2Sync\v<version>\` |
| Auto-update | GitHub (`AndreDiaz11/d2sync-updates`, público) vía `version.json` + `app_latest.zip` |

---

## Cómo funciona el ejecutable portátil

```
D2Sync_v1.1.0.exe  (C# launcher, siempre el mismo archivo que la gente descarga)
  └── app.zip  (embebido como recurso, la versión "base" de fábrica)
        └── build de Flutter (d2sync.exe + DLLs + assets)
```

Al ejecutar el `.exe`, el launcher C# (`PortableLauncher.cs`):

1. Verifica si ya existe una copia extraída en `%LocalAppData%\D2Sync\v<version>\`; si no, extrae el `app.zip` embebido ahí.
2. Intenta leer `version.json` desde GitHub (timeout de 4s; si falla — sin internet, repo caído — sigue con la copia local sin bloquear el arranque).
3. Si hay una versión más nueva publicada, muestra un diálogo "Actualizar/Cancelar" (o se lo salta si se lo llama con el argumento `--auto-update`, que es como la app lo invoca cuando el usuario acepta actualizar desde dentro).
4. Si el usuario acepta, descarga el zip nuevo con barra de progreso, lo extrae a una carpeta de versión nueva y borra la anterior.
5. Escribe `%LocalAppData%\D2Sync\status.json` (versión activa, fecha de la última actualización, versión pendiente si la hay) para que la app Flutter lo lea y lo muestre en la barra inferior.
6. Lanza el `.exe` real de esa carpeta, pasándole su propia ruta como argumento `--launcher=` (para que la app pueda relanzarlo si el usuario pide actualizar desde dentro).

### Auto-update: publicar una versión nueva

1. `flutter build windows --release` en `source/project`.
2. Comprimir `build/windows/x64/runner/Release/*` en un zip.
3. Copiarlo a `source/update-repo/app_latest.zip` (mismo nombre, reemplaza el anterior).
4. Editar `source/update-repo/version.json` con el número de versión nuevo.
5. Desde `source/update-repo/`: `git add -A && git commit -m "..." && git push`.
6. Tarda hasta ~5 minutos en propagarse por el CDN de GitHub. Después de eso, cualquiera que abra su copia del exe (sin importar cuán vieja sea, mientras tenga el mecanismo de auto-update) recibe el aviso de actualización.

---

## Cómo compilar desde cero

```powershell
cd source\project
flutter pub get
flutter build windows --release

# Empaquetar el build en un zip
Compress-Archive -Path "build\windows\x64\runner\Release\*" -DestinationPath "..\app_new.zip" -Force

# Compilar el lanzador final (embebe app_new.zip + ícono)
cd ..
.\build_exe.bat
```

`build_exe.bat` ya usa rutas absolutas fijas, no requiere copiar a una carpeta sin espacios.

---

## Paleta de colores (`theme/palette.dart`)

| Constante | Hex | Uso |
|---|---|---|
| `bgTop` | `#5878B8` | Fondo degradado arriba |
| `bgBot` | `#384E8A` | Fondo degradado abajo |
| `darkCard` | `#1A1F38` | Fondo de tarjetas y selectores |
| `darkTab` | `#12172A` | Texto sobre botones cyan |
| `cyanLight` | `#5AE4FF` | Acento principal, botones activos, iconos |
| `cyanDark` | `#1890D8` | Extremo oscuro del degradado cyan |
| `iconBlue` | `#5B9BD5` | Icono cuenta origen |
| `iconOrange` | `#E8924E` | Icono cuenta destino / optimizar |
| `textSub` | `#B0C4E8` | Texto secundario |
| `borderHi` | `#18FFFFFF` | Borde sutil |

**Colores de estado (hardcoded en las secciones):** verde `#2ECC71` (éxito/activo), rojo claro `#FF6B6B` (error/inactivo), naranja `#FFB74D` (sin config), rojo `#CC2222` (destructivo), verde oscuro `#1A7A3A` (activar cloud).

---

## Arquitectura de la UI

```
AppShell (StatefulWidget, raíz)
├── Splash (2.5s, solo visual)
├── _dragStrip()                — franja arrastrable con minimizar/cerrar
└── contenido:
    ├── HomeScreen               — cuando no hay sección elegida
    │   ├── título "D2Sync" / "by Nexo"
    │   ├── panel con grid de 5 botones (Sync data, Backup, Delete Acc, Cloud, Optimized)
    │   └── BottomBar
    └── OptionScreen             — cuando hay una sección elegida
        ├── header: "← Regresar" + logo
        ├── caja "CÓMO FUNCIONA": resumen + pasos numerados
        ├── panel con el contenido de la sección (SyncSection / BackupSection / ...)
        └── BottomBar
```

`AppShell` es dueño del estado compartido: cuentas detectadas, ocupado/cooldown, sección activa, estado de actualización. Cada `*Section` maneja su propio estado local (cuenta(s) elegida(s), etc.) y recibe callbacks (`onBusyChanged`, `onEstadoChanged`) para comunicarse hacia arriba.

**Widgets reutilizables (`widgets/common.dart`):**

| Widget / función | Descripción |
|---|---|
| `AccountCard` | Selector de cuenta que abre un popup modal |
| `AccountPickerDialog` | Modal de selección con lista scrollable |
| `StatusCard` | Tarjeta de estado contextual (icono + título + subtexto) |
| `GradButton` | Botón degradado cyan con animación de escala |
| `DarkPillButton` | Botón oscuro pill (usado en la barra inferior) |
| `CloudToggleBtn` | Botón coloreado con glow (verde/rojo para Cloud) |
| `ConfirmBtn` / `confirmar()` | Botón y función de popup de confirmación (azul/rojo) |
| `CloseBtn` | Botón X para cerrar popups |
| `WinBtn` | Botón de ventana (minimizar/cerrar) |
| `ejecutarConCarga()` | Ejecuta una acción mostrando un popup "Aplicando cambios..." de mínimo 2s, y el popup de error si falla. Usado por las 5 secciones. |

---

## Flujos por sección

### Sync data

Copia la carpeta `570` de Dota 2 de una cuenta a otra, con respaldo temporal automático y rollback si algo falla. Las cuentas origen/destino se bloquean mutuamente.

### Backup

Exporta o importa manualmente la carpeta `570` a/desde una carpeta elegida por el usuario (`file_picker`). Cargar un backup pide confirmación y usa el mismo patrón de respaldo temporal con rollback.

### Delete Acc

Borra los datos locales de una cuenta Steam. "Eliminar y quitar de Steam" además la remueve de `loginusers.vdf` y la agrega a una lista de ocultas (`%APPDATA%\D2Sync\d2sync_hidden_accounts.txt`) para que no reaparezca al recargar; requiere Steam cerrado.

### Cloud

Verifica y activa/desactiva el Steam Cloud de Dota 2 para una cuenta, modificando `sharedconfig.vdf`. Requiere Steam y Dota 2 cerrados para cambiar el estado.

### Optimized

Aplica o quita flags de rendimiento en el **Launch Options** de Dota 2 (`localconfig.vdf`), vía checkboxes. Opciones actuales (`models/optimization_option.dart`):

| Flag | Qué hace |
|---|---|
| `-novid` | Se salta el video de introducción |
| `-high` | Prioridad de procesador alta para Dota 2 |
| `-nojoy` | Desactiva soporte de joystick/mando |
| `-console` | Activa la consola de desarrollador |
| `-refresh 60` | Fuerza 60Hz de refresco |
| `+fps_max 0` | Sin límite de FPS en partida |
| `+fps_max_ui 35` | Limita FPS en menús a 35 |
| `-gamestateintegration` | Activa integración de estado del juego (overlays externos) |

Al elegir una cuenta, se leen sus opciones actuales y se marcan los checkboxes correspondientes. Al presionar Optimizar, se quitan **todas** las flags que esta app gestiona (estén o no marcadas) y se vuelven a poner solo las marcadas — así desmarcar una opción y volver a optimizar la quita, sin duplicar nada ni tocar texto que el usuario haya puesto a mano. Requiere Steam cerrado (si no, Steam puede sobrescribir el archivo con lo que tiene en memoria).

---

## Modelo de datos

### `CuentaSteam`

```dart
class CuentaSteam {
  final String steamId;         // ID numérico corto (carpeta userdata)
  final String nombre;          // Nombre de perfil Steam
  final String rutaCuenta;      // .../Steam/userdata/[id]/
  final String rutaConfigCuenta;// .../Steam/userdata/[id]/570/
  final String rutaSteamCloudCuenta; // .../Steam/userdata/[id]/7/remote/sharedconfig.vdf

  String get nombreVisible;     // "steamId" si nombre==steamId, "steamId - nombre" si difieren
}
```

### `SteamSyncService`

| Método | Descripción |
|---|---|
| `cargarCuentas()` | Lee `userdata/` del Steam instalado, construye lista de cuentas |
| `ejecutarSincronizacion(origen, destino)` | Copia carpeta 570 con backup transaccional |
| `guardarBackupCuenta(cuenta, carpeta)` | Exporta 570 a carpeta elegida |
| `cargarBackupEnCuenta(carpeta570, destino)` | Importa backup con transacción |
| `eliminarCuenta(cuenta, {quitarDelLauncher})` | Elimina datos; opcionalmente limpia loginusers.vdf |
| `obtenerSteamCloudDota(cuenta)` | Lee cloudenabled de sharedconfig.vdf → bool? |
| `cambiarSteamCloudDota(cuenta, activar)` | Modifica sharedconfig.vdf |
| `obtenerLaunchOptionsDota(cuenta)` | Lee el Launch Options actual de localconfig.vdf |
| `aplicarOptimizacionesDota(cuenta, gestionadas, activas)` | Reescribe el Launch Options |
| `estaSteamAbierto()` / `estaDotaAbierto()` | Verifica procesos vía tasklist |

**Nota importante sobre VDF:** `localconfig.vdf` y `sharedconfig.vdf` son archivos grandes con muchas secciones donde el appid `570` puede aparecer mencionado varias veces en contextos no relacionados (ej. `apptickets`, datos binarios de autenticación). `_extraerBloqueApp()` primero ubica la sección `apps` y recién ahí busca el appid dentro de ella, para no agarrar la ocurrencia equivocada.

---

## Auto-update: piezas en el lado de Flutter

| Archivo | Rol |
|---|---|
| `core/launch_args.dart` | Guarda la ruta del lanzador recibida por `--launcher=` |
| `services/update_status_service.dart` | Lee `%LocalAppData%\D2Sync\status.json` |
| `models/update_status.dart` | Versión activa, fecha última actualización, versión pendiente |
| `screens/app_shell.dart` → `_solicitarActualizacion()` | Si hay actualización pendiente y el usuario confirma, relanza el launcher con `--auto-update` y cierra la instancia actual (`exit(0)`) |

---

## Consideraciones técnicas

- **VDF encoding**: los archivos de Steam pueden ser UTF-8 o Latin-1. El servicio intenta UTF-8 primero y cae a Latin-1 si falla, preservando el encoding original al escribir.
- **Seguridad de rutas**: toda operación de escritura/borrado valida que la ruta esté dentro de `userdata/` antes de ejecutarse.
- **Transaccionalidad**: sincronización, carga de backup y eliminación usan backup temporal con rollback automático si algo falla.
- **Detección de Steam ID**: se usa el ID de la carpeta en `userdata/`. El nombre visible se resuelve leyendo `localconfig.vdf` de la cuenta o `loginusers.vdf` como fallback.
- **Cuentas ocultas**: las cuentas eliminadas con "quitar de Steam" se persisten en `%APPDATA%\D2Sync\d2sync_hidden_accounts.txt`.
- **Cooldown de "Actualizar cuentas"**: el botón se bloquea 5 segundos después de cada uso para evitar reconsultas seguidas al registro/disco.

---

## Versión

`v1.1.0` (número de app sin cambiar; las mejoras de esta ronda viajan por el mecanismo de auto-update) — Flutter / Dart · Windows desktop (x64)

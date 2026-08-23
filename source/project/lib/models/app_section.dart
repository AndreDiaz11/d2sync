import 'package:flutter/material.dart';

import '../i18n/app_language.dart';

enum AppSection { sync, backup, delete, cloud, optimized }

extension AppSectionInfo on AppSection {
  // Los nombres de los botones se dejan iguales en los dos idiomas (son la
  // marca de cada función, no texto descriptivo).
  String get titulo {
    switch (this) {
      case AppSection.sync:
        return 'Sync data';
      case AppSection.backup:
        return 'Backup';
      case AppSection.delete:
        return 'Delete Acc';
      case AppSection.cloud:
        return 'Cloud';
      case AppSection.optimized:
        return 'Optimized';
    }
  }

  IconData get icono {
    switch (this) {
      case AppSection.sync:
        return Icons.sync_alt_rounded;
      case AppSection.backup:
        return Icons.folder_copy_rounded;
      case AppSection.delete:
        return Icons.delete_rounded;
      case AppSection.cloud:
        return Icons.cloud_rounded;
      case AppSection.optimized:
        return Icons.bolt_rounded;
    }
  }

  /// Una sola línea: qué hace la sección.
  String get resumen {
    final en = languageController.isEn;
    switch (this) {
      case AppSection.sync:
        return en
            ? 'Copies the Dota 2 configuration from one Steam account to another.'
            : 'Copia la configuración de Dota 2 de una cuenta Steam a otra.';
      case AppSection.backup:
        return en
            ? 'Saves or restores a copy of the Dota 2 configuration.'
            : 'Guarda o restaura una copia de la configuración de Dota 2.';
      case AppSection.delete:
        return en
            ? 'Deletes the saved data of a Steam account on this PC.'
            : 'Elimina los datos guardados de una cuenta Steam en esta PC.';
      case AppSection.cloud:
        return en
            ? 'Enables or disables Dota 2 Steam Cloud for an account.'
            : 'Activa o desactiva el Steam Cloud de Dota 2 para una cuenta.';
      case AppSection.optimized:
        return en
            ? 'Improves Dota 2 performance for mid/low-end PCs.'
            : 'Mejora el rendimiento de Dota 2 para PCs de gama media/baja.';
    }
  }

  /// Pasos numerados: cómo se usa la sección.
  List<String> get pasos {
    final en = languageController.isEn;
    switch (this) {
      case AppSection.sync:
        return en
            ? [
                'Choose the account that has the configuration (source).',
                'Choose the account that will receive it (target).',
                'Press Sync. A backup is saved automatically before replacing anything.',
              ]
            : [
                'Elige la cuenta que tiene la configuración (origen).',
                'Elige la cuenta que la va a recibir (destino).',
                'Presiona Sincronizar. Se guarda un respaldo automático antes de reemplazar nada.',
              ];
      case AppSection.backup:
        return en
            ? [
                'Choose the account.',
                'Press Save Backup to export the configuration to a folder you choose.',
                'Or press Load Backup to restore a copy you already saved.',
              ]
            : [
                'Elige la cuenta.',
                'Presiona Guardar Backup para exportar la configuración a una carpeta que elijas.',
                'O presiona Cargar Backup para restaurar una copia que ya tengas guardada.',
              ];
      case AppSection.delete:
        return en
            ? [
                'Choose the account.',
                'Press Delete to remove only the Dota 2 configuration.',
                'Or press Delete and remove from Steam to also remove it from the launcher (Steam must be closed).',
              ]
            : [
                'Elige la cuenta.',
                'Presiona Eliminar para borrar solo la configuración de Dota 2.',
                'O presiona Eliminar y quitar de Steam para además removerla del launcher (Steam debe estar cerrado).',
              ];
      case AppSection.cloud:
        return en
            ? [
                'Choose the account.',
                'Press Check to see the current status.',
                'Press Enable or Disable (Steam and Dota 2 must be closed).',
              ]
            : [
                'Elige la cuenta.',
                'Presiona Verificar para ver el estado actual.',
                'Presiona Activar o Desactivar (Steam y Dota 2 deben estar cerrados).',
              ];
      case AppSection.optimized:
        return en
            ? [
                'Choose the account.',
                'Press Check to see the current Launch Options (the ones it already has get checked automatically).',
                'Check or uncheck the options you want.',
                'Press Optimize (Steam must be closed).',
                'To remove one option: uncheck it and press Optimize again — only that one is removed.',
                'To remove them all: uncheck everything and press Optimize.',
              ]
            : [
                'Elige la cuenta.',
                'Presiona Verificar para ver el Launch Options actual (las opciones que ya tiene se marcan solas).',
                'Marca o desmarca las opciones que quieras.',
                'Presiona Optimizar (Steam debe estar cerrado).',
                'Para quitar una opción: desmárcala y presiona Optimizar de nuevo — se quita solo esa.',
                'Para quitarlas todas: desmarca todas y presiona Optimizar.',
              ];
    }
  }
}

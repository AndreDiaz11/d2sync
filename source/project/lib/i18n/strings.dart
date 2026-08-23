import 'app_language.dart';

/// Todos los textos traducibles de la app. `S.xxx` siempre lee el idioma
/// actual de [languageController] al momento de construir el widget.
class S {
  static bool get _en => languageController.isEn;

  // ── Genérico ──────────────────────────────────────────────────────────
  static String get loading => _en ? 'Loading...' : 'Cargando...';
  static String get back => _en ? 'Back' : 'Regresar';
  static String get howItWorks => _en ? 'How it works' : 'Cómo funciona';
  static String howItWorksTitle(String titulo) =>
      _en ? 'How it works: $titulo' : 'Cómo funciona: $titulo';
  static String get cancel => _en ? 'Cancel' : 'Cancelar';
  static String get confirm => _en ? 'Confirm' : 'Confirmar';
  static String get noSelection => _en ? '— No selection —' : '— Sin elección —';
  static String get selectAccount => _en ? 'Select account' : 'Seleccionar cuenta';
  static String get applyingChanges => _en ? 'Applying changes...' : 'Aplicando cambios...';
  static String get couldNotComplete => _en ? 'Could not complete' : 'No se pudo completar';
  static String get ok => 'OK';
  static String get updateAccounts => _en ? 'Update accounts' : 'Actualizar cuentas';
  static String accountsFound(int n) =>
      _en ? '$n account(s) found.' : '$n cuenta(s) encontrada(s).';
  static String get noAccountsFound =>
      _en ? 'No Steam accounts found.' : 'No se encontraron cuentas de Steam.';
  static String get searchingAccounts =>
      _en ? 'Looking for Steam accounts...' : 'Buscando cuentas de Steam...';
  static String couldNotDetectAccounts(String msg) =>
      _en ? 'Could not detect accounts: $msg' : 'No se pudo detectar cuentas: $msg';
  static String versionLine(String version, String? fecha) => fecha == null
      ? 'v$version'
      : (_en ? 'v$version · updated $fecha' : 'v$version · actualizado $fecha');
  static String updateAvailableLink(String version) =>
      _en ? 'Update $version available — Update' : 'Actualización $version disponible — Actualizar';

  static const List<String> _mesesEs = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  static const List<String> _mesesEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String mes(int mesIndex1a12) => (_en ? _mesesEn : _mesesEs)[mesIndex1a12 - 1];

  // ── Actualización de la app ──────────────────────────────────────────
  static String get updateAppTitle => _en ? 'Update D2Sync' : 'Actualizar D2Sync';
  static String updateAppMessage(String version) => _en
      ? 'Do you want to update now to version $version?\n\n'
          'The app will close for a moment while it downloads and installs.'
      : '¿Deseas actualizar ahora a la versión $version?\n\n'
          'La app se va a cerrar un momento mientras se descarga e instala.';
  static String get installerNotFound =>
      _en ? 'Could not find the installer to update.' : 'No se encontró el instalador para actualizar.';
  static String get minimize => _en ? 'Minimize' : 'Minimizar';
  static String get closeWindow => _en ? 'Close' : 'Cerrar';

  // ── Sync ──────────────────────────────────────────────────────────────
  static String get syncSourceLabel =>
      _en ? 'Source account — config to copy' : 'Cuenta origen — config a copiar';
  static String get syncTargetLabel =>
      _en ? 'Target account — will receive the config' : 'Cuenta destino — recibirá la config';
  static String get syncMissingSource => _en ? 'Missing source account' : 'Falta la cuenta origen';
  static String get syncMissingSourceSub => _en
      ? 'Select the account that has the configuration you want to copy.'
      : 'Selecciona la cuenta que tiene la configuración que quieres copiar.';
  static String get syncMissingTarget => _en ? 'Missing target account' : 'Falta la cuenta destino';
  static String syncMissingTargetSub(String origen) => _en
      ? 'Select the account that will receive the configuration from "$origen".'
      : 'Selecciona la cuenta que recibirá la configuración de "$origen".';
  static String get syncReady => _en ? 'Ready to sync' : 'Listo para sincronizar';
  static String get syncButton => _en ? 'SYNC' : 'SINCRONIZAR';
  static String get syncConfirmTitle => _en ? 'Confirm sync' : 'Confirmar sincronización';
  static String syncConfirmMessage(String destino, String origen) => _en
      ? 'The Dota 2 configuration of "$destino" will be replaced by "$origen"\'s.\n\n'
          'A temporary backup will be saved automatically.'
      : 'La configuración de Dota 2 de "$destino" será reemplazada por la de "$origen".\n\n'
          'Se guardará un respaldo temporal automático.';
  static String get syncing => _en ? 'Syncing configuration...' : 'Sincronizando configuración...';
  static String get syncDone => _en ? 'Sync completed.' : 'Sincronización completada.';

  // ── Backup ────────────────────────────────────────────────────────────
  static String get accountLabel => _en ? 'Account' : 'Cuenta';
  static String get backupSub => _en
      ? 'Save the current config to a folder, or restore one you saved before.'
      : 'Guarda la config actual en una carpeta, o restaura una guardada anteriormente.';
  static String get saveBackupButton => _en ? 'SAVE BACKUP' : 'GUARDAR BACKUP';
  static String get loadBackupButton => _en ? 'LOAD BACKUP' : 'CARGAR BACKUP';
  static String get pickSaveFolderTitle =>
      _en ? 'Choose a folder to save the backup' : 'Elegir carpeta donde guardar backup';
  static String get savingBackup => _en ? 'Saving backup...' : 'Guardando backup...';
  static String backupSavedAt(String path) =>
      _en ? 'Backup saved to: $path' : 'Backup guardado en: $path';
  static String get loadBackupConfirmTitle => _en ? 'Load backup' : 'Cargar backup';
  static String loadBackupConfirmMessage(String cuenta) => _en
      ? 'The current 570 folder of "$cuenta" will be replaced by the selected backup.'
      : 'La carpeta 570 actual de "$cuenta" será reemplazada por el backup seleccionado.';
  static String get pickLoadFolderTitle =>
      _en ? 'Select the backup\'s 570 folder' : 'Selecciona la carpeta 570 del backup';
  static String get loadingBackup => _en ? 'Loading backup...' : 'Cargando backup...';
  static String backupLoadedInto(String cuenta) =>
      _en ? 'Backup loaded into $cuenta.' : 'Backup cargado en $cuenta.';

  // ── Delete ────────────────────────────────────────────────────────────
  static String get deleteAccountLabel => _en ? 'Account to delete' : 'Cuenta a eliminar';
  static String willDeleteData(String cuenta) =>
      _en ? 'The data for "$cuenta" will be deleted' : 'Se eliminarán los datos de "$cuenta"';
  static String get deleteWarningSub => _en
      ? 'This action cannot be undone. Make sure you have a backup if you need one.'
      : 'Esta acción no se puede deshacer. Asegúrate de tener un backup si lo necesitas.';
  static String get deleteButton => _en ? 'DELETE' : 'ELIMINAR';
  static String get deleteAndRemoveButton =>
      _en ? 'DELETE AND REMOVE FROM STEAM' : 'ELIMINAR Y QUITAR DE STEAM';
  static String get deleteNoBackupTitle => _en ? 'Delete without backup' : 'Eliminar sin backup';
  static String deleteNoBackupMessage(String cuenta) => _en
      ? 'Delete the local data of "$cuenta"?\n\nThis action cannot be undone.'
      : '¿Eliminar los datos locales de "$cuenta"?\n\nEsta acción no se puede deshacer.';
  static String get deletingAccount => _en ? 'Deleting account from userdata...' : 'Eliminando cuenta de userdata...';
  static String get accountDeleted => _en ? 'Account deleted from userdata.' : 'Cuenta eliminada de userdata.';
  static String get deleteAndRemoveTitle => _en ? 'Delete and remove from Steam' : 'Eliminar y quitar de Steam';
  static String deleteAndRemoveMessage(String cuenta) => _en
      ? 'Delete the data of "$cuenta" and remove it from the launcher?\n\nSteam must be closed.'
      : '¿Eliminar los datos de "$cuenta" y quitarla del launcher?\n\nSteam debe estar cerrado.';
  static String get deletingAndRemoving =>
      _en ? 'Deleting account and removing from launcher...' : 'Eliminando cuenta y quitando del launcher...';
  static String get accountDeletedAndRemoved => _en
      ? 'Account deleted from userdata and from the Steam launcher.'
      : 'Cuenta eliminada de userdata y del launcher de Steam.';

  // ── Cloud ─────────────────────────────────────────────────────────────
  static String get steamAccountLabel => _en ? 'Steam account' : 'Cuenta Steam';
  static String get unknownStatus => _en ? 'Unknown status' : 'Estado desconocido';
  static String get cloudCheckPrompt => _en
      ? 'Press CHECK to see the Dota 2 Steam Cloud status.'
      : 'Presiona VERIFICAR para consultar el estado del Steam Cloud de Dota 2.';
  static String get cloudEnabledTitle => _en ? 'Steam Cloud ENABLED' : 'Steam Cloud ACTIVADO';
  static String get cloudEnabledSub => _en
      ? 'Dota 2 progress syncs to the cloud automatically.'
      : 'El progreso de Dota 2 se sincroniza con la nube automáticamente.';
  static String get cloudDisabledTitle => _en ? 'Steam Cloud DISABLED' : 'Steam Cloud DESACTIVADO';
  static String get cloudDisabledSub => _en
      ? 'Dota 2 progress does not sync to the cloud.'
      : 'El progreso de Dota 2 no se sincroniza con la nube.';
  static String get cloudNoConfigTitle => _en ? 'No Cloud configuration' : 'Sin configuración de Cloud';
  static String get cloudNoConfigSub => _en
      ? 'This account has no Cloud history. You can enable it to start using it.'
      : 'Esta cuenta no tiene historial de Cloud. Puedes activarlo para empezar a usarlo.';
  static String get checkButton => _en ? 'CHECK' : 'VERIFICAR';
  static String get enableButton => _en ? 'ENABLE' : 'ACTIVAR';
  static String get disableButton => _en ? 'DISABLE' : 'DESACTIVAR';
  static String get checkingCloud => _en ? 'Checking Steam Cloud...' : 'Verificando Steam Cloud...';
  static String get noCloudConfigForAccount =>
      _en ? 'No Cloud configuration for this account.' : 'Sin configuración de Cloud para esta cuenta.';
  static String cloudEnabledFor(String cuenta) =>
      _en ? 'Steam Cloud ENABLED for $cuenta.' : 'Steam Cloud ACTIVADO para $cuenta.';
  static String cloudDisabledFor(String cuenta) =>
      _en ? 'Steam Cloud DISABLED for $cuenta.' : 'Steam Cloud DESACTIVADO para $cuenta.';
  static String get disablingCloud => _en ? 'Disabling Steam Cloud...' : 'Desactivando Steam Cloud...';
  static String cloudDisabledForLower(String cuenta) =>
      _en ? 'Steam Cloud disabled for $cuenta.' : 'Steam Cloud desactivado para $cuenta.';
  static String get enablingCloud => _en ? 'Enabling Steam Cloud...' : 'Activando Steam Cloud...';
  static String cloudEnabledForLower(String cuenta) =>
      _en ? 'Steam Cloud enabled for $cuenta.' : 'Steam Cloud activado para $cuenta.';

  // ── Optimized ─────────────────────────────────────────────────────────
  static String get optimizeAccountLabel => _en ? 'Account to optimize' : 'Cuenta a optimizar';
  static String get optimizeCheckPrompt => _en
      ? 'Press CHECK to see this account\'s current Launch Options.'
      : 'Presiona VERIFICAR para ver el Launch Options actual de esta cuenta.';
  static String get noLaunchOptionsTitle => _en ? 'No Launch Options' : 'Sin Launch Options';
  static String get noLaunchOptionsSub => _en
      ? 'This account has no options configured yet.'
      : 'Esta cuenta no tiene ninguna opción configurada todavía.';
  static String get currentLaunchOptionsTitle =>
      _en ? 'Current Launch Options' : 'Launch Options actual';
  static String get optimizeButton => _en ? 'OPTIMIZE' : 'OPTIMIZAR';
  static String get checkingLaunchOptions =>
      _en ? 'Checking Launch Options...' : 'Revisando Launch Options...';
  static String noLaunchOptionsFor(String cuenta) => _en
      ? 'No Launch Options configured for $cuenta.'
      : 'Sin Launch Options configurado para $cuenta.';
  static String launchOptionsCheckedFor(String cuenta) => _en
      ? 'Launch Options checked for $cuenta.'
      : 'Launch Options revisado para $cuenta.';
  static String get applyingOptimizations =>
      _en ? 'Applying optimizations...' : 'Aplicando optimizaciones...';
  static String optimizationsApplied(String cuenta, int activas) => _en
      ? 'Optimizations applied to $cuenta ($activas active).'
      : 'Optimizaciones aplicadas a $cuenta ($activas activas).';
}

using System.Globalization;

namespace D2Sync.Services;

public static class Strings
{
    private static bool En => LanguageService.IsEnglish;

    public static string Loading => En ? "Loading..." : "Cargando...";
    public static string Back => En ? "Back" : "Regresar";
    public static string HowItWorks => En ? "How it works" : "Cómo funciona";
    public static string HowItWorksTitle(string titulo) => En ? $"How it works: {titulo}" : $"Cómo funciona: {titulo}";
    public static string Cancel => En ? "Cancel" : "Cancelar";
    public static string Confirm => En ? "Confirm" : "Confirmar";
    public static string NoSelection => En ? "— No selection —" : "— Sin elección —";
    public static string SelectAccount => En ? "Select account" : "Seleccionar cuenta";
    public static string ApplyingChanges => En ? "Applying changes..." : "Aplicando cambios...";
    public static string CouldNotComplete => En ? "Could not complete" : "No se pudo completar";
    public static string Ok => "OK";
    public static string UpdateAccounts => En ? "Update accounts" : "Actualizar cuentas";
    public static string AccountsFound(int n) => En ? $"{n} account(s) found." : $"{n} cuenta(s) encontrada(s).";
    public static string NoAccountsFound => En ? "No Steam accounts found." : "No se encontraron cuentas de Steam.";
    public static string SearchingAccounts => En ? "Looking for Steam accounts..." : "Buscando cuentas de Steam...";
    public static string CouldNotDetectAccounts(string msg) => En ? $"Could not detect accounts: {msg}" : $"No se pudo detectar cuentas: {msg}";
    public static string VersionLine(string version, string? fecha) => fecha == null
        ? $"v{version}"
        : (En ? $"v{version} · updated {fecha}" : $"v{version} · actualizado {fecha}");

    public static string MinimizeLabel => En ? "Minimize" : "Minimizar";
    public static string CloseWindowLabel => En ? "Close" : "Cerrar";

    public static string AppTitle => "D2Sync";

    // ── Sync ──────────────────────────────────────────────
    public static string SyncSourceLabel => En ? "Source account — config to copy" : "Cuenta origen — config a copiar";
    public static string SyncTargetLabel => En ? "Target account — will receive the config" : "Cuenta destino — recibirá la config";
    public static string SyncMissingSource => En ? "Missing source account" : "Falta la cuenta origen";
    public static string SyncMissingSourceSub => En
        ? "Select the account that has the configuration you want to copy."
        : "Selecciona la cuenta que tiene la configuración que quieres copiar.";
    public static string SyncMissingTarget => En ? "Missing target account" : "Falta la cuenta destino";
    public static string SyncMissingTargetSub(string origen) => En
        ? $"Select the account that will receive the configuration from \"{origen}\"."
        : $"Selecciona la cuenta que recibirá la configuración de \"{origen}\".";
    public static string SyncReady => En ? "Ready to sync" : "Listo para sincronizar";
    public static string SyncButton => En ? "SYNC" : "SINCRONIZAR";
    public static string SyncConfirmTitle => En ? "Confirm sync" : "Confirmar sincronización";
    public static string SyncConfirmMessage(string destino, string origen) => En
        ? $"The Dota 2 configuration of \"{destino}\" will be replaced by \"{origen}\"'s.\n\nA temporary backup will be saved automatically."
        : $"La configuración de Dota 2 de \"{destino}\" será reemplazada por la de \"{origen}\".\n\nSe guardará un respaldo temporal automático.";
    public static string Syncing => En ? "Syncing configuration..." : "Sincronizando configuración...";
    public static string SyncDone => En ? "Sync completed." : "Sincronización completada.";

    // ── Backup ────────────────────────────────────────────
    public static string AccountLabel => En ? "Account" : "Cuenta";
    public static string BackupSub => En
        ? "Save the current config to a folder, or restore one you saved before."
        : "Guarda la config actual en una carpeta, o restaura una guardada anteriormente.";
    public static string SaveBackupButton => En ? "SAVE BACKUP" : "GUARDAR BACKUP";
    public static string LoadBackupButton => En ? "LOAD BACKUP" : "CARGAR BACKUP";
    public static string PickSaveFolderTitle => En ? "Choose a folder to save the backup" : "Elegir carpeta donde guardar backup";
    public static string SavingBackup => En ? "Saving backup..." : "Guardando backup...";
    public static string BackupSavedAt(string path) => En ? $"Backup saved to: {path}" : $"Backup guardado en: {path}";
    public static string LoadBackupConfirmTitle => En ? "Load backup" : "Cargar backup";
    public static string LoadBackupConfirmMessage(string cuenta) => En
        ? $"The current 570 folder of \"{cuenta}\" will be replaced by the selected backup."
        : $"La carpeta 570 actual de \"{cuenta}\" será reemplazada por el backup seleccionado.";
    public static string PickLoadFolderTitle => En ? "Select the backup's 570 folder" : "Selecciona la carpeta 570 del backup";
    public static string LoadingBackup => En ? "Loading backup..." : "Cargando backup...";
    public static string BackupLoadedInto(string cuenta) => En ? $"Backup loaded into {cuenta}." : $"Backup cargado en {cuenta}.";

    // ── Delete ────────────────────────────────────────────
    public static string DeleteAccountLabel => En ? "Account to delete" : "Cuenta a eliminar";
    public static string WillDeleteData(string cuenta) => En ? $"The data for \"{cuenta}\" will be deleted" : $"Se eliminarán los datos de \"{cuenta}\"";
    public static string DeleteWarningSub => En
        ? "This action cannot be undone. Make sure you have a backup if you need one."
        : "Esta acción no se puede deshacer. Asegúrate de tener un backup si lo necesitas.";
    public static string DeleteButton => En ? "DELETE" : "ELIMINAR";
    public static string DeleteAndRemoveButton => En ? "DELETE AND REMOVE FROM STEAM" : "ELIMINAR Y QUITAR DE STEAM";
    public static string DeleteNoBackupTitle => En ? "Delete without backup" : "Eliminar sin backup";
    public static string DeleteNoBackupMessage(string cuenta) => En
        ? $"Delete the local data of \"{cuenta}\"?\n\nThis action cannot be undone."
        : $"¿Eliminar los datos locales de \"{cuenta}\"?\n\nEsta acción no se puede deshacer.";
    public static string DeletingAccount => En ? "Deleting account from userdata..." : "Eliminando cuenta de userdata...";
    public static string AccountDeleted => En ? "Account deleted from userdata." : "Cuenta eliminada de userdata.";
    public static string DeleteAndRemoveTitle => En ? "Delete and remove from Steam" : "Eliminar y quitar de Steam";
    public static string DeleteAndRemoveMessage(string cuenta) => En
        ? $"Delete the data of \"{cuenta}\" and remove it from the launcher?\n\nSteam must be closed."
        : $"¿Eliminar los datos de \"{cuenta}\" y quitarla del launcher?\n\nSteam debe estar cerrado.";
    public static string DeletingAndRemoving => En ? "Deleting account and removing from launcher..." : "Eliminando cuenta y quitando del launcher...";
    public static string AccountDeletedAndRemoved => En
        ? "Account deleted from userdata and from the Steam launcher."
        : "Cuenta eliminada de userdata y del launcher de Steam.";

    // ── Cloud ─────────────────────────────────────────────
    public static string SteamAccountLabel => En ? "Steam account" : "Cuenta Steam";
    public static string UnknownStatus => En ? "Unknown status" : "Estado desconocido";
    public static string CloudCheckPrompt => En
        ? "Press CHECK to see the Dota 2 Steam Cloud status."
        : "Presiona VERIFICAR para consultar el estado del Steam Cloud de Dota 2.";
    public static string CloudEnabledTitle => En ? "Steam Cloud ENABLED" : "Steam Cloud ACTIVADO";
    public static string CloudEnabledSub => En
        ? "Dota 2 progress syncs to the cloud automatically."
        : "El progreso de Dota 2 se sincroniza con la nube automáticamente.";
    public static string CloudDisabledTitle => En ? "Steam Cloud DISABLED" : "Steam Cloud DESACTIVADO";
    public static string CloudDisabledSub => En
        ? "Dota 2 progress does not sync to the cloud."
        : "El progreso de Dota 2 no se sincroniza con la nube.";
    public static string CloudNoConfigTitle => En ? "No Cloud configuration" : "Sin configuración de Cloud";
    public static string CloudNoConfigSub => En
        ? "This account has no Cloud history. You can enable it to start using it."
        : "Esta cuenta no tiene historial de Cloud. Puedes activarlo para empezar a usarlo.";
    public static string CheckButton => En ? "CHECK" : "VERIFICAR";
    public static string EnableButton => En ? "ENABLE" : "ACTIVAR";
    public static string DisableButton => En ? "DISABLE" : "DESACTIVAR";
    public static string CheckingCloud => En ? "Checking Steam Cloud..." : "Verificando Steam Cloud...";
    public static string NoCloudConfigForAccount => En ? "No Cloud configuration for this account." : "Sin configuración de Cloud para esta cuenta.";
    public static string CloudEnabledFor(string cuenta) => En ? $"Steam Cloud ENABLED for {cuenta}." : $"Steam Cloud ACTIVADO para {cuenta}.";
    public static string CloudDisabledFor(string cuenta) => En ? $"Steam Cloud DISABLED for {cuenta}." : $"Steam Cloud DESACTIVADO para {cuenta}.";
    public static string DisablingCloud => En ? "Disabling Steam Cloud..." : "Desactivando Steam Cloud...";
    public static string CloudDisabledForLower(string cuenta) => En ? $"Steam Cloud disabled for {cuenta}." : $"Steam Cloud desactivado para {cuenta}.";
    public static string EnablingCloud => En ? "Enabling Steam Cloud..." : "Activando Steam Cloud...";
    public static string CloudEnabledForLower(string cuenta) => En ? $"Steam Cloud enabled for {cuenta}." : $"Steam Cloud activado para {cuenta}.";

    // ── Optimized ─────────────────────────────────────────
    public static string OptimizeAccountLabel => En ? "Account to optimize" : "Cuenta a optimizar";
    public static string OptimizeCheckPrompt => En
        ? "Press CHECK to see this account's current Launch Options."
        : "Presiona VERIFICAR para ver el Launch Options actual de esta cuenta.";
    public static string NoLaunchOptionsTitle => En ? "No Launch Options" : "Sin Launch Options";
    public static string NoLaunchOptionsSub => En
        ? "This account has no options configured yet."
        : "Esta cuenta no tiene ninguna opción configurada todavía.";
    public static string CurrentLaunchOptionsTitle => En ? "Current Launch Options" : "Launch Options actual";
    public static string OptimizeButton => En ? "OPTIMIZE" : "OPTIMIZAR";
    public static string CheckingLaunchOptions => En ? "Checking Launch Options..." : "Revisando Launch Options...";
    public static string NoLaunchOptionsFor(string cuenta) => En ? $"No Launch Options configured for {cuenta}." : $"Sin Launch Options configurado para {cuenta}.";
    public static string LaunchOptionsCheckedFor(string cuenta) => En ? $"Launch Options checked for {cuenta}." : $"Launch Options revisado para {cuenta}.";
    public static string ApplyingOptimizations => En ? "Applying optimizations..." : "Aplicando optimizaciones...";
    public static string OptimizationsApplied(string cuenta, int activas) => En
        ? $"Optimizations applied to {cuenta} ({activas} active)."
        : $"Optimizaciones aplicadas a {cuenta} ({activas} activas).";
}

using System.Collections.Generic;
using D2Sync.Services;

namespace D2Sync.Models;

public enum AppSection
{
    Sync,
    Backup,
    Delete,
    Cloud,
    Optimized,
}

public static class AppSectionInfo
{
    public static string Titulo(this AppSection s) => s switch
    {
        AppSection.Sync => "Sync data",
        AppSection.Backup => "Backup",
        AppSection.Delete => "Delete Acc",
        AppSection.Cloud => "Cloud",
        AppSection.Optimized => "Optimized",
        _ => "",
    };

    public static string IconGlyph(this AppSection s) => s switch
    {
        AppSection.Sync => "⇄",
        AppSection.Backup => "🗂",
        AppSection.Delete => "🗑",
        AppSection.Cloud => "☁",
        AppSection.Optimized => "⚡",
        _ => "",
    };

    public static string Resumen(this AppSection s)
    {
        var en = LanguageService.IsEnglish;
        return s switch
        {
            AppSection.Sync => en
                ? "Copies the Dota 2 configuration from one Steam account to another."
                : "Copia la configuración de Dota 2 de una cuenta Steam a otra.",
            AppSection.Backup => en
                ? "Saves or restores a copy of the Dota 2 configuration."
                : "Guarda o restaura una copia de la configuración de Dota 2.",
            AppSection.Delete => en
                ? "Deletes the saved data of a Steam account on this PC."
                : "Elimina los datos guardados de una cuenta Steam en esta PC.",
            AppSection.Cloud => en
                ? "Enables or disables Dota 2 Steam Cloud for an account."
                : "Activa o desactiva el Steam Cloud de Dota 2 para una cuenta.",
            AppSection.Optimized => en
                ? "Improves Dota 2 performance for mid/low-end PCs."
                : "Mejora el rendimiento de Dota 2 para PCs de gama media/baja.",
            _ => "",
        };
    }

    public static List<string> Pasos(this AppSection s)
    {
        var en = LanguageService.IsEnglish;
        return s switch
        {
            AppSection.Sync => en
                ? new() {
                    "Choose the account that has the configuration (source).",
                    "Choose the account that will receive it (target).",
                    "Press Sync. A backup is saved automatically before replacing anything.",
                }
                : new() {
                    "Elige la cuenta que tiene la configuración (origen).",
                    "Elige la cuenta que la va a recibir (destino).",
                    "Presiona Sincronizar. Se guarda un respaldo automático antes de reemplazar nada.",
                },
            AppSection.Backup => en
                ? new() {
                    "Choose the account.",
                    "Press Save Backup to export the configuration to a folder you choose.",
                    "Or press Load Backup to restore a copy you already saved.",
                }
                : new() {
                    "Elige la cuenta.",
                    "Presiona Guardar Backup para exportar la configuración a una carpeta que elijas.",
                    "O presiona Cargar Backup para restaurar una copia que ya tengas guardada.",
                },
            AppSection.Delete => en
                ? new() {
                    "Choose the account.",
                    "Press Delete to remove only the Dota 2 configuration.",
                    "Or press Delete and remove from Steam to also remove it from the launcher (Steam must be closed).",
                }
                : new() {
                    "Elige la cuenta.",
                    "Presiona Eliminar para borrar solo la configuración de Dota 2.",
                    "O presiona Eliminar y quitar de Steam para además removerla del launcher (Steam debe estar cerrado).",
                },
            AppSection.Cloud => en
                ? new() {
                    "Choose the account.",
                    "Press Check to see the current status.",
                    "Press Enable or Disable (Steam and Dota 2 must be closed).",
                }
                : new() {
                    "Elige la cuenta.",
                    "Presiona Verificar para ver el estado actual.",
                    "Presiona Activar o Desactivar (Steam y Dota 2 deben estar cerrados).",
                },
            AppSection.Optimized => en
                ? new() {
                    "Choose the account.",
                    "Press Check to see the current Launch Options (the ones it already has get checked automatically).",
                    "Check or uncheck the options you want.",
                    "Press Optimize (Steam must be closed).",
                    "To remove one option: uncheck it and press Optimize again — only that one is removed.",
                    "To remove them all: uncheck everything and press Optimize.",
                }
                : new() {
                    "Elige la cuenta.",
                    "Presiona Verificar para ver el Launch Options actual (las opciones que ya tiene se marcan solas).",
                    "Marca o desmarca las opciones que quieras.",
                    "Presiona Optimizar (Steam debe estar cerrado).",
                    "Para quitar una opción: desmárcala y presiona Optimizar de nuevo — se quita solo esa.",
                    "Para quitarlas todas: desmarca todas y presiona Optimizar.",
                },
            _ => new(),
        };
    }
}

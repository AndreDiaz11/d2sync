using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using D2Sync.Models;

namespace D2Sync.Services;

public class SteamSyncService
{
    public const string DotaAppId = "570";
    private const long SteamId64Base = 76561197960265728L;

    private string? _steamPath;

    public async Task<string> ObtenerRutaSteamAsync()
    {
        if (_steamPath != null) return _steamPath;

        var psi = new ProcessStartInfo("reg.exe", "query \"HKCU\\Software\\Valve\\Steam\" /v SteamPath")
        {
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        };
        using var proc = Process.Start(psi)!;
        var output = await proc.StandardOutput.ReadToEndAsync();
        await proc.WaitForExitAsync();
        if (proc.ExitCode != 0)
            throw new InvalidOperationException("No se encontró la instalación de Steam.");

        var match = Regex.Match(output, @"SteamPath\s+REG_\w+\s+(.+)", RegexOptions.IgnoreCase);
        if (!match.Success)
            throw new InvalidOperationException("No se pudo leer SteamPath del registro de Windows.");

        _steamPath = Path.GetFullPath(match.Groups[1].Value.Trim());
        return _steamPath;
    }

    public async Task<List<CuentaSteam>> CargarCuentasAsync()
    {
        var steam = await ObtenerRutaSteamAsync();
        var userdata = Path.Combine(steam, "userdata");
        if (!Directory.Exists(userdata))
            throw new InvalidOperationException("No se encontró la carpeta userdata de Steam.");

        var hidden = LeerCuentasOcultas();
        var loginNames = await ObtenerMapeoCuentasAsync();
        var accounts = new List<CuentaSteam>();

        foreach (var dir in Directory.GetDirectories(userdata))
        {
            var id = Path.GetFileName(dir);
            if (!Regex.IsMatch(id, @"^\d+$") || hidden.Contains(id)) continue;

            var localName = ObtenerNombreLocalConfig(dir);
            var id64 = (long.Parse(id) + SteamId64Base).ToString();
            var name = localName ?? (loginNames.TryGetValue(id64, out var n) ? n : id);

            accounts.Add(new CuentaSteam
            {
                SteamId = id,
                Nombre = name,
                RutaCuenta = dir,
                RutaConfigCuenta = Path.Combine(dir, DotaAppId),
                RutaSteamCloudCuenta = Path.Combine(dir, "7", "remote", "sharedconfig.vdf"),
            });
        }

        accounts.Sort((a, b) => string.Compare(a.NombreVisible, b.NombreVisible, StringComparison.OrdinalIgnoreCase));
        return accounts;
    }

    public async Task EjecutarSincronizacionAsync(CuentaSteam origen, CuentaSteam destino)
    {
        if (origen.SteamId == destino.SteamId)
            throw new ArgumentException("La cuenta de origen y destino no pueden ser la misma.");

        if (!Directory.Exists(origen.RutaConfigCuenta))
            throw new InvalidOperationException("No existe la carpeta 570 de origen.");

        await ValidarRutaDentroDeUserDataAsync(destino.RutaConfigCuenta);
        await CopiarConRestauroAsync(origen.RutaConfigCuenta, destino.RutaConfigCuenta,
            "La copia falló y se restauró la configuración anterior");
    }

    public async Task<string> GuardarBackupCuentaAsync(CuentaSteam cuenta, string carpetaDestino)
    {
        if (!Directory.Exists(cuenta.RutaConfigCuenta))
            throw new InvalidOperationException("La cuenta seleccionada no tiene carpeta 570.");
        if (!Directory.Exists(carpetaDestino))
            throw new InvalidOperationException("La ubicación elegida para el backup no existe.");

        var target = Path.Combine(carpetaDestino, DotaAppId);
        if (Directory.Exists(target) && Directory.EnumerateFileSystemEntries(target).Any())
            throw new InvalidOperationException("La carpeta 570 de backup ya existe y no está vacía.");

        CopiarDirectorio(cuenta.RutaConfigCuenta, target);
        return target;
    }

    public async Task CargarBackupEnCuentaAsync(string carpeta570, CuentaSteam destino)
    {
        if (Path.GetFileName(Path.GetFullPath(carpeta570)) != DotaAppId)
            throw new ArgumentException("La carpeta seleccionada debe llamarse exactamente 570.");
        if (!Directory.Exists(carpeta570))
            throw new InvalidOperationException("No existe la carpeta 570 de origen.");

        await ValidarRutaDentroDeUserDataAsync(destino.RutaConfigCuenta);
        await CopiarConRestauroAsync(carpeta570, destino.RutaConfigCuenta,
            "La carga del backup falló y se restauró la configuración anterior");
    }

    public async Task EliminarCuentaAsync(CuentaSteam cuenta, bool quitarDelLauncher = false)
    {
        await ValidarRutaDentroDeUserDataAsync(cuenta.RutaCuenta);
        if (quitarDelLauncher)
        {
            await ValidarSteamCerradoAsync();
            await EliminarCuentaDeLoginUsersAsync(cuenta.SteamId);
            AgregarCuentaOculta(cuenta.SteamId);
        }
        if (Directory.Exists(cuenta.RutaCuenta)) Directory.Delete(cuenta.RutaCuenta, true);
    }

    // Retorna true=activado, false=desactivado, null=sin datos (archivo no existe)
    public async Task<bool?> ObtenerSteamCloudDotaAsync(CuentaSteam cuenta)
    {
        if (!File.Exists(cuenta.RutaSteamCloudCuenta)) return null;
        var (text, _) = LeerVdf(cuenta.RutaSteamCloudCuenta);
        var block = ExtraerBloqueApp(text, DotaAppId);
        if (block == null) return null;
        var match = Regex.Match(block.Text, @"""cloudenabled""\s+""([01])""", RegexOptions.IgnoreCase);
        if (!match.Success) return null;
        return match.Groups[1].Value == "1";
    }

    public async Task CambiarSteamCloudDotaAsync(CuentaSteam cuenta, bool activar)
    {
        await ValidarDotaCerradoAsync();
        await ValidarSteamCerradoAsync();
        if (!File.Exists(cuenta.RutaSteamCloudCuenta)) CrearSharedConfigCloud(cuenta.RutaSteamCloudCuenta, activar);

        var (text, wasUtf8) = LeerVdf(cuenta.RutaSteamCloudCuenta);
        var block = ExtraerBloqueApp(text, DotaAppId);
        var value = activar ? "1" : "0";

        if (block != null)
        {
            var replacement = block.Text;
            var cloudPattern = new Regex(@"""cloudenabled""\s+""[01]""", RegexOptions.IgnoreCase);
            replacement = cloudPattern.IsMatch(replacement)
                ? cloudPattern.Replace(replacement, $"\"cloudenabled\"\t\t\"{value}\"", 1)
                : Regex.Replace(replacement, @"}\s*$", $"\t\"cloudenabled\"\t\t\"{value}\"\n}}");
            text = text[..block.Start] + replacement + text[block.End..];
        }
        else
        {
            var appsMatch = Regex.Match(text, "\"apps\"", RegexOptions.IgnoreCase);
            var appsBlock = appsMatch.Success ? ExtractBlockAt(text, appsMatch.Index) : null;
            var nuevoBloque = $"\t\t\"{DotaAppId}\"\n\t\t{{\n\t\t\t\"cloudenabled\"\t\t\"{value}\"\n\t\t}}\n\t";
            if (appsBlock != null)
            {
                var closeIdx = appsBlock.Start + appsBlock.Text.LastIndexOf('}');
                text = text[..closeIdx] + nuevoBloque + text[closeIdx..];
            }
            else
            {
                text = $"{text}\n\"{DotaAppId}\"\n{{\n\t\"cloudenabled\"\t\t\"{value}\"\n}}\n";
            }
        }
        EscribirVdf(cuenta.RutaSteamCloudCuenta, text, wasUtf8);
    }

    private static string RutaLocalConfig(CuentaSteam cuenta) => Path.Combine(cuenta.RutaCuenta, "config", "localconfig.vdf");

    public async Task<string> ObtenerLaunchOptionsDotaAsync(CuentaSteam cuenta)
    {
        var path = RutaLocalConfig(cuenta);
        if (!File.Exists(path)) return "";
        var (text, _) = LeerVdf(path);
        var block = ExtraerBloqueApp(text, DotaAppId);
        if (block == null) return "";
        var match = Regex.Match(block.Text, @"""LaunchOptions""\s+""([^""]*)""", RegexOptions.IgnoreCase);
        return match.Success ? match.Groups[1].Value : "";
    }

    // Reescribe el Launch Options completo: quita todas las flags que este programa
    // gestiona (estén o no activas) y vuelve a poner solo las que están en activas.
    // Cualquier otro texto que el usuario haya puesto a mano se conserva intacto.
    public async Task AplicarOptimizacionesDotaAsync(CuentaSteam cuenta, List<string> flagsGestionadas, HashSet<string> flagsActivas)
    {
        await ValidarSteamCerradoAsync();
        var path = RutaLocalConfig(cuenta);
        if (!File.Exists(path))
            throw new InvalidOperationException("No se encontró la configuración local de esta cuenta.");

        var (text, wasUtf8) = LeerVdf(path);
        var block = ExtraerBloqueApp(text, DotaAppId);
        if (block == null)
            throw new InvalidOperationException("No se encontró Dota 2 en la configuración de Steam de esta cuenta.");

        var match = Regex.Match(block.Text, @"""LaunchOptions""\s+""([^""]*)""", RegexOptions.IgnoreCase);

        var restante = $" {(match.Success ? match.Groups[1].Value : "")} ";
        foreach (var flag in flagsGestionadas)
        {
            restante = restante.Replace($" {flag} ", " ");
        }
        var conservadas = Regex.Split(restante.Trim(), @"\s+").Where(t => t.Length > 0);
        var nuevoValor = string.Join(" ", conservadas.Concat(flagsActivas));

        string replacement;
        if (match.Success)
        {
            replacement = block.Text[..match.Index] + $"\"LaunchOptions\"\t\t\"{nuevoValor}\"" + block.Text[(match.Index + match.Length)..];
        }
        else
        {
            replacement = Regex.Replace(block.Text, @"}\s*$", $"\t\"LaunchOptions\"\t\t\"{nuevoValor}\"\n}}");
        }
        text = text[..block.Start] + replacement + text[block.End..];
        EscribirVdf(path, text, wasUtf8);
    }

    public Task<bool> EstaSteamAbiertoAsync() => EstaProcesoAbiertoAsync("steam");
    public Task<bool> EstaDotaAbiertoAsync() => EstaProcesoAbiertoAsync("dota2");

    private static Task<bool> EstaProcesoAbiertoAsync(string nombreProceso)
        => Task.FromResult(Process.GetProcessesByName(nombreProceso).Length > 0);

    private async Task ValidarSteamCerradoAsync()
    {
        if (await EstaSteamAbiertoAsync())
            throw new InvalidOperationException("Cierra Steam completamente antes de continuar.");
    }

    private async Task ValidarDotaCerradoAsync()
    {
        if (await EstaDotaAbiertoAsync())
            throw new InvalidOperationException("Cierra Dota 2 completamente antes de continuar.");
    }

    private async Task ValidarRutaDentroDeUserDataAsync(string candidate)
    {
        var userdata = Path.GetFullPath(Path.Combine(await ObtenerRutaSteamAsync(), "userdata"));
        var target = Path.GetFullPath(candidate);
        if (!target.StartsWith(userdata, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Ruta fuera de userdata bloqueada por seguridad.");
    }

    private async Task CopiarConRestauroAsync(string sourcePath, string targetPath, string mensajeError)
    {
        var restorePath = $"{targetPath}_restore_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
        try
        {
            if (Directory.Exists(targetPath))
            {
                CopiarDirectorio(targetPath, restorePath);
                Directory.Delete(targetPath, true);
            }
            CopiarDirectorio(sourcePath, targetPath);
            if (Directory.Exists(restorePath)) Directory.Delete(restorePath, true);
        }
        catch (Exception error)
        {
            if (Directory.Exists(targetPath)) Directory.Delete(targetPath, true);
            if (Directory.Exists(restorePath)) CopiarDirectorio(restorePath, targetPath);
            throw new InvalidOperationException($"{mensajeError}: {error.Message}");
        }
        finally
        {
            if (Directory.Exists(restorePath)) Directory.Delete(restorePath, true);
        }
        await Task.CompletedTask;
    }

    private static void CopiarDirectorio(string source, string target)
    {
        Directory.CreateDirectory(target);
        foreach (var dir in Directory.GetDirectories(source))
        {
            CopiarDirectorio(dir, Path.Combine(target, Path.GetFileName(dir)));
        }
        foreach (var file in Directory.GetFiles(source))
        {
            File.Copy(file, Path.Combine(target, Path.GetFileName(file)), true);
        }
    }

    private static string? ObtenerNombreLocalConfig(string accountPath)
    {
        var path = Path.Combine(accountPath, "config", "localconfig.vdf");
        if (!File.Exists(path)) return null;
        var match = Regex.Match(File.ReadAllText(path), @"""PersonaName""\s+""([^""]+)""", RegexOptions.IgnoreCase);
        return match.Success ? match.Groups[1].Value : null;
    }

    private async Task<Dictionary<string, string>> ObtenerMapeoCuentasAsync()
    {
        var path = Path.Combine(await ObtenerRutaSteamAsync(), "config", "loginusers.vdf");
        var result = new Dictionary<string, string>();
        if (!File.Exists(path)) return result;

        var (text, _) = LeerVdf(path);
        foreach (Match idMatch in Regex.Matches(text, "\"(7656119\\d+)\""))
        {
            var block = ExtractBlockAt(text, idMatch.Index);
            if (block == null) continue;
            var nameMatch = Regex.Match(block.Text, @"""PersonaName""\s+""([^""]+)""", RegexOptions.IgnoreCase);
            if (nameMatch.Success) result[idMatch.Groups[1].Value] = nameMatch.Groups[1].Value;
        }
        return result;
    }

    private async Task EliminarCuentaDeLoginUsersAsync(string accountId)
    {
        var path = Path.Combine(await ObtenerRutaSteamAsync(), "config", "loginusers.vdf");
        if (!File.Exists(path)) return;

        var (text, wasUtf8) = LeerVdf(path);
        var id64 = (long.Parse(accountId) + SteamId64Base).ToString();
        var match = Regex.Match(text, $"\"{id64}\"");
        if (!match.Success) return;
        var block = ExtractBlockAt(text, match.Index);
        if (block != null)
        {
            text = text[..block.Start] + text[block.End..];
            EscribirVdf(path, text, wasUtf8);
        }
    }

    private static string RutaCuentasOcultas
    {
        get
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            return Path.Combine(appData, "D2Sync", "d2sync_hidden_accounts.txt");
        }
    }

    private static HashSet<string> LeerCuentasOcultas()
    {
        if (!File.Exists(RutaCuentasOcultas)) return new HashSet<string>();
        return File.ReadAllLines(RutaCuentasOcultas)
            .Select(l => l.Trim())
            .Where(l => Regex.IsMatch(l, @"^\d+$"))
            .ToHashSet();
    }

    private static void AgregarCuentaOculta(string id)
    {
        var values = LeerCuentasOcultas();
        values.Add(id);
        Directory.CreateDirectory(Path.GetDirectoryName(RutaCuentasOcultas)!);
        File.WriteAllText(RutaCuentasOcultas, string.Join("\n", values) + "\n");
    }

    private static void CrearSharedConfigCloud(string path, bool enabled)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        File.WriteAllText(path,
            "\"UserRoamingConfigStore\"\n{\n\t\"apps\"\n\t{\n" +
            $"\t\t\"{DotaAppId}\"\n\t\t{{\n" +
            $"\t\t\t\"cloudenabled\"\t\t\"{(enabled ? 1 : 0)}\"\n" +
            "\t\t}\n\t}\n}\n");
    }

    // Lee un archivo VDF intentando UTF-8 primero; si hay error usa Latin-1
    private static (string Text, bool WasUtf8) LeerVdf(string path)
    {
        var bytes = File.ReadAllBytes(path);
        try
        {
            var strict = new UTF8Encoding(false, true);
            return (strict.GetString(bytes), true);
        }
        catch (DecoderFallbackException)
        {
            return (Encoding.Latin1.GetString(bytes), false);
        }
    }

    // Escribe con el mismo encoding que tenía el archivo original
    private static void EscribirVdf(string path, string text, bool wasUtf8)
    {
        var bytes = wasUtf8 ? new UTF8Encoding(false).GetBytes(text) : Encoding.Latin1.GetBytes(text);
        File.WriteAllBytes(path, bytes);
    }

    // localconfig.vdf y sharedconfig.vdf son archivos grandes con muchas
    // secciones (noticias, amigos, streaming, etc.) donde el appid puede
    // aparecer mencionado en varios lugares. Para no agarrar el "570"
    // equivocado, primero se ubica la sección "apps" y recién ahí se busca
    // el appid dentro de ella.
    private static VdfBlock? ExtraerBloqueApp(string text, string appId)
    {
        var appsMatch = Regex.Match(text, "\"apps\"", RegexOptions.IgnoreCase);
        if (!appsMatch.Success) return null;
        var appsBlock = ExtractBlockAt(text, appsMatch.Index);
        if (appsBlock == null) return null;

        var appMatch = Regex.Match(appsBlock.Text, $"\"{Regex.Escape(appId)}\"");
        if (!appMatch.Success) return null;
        var relativo = ExtractBlockAt(appsBlock.Text, appMatch.Index);
        if (relativo == null) return null;

        var start = appsBlock.Start + relativo.Start;
        var end = appsBlock.Start + relativo.End;
        return new VdfBlock(start, end, text[start..end]);
    }

    private static VdfBlock? ExtractBlockAt(string text, int keyStart)
    {
        var open = text.IndexOf('{', keyStart);
        if (open < 0) return null;
        var depth = 0;
        for (var index = open; index < text.Length; index++)
        {
            if (text[index] == '{') depth++;
            if (text[index] == '}')
            {
                depth--;
                if (depth == 0)
                {
                    var start = keyStart;
                    while (start > 0 && text[start - 1] != '\n') start--;
                    var end = index + 1;
                    while (end < text.Length && (text[end] == '\r' || text[end] == '\n')) end++;
                    return new VdfBlock(start, end, text[start..end]);
                }
            }
        }
        return null;
    }

    private record VdfBlock(int Start, int End, string Text);
}

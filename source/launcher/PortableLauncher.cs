using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Windows.Forms;

internal static class PortableLauncher
{
    private const string AppVersion  = "1.2.9";
    private const string AppName     = "D2Sync";
    private const string ManifestUrl = "https://raw.githubusercontent.com/AndreDiaz11/d2sync-updates/main/version.json";

    [STAThread]
    private static void Main(string[] args)
    {
        try
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            bool autoUpdate = args != null && args.Contains("--auto-update");

            string localApp    = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string baseDir      = Path.Combine(localApp, AppName);
            string versionFile  = Path.Combine(baseDir, "current_version.txt");
            string statusFile   = Path.Combine(baseDir, "status.json");

            string currentVersion = File.Exists(versionFile) ? File.ReadAllText(versionFile).Trim() : "";
            if (string.IsNullOrEmpty(currentVersion)) currentVersion = AppVersion;

            string currentDir = Path.Combine(baseDir, "v" + currentVersion);
            string currentExe = Path.Combine(currentDir, AppName + ".exe");

            if (!File.Exists(currentExe))
            {
                // Copia local rota o inexistente: recae en la versión embebida en el exe.
                currentVersion = AppVersion;
                currentDir = Path.Combine(baseDir, "v" + currentVersion);
                currentExe = Path.Combine(currentDir, AppName + ".exe");
                ExtractEmbeddedApp(currentDir);
                Directory.CreateDirectory(baseDir);
                File.WriteAllText(versionFile, currentVersion);
            }

            UpdateManifest manifest = TryFetchManifest();
            if (manifest != null && IsNewerVersion(manifest.Version, currentVersion))
            {
                if (autoUpdate || ShowUpdateDialog(manifest.Version))
                {
                    string newDir = Path.Combine(baseDir, "v" + manifest.Version);
                    if (DownloadAndExtractUpdate(manifest.ZipUrl, newDir))
                    {
                        File.WriteAllText(versionFile, manifest.Version);
                        try
                        {
                            if (Directory.Exists(currentDir) &&
                                !string.Equals(currentDir, newDir, StringComparison.OrdinalIgnoreCase))
                                Directory.Delete(currentDir, recursive: true);
                        }
                        catch { /* limpieza best-effort, no bloquea el arranque */ }

                        currentDir = newDir;
                        currentExe = Path.Combine(currentDir, AppName + ".exe");
                        currentVersion = manifest.Version;
                    }
                }
            }

            string pendingUpdateVersion =
                (manifest != null && IsNewerVersion(manifest.Version, currentVersion)) ? manifest.Version : null;
            WriteStatusFile(statusFile, currentVersion, versionFile, pendingUpdateVersion);

            string launcherPath = Assembly.GetExecutingAssembly().Location;
            Process.Start(new ProcessStartInfo(currentExe)
            {
                WorkingDirectory = currentDir,
                UseShellExecute  = true,
                Arguments        = "--launcher=\"" + launcherPath + "\"",
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                "No se pudo abrir " + AppName + ".\n\n" + ex.Message,
                AppName,
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }

    private static void WriteStatusFile(string statusFile, string version, string versionFile, string updateAvailableVersion)
    {
        try
        {
            DateTime lastUpdatedUtc = File.Exists(versionFile)
                ? File.GetLastWriteTimeUtc(versionFile)
                : DateTime.UtcNow;

            string json = "{\n" +
                "  \"version\": \"" + version + "\",\n" +
                "  \"lastUpdatedUtc\": \"" + lastUpdatedUtc.ToString("o") + "\",\n" +
                "  \"updateAvailableVersion\": " +
                    (updateAvailableVersion == null ? "null" : "\"" + updateAvailableVersion + "\"") + "\n" +
                "}\n";

            File.WriteAllText(statusFile, json);
        }
        catch { /* informativo únicamente, nunca bloquea el arranque */ }
    }

    private static void ExtractEmbeddedApp(string targetDir)
    {
        if (Directory.Exists(targetDir))
            Directory.Delete(targetDir, recursive: true);
        Directory.CreateDirectory(targetDir);

        using (Stream resource = Assembly.GetExecutingAssembly()
                                         .GetManifestResourceStream("app.zip"))
        {
            if (resource == null)
                throw new InvalidOperationException("Recurso app.zip no encontrado en el ejecutable.");

            using (var archive = new ZipArchive(resource, ZipArchiveMode.Read))
            {
                archive.ExtractToDirectory(targetDir);
            }
        }
    }

    // ── Chequeo de actualización remota ──────────────────────────────────────

    private sealed class UpdateManifest
    {
        public string Version;
        public string ZipUrl;
    }

    private static UpdateManifest TryFetchManifest()
    {
        try
        {
            var request = (HttpWebRequest)WebRequest.Create(ManifestUrl);
            request.Timeout = 4000;
            request.ReadWriteTimeout = 4000;
            request.UserAgent = AppName + "-Launcher";
            request.CachePolicy = new System.Net.Cache.RequestCachePolicy(
                System.Net.Cache.RequestCacheLevel.NoCacheNoStore);

            using (var response = (HttpWebResponse)request.GetResponse())
            using (var reader = new StreamReader(response.GetResponseStream()))
            {
                string json = reader.ReadToEnd();
                string version = ExtractJsonValue(json, "version");
                string zipUrl  = ExtractJsonValue(json, "zipUrl");
                if (string.IsNullOrEmpty(version) || string.IsNullOrEmpty(zipUrl))
                    return null;
                return new UpdateManifest { Version = version, ZipUrl = zipUrl };
            }
        }
        catch
        {
            return null; // sin internet, timeout o repo caído: seguimos con la versión local
        }
    }

    private static string ExtractJsonValue(string json, string key)
    {
        var match = Regex.Match(json, "\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
        return match.Success ? match.Groups[1].Value : null;
    }

    private static bool IsNewerVersion(string remote, string local)
    {
        Version remoteVer, localVer;
        if (!Version.TryParse(NormalizeVersion(remote), out remoteVer)) return false;
        if (!Version.TryParse(NormalizeVersion(local), out localVer)) return true;
        return remoteVer > localVer;
    }

    private static string NormalizeVersion(string v)
    {
        return v.Contains(".") ? v : v + ".0";
    }

    // ── UI: diálogo "hay una actualización disponible" ──────────────────────

    private static bool ShowUpdateDialog(string newVersion)
    {
        using (var form = new Form())
        {
            form.Text = AppName;
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            form.MaximizeBox = false;
            form.MinimizeBox = false;
            form.ClientSize = new Size(380, 150);
            form.BackColor = ColorTranslator.FromHtml("#1A1F38");

            var label = new Label
            {
                Text = "Tienes una nueva actualización " + newVersion + " disponible.\n\n¿Deseas actualizar ahora?",
                ForeColor = Color.White,
                Font = new Font("Segoe UI", 10f),
                TextAlign = ContentAlignment.MiddleCenter,
                Location = new Point(20, 18),
                Size = new Size(340, 65),
            };

            var btnUpdate = new Button
            {
                Text = "Actualizar",
                DialogResult = DialogResult.Yes,
                Location = new Point(90, 95),
                Size = new Size(110, 34),
                BackColor = ColorTranslator.FromHtml("#1890D8"),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
            };
            btnUpdate.FlatAppearance.BorderSize = 0;

            var btnCancel = new Button
            {
                Text = "Cancelar",
                DialogResult = DialogResult.Cancel,
                Location = new Point(210, 95),
                Size = new Size(110, 34),
                BackColor = ColorTranslator.FromHtml("#2E3A58"),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Font = new Font("Segoe UI", 9.5f),
            };
            btnCancel.FlatAppearance.BorderSize = 0;

            form.Controls.Add(label);
            form.Controls.Add(btnUpdate);
            form.Controls.Add(btnCancel);
            form.AcceptButton = btnUpdate;
            form.CancelButton = btnCancel;

            return form.ShowDialog() == DialogResult.Yes;
        }
    }

    // ── UI + lógica: descarga y aplica la actualización ─────────────────────

    private static bool DownloadAndExtractUpdate(string zipUrl, string targetDir)
    {
        string tempZip = Path.Combine(
            Path.GetTempPath(),
            AppName + "_update_" + Guid.NewGuid().ToString("N") + ".zip");
        bool success = false;

        using (var form = new Form())
        using (var client = new WebClient())
        {
            form.Text = AppName;
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            form.MaximizeBox = false;
            form.MinimizeBox = false;
            form.ControlBox = false;
            form.ClientSize = new Size(340, 110);
            form.BackColor = ColorTranslator.FromHtml("#1A1F38");

            var label = new Label
            {
                Text = "Descargando actualización...",
                ForeColor = Color.White,
                Font = new Font("Segoe UI", 9.5f),
                TextAlign = ContentAlignment.MiddleCenter,
                Location = new Point(20, 20),
                Size = new Size(300, 24),
            };

            var progress = new ProgressBar
            {
                Location = new Point(20, 55),
                Size = new Size(300, 22),
                Minimum = 0,
                Maximum = 100,
                Style = ProgressBarStyle.Continuous,
            };

            form.Controls.Add(label);
            form.Controls.Add(progress);

            client.DownloadProgressChanged += (s, e) =>
            {
                progress.Value = Math.Min(100, Math.Max(0, e.ProgressPercentage));
            };

            client.DownloadFileCompleted += (s, e) =>
            {
                try
                {
                    if (e.Error == null && !e.Cancelled)
                    {
                        label.Text = "Instalando actualización...";
                        label.Refresh();
                        if (Directory.Exists(targetDir))
                            Directory.Delete(targetDir, recursive: true);
                        Directory.CreateDirectory(targetDir);
                        ZipFile.ExtractToDirectory(tempZip, targetDir);
                        success = true;
                    }
                }
                catch
                {
                    success = false;
                }
                finally
                {
                    try { if (File.Exists(tempZip)) File.Delete(tempZip); } catch { }
                    form.Close();
                }
            };

            form.Shown += (s, e) =>
            {
                try
                {
                    client.DownloadFileAsync(new Uri(zipUrl), tempZip);
                }
                catch
                {
                    success = false;
                    form.Close();
                }
            };

            form.ShowDialog();
        }

        return success;
    }
}

using System.Threading.Tasks;
using Avalonia.Platform.Storage;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class BackupSectionViewModel : SectionViewModelBase
{
    [ObservableProperty]
    private CuentaSteam? _seleccion;

    public string AccountLabel => Strings.AccountLabel;
    public string BackupSub => Strings.BackupSub;
    public string SaveBackupLabel => Strings.SaveBackupButton;
    public string LoadBackupLabel => Strings.LoadBackupButton;

    public BackupSectionViewModel(MainWindowViewModel shell) : base(shell, AppSection.Backup)
    {
    }

    partial void OnSeleccionChanged(CuentaSteam? value) { }

    [RelayCommand]
    private async Task PickAsync()
    {
        if (Shell.OwnerWindow == null) return;
        var result = await DialogService.PickAccountAsync(Shell.OwnerWindow, new(Shell.Cuentas), Seleccion, null);
        if (!result.Cancelled) Seleccion = result.Account;
    }

    private async Task<string?> ElegirCarpetaAsync(string titulo)
    {
        if (Shell.OwnerWindow?.StorageProvider is not { } storage) return null;
        var folders = await storage.OpenFolderPickerAsync(new FolderPickerOpenOptions { Title = titulo, AllowMultiple = false });
        return folders.Count > 0 ? folders[0].TryGetLocalPath() : null;
    }

    [RelayCommand]
    private async Task SaveBackupAsync()
    {
        if (Seleccion == null) return;
        var folder = await ElegirCarpetaAsync(Strings.PickSaveFolderTitle);
        if (folder == null) return;

        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.SavingBackup;
            var path = await Shell.Service.GuardarBackupCuentaAsync(Seleccion, folder);
            Shell.Estado = Strings.BackupSavedAt(path);
        });
    }

    [RelayCommand]
    private async Task LoadBackupAsync()
    {
        if (Seleccion == null || Shell.OwnerWindow == null) return;
        var ok = await DialogService.ConfirmAsync(Shell.OwnerWindow, Strings.LoadBackupConfirmTitle,
            Strings.LoadBackupConfirmMessage(Seleccion.NombreVisible), destructive: true);
        if (!ok) return;

        var folder = await ElegirCarpetaAsync(Strings.PickLoadFolderTitle);
        if (folder == null) return;

        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.LoadingBackup;
            await Shell.Service.CargarBackupEnCuentaAsync(folder, Seleccion);
            Shell.Estado = Strings.BackupLoadedInto(Seleccion.NombreVisible);
        });
    }
}

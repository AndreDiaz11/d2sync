using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class SyncSectionViewModel : SectionViewModelBase
{
    [ObservableProperty]
    private CuentaSteam? _origen;

    [ObservableProperty]
    private CuentaSteam? _destino;

    public bool Listos => Origen != null && Destino != null;
    public bool TieneAlgo => Origen != null || Destino != null;

    public string SyncSourceLabel => Strings.SyncSourceLabel;
    public string SyncTargetLabel => Strings.SyncTargetLabel;
    public string SyncButtonLabel => Strings.SyncButton;

    public string StatusColor => Origen == null ? "#5B9BD5" : Destino == null ? "#E8924E" : "#2ECC71";
    public string StatusIcon => Origen == null ? "←" : Destino == null ? "→" : "⇄";
    public string StatusTitle => Origen == null ? Strings.SyncMissingSource : Destino == null ? Strings.SyncMissingTarget : Strings.SyncReady;
    public string StatusSub => Origen == null
        ? Strings.SyncMissingSourceSub
        : Destino == null
            ? Strings.SyncMissingTargetSub(Origen.NombreVisible)
            : $"\"{Origen.NombreVisible}\"  →  \"{Destino.NombreVisible}\"";

    public SyncSectionViewModel(MainWindowViewModel shell) : base(shell, AppSection.Sync)
    {
    }

    partial void OnOrigenChanged(CuentaSteam? value) => RaiseComputed();
    partial void OnDestinoChanged(CuentaSteam? value) => RaiseComputed();

    private void RaiseComputed()
    {
        OnPropertyChanged(nameof(Listos));
        OnPropertyChanged(nameof(TieneAlgo));
        OnPropertyChanged(nameof(StatusColor));
        OnPropertyChanged(nameof(StatusIcon));
        OnPropertyChanged(nameof(StatusTitle));
        OnPropertyChanged(nameof(StatusSub));
    }

    [RelayCommand]
    private async Task PickOrigenAsync()
    {
        if (Shell.OwnerWindow == null) return;
        var result = await DialogService.PickAccountAsync(Shell.OwnerWindow, new(Shell.Cuentas), Origen, Destino);
        if (!result.Cancelled) Origen = result.Account;
    }

    [RelayCommand]
    private async Task PickDestinoAsync()
    {
        if (Shell.OwnerWindow == null) return;
        var result = await DialogService.PickAccountAsync(Shell.OwnerWindow, new(Shell.Cuentas), Destino, Origen);
        if (!result.Cancelled) Destino = result.Account;
    }

    [RelayCommand]
    private async Task SyncAsync()
    {
        if (Origen == null || Destino == null || Shell.OwnerWindow == null) return;
        var ok = await DialogService.ConfirmAsync(Shell.OwnerWindow, Strings.SyncConfirmTitle,
            Strings.SyncConfirmMessage(Destino.NombreVisible, Origen.NombreVisible));
        if (!ok) return;

        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.Syncing;
            await Shell.Service.EjecutarSincronizacionAsync(Origen, Destino);
            Shell.Estado = Strings.SyncDone;
        });
    }
}

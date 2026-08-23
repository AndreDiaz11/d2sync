using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class CloudSectionViewModel : SectionViewModelBase
{
    [ObservableProperty]
    private CuentaSteam? _seleccion;

    [ObservableProperty]
    private bool? _cloudStatus;

    [ObservableProperty]
    private bool _verificado;

    public bool CloudActivo => CloudStatus == true;

    public string StatusColor => !Verificado ? "#666666" : CloudActivo ? "#2ECC71" : CloudStatus == false ? "#FF6B6B" : "#FFB74D";
    public string StatusIcon => !Verificado ? "☁" : CloudActivo ? "✓" : CloudStatus == false ? "✕" : "↑";
    public string StatusTitle => !Verificado
        ? Strings.UnknownStatus
        : CloudActivo ? Strings.CloudEnabledTitle : CloudStatus == false ? Strings.CloudDisabledTitle : Strings.CloudNoConfigTitle;
    public string StatusSub => !Verificado
        ? Strings.CloudCheckPrompt
        : CloudActivo ? Strings.CloudEnabledSub : CloudStatus == false ? Strings.CloudDisabledSub : Strings.CloudNoConfigSub;

    public string SteamAccountLabel => Strings.SteamAccountLabel;
    public string CheckLabel => Strings.CheckButton;
    public string EnableLabel => Strings.EnableButton;
    public string DisableLabel => Strings.DisableButton;

    public CloudSectionViewModel(MainWindowViewModel shell) : base(shell, AppSection.Cloud)
    {
    }

    partial void OnSeleccionChanged(CuentaSteam? value)
    {
        CloudStatus = null;
        Verificado = false;
        RaiseComputed();
    }

    partial void OnCloudStatusChanged(bool? value) => RaiseComputed();
    partial void OnVerificadoChanged(bool value) => RaiseComputed();

    private void RaiseComputed()
    {
        OnPropertyChanged(nameof(CloudActivo));
        OnPropertyChanged(nameof(StatusColor));
        OnPropertyChanged(nameof(StatusIcon));
        OnPropertyChanged(nameof(StatusTitle));
        OnPropertyChanged(nameof(StatusSub));
    }

    [RelayCommand]
    private async Task PickAsync()
    {
        if (Shell.OwnerWindow == null) return;
        var result = await DialogService.PickAccountAsync(Shell.OwnerWindow, new(Shell.Cuentas), Seleccion, null);
        if (!result.Cancelled) Seleccion = result.Account;
    }

    [RelayCommand]
    private async Task CheckAsync()
    {
        if (Seleccion == null) return;
        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.CheckingCloud;
            var enabled = await Shell.Service.ObtenerSteamCloudDotaAsync(Seleccion);
            CloudStatus = enabled;
            Verificado = true;
            Shell.Estado = enabled == null
                ? Strings.NoCloudConfigForAccount
                : enabled == true
                    ? Strings.CloudEnabledFor(Seleccion.NombreVisible)
                    : Strings.CloudDisabledFor(Seleccion.NombreVisible);
        });
    }

    [RelayCommand]
    private async Task DisableAsync()
    {
        if (Seleccion == null) return;
        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.DisablingCloud;
            await Shell.Service.CambiarSteamCloudDotaAsync(Seleccion, false);
            CloudStatus = false;
            Shell.Estado = Strings.CloudDisabledForLower(Seleccion.NombreVisible);
        });
    }

    [RelayCommand]
    private async Task EnableAsync()
    {
        if (Seleccion == null) return;
        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.EnablingCloud;
            await Shell.Service.CambiarSteamCloudDotaAsync(Seleccion, true);
            CloudStatus = true;
            Shell.Estado = Strings.CloudEnabledForLower(Seleccion.NombreVisible);
        });
    }
}

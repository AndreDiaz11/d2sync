using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class OptimizedSectionViewModel : SectionViewModelBase
{
    [ObservableProperty]
    private CuentaSteam? _seleccion;

    [ObservableProperty]
    private bool _verificado;

    [ObservableProperty]
    private string _launchActual = "";

    public ObservableCollection<OptimizationOptionViewModel> Opciones { get; } =
        new(OptimizationOption.All.Select(o => new OptimizationOptionViewModel(o)));

    public string StatusColor => !Verificado ? "#666666" : LaunchActual.Length == 0 ? "#FFB74D" : "#8BD4FF";
    public string StatusIcon => !Verificado ? "?" : LaunchActual.Length == 0 ? "ⓘ" : ">_";
    public string StatusTitle => !Verificado ? Strings.UnknownStatus : LaunchActual.Length == 0 ? Strings.NoLaunchOptionsTitle : Strings.CurrentLaunchOptionsTitle;
    public string StatusSub => !Verificado ? Strings.OptimizeCheckPrompt : LaunchActual.Length == 0 ? Strings.NoLaunchOptionsSub : LaunchActual;

    public string OptimizeAccountLabel => Strings.OptimizeAccountLabel;
    public string CheckLabel => Strings.CheckButton;
    public string OptimizeLabel => Strings.OptimizeButton;

    public OptimizedSectionViewModel(MainWindowViewModel shell) : base(shell, AppSection.Optimized)
    {
    }

    partial void OnSeleccionChanged(CuentaSteam? value)
    {
        Verificado = false;
        LaunchActual = "";
        foreach (var o in Opciones) o.IsChecked = false;
        RaiseComputed();
    }

    partial void OnVerificadoChanged(bool value) => RaiseComputed();
    partial void OnLaunchActualChanged(string value) => RaiseComputed();

    private void RaiseComputed()
    {
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
            Shell.Estado = Strings.CheckingLaunchOptions;
            var actuales = await Shell.Service.ObtenerLaunchOptionsDotaAsync(Seleccion);
            var tokens = $" {actuales} ";
            LaunchActual = actuales;
            foreach (var o in Opciones) o.IsChecked = tokens.Contains($" {o.Option.Flag} ");
            Verificado = true;
            Shell.Estado = actuales.Length == 0 ? Strings.NoLaunchOptionsFor(Seleccion.NombreVisible) : Strings.LaunchOptionsCheckedFor(Seleccion.NombreVisible);
        });
    }

    [RelayCommand]
    private async Task OptimizeAsync()
    {
        if (Seleccion == null) return;
        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.ApplyingOptimizations;
            var activas = Opciones.Where(o => o.IsChecked).Select(o => o.Option.Flag).ToHashSet();
            var todas = Opciones.Select(o => o.Option.Flag).ToList();
            await Shell.Service.AplicarOptimizacionesDotaAsync(Seleccion, todas, activas);
            LaunchActual = await Shell.Service.ObtenerLaunchOptionsDotaAsync(Seleccion);
            Shell.Estado = Strings.OptimizationsApplied(Seleccion.NombreVisible, activas.Count);
        });
    }
}

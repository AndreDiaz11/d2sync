using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class DeleteSectionViewModel : SectionViewModelBase
{
    [ObservableProperty]
    private CuentaSteam? _seleccion;

    public string DeleteAccountLabel => Strings.DeleteAccountLabel;
    public string DeleteWarningSub => Strings.DeleteWarningSub;
    public string DeleteLabel => Strings.DeleteButton;
    public string DeleteAndRemoveLabel => Strings.DeleteAndRemoveButton;
    public string WillDeleteText => Seleccion == null ? "" : Strings.WillDeleteData(Seleccion.NombreVisible);

    partial void OnSeleccionChanged(CuentaSteam? value) => OnPropertyChanged(nameof(WillDeleteText));

    public DeleteSectionViewModel(MainWindowViewModel shell) : base(shell, AppSection.Delete)
    {
    }

    [RelayCommand]
    private async Task PickAsync()
    {
        if (Shell.OwnerWindow == null) return;
        var result = await DialogService.PickAccountAsync(Shell.OwnerWindow, new(Shell.Cuentas), Seleccion, null);
        if (!result.Cancelled) Seleccion = result.Account;
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        if (Seleccion == null || Shell.OwnerWindow == null) return;
        var ok = await DialogService.ConfirmAsync(Shell.OwnerWindow, Strings.DeleteNoBackupTitle,
            Strings.DeleteNoBackupMessage(Seleccion.NombreVisible), destructive: true);
        if (!ok) return;

        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.DeletingAccount;
            await Shell.Service.EliminarCuentaAsync(Seleccion);
            Shell.Estado = Strings.AccountDeleted;
            Seleccion = null;
        });
    }

    [RelayCommand]
    private async Task DeleteAndRemoveAsync()
    {
        if (Seleccion == null || Shell.OwnerWindow == null) return;
        var ok = await DialogService.ConfirmAsync(Shell.OwnerWindow, Strings.DeleteAndRemoveTitle,
            Strings.DeleteAndRemoveMessage(Seleccion.NombreVisible), destructive: true);
        if (!ok) return;

        await RunWithLoadingAsync(async () =>
        {
            Shell.Estado = Strings.DeletingAndRemoving;
            await Shell.Service.EliminarCuentaAsync(Seleccion, quitarDelLauncher: true);
            Shell.Estado = Strings.AccountDeletedAndRemoved;
            Seleccion = null;
        });
    }
}

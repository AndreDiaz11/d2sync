using System.Collections.Generic;
using System.Threading.Tasks;
using Avalonia.Controls;
using D2Sync.Models;
using D2Sync.Views;

namespace D2Sync.Services;

public static class DialogService
{
    public static async Task<bool> ConfirmAsync(Window owner, string title, string message, bool destructive = false)
    {
        var win = new ConfirmDialogWindow(title, message, destructive);
        var result = await win.ShowDialog<bool>(owner);
        return result;
    }

    public static async Task<AccountPickResult> PickAccountAsync(Window owner, List<CuentaSteam> cuentas, CuentaSteam? selected, CuentaSteam? excluded)
    {
        var win = new AccountPickerWindow(cuentas, selected, excluded);
        var result = await win.ShowDialog<AccountPickResult?>(owner);
        return result ?? new AccountPickResult { Cancelled = true };
    }
}

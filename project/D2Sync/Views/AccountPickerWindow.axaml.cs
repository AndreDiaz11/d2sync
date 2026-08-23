using System.Collections.Generic;
using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.Layout;
using Avalonia.Media;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.Views;

public class AccountPickResult
{
    public bool Cancelled { get; init; }
    public CuentaSteam? Account { get; init; }
}

public partial class AccountPickerWindow : Window
{
    private AccountPickResult _result = new() { Cancelled = true };

    public AccountPickerWindow()
    {
        InitializeComponent();
    }

    public AccountPickerWindow(List<CuentaSteam> cuentas, CuentaSteam? selected, CuentaSteam? excluded) : this()
    {
        HeaderText.Text = Strings.SelectAccount;

        ItemsPanel.Children.Add(BuildItem(Strings.NoSelection, "", selected == null, false,
            () => CloseWith(new AccountPickResult { Cancelled = false, Account = null })));

        foreach (var c in cuentas)
        {
            var isSelected = selected?.SteamId == c.SteamId;
            var isLocked = excluded?.SteamId == c.SteamId;
            var cuenta = c;
            ItemsPanel.Children.Add(BuildItem(c.SteamId, c.Nombre == c.SteamId ? "" : c.Nombre, isSelected, isLocked,
                isLocked ? null : () => CloseWith(new AccountPickResult { Cancelled = false, Account = cuenta })));
        }
    }

    private Control BuildItem(string primary, string secondary, bool isSelected, bool isLocked, System.Action? onClick)
    {
        var border = new Border
        {
            Padding = new Avalonia.Thickness(20, 11),
            Background = isSelected ? new SolidColorBrush(Color.Parse("#1890D8"), 0.14) : Brushes.Transparent,
            Cursor = isLocked ? Cursor.Default : new Cursor(StandardCursorType.Hand),
        };

        var stack = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 10 };
        stack.Children.Add(new TextBlock
        {
            Text = "●",
            FontSize = 10,
            Foreground = isLocked ? Brushes.Gray : (isSelected ? new SolidColorBrush(Color.Parse("#5AE4FF")) : new SolidColorBrush(Color.Parse("#4D4D4D"), 0.4)),
            VerticalAlignment = Avalonia.Layout.VerticalAlignment.Center,
        });

        var textStack = new StackPanel { Spacing = 1 };
        textStack.Children.Add(new TextBlock
        {
            Text = primary,
            FontSize = 13.5,
            FontWeight = Avalonia.Media.FontWeight.Medium,
            Foreground = isLocked ? new SolidColorBrush(Colors.White, 0.28) : Brushes.White,
        });
        if (!string.IsNullOrEmpty(secondary))
        {
            textStack.Children.Add(new TextBlock
            {
                Text = secondary,
                FontSize = 11,
                Foreground = new SolidColorBrush(Color.Parse("#B0C4E8"), isLocked ? 0.4 : 0.8),
            });
        }
        stack.Children.Add(textStack);
        border.Child = stack;

        if (onClick != null)
        {
            border.PointerPressed += (_, _) => onClick();
        }

        return border;
    }

    private void CloseClick(object? sender, RoutedEventArgs e) => CloseWith(new AccountPickResult { Cancelled = true });

    private void CloseWith(AccountPickResult result)
    {
        _result = result;
        Close(result);
    }
}

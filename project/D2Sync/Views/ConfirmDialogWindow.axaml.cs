using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;
using D2Sync.Services;

namespace D2Sync.Views;

public partial class ConfirmDialogWindow : Window
{
    public ConfirmDialogWindow()
    {
        InitializeComponent();
    }

    public ConfirmDialogWindow(string title, string message, bool destructive) : this()
    {
        TitleText.Text = title;
        MessageText.Text = message;
        CancelButton.Content = Strings.Cancel;
        ConfirmButton.Content = Strings.Confirm;

        var accent = destructive ? Color.Parse("#CC3333") : Color.Parse("#1890D8");
        IconBadge.Background = new SolidColorBrush(accent, 0.18);
        IconText.Text = destructive ? "⚠" : "?";
        IconText.Foreground = new SolidColorBrush(destructive ? Color.Parse("#FF5555") : Color.Parse("#5AE4FF"));
        ConfirmButton.Background = new SolidColorBrush(destructive ? Color.Parse("#CC3333") : Color.Parse("#1890D8"));
    }

    private void CancelClick(object? sender, RoutedEventArgs e) => Close(false);

    private void ConfirmClick(object? sender, RoutedEventArgs e) => Close(true);
}

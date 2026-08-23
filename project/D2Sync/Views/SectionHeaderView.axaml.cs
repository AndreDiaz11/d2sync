using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.VisualTree;
using D2Sync.ViewModels;

namespace D2Sync.Views;

public partial class SectionHeaderView : UserControl
{
    public SectionHeaderView()
    {
        InitializeComponent();
    }

    private async void HowItWorksClick(object? sender, RoutedEventArgs e)
    {
        if (DataContext is not SectionViewModelBase vm) return;
        var owner = this.FindAncestorOfType<Window>();
        if (owner == null) return;
        var win = new HowItWorksWindow(vm.Title, vm.Steps);
        await win.ShowDialog(owner);
    }
}

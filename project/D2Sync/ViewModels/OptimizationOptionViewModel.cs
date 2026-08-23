using CommunityToolkit.Mvvm.ComponentModel;
using D2Sync.Models;

namespace D2Sync.ViewModels;

public partial class OptimizationOptionViewModel : ViewModelBase
{
    public OptimizationOption Option { get; }
    public string Title => Option.Title;
    public string Description => Option.Description;

    [ObservableProperty]
    private bool _isChecked;

    public OptimizationOptionViewModel(OptimizationOption option)
    {
        Option = option;
    }
}

using System.Collections.Generic;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public abstract partial class SectionViewModelBase : ViewModelBase
{
    public MainWindowViewModel Shell { get; }
    public AppSection Section { get; }

    public string Title => Section.Titulo();
    public string IconGlyph => Section.IconGlyph();
    public string Summary => Section.Resumen();
    public List<string> Steps => Section.Pasos();

    protected SectionViewModelBase(MainWindowViewModel shell, AppSection section)
    {
        Shell = shell;
        Section = section;
        LanguageService.Changed += OnLanguageChanged;
    }

    private void OnLanguageChanged() => OnPropertyChanged(string.Empty);

    public virtual void Dispose()
    {
        LanguageService.Changed -= OnLanguageChanged;
    }

    protected Task RunWithLoadingAsync(System.Func<Task> action) => Shell.RunWithLoadingAsync(action);
}

using System;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using Avalonia.Controls;
using Avalonia.Threading;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using D2Sync.Models;
using D2Sync.Services;

namespace D2Sync.ViewModels;

public partial class MainWindowViewModel : ViewModelBase
{
    public const string AppVersion = "1.0.0";

    public SteamSyncService Service { get; } = new();
    public Window? OwnerWindow { get; set; }

    [ObservableProperty]
    private ObservableCollection<CuentaSteam> _cuentas = new();

    [ObservableProperty]
    private bool _busy;

    [ObservableProperty]
    private bool _cooldown;

    [ObservableProperty]
    private string _estado = "";

    [ObservableProperty]
    private bool _isLoadingPopupVisible;

    [ObservableProperty]
    private string _errorMessage = "";

    [ObservableProperty]
    private bool _errorPopupVisible;

    [ObservableProperty]
    private SectionViewModelBase? _currentSection;

    [ObservableProperty]
    private DateTime? _lastUpdatedLocal;

    [ObservableProperty]
    private string? _updateAvailableVersion;

    public bool IsHome => CurrentSection == null;
    public bool IsEnglish => LanguageService.IsEnglish;
    public string VersionLine => Strings.VersionLine(AppVersion, LastUpdatedLocal?.ToString("d MMM yyyy"));
    public bool HasUpdateLink => UpdateAvailableVersion != null && UpdateAvailableVersion != AppVersion;
    public string RefreshLabel => Strings.UpdateAccounts;
    public string BackLabel => Strings.Back;
    public string HowItWorksLabel => Strings.HowItWorks;
    public string ApplyingChangesLabel => Strings.ApplyingChanges;
    public string CouldNotCompleteLabel => Strings.CouldNotComplete;
    public System.Collections.Generic.List<HomeSectionEntry> HomeSections { get; }
    public string UpdateLinkText => HasUpdateLink
        ? (IsEnglish ? $"Update {UpdateAvailableVersion} available — Update" : $"Actualización {UpdateAvailableVersion} disponible — Actualizar")
        : "";

    public MainWindowViewModel()
    {
        LanguageService.Changed += OnLanguageChanged;
        Estado = Strings.SearchingAccounts;

        HomeSections = new()
        {
            new(AppSection.Sync, OpenSectionCommand),
            new(AppSection.Backup, OpenSectionCommand),
            new(AppSection.Delete, OpenSectionCommand),
            new(AppSection.Cloud, OpenSectionCommand),
            new(AppSection.Optimized, OpenSectionCommand),
        };

        _ = RefreshAsync();
        _ = CheckNewsAndUpdatesAsync();
    }

    private void OnLanguageChanged() => OnPropertyChanged(string.Empty);

    [RelayCommand]
    private void SetLanguage(string code)
    {
        LanguageService.SetEnglish(code == "en");
    }

    [RelayCommand]
    private async Task RefreshAsync()
    {
        Busy = true;
        Estado = Strings.SearchingAccounts;
        try
        {
            var values = await Service.CargarCuentasAsync();
            Cuentas = new ObservableCollection<CuentaSteam>(values);
            Estado = values.Count == 0 ? Strings.NoAccountsFound : Strings.AccountsFound(values.Count);
        }
        catch (Exception e)
        {
            Estado = Strings.CouldNotDetectAccounts(e.Message);
            ErrorLogger.Log("cargar-cuentas", e);
        }
        finally
        {
            Busy = false;
            StartCooldown();
        }
    }

    private async void StartCooldown()
    {
        Cooldown = true;
        await Task.Delay(5000);
        Cooldown = false;
    }

    [RelayCommand]
    private void OpenSection(AppSection section)
    {
        CurrentSection?.Dispose();
        CurrentSection = section switch
        {
            AppSection.Sync => new SyncSectionViewModel(this),
            AppSection.Backup => new BackupSectionViewModel(this),
            AppSection.Delete => new DeleteSectionViewModel(this),
            AppSection.Cloud => new CloudSectionViewModel(this),
            AppSection.Optimized => new OptimizedSectionViewModel(this),
            _ => null,
        };
        OnPropertyChanged(nameof(IsHome));
    }

    [RelayCommand]
    private void Back()
    {
        CurrentSection?.Dispose();
        CurrentSection = null;
        OnPropertyChanged(nameof(IsHome));
    }

    public async Task RunWithLoadingAsync(Func<Task> action)
    {
        Busy = true;
        IsLoadingPopupVisible = true;
        ErrorPopupVisible = false;

        var start = DateTime.Now;
        Exception? error = null;
        try
        {
            await action();
        }
        catch (Exception e)
        {
            error = e;
            ErrorLogger.Log("accion-usuario", e);
        }

        var falta = TimeSpan.FromSeconds(1) - (DateTime.Now - start);
        if (falta > TimeSpan.Zero) await Task.Delay(falta);

        IsLoadingPopupVisible = false;
        Busy = false;

        if (error != null)
        {
            ErrorMessage = error.Message;
            ErrorPopupVisible = true;
        }
    }

    [RelayCommand]
    private void DismissError() => ErrorPopupVisible = false;

    private async Task CheckNewsAndUpdatesAsync()
    {
        var config = ConfigStore.Load();
        var newsTask = NewsService.CheckAsync(config);
        var updateTask = UpdateService.CheckAsync();
        await Task.WhenAll(newsTask, updateTask);

        await Task.Delay(300);

        var news = newsTask.Result;
        if (news.ShouldShow && OwnerWindow != null)
        {
            var win = new Views.NewsWindow(news.Version, news.Notes);
            await win.ShowDialog(OwnerWindow);
            NewsService.MarkSeen(config, news.Version);
        }

        var update = updateTask.Result;
        if (update.Available && update.Version != null)
        {
            UpdateAvailableVersion = update.Version;
            OnPropertyChanged(nameof(HasUpdateLink));
            OnPropertyChanged(nameof(UpdateLinkText));
        }
    }

    [RelayCommand]
    private async Task RequestUpdateAsync()
    {
        if (!HasUpdateLink || OwnerWindow == null) return;
        var win = new Views.UpdateAvailableWindow(UpdateAvailableVersion!);
        await win.ShowDialog(OwnerWindow);
    }
}

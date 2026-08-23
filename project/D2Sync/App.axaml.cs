using System;
using System.Threading.Tasks;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using D2Sync.Services;
using D2Sync.ViewModels;
using D2Sync.Views;

namespace D2Sync;

public partial class App : Application
{
    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);

        AppDomain.CurrentDomain.UnhandledException += (_, e) =>
            ErrorLogger.Log("unhandled", e.ExceptionObject as Exception ?? new Exception(e.ExceptionObject?.ToString()));
        TaskScheduler.UnobservedTaskException += (_, e) =>
        {
            ErrorLogger.Log("unobserved-task", e.Exception);
            e.SetObserved();
        };
    }

    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            var vm = new MainWindowViewModel();
            var window = new MainWindow { DataContext = vm };
            vm.OwnerWindow = window;
            desktop.MainWindow = window;
        }

        base.OnFrameworkInitializationCompleted();
    }
}

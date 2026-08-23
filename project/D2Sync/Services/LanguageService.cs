using System;

namespace D2Sync.Services;

public static class LanguageService
{
    public static event Action? Changed;

    private static bool _isEnglish;

    static LanguageService()
    {
        _isEnglish = ConfigStore.Load().IsEnglish;
    }

    public static bool IsEnglish
    {
        get => _isEnglish;
        private set
        {
            if (_isEnglish == value) return;
            _isEnglish = value;
            var cfg = ConfigStore.Load();
            cfg.IsEnglish = value;
            ConfigStore.Save(cfg);
            Changed?.Invoke();
        }
    }

    public static void SetEnglish(bool value) => IsEnglish = value;
}

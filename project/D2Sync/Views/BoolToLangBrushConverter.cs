using System;
using System.Globalization;
using Avalonia.Data.Converters;
using Avalonia.Media;

namespace D2Sync.Views;

public class BoolToLangBrushConverter : IValueConverter
{
    public static readonly BoolToLangBrushConverter Instance = new();

    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        var active = value is true;
        return new SolidColorBrush(active ? Color.Parse("#1890D8") : Color.Parse("#26FFFFFF"));
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

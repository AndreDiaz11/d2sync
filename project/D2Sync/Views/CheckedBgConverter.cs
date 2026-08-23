using System;
using System.Globalization;
using Avalonia.Data.Converters;
using Avalonia.Media;

namespace D2Sync.Views;

public class CheckedBgConverter : IValueConverter
{
    public static readonly CheckedBgConverter Instance = new();

    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
        => new SolidColorBrush(Color.Parse(value is true ? "#1A1890D8" : "#0DFFFFFF"));

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

public class CheckedBorderConverter : IValueConverter
{
    public static readonly CheckedBorderConverter Instance = new();

    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
        => new SolidColorBrush(Color.Parse(value is true ? "#595AE4FF" : "#14FFFFFF"));

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

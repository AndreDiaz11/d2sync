using System.Collections.Generic;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Layout;
using Avalonia.Media;
using D2Sync.Services;

namespace D2Sync.Views;

public partial class HowItWorksWindow : Window
{
    public HowItWorksWindow()
    {
        InitializeComponent();
    }

    public HowItWorksWindow(string titulo, List<string> pasos) : this()
    {
        HeaderText.Text = Strings.HowItWorksTitle(titulo);
        for (var i = 0; i < pasos.Count; i++)
        {
            var row = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 10 };
            row.Children.Add(new Border
            {
                Width = 20,
                Height = 20,
                Margin = new Avalonia.Thickness(0, 1, 0, 0),
                CornerRadius = new Avalonia.CornerRadius(10),
                Background = new SolidColorBrush(Color.Parse("#1890D8")),
                Child = new TextBlock
                {
                    Text = (i + 1).ToString(),
                    FontSize = 11,
                    FontWeight = FontWeight.Bold,
                    Foreground = Brushes.White,
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center,
                },
            });
            row.Children.Add(new TextBlock
            {
                Text = pasos[i],
                FontSize = 13,
                Foreground = new SolidColorBrush(Color.Parse("#B0C4E8")),
                TextWrapping = Avalonia.Media.TextWrapping.Wrap,
                Width = 340,
                LineHeight = 19,
            });
            StepsPanel.Children.Add(row);
        }
    }

    private void CloseClick(object? sender, RoutedEventArgs e) => Close();
}

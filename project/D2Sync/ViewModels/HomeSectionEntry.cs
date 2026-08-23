using System.Windows.Input;
using D2Sync.Models;

namespace D2Sync.ViewModels;

public class HomeSectionEntry
{
    public AppSection Section { get; }
    public string IconGlyph => Section.IconGlyph();
    public string Titulo => Section.Titulo();
    public ICommand OpenCommand { get; }

    public HomeSectionEntry(AppSection section, ICommand openCommand)
    {
        Section = section;
        OpenCommand = openCommand;
    }
}

using System.Collections.Generic;
using D2Sync.Services;

namespace D2Sync.Models;

public class OptimizationOption
{
    public required string Id { get; init; }
    public required string Title { get; init; }
    public required string DescriptionEs { get; init; }
    public required string DescriptionEn { get; init; }
    public required string Flag { get; init; }

    public string Description => LanguageService.IsEnglish ? DescriptionEn : DescriptionEs;

    public static readonly List<OptimizationOption> All = new()
    {
        new() { Id = "novid", Title = "-novid", Flag = "-novid",
            DescriptionEs = "Se salta el video de introducción al abrir el juego, para que cargue más rápido.",
            DescriptionEn = "Skips the intro video when opening the game, so it loads faster." },
        new() { Id = "high", Title = "-high", Flag = "-high",
            DescriptionEs = "Le pide a Windows que le dé más prioridad de procesador a Dota 2, mejorando el rendimiento general.",
            DescriptionEn = "Asks Windows to give Dota 2 higher processor priority, improving overall performance." },
        new() { Id = "nojoy", Title = "-nojoy", Flag = "-nojoy",
            DescriptionEs = "Desactiva el soporte de mando/joystick, liberando recursos que no necesitas si juegas con teclado y mouse.",
            DescriptionEn = "Disables gamepad/joystick support, freeing up resources you don't need if you play with keyboard and mouse." },
        new() { Id = "console", Title = "-console", Flag = "-console",
            DescriptionEs = "Activa la consola de desarrollador dentro del juego, útil para ver mensajes técnicos.",
            DescriptionEn = "Enables the developer console inside the game, useful for seeing technical messages." },
        new() { Id = "refresh", Title = "-refresh 60", Flag = "-refresh 60",
            DescriptionEs = "Fuerza que el juego corra a 60Hz de refresco, evitando problemas de sincronización en monitores de 60Hz.",
            DescriptionEn = "Forces the game to run at 60Hz refresh rate, avoiding sync issues on 60Hz monitors." },
        new() { Id = "fps_max", Title = "+fps_max 0", Flag = "+fps_max 0",
            DescriptionEs = "Quita el límite de FPS (cuadros por segundo) en partida, dejando que el juego corra tan rápido como tu PC pueda.",
            DescriptionEn = "Removes the FPS (frames per second) cap in-match, letting the game run as fast as your PC can." },
        new() { Id = "fps_max_ui", Title = "+fps_max_ui 35", Flag = "+fps_max_ui 35",
            DescriptionEs = "Limita los FPS a 35 mientras estás en los menús (fuera de partida), para que la PC no se esfuerce de más ahí.",
            DescriptionEn = "Caps FPS at 35 while in menus (outside of matches), so your PC doesn't work harder than it needs to there." },
        new() { Id = "gamestateintegration", Title = "-gamestateintegration", Flag = "-gamestateintegration",
            DescriptionEs = "Activa la integración de estado del juego, usada por overlays o herramientas externas que muestran información en vivo de la partida.",
            DescriptionEn = "Enables Game State Integration, used by overlays or external tools that show live match information." },
    };
}

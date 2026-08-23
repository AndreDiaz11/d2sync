namespace D2Sync.Models;

public class CuentaSteam
{
    public required string SteamId { get; init; }
    public required string Nombre { get; init; }
    public required string RutaCuenta { get; init; }
    public required string RutaConfigCuenta { get; init; }
    public required string RutaSteamCloudCuenta { get; init; }

    public string NombreVisible => Nombre == SteamId ? SteamId : $"{SteamId} - {Nombre}";

    public override string ToString() => NombreVisible;
}

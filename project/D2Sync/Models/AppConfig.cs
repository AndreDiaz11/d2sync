using System.Text.Json.Serialization;

namespace D2Sync.Models;

public class AppConfig
{
    [JsonPropertyName("isEnglish")]
    public bool IsEnglish { get; set; }

    [JsonPropertyName("lastSeenVersion")]
    public string LastSeenVersion { get; set; } = "";
}

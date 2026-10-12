using TrieuHiNeCon.Debugging;

namespace TrieuHiNeCon;

public class TrieuHiNeConConsts
{
    public const string LocalizationSourceName = "TrieuHiNeCon";

    public const string ConnectionStringName = "Default";

    public const bool MultiTenancyEnabled = true;


    /// <summary>
    /// Default pass phrase for SimpleStringCipher decrypt/encrypt operations
    /// </summary>
    public static readonly string DefaultPassPhrase =
        DebugHelper.IsDebug ? "gsKxGZ012HLL3MI5" : "99fce759f72a48bfbadefe7bfe9f8e02";
}

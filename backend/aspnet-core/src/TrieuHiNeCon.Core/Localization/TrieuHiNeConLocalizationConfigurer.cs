using Abp.Configuration.Startup;
using Abp.Localization.Dictionaries;
using Abp.Localization.Dictionaries.Xml;
using Abp.Reflection.Extensions;

namespace TrieuHiNeCon.Localization;

public static class TrieuHiNeConLocalizationConfigurer
{
    public static void Configure(ILocalizationConfiguration localizationConfiguration)
    {
        localizationConfiguration.Sources.Add(
            new DictionaryBasedLocalizationSource(TrieuHiNeConConsts.LocalizationSourceName,
                new XmlEmbeddedFileLocalizationDictionaryProvider(
                    typeof(TrieuHiNeConLocalizationConfigurer).GetAssembly(),
                    "TrieuHiNeCon.Localization.SourceFiles"
                )
            )
        );
    }
}

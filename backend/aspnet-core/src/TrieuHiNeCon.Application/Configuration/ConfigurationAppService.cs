using Abp.Authorization;
using Abp.Runtime.Session;
using TrieuHiNeCon.Configuration.Dto;
using System.Threading.Tasks;

namespace TrieuHiNeCon.Configuration;

[AbpAuthorize]
public class ConfigurationAppService : TrieuHiNeConAppServiceBase, IConfigurationAppService
{
    public async Task ChangeUiTheme(ChangeUiThemeInput input)
    {
        await SettingManager.ChangeSettingForUserAsync(AbpSession.ToUserIdentifier(), AppSettingNames.UiTheme, input.Theme);
    }
}

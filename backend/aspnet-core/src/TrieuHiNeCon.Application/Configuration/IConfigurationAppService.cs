using TrieuHiNeCon.Configuration.Dto;
using System.Threading.Tasks;

namespace TrieuHiNeCon.Configuration;

public interface IConfigurationAppService
{
    Task ChangeUiTheme(ChangeUiThemeInput input);
}

using Abp.Application.Services;
using TrieuHiNeCon.Authorization.Accounts.Dto;
using System.Threading.Tasks;

namespace TrieuHiNeCon.Authorization.Accounts;

public interface IAccountAppService : IApplicationService
{
    Task<IsTenantAvailableOutput> IsTenantAvailable(IsTenantAvailableInput input);

    Task<RegisterOutput> Register(RegisterInput input);
}

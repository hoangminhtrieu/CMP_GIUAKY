using Abp.Application.Services;
using TrieuHiNeCon.Sessions.Dto;
using System.Threading.Tasks;

namespace TrieuHiNeCon.Sessions;

public interface ISessionAppService : IApplicationService
{
    Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();
}

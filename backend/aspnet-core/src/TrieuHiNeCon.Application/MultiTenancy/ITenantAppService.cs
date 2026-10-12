using Abp.Application.Services;
using TrieuHiNeCon.MultiTenancy.Dto;

namespace TrieuHiNeCon.MultiTenancy;

public interface ITenantAppService : IAsyncCrudAppService<TenantDto, int, PagedTenantResultRequestDto, CreateTenantDto, TenantDto>
{
}


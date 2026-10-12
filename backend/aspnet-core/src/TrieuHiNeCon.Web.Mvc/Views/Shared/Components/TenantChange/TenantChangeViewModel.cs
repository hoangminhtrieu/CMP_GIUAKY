using Abp.AutoMapper;
using TrieuHiNeCon.Sessions.Dto;

namespace TrieuHiNeCon.Web.Views.Shared.Components.TenantChange;

[AutoMapFrom(typeof(GetCurrentLoginInformationsOutput))]
public class TenantChangeViewModel
{
    public TenantLoginInfoDto Tenant { get; set; }
}

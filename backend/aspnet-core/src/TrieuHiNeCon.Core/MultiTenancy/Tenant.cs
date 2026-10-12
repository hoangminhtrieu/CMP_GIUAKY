using Abp.MultiTenancy;
using TrieuHiNeCon.Authorization.Users;

namespace TrieuHiNeCon.MultiTenancy;

public class Tenant : AbpTenant<User>
{
    public Tenant()
    {
    }

    public Tenant(string tenancyName, string name)
        : base(tenancyName, name)
    {
    }
}

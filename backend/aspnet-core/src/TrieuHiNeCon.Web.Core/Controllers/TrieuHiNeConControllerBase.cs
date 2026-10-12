using Abp.AspNetCore.Mvc.Controllers;
using Abp.IdentityFramework;
using Microsoft.AspNetCore.Identity;

namespace TrieuHiNeCon.Controllers
{
    public abstract class TrieuHiNeConControllerBase : AbpController
    {
        protected TrieuHiNeConControllerBase()
        {
            LocalizationSourceName = TrieuHiNeConConsts.LocalizationSourceName;
        }

        protected void CheckErrors(IdentityResult identityResult)
        {
            identityResult.CheckErrors(LocalizationManager);
        }
    }
}

using Abp.AspNetCore.Mvc.ViewComponents;

namespace TrieuHiNeCon.Web.Views;

public abstract class TrieuHiNeConViewComponent : AbpViewComponent
{
    protected TrieuHiNeConViewComponent()
    {
        LocalizationSourceName = TrieuHiNeConConsts.LocalizationSourceName;
    }
}

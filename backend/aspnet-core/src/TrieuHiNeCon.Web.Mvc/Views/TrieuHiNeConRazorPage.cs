using Abp.AspNetCore.Mvc.Views;
using Abp.Runtime.Session;
using Microsoft.AspNetCore.Mvc.Razor.Internal;

namespace TrieuHiNeCon.Web.Views;

public abstract class TrieuHiNeConRazorPage<TModel> : AbpRazorPage<TModel>
{
    [RazorInject]
    public IAbpSession AbpSession { get; set; }

    protected TrieuHiNeConRazorPage()
    {
        LocalizationSourceName = TrieuHiNeConConsts.LocalizationSourceName;
    }
}

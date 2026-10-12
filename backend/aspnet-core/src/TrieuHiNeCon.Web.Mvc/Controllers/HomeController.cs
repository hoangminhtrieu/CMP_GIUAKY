using Abp.AspNetCore.Mvc.Authorization;
using TrieuHiNeCon.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace TrieuHiNeCon.Web.Controllers;

[AbpMvcAuthorize]
public class HomeController : TrieuHiNeConControllerBase
{
    public ActionResult Index()
    {
        return View();
    }
}

using Abp.Modules;
using Abp.Reflection.Extensions;
using TrieuHiNeCon.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace TrieuHiNeCon.Web.Startup;

[DependsOn(typeof(TrieuHiNeConWebCoreModule))]
public class TrieuHiNeConWebMvcModule : AbpModule
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfigurationRoot _appConfiguration;

    public TrieuHiNeConWebMvcModule(IWebHostEnvironment env)
    {
        _env = env;
        _appConfiguration = env.GetAppConfiguration();
    }

    public override void PreInitialize()
    {
        Configuration.Navigation.Providers.Add<TrieuHiNeConNavigationProvider>();
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(TrieuHiNeConWebMvcModule).GetAssembly());
    }
}

using Abp.Modules;
using Abp.Reflection.Extensions;
using TrieuHiNeCon.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace TrieuHiNeCon.Web.Host.Startup
{
    [DependsOn(
       typeof(TrieuHiNeConWebCoreModule))]
    public class TrieuHiNeConWebHostModule : AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public TrieuHiNeConWebHostModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(TrieuHiNeConWebHostModule).GetAssembly());
        }
    }
}

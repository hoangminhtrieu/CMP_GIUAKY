using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;
using TrieuHiNeCon.Authorization;

namespace TrieuHiNeCon;

[DependsOn(
    typeof(TrieuHiNeConCoreModule),
    typeof(AbpAutoMapperModule))]
public class TrieuHiNeConApplicationModule : AbpModule
{
    public override void PreInitialize()
    {
        Configuration.Authorization.Providers.Add<TrieuHiNeConAuthorizationProvider>();
    }

    public override void Initialize()
    {
        var thisAssembly = typeof(TrieuHiNeConApplicationModule).GetAssembly();

        IocManager.RegisterAssemblyByConvention(thisAssembly);

        Configuration.Modules.AbpAutoMapper().Configurators.Add(
            // Scan the assembly for classes which inherit from AutoMapper.Profile
            cfg => cfg.AddMaps(thisAssembly)
        );
    }
}

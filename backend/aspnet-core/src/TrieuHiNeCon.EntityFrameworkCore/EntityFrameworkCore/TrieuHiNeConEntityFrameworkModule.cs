using Abp.EntityFrameworkCore.Configuration;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Abp.Zero.EntityFrameworkCore;
using TrieuHiNeCon.EntityFrameworkCore.Seed;

namespace TrieuHiNeCon.EntityFrameworkCore;

[DependsOn(
    typeof(TrieuHiNeConCoreModule),
    typeof(AbpZeroCoreEntityFrameworkCoreModule))]
public class TrieuHiNeConEntityFrameworkModule : AbpModule
{
    /* Used it tests to skip dbcontext registration, in order to use in-memory database of EF Core */
    public bool SkipDbContextRegistration { get; set; }

    public bool SkipDbSeed { get; set; }

    public override void PreInitialize()
    {
        if (!SkipDbContextRegistration)
        {
            Configuration.Modules.AbpEfCore().AddDbContext<TrieuHiNeConDbContext>(options =>
            {
                if (options.ExistingConnection != null)
                {
                    TrieuHiNeConDbContextConfigurer.Configure(options.DbContextOptions, options.ExistingConnection);
                }
                else
                {
                    TrieuHiNeConDbContextConfigurer.Configure(options.DbContextOptions, options.ConnectionString);
                }
            });
        }
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(TrieuHiNeConEntityFrameworkModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        if (!SkipDbSeed)
        {
            SeedHelper.SeedHostDb(IocManager);
        }
    }
}

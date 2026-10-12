using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using TrieuHiNeCon.EntityFrameworkCore;
using TrieuHiNeCon.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace TrieuHiNeCon.Web.Tests;

[DependsOn(
    typeof(TrieuHiNeConWebMvcModule),
    typeof(AbpAspNetCoreTestBaseModule)
)]
public class TrieuHiNeConWebTestModule : AbpModule
{
    public TrieuHiNeConWebTestModule(TrieuHiNeConEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
    }

    public override void PreInitialize()
    {
        Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(TrieuHiNeConWebTestModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        IocManager.Resolve<ApplicationPartManager>()
            .AddApplicationPartsIfNotAddedBefore(typeof(TrieuHiNeConWebMvcModule).Assembly);
    }
}
using Abp.Events.Bus;
using Abp.Modules;
using Abp.Reflection.Extensions;
using TrieuHiNeCon.Configuration;
using TrieuHiNeCon.EntityFrameworkCore;
using TrieuHiNeCon.Migrator.DependencyInjection;
using Castle.MicroKernel.Registration;
using Microsoft.Extensions.Configuration;

namespace TrieuHiNeCon.Migrator;

[DependsOn(typeof(TrieuHiNeConEntityFrameworkModule))]
public class TrieuHiNeConMigratorModule : AbpModule
{
    private readonly IConfigurationRoot _appConfiguration;

    public TrieuHiNeConMigratorModule(TrieuHiNeConEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbSeed = true;

        _appConfiguration = AppConfigurations.Get(
            typeof(TrieuHiNeConMigratorModule).GetAssembly().GetDirectoryPathOrNull()
        );
    }

    public override void PreInitialize()
    {
        Configuration.DefaultNameOrConnectionString = _appConfiguration.GetConnectionString(
            TrieuHiNeConConsts.ConnectionStringName
        );

        Configuration.BackgroundJobs.IsJobExecutionEnabled = false;
        Configuration.ReplaceService(
            typeof(IEventBus),
            () => IocManager.IocContainer.Register(
                Component.For<IEventBus>().Instance(NullEventBus.Instance)
            )
        );
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(TrieuHiNeConMigratorModule).GetAssembly());
        ServiceCollectionRegistrar.Register(IocManager);
    }
}

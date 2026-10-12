using Abp.Application.Navigation;
using Abp.Authorization;
using Abp.Localization;
using TrieuHiNeCon.Authorization;

namespace TrieuHiNeCon.Web.Startup;

/// <summary>
/// This class defines menus for the application.
/// </summary>
public class TrieuHiNeConNavigationProvider : NavigationProvider
{
    public override void SetNavigation(INavigationProviderContext context)
    {
        context.Manager.MainMenu
            .AddItem(
                new MenuItemDefinition(
                    PageNames.Home,
                    new FixedLocalizableString("Home"),
                    url: "",
                    icon: "fas fa-home",
                    requiresAuthentication: false
                )
            ).AddItem(
                new MenuItemDefinition(
                    "ToeicExam",
                    new FixedLocalizableString("TOEIC Exam Library"),
                    url: "Exam",
                    icon: "fas fa-book-reader"
                )
            ).AddItem(
                new MenuItemDefinition(
                    PageNames.About,
                    new FixedLocalizableString("About"),
                    url: "About",
                    icon: "fas fa-info-circle"
                )
            ).AddItem(
                new MenuItemDefinition(
                    PageNames.Tenants,
                    new FixedLocalizableString("Tenants"),
                    url: "Tenants",
                    icon: "fas fa-building",
                    permissionDependency: new SimplePermissionDependency(PermissionNames.Pages_Tenants)
                )
            ).AddItem(
                new MenuItemDefinition(
                    PageNames.Users,
                    new FixedLocalizableString("Users"),
                    url: "Users",
                    icon: "fas fa-users",
                    permissionDependency: new SimplePermissionDependency(PermissionNames.Pages_Users)
                )
            ).AddItem(
                new MenuItemDefinition(
                    PageNames.Roles,
                    new FixedLocalizableString("Roles"),
                    url: "Roles",
                    icon: "fas fa-user-shield",
                    permissionDependency: new SimplePermissionDependency(PermissionNames.Pages_Roles)
                )
            );
    }

    private static ILocalizableString L(string name)
    {
        return new LocalizableString(name, TrieuHiNeConConsts.LocalizationSourceName);
    }
}
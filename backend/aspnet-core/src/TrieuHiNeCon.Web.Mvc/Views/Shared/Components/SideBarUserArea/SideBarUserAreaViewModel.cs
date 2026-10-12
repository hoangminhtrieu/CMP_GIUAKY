using TrieuHiNeCon.Sessions.Dto;

namespace TrieuHiNeCon.Web.Views.Shared.Components.SideBarUserArea;

public class SideBarUserAreaViewModel
{
    public GetCurrentLoginInformationsOutput LoginInformations { get; set; }

    public bool IsMultiTenancyEnabled { get; set; }

    public string GetShownLoginName()
    {
        if (LoginInformations?.User == null)
        {
            return "Giảng viên (Admin)";
        }

        var userName = LoginInformations.User.UserName;

        if (!IsMultiTenancyEnabled)
        {
            return userName;
        }

        return LoginInformations.Tenant == null
            ? ".\\" + userName
            : LoginInformations.Tenant.TenancyName + "\\" + userName;
    }
}

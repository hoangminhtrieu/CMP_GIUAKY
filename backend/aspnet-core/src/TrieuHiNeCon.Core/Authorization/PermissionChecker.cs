using Abp.Authorization;
using TrieuHiNeCon.Authorization.Roles;
using TrieuHiNeCon.Authorization.Users;

namespace TrieuHiNeCon.Authorization;

public class PermissionChecker : PermissionChecker<Role, User>
{
    public PermissionChecker(UserManager userManager)
        : base(userManager)
    {
    }
}

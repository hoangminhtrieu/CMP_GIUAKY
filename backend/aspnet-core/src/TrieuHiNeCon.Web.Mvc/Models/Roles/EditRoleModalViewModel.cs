using Abp.AutoMapper;
using TrieuHiNeCon.Roles.Dto;
using TrieuHiNeCon.Web.Models.Common;

namespace TrieuHiNeCon.Web.Models.Roles;

[AutoMapFrom(typeof(GetRoleForEditOutput))]
public class EditRoleModalViewModel : GetRoleForEditOutput, IPermissionsEditViewModel
{
    public bool HasPermission(FlatPermissionDto permission)
    {
        return GrantedPermissionNames.Contains(permission.Name);
    }
}

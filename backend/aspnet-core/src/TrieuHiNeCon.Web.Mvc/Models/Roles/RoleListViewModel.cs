using TrieuHiNeCon.Roles.Dto;
using System.Collections.Generic;

namespace TrieuHiNeCon.Web.Models.Roles;

public class RoleListViewModel
{
    public IReadOnlyList<PermissionDto> Permissions { get; set; }
}

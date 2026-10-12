using TrieuHiNeCon.Roles.Dto;
using System.Collections.Generic;

namespace TrieuHiNeCon.Web.Models.Users;

public class UserListViewModel
{
    public IReadOnlyList<RoleDto> Roles { get; set; }
}

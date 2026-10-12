using TrieuHiNeCon.Roles.Dto;
using System.Collections.Generic;

namespace TrieuHiNeCon.Web.Models.Common;

public interface IPermissionsEditViewModel
{
    List<FlatPermissionDto> Permissions { get; set; }
}
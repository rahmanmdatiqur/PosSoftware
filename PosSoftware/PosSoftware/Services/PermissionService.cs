using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Models.Entities;

namespace PosSoftware.Services
{
    public interface IPermissionService
    {
        Task<bool> HasPermissionAsync(int roleId, string pageName, string permissionType);
        Task<List<AppModulePage>> GetPermittedPagesForRoleAsync(int roleId);
        Task<List<RolePermission>> GetPermissionsForRoleAsync(int roleId);
        Task UpdateRolePermissionsAsync(int roleId, List<RolePermissionUpdateModel> updates);
    }

    public class RolePermissionUpdateModel
    {
        public int ModulePageId { get; set; }
        public bool CanView { get; set; }
        public bool CanCreate { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
    }

    public class PermissionService : IPermissionService
    {
        private readonly ApplicationDbContext _context;

        public PermissionService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> HasPermissionAsync(int roleId, string pageName, string permissionType)
        {
            var role = await _context.Roles.FindAsync(roleId);
            if (role != null && role.RoleName.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            var perm = await _context.RolePermissions
                .Include(rp => rp.AppModulePage)
                .FirstOrDefaultAsync(rp => rp.RoleId == roleId && rp.AppModulePage != null && rp.AppModulePage.PageName == pageName);

            if (perm == null) return false;

            return permissionType.ToLower() switch
            {
                "view" or "canview" => perm.CanView,
                "create" or "cancreate" => perm.CanCreate,
                "edit" or "canedit" => perm.CanEdit,
                "delete" or "candelete" => perm.CanDelete,
                _ => false
            };
        }

        public async Task<List<AppModulePage>> GetPermittedPagesForRoleAsync(int roleId)
        {
            var role = await _context.Roles.FindAsync(roleId);
            if (role != null && role.RoleName.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase))
            {
                return await _context.ModulePages
                    .Where(p => p.IsActive)
                    .OrderBy(p => p.SortOrder)
                    .ToListAsync();
            }

            return await _context.RolePermissions
                .Include(rp => rp.AppModulePage)
                .Where(rp => rp.RoleId == roleId && rp.CanView && rp.AppModulePage != null && rp.AppModulePage.IsActive)
                .Select(rp => rp.AppModulePage!)
                .OrderBy(p => p.SortOrder)
                .ToListAsync();
        }

        public async Task<List<RolePermission>> GetPermissionsForRoleAsync(int roleId)
        {
            return await _context.RolePermissions
                .Include(rp => rp.AppModulePage)
                .Where(rp => rp.RoleId == roleId)
                .OrderBy(rp => rp.AppModulePage!.SortOrder)
                .ToListAsync();
        }

        public async Task UpdateRolePermissionsAsync(int roleId, List<RolePermissionUpdateModel> updates)
        {
            var existing = await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .ToListAsync();

            foreach (var item in updates)
            {
                var record = existing.FirstOrDefault(x => x.AppModulePageId == item.ModulePageId);
                if (record != null)
                {
                    record.CanView = item.CanView;
                    record.CanCreate = item.CanCreate;
                    record.CanEdit = item.CanEdit;
                    record.CanDelete = item.CanDelete;
                }
                else
                {
                    _context.RolePermissions.Add(new RolePermission
                    {
                        RoleId = roleId,
                        AppModulePageId = item.ModulePageId,
                        CanView = item.CanView,
                        CanCreate = item.CanCreate,
                        CanEdit = item.CanEdit,
                        CanDelete = item.CanDelete
                    });
                }
            }

            await _context.SaveChangesAsync();
        }
    }
}

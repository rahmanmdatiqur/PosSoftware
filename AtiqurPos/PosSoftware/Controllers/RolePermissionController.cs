using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;
using PosSoftware.Models.ViewModels;
using PosSoftware.Services;

namespace PosSoftware.Controllers
{
    [Authorize]
    [AuthorizePermission("RolePermissions", "View")]
    public class RolePermissionController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IPermissionService _permissionService;

        public RolePermissionController(ApplicationDbContext context, IPermissionService permissionService)
        {
            _context = context;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<IActionResult> Index(int? roleId)
        {
            var roles = await _context.Roles.Where(r => r.IsActive).OrderBy(r => r.Id).ToListAsync();
            var selectedRoleId = roleId ?? roles.FirstOrDefault()?.Id ?? 1;
            var currentRole = roles.FirstOrDefault(r => r.Id == selectedRoleId);

            var allPages = await _context.ModulePages
                .Where(p => p.IsActive)
                .OrderBy(p => p.ModuleName)
                .ThenBy(p => p.SortOrder)
                .ToListAsync();

            var rolePermissions = await _context.RolePermissions
                .Where(rp => rp.RoleId == selectedRoleId)
                .ToListAsync();

            var rows = new List<PagePermissionRowDto>();
            foreach (var page in allPages)
            {
                var existing = rolePermissions.FirstOrDefault(rp => rp.AppModulePageId == page.Id);
                rows.Add(new PagePermissionRowDto
                {
                    AppModulePageId = page.Id,
                    ModuleName = page.ModuleName,
                    PageName = page.PageName,
                    DisplayName = page.DisplayName,
                    IconClass = page.IconClass,
                    CanView = existing?.CanView ?? false,
                    CanCreate = existing?.CanCreate ?? false,
                    CanEdit = existing?.CanEdit ?? false,
                    CanDelete = existing?.CanDelete ?? false
                });
            }

            var vm = new RolePermissionMatrixViewModel
            {
                RoleId = selectedRoleId,
                RoleName = currentRole?.RoleName ?? "Role",
                Roles = roles,
                AllPages = allPages,
                Rows = rows
            };

            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("RolePermissions", "Edit")]
        public async Task<IActionResult> SavePermissions(int roleId, List<RolePermissionUpdateModel> permissions)
        {
            if (roleId <= 0) return BadRequest();

            await _permissionService.UpdateRolePermissionsAsync(roleId, permissions);

            TempData["SuccessMessage"] = "Role permissions updated successfully!";
            return RedirectToAction("Index", new { roleId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("RolePermissions", "Create")]
        public async Task<IActionResult> CreateRole(AppRole role)
        {
            if (ModelState.IsValid)
            {
                role.CreatedAt = DateTime.UtcNow;
                _context.Roles.Add(role);
                await _context.SaveChangesAsync();

                var pages = await _context.ModulePages.ToListAsync();
                foreach (var p in pages)
                {
                    _context.RolePermissions.Add(new RolePermission
                    {
                        RoleId = role.Id,
                        AppModulePageId = p.Id,
                        CanView = false,
                        CanCreate = false,
                        CanEdit = false,
                        CanDelete = false
                    });
                }
                await _context.SaveChangesAsync();

                TempData["SuccessMessage"] = $"Role '{role.RoleName}' created!";
                return RedirectToAction("Index", new { roleId = role.Id });
            }

            return RedirectToAction("Index");
        }
    }
}

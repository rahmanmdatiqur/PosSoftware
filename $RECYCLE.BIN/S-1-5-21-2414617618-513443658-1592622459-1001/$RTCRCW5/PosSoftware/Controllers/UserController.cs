using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;
using PosSoftware.Models.ViewModels;
using PosSoftware.Services;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class UserController : Controller
    {
        private readonly ApplicationDbContext _context;

        public UserController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [AuthorizePermission("Users", "View")]
        public async Task<IActionResult> Index()
        {
            var users = await _context.Users
                .Include(u => u.Role)
                .OrderBy(u => u.Id)
                .ToListAsync();
            return View(users);
        }

        [HttpGet]
        [AuthorizePermission("Users", "Create")]
        public async Task<IActionResult> Create()
        {
            ViewBag.Roles = new SelectList(await _context.Roles.Where(r => r.IsActive).ToListAsync(), "Id", "RoleName");
            return View(new UserFormViewModel { IsActive = true });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Users", "Create")]
        public async Task<IActionResult> Create(UserFormViewModel model)
        {
            if (string.IsNullOrWhiteSpace(model.Password))
            {
                ModelState.AddModelError("Password", "Password is required for new user.");
            }

            if (await _context.Users.AnyAsync(u => u.Username == model.Username))
            {
                ModelState.AddModelError("Username", "Username is already taken.");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.Roles = new SelectList(await _context.Roles.Where(r => r.IsActive).ToListAsync(), "Id", "RoleName", model.RoleId);
                return View(model);
            }

            var (hash, salt) = PasswordHasher.HashPassword(model.Password!);

            var user = new AppUser
            {
                Username = model.Username.Trim(),
                FullName = model.FullName.Trim(),
                Email = model.Email?.Trim(),
                Phone = model.Phone?.Trim(),
                PasswordHash = hash,
                Salt = salt,
                RoleId = model.RoleId,
                IsActive = model.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = $"User '{user.Username}' created successfully!";
            return RedirectToAction("Index");
        }

        [HttpGet]
        [AuthorizePermission("Users", "Edit")]
        public async Task<IActionResult> Edit(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound();

            var vm = new UserFormViewModel
            {
                Id = user.Id,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                IsActive = user.IsActive
            };

            ViewBag.Roles = new SelectList(await _context.Roles.Where(r => r.IsActive).ToListAsync(), "Id", "RoleName", user.RoleId);
            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Users", "Edit")]
        public async Task<IActionResult> Edit(int id, UserFormViewModel model)
        {
            if (id != model.Id) return BadRequest();

            if (await _context.Users.AnyAsync(u => u.Username == model.Username && u.Id != id))
            {
                ModelState.AddModelError("Username", "Username is already taken.");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.Roles = new SelectList(await _context.Roles.Where(r => r.IsActive).ToListAsync(), "Id", "RoleName", model.RoleId);
                return View(model);
            }

            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound();

            user.FullName = model.FullName.Trim();
            user.Email = model.Email?.Trim();
            user.Phone = model.Phone?.Trim();
            user.RoleId = model.RoleId;
            user.IsActive = model.IsActive;

            if (!string.IsNullOrWhiteSpace(model.Password))
            {
                var (hash, salt) = PasswordHasher.HashPassword(model.Password);
                user.PasswordHash = hash;
                user.Salt = salt;
            }

            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = $"User '{user.Username}' updated successfully!";
            return RedirectToAction("Index");
        }
    }
}

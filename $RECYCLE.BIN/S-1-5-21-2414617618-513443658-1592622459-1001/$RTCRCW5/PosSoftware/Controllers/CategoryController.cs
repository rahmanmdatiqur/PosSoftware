using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class CategoryController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CategoryController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [AuthorizePermission("Categories", "View")]
        public async Task<IActionResult> Index()
        {
            var categories = await _context.Categories
                .Include(c => c.Products)
                .OrderBy(c => c.Name)
                .ToListAsync();
            return View(categories);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Categories", "Create")]
        public async Task<IActionResult> Create(Category category)
        {
            if (ModelState.IsValid)
            {
                _context.Categories.Add(category);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = $"Category '{category.Name}' created!";
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Categories", "Edit")]
        public async Task<IActionResult> Edit(Category category)
        {
            if (ModelState.IsValid)
            {
                var existing = await _context.Categories.FindAsync(category.Id);
                if (existing != null)
                {
                    existing.Name = category.Name;
                    existing.Description = category.Description;
                    existing.IsActive = category.IsActive;
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = $"Category '{category.Name}' updated!";
                }
            }
            return RedirectToAction("Index");
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class SupplierController : Controller
    {
        private readonly ApplicationDbContext _context;

        public SupplierController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [AuthorizePermission("Suppliers", "View")]
        public async Task<IActionResult> Index()
        {
            var list = await _context.Suppliers
                .Include(s => s.Products)
                .OrderBy(s => s.Name)
                .ToListAsync();
            return View(list);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Suppliers", "Create")]
        public async Task<IActionResult> Create(Supplier supplier)
        {
            if (ModelState.IsValid)
            {
                supplier.CreatedAt = DateTime.UtcNow;
                _context.Suppliers.Add(supplier);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = $"Supplier '{supplier.Name}' added!";
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Suppliers", "Edit")]
        public async Task<IActionResult> Edit(Supplier supplier)
        {
            if (ModelState.IsValid)
            {
                var existing = await _context.Suppliers.FindAsync(supplier.Id);
                if (existing != null)
                {
                    existing.Name = supplier.Name;
                    existing.ContactPerson = supplier.ContactPerson;
                    existing.Phone = supplier.Phone;
                    existing.Email = supplier.Email;
                    existing.Address = supplier.Address;
                    existing.IsActive = supplier.IsActive;
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = $"Supplier '{supplier.Name}' updated!";
                }
            }
            return RedirectToAction("Index");
        }
    }
}

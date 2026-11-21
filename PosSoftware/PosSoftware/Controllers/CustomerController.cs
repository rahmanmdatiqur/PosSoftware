using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class CustomerController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CustomerController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [AuthorizePermission("Customers", "View")]
        public async Task<IActionResult> Index()
        {
            var list = await _context.Customers
                .OrderBy(c => c.Name)
                .ToListAsync();
            return View(list);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Customers", "Create")]
        public async Task<IActionResult> Create(Customer customer)
        {
            if (ModelState.IsValid)
            {
                customer.CreatedAt = DateTime.UtcNow;
                _context.Customers.Add(customer);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = $"Customer '{customer.Name}' added!";
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Customers", "Edit")]
        public async Task<IActionResult> Edit(Customer customer)
        {
            if (ModelState.IsValid)
            {
                var existing = await _context.Customers.FindAsync(customer.Id);
                if (existing != null)
                {
                    existing.Name = customer.Name;
                    existing.Phone = customer.Phone;
                    existing.Email = customer.Email;
                    existing.Address = customer.Address;
                    existing.IsActive = customer.IsActive;
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = $"Customer '{customer.Name}' updated!";
                }
            }
            return RedirectToAction("Index");
        }
    }
}

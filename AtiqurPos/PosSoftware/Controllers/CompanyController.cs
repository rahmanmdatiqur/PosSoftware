using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Models.Entities;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class CompanyController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CompanyController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var companies = await _context.Companies
                .OrderByDescending(c => c.IsActive)
                .ThenBy(c => c.Id)
                .ToListAsync();

            // Fallback ensure at least 1 default company
            if (!companies.Any())
            {
                var defaultCo = new Company
                {
                    CompanyCode = "ASM",
                    CompanyName = "ASM ENTERPRISE",
                    Address = "Motlab Tower, Chowk Bazar, Dhaka",
                    Phone = "+880 1700-000000",
                    Email = "info@asmenterprise.com",
                    Website = "www.asmenterprise.com",
                    InvoiceFooterNote = "Thank you for your business! Goods once sold can be returned within 7 days with original invoice.",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Companies.Add(defaultCo);
                await _context.SaveChangesAsync();
                companies.Add(defaultCo);
            }

            return View(companies);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Company model)
        {
            if (ModelState.IsValid)
            {
                model.CompanyCode = model.CompanyCode.Trim().ToUpper();
                model.CompanyName = model.CompanyName.Trim();
                model.CreatedAt = DateTime.UtcNow;

                _context.Companies.Add(model);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = $"Company '{model.CompanyName}' created successfully!";
            }
            else
            {
                TempData["ErrorMessage"] = "Failed to create company. Please check the required fields.";
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Company model)
        {
            if (ModelState.IsValid)
            {
                var existing = await _context.Companies.FindAsync(model.Id);
                if (existing == null)
                {
                    TempData["ErrorMessage"] = "Company not found.";
                    return RedirectToAction(nameof(Index));
                }

                existing.CompanyCode = model.CompanyCode.Trim().ToUpper();
                existing.CompanyName = model.CompanyName.Trim();
                existing.Address = model.Address?.Trim();
                existing.Phone = model.Phone?.Trim();
                existing.Email = model.Email?.Trim();
                existing.Website = model.Website?.Trim();
                existing.LogoUrl = model.LogoUrl?.Trim();
                existing.InvoiceFooterNote = model.InvoiceFooterNote?.Trim();
                existing.IsActive = model.IsActive;
                existing.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = $"Company '{existing.CompanyName}' updated successfully!";
            }
            else
            {
                TempData["ErrorMessage"] = "Failed to update company. Please check the required fields.";
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public async Task<IActionResult> GetCompany(int id)
        {
            var company = await _context.Companies.FindAsync(id);
            if (company == null) return NotFound();
            return Json(company);
        }
    }
}

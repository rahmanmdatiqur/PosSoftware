using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class ProductController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public ProductController(ApplicationDbContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        [HttpGet]
        [AuthorizePermission("Products", "View")]
        public async Task<IActionResult> Index(int? categoryId, string? search)
        {
            var q = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Unit)
                .Include(p => p.Supplier)
                .AsQueryable();

            if (categoryId.HasValue && categoryId.Value > 0)
            {
                q = q.Where(p => p.CategoryId == categoryId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim().ToLower();
                q = q.Where(p => p.Name.ToLower().Contains(term) 
                              || (p.GenericName != null && p.GenericName.ToLower().Contains(term))
                              || p.Barcode.ToLower().Contains(term) 
                              || p.SKU.ToLower().Contains(term));
            }

            ViewBag.Categories = new SelectList(await _context.Categories.Where(c => c.IsActive).ToListAsync(), "Id", "Name", categoryId);
            ViewBag.SearchTerm = search;

            var products = await q.OrderBy(p => p.Name).ToListAsync();
            return View(products);
        }

        [HttpGet]
        [AuthorizePermission("Products", "Create")]
        public async Task<IActionResult> Create()
        {
            await PopulateDropdowns();
            return View(new Product { CurrentStock = 0, MinAlertStock = 5, IsActive = true, ImageUrl = "/uploads/products/pharma-item.svg" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Products", "Create")]
        public async Task<IActionResult> Create(Product model, IFormFile? imageFile)
        {
            if (await _context.Products.AnyAsync(p => p.Barcode == model.Barcode))
            {
                ModelState.AddModelError("Barcode", "Barcode is already in use by another product.");
            }
            if (await _context.Products.AnyAsync(p => p.SKU == model.SKU))
            {
                ModelState.AddModelError("SKU", "SKU code is already in use.");
            }

            if (!ModelState.IsValid)
            {
                await PopulateDropdowns(model.CategoryId, model.UnitId, model.SupplierId);
                return View(model);
            }

            if (imageFile != null && imageFile.Length > 0)
            {
                var uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", "products");
                if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

                var uniqueFileName = $"{Guid.NewGuid():N}_{Path.GetFileName(imageFile.FileName)}";
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await imageFile.CopyToAsync(fileStream);
                }
                model.ImageUrl = $"/uploads/products/{uniqueFileName}";
            }
            else if (string.IsNullOrEmpty(model.ImageUrl))
            {
                model.ImageUrl = "/uploads/products/pharma-item.svg";
            }

            model.CreatedAt = DateTime.UtcNow;
            _context.Products.Add(model);
            await _context.SaveChangesAsync();

            if (model.CurrentStock > 0)
            {
                _context.StockTransactions.Add(new StockTransaction
                {
                    ProductId = model.Id,
                    TransactionType = "StockIn",
                    Quantity = model.CurrentStock,
                    PreviousStock = 0,
                    NewStock = model.CurrentStock,
                    ReferenceNo = "OPENING-STOCK",
                    Notes = "Initial opening stock upon product creation",
                    CreatedAt = DateTime.UtcNow
                });
                await _context.SaveChangesAsync();
            }

            TempData["SuccessMessage"] = $"Product '{model.Name}' created successfully!";
            return RedirectToAction("Index");
        }

        [HttpGet]
        [AuthorizePermission("Products", "Edit")]
        public async Task<IActionResult> Edit(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            await PopulateDropdowns(product.CategoryId, product.UnitId, product.SupplierId);
            return View(product);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Products", "Edit")]
        public async Task<IActionResult> Edit(int id, Product model, IFormFile? imageFile)
        {
            if (id != model.Id) return BadRequest();

            if (await _context.Products.AnyAsync(p => p.Barcode == model.Barcode && p.Id != id))
            {
                ModelState.AddModelError("Barcode", "Barcode is already in use by another product.");
            }
            if (await _context.Products.AnyAsync(p => p.SKU == model.SKU && p.Id != id))
            {
                ModelState.AddModelError("SKU", "SKU code is already in use.");
            }

            if (!ModelState.IsValid)
            {
                await PopulateDropdowns(model.CategoryId, model.UnitId, model.SupplierId);
                return View(model);
            }

            var prod = await _context.Products.FindAsync(id);
            if (prod == null) return NotFound();

            if (imageFile != null && imageFile.Length > 0)
            {
                var uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", "products");
                if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

                var uniqueFileName = $"{Guid.NewGuid():N}_{Path.GetFileName(imageFile.FileName)}";
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await imageFile.CopyToAsync(fileStream);
                }
                prod.ImageUrl = $"/uploads/products/{uniqueFileName}";
            }

            prod.Name = model.Name;
            prod.GenericName = model.GenericName;
            prod.SKU = model.SKU;
            prod.Barcode = model.Barcode;
            prod.Description = model.Description;
            prod.CategoryId = model.CategoryId;
            prod.UnitId = model.UnitId;
            prod.SupplierId = model.SupplierId;
            prod.CostPrice = model.CostPrice;
            prod.SellingPrice = model.SellingPrice;
            prod.MinAlertStock = model.MinAlertStock;
            prod.IsActive = model.IsActive;

            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = $"Product '{prod.Name}' updated successfully!";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("Products", "Delete")]
        public async Task<IActionResult> Delete(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            product.IsActive = false;
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = $"Product '{product.Name}' archived.";
            return RedirectToAction("Index");
        }

        private async Task PopulateDropdowns(int? selectedCat = null, int? selectedUnit = null, int? selectedSupplier = null)
        {
            ViewBag.Categories = new SelectList(await _context.Categories.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync(), "Id", "Name", selectedCat);
            ViewBag.Units = new SelectList(await _context.Units.Where(u => u.IsActive).OrderBy(u => u.Name).ToListAsync(), "Id", "Name", selectedUnit);
            ViewBag.Suppliers = new SelectList(await _context.Suppliers.Where(s => s.IsActive).OrderBy(s => s.Name).ToListAsync(), "Id", "Name", selectedSupplier);
        }
    }
}

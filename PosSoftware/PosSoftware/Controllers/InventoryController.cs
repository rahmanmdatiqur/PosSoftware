using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Filters;
using PosSoftware.Models.Entities;
using PosSoftware.Models.ViewModels;
using PosSoftware.Services;
using System.Security.Claims;

namespace PosSoftware.Controllers
{
    [Authorize]
    public class InventoryController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IInventoryService _inventoryService;

        public InventoryController(ApplicationDbContext context, IInventoryService inventoryService)
        {
            _context = context;
            _inventoryService = inventoryService;
        }

        [HttpGet]
        [AuthorizePermission("InventoryList", "View")]
        public async Task<IActionResult> Index(int? categoryId, string? status, string? search)
        {
            var q = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Unit)
                .Include(p => p.Supplier)
                .Where(p => p.IsActive);

            if (categoryId.HasValue && categoryId.Value > 0)
            {
                q = q.Where(p => p.CategoryId == categoryId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim().ToLower();
                q = q.Where(p => p.Name.ToLower().Contains(term) || p.Barcode.ToLower().Contains(term) || p.SKU.ToLower().Contains(term));
            }

            if (!string.IsNullOrEmpty(status))
            {
                if (status == "low")
                {
                    q = q.Where(p => p.CurrentStock > 0 && p.CurrentStock <= p.MinAlertStock);
                }
                else if (status == "out")
                {
                    q = q.Where(p => p.CurrentStock <= 0);
                }
                else if (status == "in")
                {
                    q = q.Where(p => p.CurrentStock > p.MinAlertStock);
                }
            }

            ViewBag.Categories = await _context.Categories.Where(c => c.IsActive).ToListAsync();
            ViewBag.SelectedCategory = categoryId;
            ViewBag.SelectedStatus = status;
            ViewBag.SearchTerm = search;

            var list = await q.OrderBy(p => p.Name).ToListAsync();
            return View(list);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("InventoryList", "Edit")]
        public async Task<IActionResult> QuickStockIn(int productId, int quantity, string? referenceNo, string? notes)
        {
            if (quantity <= 0)
            {
                TempData["ErrorMessage"] = "Stock In quantity must be greater than zero.";
                return RedirectToAction("Index");
            }

            int userId = 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) userId = uid;

            await _inventoryService.AddStockAsync(productId, quantity, referenceNo ?? "MANUAL-IN", notes ?? "Quick stock receipt", userId);

            TempData["SuccessMessage"] = $"Stock successfully added for product ID #{productId}.";
            return RedirectToAction("Index");
        }

        [HttpGet]
        [AuthorizePermission("StockAdjustment", "View")]
        public async Task<IActionResult> Adjust()
        {
            var todayStr = DateTime.UtcNow.ToString("yyyyMMdd");
            var countToday = await _context.StockAdjustments.CountAsync(a => a.AdjustmentDate.Date == DateTime.UtcNow.Date);
            var adjNo = $"ADJ-{todayStr}-{(countToday + 1):D3}";

            ViewBag.AdjustmentNo = adjNo;
            ViewBag.Products = await _context.Products.Where(p => p.IsActive).OrderBy(p => p.Name).ToListAsync();

            return View(new StockAdjustmentFormViewModel { AdjustmentNo = adjNo });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AuthorizePermission("StockAdjustment", "Create")]
        public async Task<IActionResult> Adjust(StockAdjustmentFormViewModel model)
        {
            if (model.Items == null || !model.Items.Any())
            {
                TempData["ErrorMessage"] = "Please add at least one product to adjust.";
                return RedirectToAction("Adjust");
            }

            int userId = 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) userId = uid;

            var adj = new StockAdjustment
            {
                AdjustmentNo = model.AdjustmentNo,
                Notes = model.Notes,
                Items = model.Items.Select(x => new StockAdjustmentItem
                {
                    ProductId = x.ProductId,
                    AdjustedStock = x.AdjustedStock,
                    Reason = x.Reason ?? "Manual reconciliation"
                }).ToList()
            };

            await _inventoryService.CreateStockAdjustmentAsync(adj, userId);

            TempData["SuccessMessage"] = $"Stock adjustment {model.AdjustmentNo} saved successfully!";
            return RedirectToAction("Index");
        }

        [HttpGet]
        [AuthorizePermission("InventoryList", "View")]
        public async Task<IActionResult> Transactions(int? productId, string? type)
        {
            var q = _context.StockTransactions
                .Include(st => st.Product)
                .Include(st => st.CreatedByUser)
                .AsQueryable();

            if (productId.HasValue && productId.Value > 0)
            {
                q = q.Where(st => st.ProductId == productId.Value);
            }

            if (!string.IsNullOrEmpty(type))
            {
                q = q.Where(st => st.TransactionType == type);
            }

            ViewBag.Products = await _context.Products.Where(p => p.IsActive).OrderBy(p => p.Name).ToListAsync();
            ViewBag.SelectedProductId = productId;
            ViewBag.SelectedType = type;

            var list = await q.OrderByDescending(st => st.CreatedAt).Take(200).ToListAsync();
            return View(list);
        }
    }
}

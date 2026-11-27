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
    public class PurchaseController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly INumberSequenceService _sequenceService;

        public PurchaseController(ApplicationDbContext context, INumberSequenceService sequenceService)
        {
            _context = context;
            _sequenceService = sequenceService;
        }

        [HttpGet]
        public async Task<IActionResult> Index(string? search, int page = 1, int pageSize = 10)
        {
            if (pageSize <= 0) pageSize = 10;
            if (page <= 0) page = 1;

            var q = _context.Purchases
                .Include(p => p.Supplier)
                .Include(p => p.CreatedByUser)
                .Include(p => p.PurchaseItems)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim().ToLower();
                q = q.Where(p => p.PurchaseNo.ToLower().Contains(term) 
                              || (p.Supplier != null && p.Supplier.Name.ToLower().Contains(term))
                              || (p.PurchaseOrderNo != null && p.PurchaseOrderNo.ToLower().Contains(term)));
            }

            int totalItems = await q.CountAsync();
            int totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);
            if (totalPages <= 0) totalPages = 1;
            if (page > totalPages) page = totalPages;

            ViewBag.SearchTerm = search;
            ViewBag.CurrentPage = page;
            ViewBag.PageSize = pageSize;
            ViewBag.TotalItems = totalItems;
            ViewBag.TotalPages = totalPages;

            var purchases = await q.OrderByDescending(p => p.PurchaseDate).ThenByDescending(p => p.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return View(purchases);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            var nextPurchaseNo = await _sequenceService.GetNextPurchaseNumberAsync();
            var nextPo = await _sequenceService.GetNextPurchaseOrderNumberAsync();

            ViewBag.Suppliers = await _context.Suppliers.Where(s => s.IsActive).OrderBy(s => s.Name).ToListAsync();
            ViewBag.Categories = await _context.Categories.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();

            var vm = new PurchaseEntryViewModel
            {
                PurchaseNo = nextPurchaseNo,
                PurchaseOrderNo = nextPo,
                PurchaseDate = DateTime.UtcNow,
                ReceiveDate = DateTime.UtcNow,
                SupplierId = (await _context.Suppliers.FirstOrDefaultAsync(s => s.IsActive))?.Id ?? 1
            };

            return View(vm);
        }

        [HttpGet]
        public async Task<IActionResult> GetNextPurchaseNo()
        {
            var nextNo = await _sequenceService.GetNextPurchaseNumberAsync();
            return Json(new { success = true, purchaseNo = nextNo });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([FromBody] PurchaseEntryViewModel model)
        {
            if (model == null || model.Items == null || !model.Items.Any())
            {
                return Json(new { success = false, message = "Please add at least one item to purchase." });
            }

            int userId = 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) userId = uid;

            // Auto-generate purchase number if missing or already in use
            string purchaseNo = model.PurchaseNo;
            if (string.IsNullOrWhiteSpace(purchaseNo) || await _context.Purchases.AnyAsync(p => p.PurchaseNo == purchaseNo))
            {
                purchaseNo = await _sequenceService.GetNextPurchaseNumberAsync();
            }

            string? poNo = model.PurchaseOrderNo;
            if (string.IsNullOrWhiteSpace(poNo))
            {
                poNo = await _sequenceService.GetNextPurchaseOrderNumberAsync();
            }

            var purchase = new Purchase
            {
                PurchaseNo = purchaseNo,
                SupplierId = model.SupplierId,
                PurchaseDate = model.PurchaseDate,
                ReceiveDate = model.ReceiveDate,
                PurchaseOrderNo = poNo,
                TotalQty = model.Items.Sum(x => x.Quantity),
                SubTotal = model.SubTotal,
                DiscountAmount = model.DiscountAmount,
                TotalAmount = model.TotalAmount,
                PaidAmount = model.PaidAmount,
                DueAmount = model.DueAmount,
                Status = "Unposted",
                IsPosted = false,
                Notes = model.Notes,
                CreatedByUserId = userId,
                CreatedAt = DateTime.UtcNow
            };

            foreach (var item in model.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    // Update purchase cost price
                    if (item.PurchasePrice > 0)
                    {
                        product.CostPrice = item.PurchasePrice;
                    }

                    // Add stock
                    int prevStock = product.CurrentStock;
                    product.CurrentStock += item.Quantity;

                    // Log stock audit transaction
                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Purchase",
                        Quantity = item.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = model.PurchaseNo,
                        Notes = $"Stock received via Purchase #{model.PurchaseNo}",
                        CreatedByUserId = userId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }

                purchase.PurchaseItems.Add(new PurchaseItem
                {
                    ProductId = item.ProductId,
                    ProductName = item.ProductName,
                    ProductCode = item.ProductCode,
                    Quantity = item.Quantity,
                    UnitPrice = item.PurchasePrice,
                    TotalAmount = item.TotalAmount
                });
            }

            _context.Purchases.Add(purchase);
            await _context.SaveChangesAsync();

            return Json(new
            {
                success = true,
                message = "Purchase order saved and stock updated successfully!",
                purchaseId = purchase.Id,
                purchaseNo = purchase.PurchaseNo
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetReport(int id)
        {
            var purchase = await _context.Purchases
                .Include(p => p.Supplier)
                .Include(p => p.CreatedByUser)
                .Include(p => p.PurchaseItems)
                .ThenInclude(pi => pi.Product)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (purchase == null) return NotFound();

            ViewBag.BarcodeSvg = BarcodeService.GenerateSvgBarcode(purchase.PurchaseNo);
            ViewBag.AmountInWords = NumberToWordsConverter.ConvertToWords(purchase.TotalAmount, "Taka");

            return View(purchase);
        }

        [HttpPost]
        public async Task<IActionResult> PostPurchase(int id)
        {
            var purchase = await _context.Purchases.FindAsync(id);
            if (purchase == null) return Json(new { success = false, message = "Purchase not found" });

            purchase.IsPosted = true;
            purchase.Status = "Posted";
            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Purchase marked as Posted." });
        }

        [HttpPost]
        public async Task<IActionResult> BulkPost([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
            {
                return Json(new { success = false, message = "No purchases selected to post." });
            }

            var purchases = await _context.Purchases.Where(p => ids.Contains(p.Id)).ToListAsync();
            foreach (var p in purchases)
            {
                p.IsPosted = true;
                p.Status = "Posted";
            }
            await _context.SaveChangesAsync();

            return Json(new { success = true, count = purchases.Count, message = $"{purchases.Count} purchase(s) marked as Posted successfully." });
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var purchase = await _context.Purchases
                .Include(p => p.Supplier)
                .Include(p => p.PurchaseItems)
                .ThenInclude(pi => pi.Product)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (purchase == null) return NotFound();

            if (purchase.IsPosted)
            {
                TempData["ErrorMessage"] = $"Purchase Order #{purchase.PurchaseNo} is already Posted and cannot be updated.";
                return RedirectToAction(nameof(Index));
            }

            ViewBag.Suppliers = await _context.Suppliers.Where(s => s.IsActive).OrderBy(s => s.Name).ToListAsync();
            ViewBag.Categories = await _context.Categories.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();

            var vm = new PurchaseEntryViewModel
            {
                Id = purchase.Id,
                PurchaseNo = purchase.PurchaseNo,
                SupplierId = purchase.SupplierId,
                PurchaseDate = purchase.PurchaseDate,
                ReceiveDate = purchase.ReceiveDate,
                PurchaseOrderNo = purchase.PurchaseOrderNo,
                SubTotal = purchase.SubTotal,
                DiscountAmount = purchase.DiscountAmount,
                TotalAmount = purchase.TotalAmount,
                PaidAmount = purchase.PaidAmount,
                DueAmount = purchase.DueAmount,
                Notes = purchase.Notes,
                Items = purchase.PurchaseItems.Select(pi => new PurchaseItemEntryInput
                {
                    ProductId = pi.ProductId,
                    ProductName = pi.ProductName,
                    ProductCode = pi.ProductCode ?? (pi.Product != null ? (!string.IsNullOrEmpty(pi.Product.Barcode) ? pi.Product.Barcode : pi.Product.SKU) : ""),
                    Quantity = pi.Quantity,
                    PurchasePrice = pi.UnitPrice,
                    TotalAmount = pi.TotalAmount
                }).ToList()
            };

            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit([FromBody] PurchaseEntryViewModel model)
        {
            if (model == null || model.Items == null || !model.Items.Any())
            {
                return Json(new { success = false, message = "Please add at least one item to purchase." });
            }

            var purchase = await _context.Purchases
                .Include(p => p.PurchaseItems)
                .FirstOrDefaultAsync(p => p.Id == model.Id);

            if (purchase == null)
            {
                return Json(new { success = false, message = "Purchase order not found." });
            }

            if (purchase.IsPosted)
            {
                return Json(new { success = false, message = "Posted purchase orders cannot be updated." });
            }

            int userId = purchase.CreatedByUserId ?? 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) userId = uid;

            // 1. Revert previous stock additions for old items
            foreach (var oldItem in purchase.PurchaseItems)
            {
                var product = await _context.Products.FindAsync(oldItem.ProductId);
                if (product != null)
                {
                    int prevStock = product.CurrentStock;
                    product.CurrentStock -= oldItem.Quantity;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Adjustment",
                        Quantity = oldItem.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = purchase.PurchaseNo,
                        Notes = $"Stock deducted due to Purchase #{purchase.PurchaseNo} edit",
                        CreatedByUserId = userId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }
            }

            // Remove old purchase items
            _context.PurchaseItems.RemoveRange(purchase.PurchaseItems);
            purchase.PurchaseItems.Clear();

            // 2. Add new items and update stock
            foreach (var item in model.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    if (item.PurchasePrice > 0)
                    {
                        product.CostPrice = item.PurchasePrice;
                    }

                    int prevStock = product.CurrentStock;
                    product.CurrentStock += item.Quantity;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Purchase",
                        Quantity = item.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = purchase.PurchaseNo,
                        Notes = $"Stock received via updated Purchase #{purchase.PurchaseNo}",
                        CreatedByUserId = userId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }

                purchase.PurchaseItems.Add(new PurchaseItem
                {
                    ProductId = item.ProductId,
                    ProductName = item.ProductName,
                    ProductCode = item.ProductCode,
                    Quantity = item.Quantity,
                    UnitPrice = item.PurchasePrice,
                    TotalAmount = item.TotalAmount
                });
            }

            // 3. Update purchase headers
            purchase.SupplierId = model.SupplierId;
            purchase.PurchaseDate = model.PurchaseDate;
            purchase.ReceiveDate = model.ReceiveDate;
            purchase.PurchaseOrderNo = model.PurchaseOrderNo;
            purchase.TotalQty = model.Items.Sum(x => x.Quantity);
            purchase.SubTotal = model.SubTotal;
            purchase.DiscountAmount = model.DiscountAmount;
            purchase.TotalAmount = model.TotalAmount;
            purchase.PaidAmount = model.PaidAmount;
            purchase.DueAmount = model.DueAmount;
            purchase.Notes = model.Notes;
            purchase.Status = "Unposted";
            purchase.IsPosted = false;

            await _context.SaveChangesAsync();

            return Json(new
            {
                success = true,
                message = "Purchase order updated successfully!",
                purchaseId = purchase.Id,
                purchaseNo = purchase.PurchaseNo
            });
        }
    }
}


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
    public class SalesController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IInventoryService _inventoryService;
        private readonly INumberSequenceService _sequenceService;

        public SalesController(ApplicationDbContext context, IInventoryService inventoryService, INumberSequenceService sequenceService)
        {
            _context = context;
            _inventoryService = inventoryService;
            _sequenceService = sequenceService;
        }

        [HttpGet]
        [AuthorizePermission("SalesOrders", "View")]
        public async Task<IActionResult> Index(string? search, string? startDate, string? endDate, string? paymentMethod, int page = 1, int pageSize = 10)
        {
            if (pageSize <= 0) pageSize = 10;
            if (page <= 0) page = 1;

            var q = _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.Cashier)
                .Include(s => s.SaleItems)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.Trim().ToLower();
                q = q.Where(s => s.InvoiceNumber.ToLower().Contains(term) 
                              || (s.Customer != null && s.Customer.Name.ToLower().Contains(term))
                              || (s.SaleOrderNo != null && s.SaleOrderNo.ToLower().Contains(term)));
            }

            if (!string.IsNullOrEmpty(paymentMethod))
            {
                q = q.Where(s => s.PaymentMethod == paymentMethod);
            }

            if (DateTime.TryParse(startDate, out var sDate))
            {
                q = q.Where(s => s.SaleDate >= sDate.Date);
                ViewBag.StartDate = sDate.ToString("yyyy-MM-dd");
            }

            if (DateTime.TryParse(endDate, out var eDate))
            {
                var eDayEnd = eDate.Date.AddDays(1).AddTicks(-1);
                q = q.Where(s => s.SaleDate <= eDayEnd);
                ViewBag.EndDate = eDate.ToString("yyyy-MM-dd");
            }

            int totalItems = await q.CountAsync();
            int totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);
            if (totalPages <= 0) totalPages = 1;
            if (page > totalPages) page = totalPages;

            ViewBag.Search = search;
            ViewBag.PaymentMethod = paymentMethod;
            ViewBag.CurrentPage = page;
            ViewBag.PageSize = pageSize;
            ViewBag.TotalItems = totalItems;
            ViewBag.TotalPages = totalPages;

            var sales = await q.OrderByDescending(s => s.SaleDate).ThenByDescending(s => s.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return View(sales);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            var nextInvoice = await _sequenceService.GetNextInvoiceNumberAsync();
            var nextSo = await _sequenceService.GetNextSaleOrderNumberAsync();

            ViewBag.Customers = await _context.Customers.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();
            ViewBag.Categories = await _context.Categories.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();

            var vm = new SaleEntryViewModel
            {
                InvoiceNo = nextInvoice,
                SaleOrderNo = nextSo,
                SaleDate = DateTime.UtcNow,
                CustomerId = (await _context.Customers.FirstOrDefaultAsync(c => c.Name == "Walk-in" || c.IsActive))?.Id ?? 1,
                CustomerType = "Walk-in",
                FundType = "Cash"
            };

            return View(vm);
        }

        [HttpGet]
        public async Task<IActionResult> GetNextInvoiceNo()
        {
            var nextNo = await _sequenceService.GetNextInvoiceNumberAsync();
            return Json(new { success = true, invoiceNo = nextNo });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([FromBody] SaleEntryViewModel model)
        {
            if (model == null || model.Items == null || !model.Items.Any())
            {
                return Json(new { success = false, message = "Please add at least one item to the sale." });
            }

            int cashierId = 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) cashierId = uid;

            // Auto-generate invoice number if missing or already in use
            string invoiceNo = model.InvoiceNo;
            if (string.IsNullOrWhiteSpace(invoiceNo) || await _context.Sales.AnyAsync(s => s.InvoiceNumber == invoiceNo))
            {
                invoiceNo = await _sequenceService.GetNextInvoiceNumberAsync();
            }

            string? saleOrderNo = model.SaleOrderNo;
            if (string.IsNullOrWhiteSpace(saleOrderNo))
            {
                saleOrderNo = await _sequenceService.GetNextSaleOrderNumberAsync();
            }

            var sale = new Sale
            {
                InvoiceNumber = invoiceNo,
                SaleDate = model.SaleDate,
                CustomerId = model.CustomerId > 0 ? model.CustomerId : 1,
                CustomerType = model.CustomerType ?? "Walk-in",
                AdmissionNo = model.AdmissionNo,
                SaleOrderNo = saleOrderNo,
                FundType = model.FundType ?? "Cash",
                MobileNumber = model.MobileNumber,
                SubTotal = model.TotalAmount,
                DiscountPercent = model.DiscountPercent,
                DiscountAmount = model.DiscountAmount,
                RoundUp = model.RoundUp,
                FinalPayable = model.FinalPayable,
                GrandTotal = model.FinalPayable > 0 ? model.FinalPayable : model.TotalAmount - model.DiscountAmount,
                PaidAmount = model.PaidAmount,
                ChangeAmount = (model.PaidAmount > model.FinalPayable) ? (model.PaidAmount - model.FinalPayable) : 0,
                DuesAmount = model.DuesAmount,
                PaymentMethod = model.PaymentMethod ?? "Cash",
                Status = "Unposted",
                IsPosted = false,
                Notes = model.Notes,
                CashierId = cashierId
            };

            foreach (var item in model.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    int prevStock = product.CurrentStock;
                    product.CurrentStock -= item.Quantity;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Sale",
                        Quantity = item.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = sale.InvoiceNumber,
                        Notes = $"Sale item deducted via Invoice #{sale.InvoiceNumber}",
                        CreatedByUserId = cashierId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }

                sale.SaleItems.Add(new SaleItem
                {
                    ProductId = item.ProductId,
                    ProductName = item.ProductName,
                    BatchNo = item.BatchNo,
                    Quantity = item.Quantity,
                    UnitPrice = item.Price,
                    SubTotal = item.SubTotal,
                    DiscountAmount = item.DiscountAmount,
                    TotalAmount = item.TotalAmount
                });
            }

            _context.Sales.Add(sale);
            await _context.SaveChangesAsync();

            return Json(new
            {
                success = true,
                message = "Sale invoice created successfully!",
                saleId = sale.Id,
                invoiceNumber = sale.InvoiceNumber
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetReport(int id)
        {
            var sale = await _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.Cashier)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (sale == null) return NotFound();

            ViewBag.BarcodeSvg = BarcodeService.GenerateSvgBarcode(sale.InvoiceNumber);
            ViewBag.AmountInWords = NumberToWordsConverter.ConvertToWords(sale.PaidAmount > 0 ? sale.PaidAmount : sale.GrandTotal, "Taka");

            return View(sale);
        }

        [HttpPost]
        public async Task<IActionResult> PostSale(int id)
        {
            var sale = await _context.Sales.FindAsync(id);
            if (sale == null) return Json(new { success = false, message = "Sale not found" });

            sale.IsPosted = true;
            sale.Status = "Posted";
            await _context.SaveChangesAsync();

            return Json(new { success = true, message = "Sale marked as Posted." });
        }

        [HttpPost]
        public async Task<IActionResult> BulkPost([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
            {
                return Json(new { success = false, message = "No invoices selected to post." });
            }

            var sales = await _context.Sales.Where(s => ids.Contains(s.Id)).ToListAsync();
            foreach (var s in sales)
            {
                s.IsPosted = true;
                s.Status = "Posted";
            }
            await _context.SaveChangesAsync();

            return Json(new { success = true, count = sales.Count, message = $"{sales.Count} invoice(s) marked as Posted successfully." });
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var sale = await _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (sale == null) return NotFound();

            if (sale.IsPosted)
            {
                TempData["ErrorMessage"] = $"Sale Invoice #{sale.InvoiceNumber} is already Posted and cannot be updated.";
                return RedirectToAction(nameof(Index));
            }

            ViewBag.Customers = await _context.Customers.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();
            ViewBag.Categories = await _context.Categories.Where(c => c.IsActive).OrderBy(c => c.Name).ToListAsync();

            var vm = new SaleEntryViewModel
            {
                Id = sale.Id,
                InvoiceNo = sale.InvoiceNumber,
                SaleDate = sale.SaleDate,
                CustomerId = sale.CustomerId,
                CustomerType = sale.CustomerType ?? "Walk-in",
                AdmissionNo = sale.AdmissionNo,
                SaleOrderNo = sale.SaleOrderNo,
                FundType = sale.FundType ?? "Cash",
                MobileNumber = sale.MobileNumber,
                TotalAmount = sale.SubTotal,
                DiscountPercent = sale.DiscountPercent,
                DiscountAmount = sale.DiscountAmount,
                RoundUp = sale.RoundUp,
                FinalPayable = sale.FinalPayable > 0 ? sale.FinalPayable : sale.GrandTotal,
                PaidAmount = sale.PaidAmount,
                DuesAmount = sale.DuesAmount,
                PaymentMethod = sale.PaymentMethod ?? "Cash",
                Notes = sale.Notes,
                Items = sale.SaleItems.Select(si => new SaleItemEntryInput
                {
                    ProductId = si.ProductId,
                    ProductName = si.ProductName,
                    ProductCode = si.Product != null ? (!string.IsNullOrEmpty(si.Product.Barcode) ? si.Product.Barcode : si.Product.SKU) : "",
                    BatchNo = si.BatchNo,
                    Quantity = si.Quantity,
                    Price = si.UnitPrice,
                    SubTotal = si.SubTotal,
                    DiscountPercent = 0,
                    DiscountAmount = si.DiscountAmount,
                    TotalAmount = si.TotalAmount
                }).ToList()
            };

            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit([FromBody] SaleEntryViewModel model)
        {
            if (model == null || model.Items == null || !model.Items.Any())
            {
                return Json(new { success = false, message = "Please add at least one item to the sale." });
            }

            var sale = await _context.Sales
                .Include(s => s.SaleItems)
                .FirstOrDefaultAsync(s => s.Id == model.Id);

            if (sale == null)
            {
                return Json(new { success = false, message = "Sale record not found." });
            }

            if (sale.IsPosted)
            {
                return Json(new { success = false, message = "Posted sales cannot be updated." });
            }

            int cashierId = sale.CashierId ?? 1;
            var uidClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(uidClaim, out int uid)) cashierId = uid;

            // 1. Revert previous stock deductions for old items
            foreach (var oldItem in sale.SaleItems)
            {
                var product = await _context.Products.FindAsync(oldItem.ProductId);
                if (product != null)
                {
                    int prevStock = product.CurrentStock;
                    product.CurrentStock += oldItem.Quantity;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Adjustment",
                        Quantity = oldItem.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = sale.InvoiceNumber,
                        Notes = $"Stock restored due to Invoice #{sale.InvoiceNumber} edit",
                        CreatedByUserId = cashierId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }
            }

            // Remove previous items
            _context.SaleItems.RemoveRange(sale.SaleItems);
            sale.SaleItems.Clear();

            // 2. Apply new stock deductions and add new items
            foreach (var item in model.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    int prevStock = product.CurrentStock;
                    product.CurrentStock -= item.Quantity;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Sale",
                        Quantity = item.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = sale.InvoiceNumber,
                        Notes = $"Sale item updated via Invoice #{sale.InvoiceNumber}",
                        CreatedByUserId = cashierId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }

                sale.SaleItems.Add(new SaleItem
                {
                    ProductId = item.ProductId,
                    ProductName = item.ProductName,
                    BatchNo = item.BatchNo,
                    Quantity = item.Quantity,
                    UnitPrice = item.Price,
                    SubTotal = item.SubTotal,
                    DiscountAmount = item.DiscountAmount,
                    TotalAmount = item.TotalAmount
                });
            }

            // 3. Update sale header info
            sale.SaleDate = model.SaleDate;
            sale.CustomerId = model.CustomerId > 0 ? model.CustomerId : 1;
            sale.CustomerType = model.CustomerType ?? "Walk-in";
            sale.AdmissionNo = model.AdmissionNo;
            sale.SaleOrderNo = model.SaleOrderNo;
            sale.FundType = model.FundType ?? "Cash";
            sale.MobileNumber = model.MobileNumber;
            sale.SubTotal = model.TotalAmount;
            sale.DiscountPercent = model.DiscountPercent;
            sale.DiscountAmount = model.DiscountAmount;
            sale.RoundUp = model.RoundUp;
            sale.FinalPayable = model.FinalPayable;
            sale.GrandTotal = model.FinalPayable > 0 ? model.FinalPayable : model.TotalAmount - model.DiscountAmount;
            sale.PaidAmount = model.PaidAmount;
            sale.ChangeAmount = (model.PaidAmount > model.FinalPayable) ? (model.PaidAmount - model.FinalPayable) : 0;
            sale.DuesAmount = model.DuesAmount;
            sale.PaymentMethod = model.PaymentMethod ?? "Cash";
            sale.Notes = model.Notes;
            sale.CashierId = cashierId;
            sale.Status = "Unposted";
            sale.IsPosted = false;

            await _context.SaveChangesAsync();

            return Json(new
            {
                success = true,
                message = "Sale invoice updated successfully!",
                saleId = sale.Id,
                invoiceNumber = sale.InvoiceNumber
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetProductsJson(string? query, int? categoryId)
        {
            var q = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Unit)
                .Where(p => p.IsActive);

            if (categoryId.HasValue && categoryId.Value > 0)
            {
                q = q.Where(p => p.CategoryId == categoryId.Value);
            }

            if (!string.IsNullOrWhiteSpace(query))
            {
                var term = query.Trim().ToLower();
                q = q.Where(p => p.Name.ToLower().Contains(term)
                              || (p.GenericName != null && p.GenericName.ToLower().Contains(term))
                              || p.SKU.ToLower().Contains(term)
                              || p.Barcode.ToLower().Contains(term)
                              || (p.Category != null && p.Category.Name.ToLower().Contains(term)));
            }

            // Return ALL products sorted by Order Form sequence (ASM-001 ... ASM-170)
            var list = await q
                .OrderBy(p => p.SKU.StartsWith("ASM-") ? 0 : 1)
                .ThenBy(p => p.SKU)
                .ThenBy(p => p.Name)
                .Select(p => new ProductModalDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    GenericName = p.GenericName ?? "",
                    Code = p.SKU,
                    Barcode = p.Barcode,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category != null ? p.Category.Name : "",
                    UnitName = p.Unit != null ? p.Unit.ShortCode : "PCS",
                    PurchasePrice = p.CostPrice,
                    SalePrice = p.SellingPrice,
                    CurrentStock = p.CurrentStock,
                    ImageUrl = p.ImageUrl ?? "/uploads/products/pharma-item.svg"
                }).ToListAsync();

            return Json(new { success = true, items = list });
        }

        [HttpGet]
        public async Task<IActionResult> OrderForm(int? categoryId)
        {
            var q = _context.Products
                .Include(p => p.Category)
                .Where(p => p.IsActive)
                .AsQueryable();

            if (categoryId.HasValue && categoryId.Value > 0)
            {
                q = q.Where(p => p.CategoryId == categoryId.Value);
                ViewBag.SelectedCategoryName = await _context.Categories
                    .Where(c => c.Id == categoryId.Value)
                    .Select(c => c.Name)
                    .FirstOrDefaultAsync();
            }

            var products = await q
                .OrderBy(p => p.Category != null ? p.Category.Name : "")
                .ThenBy(p => p.SKU)
                .ThenBy(p => p.Name)
                .ToListAsync();

            ViewBag.Categories = await _context.Categories
                .Where(c => c.IsActive)
                .OrderBy(c => c.Name)
                .ToListAsync();

            ViewBag.SelectedCategoryId = categoryId;

            return View(products);
        }

        [HttpGet]
        [AuthorizePermission("SalesOrders", "View")]
        public async Task<IActionResult> Details(int id)
        {
            var sale = await _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.Cashier)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (sale == null) return NotFound();

            return View(sale);
        }

        [HttpGet]
        [AuthorizePermission("Reports", "View")]
        public async Task<IActionResult> Reports(string? startDate, string? endDate)
        {
            var sDate = DateTime.TryParse(startDate, out var parsedStart) ? parsedStart.Date : DateTime.UtcNow.Date.AddDays(-30);
            var eDate = DateTime.TryParse(endDate, out var parsedEnd) ? parsedEnd.Date.AddDays(1).AddTicks(-1) : DateTime.UtcNow.Date.AddDays(1).AddTicks(-1);

            var sales = await _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.SaleItems)
                .Where(s => s.SaleDate >= sDate && s.SaleDate <= eDate)
                .OrderBy(s => s.SaleDate)
                .ToListAsync();

            ViewBag.StartDate = sDate.ToString("yyyy-MM-dd");
            ViewBag.EndDate = eDate.ToString("yyyy-MM-dd");

            ViewBag.TotalSales = sales.Sum(s => s.GrandTotal);
            ViewBag.TotalOrders = sales.Count;
            ViewBag.TotalTax = sales.Sum(s => s.TaxAmount);
            ViewBag.TotalDiscount = sales.Sum(s => s.DiscountAmount);

            ViewBag.CashTotal = sales.Where(s => s.PaymentMethod == "Cash").Sum(s => s.GrandTotal);
            ViewBag.CardTotal = sales.Where(s => s.PaymentMethod == "Card").Sum(s => s.GrandTotal);
            ViewBag.MobileTotal = sales.Where(s => s.PaymentMethod == "MobileBanking").Sum(s => s.GrandTotal);

            return View(sales);
        }
    }
}

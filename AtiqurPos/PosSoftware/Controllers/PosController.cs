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
    [AuthorizePermission("PosTerminal", "View")]
    public class PosController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IInventoryService _inventoryService;
        private readonly INumberSequenceService _sequenceService;
        private readonly ICompanyService _companyService;

        public PosController(ApplicationDbContext context, IInventoryService inventoryService, INumberSequenceService sequenceService, ICompanyService companyService)
        {
            _context = context;
            _inventoryService = inventoryService;
            _sequenceService = sequenceService;
            _companyService = companyService;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var categories = await _context.Categories
                .Where(c => c.IsActive)
                .OrderBy(c => c.Name)
                .ToListAsync();

            var products = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Unit)
                .Where(p => p.IsActive)
                .OrderBy(p => p.SKU.StartsWith("ASM-") ? 0 : 1)
                .ThenBy(p => p.SKU)
                .ThenBy(p => p.Name)
                .ToListAsync();

            var customers = await _context.Customers
                .Where(c => c.IsActive)
                .OrderBy(c => c.Id)
                .ToListAsync();

            var nextInvoice = await _sequenceService.GetNextInvoiceNumberAsync();

            var model = new PosTerminalViewModel
            {
                Categories = categories,
                Products = products,
                Customers = customers,
                DefaultInvoiceNumber = nextInvoice
            };

            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> GetProductByBarcode(string barcode)
        {
            if (string.IsNullOrWhiteSpace(barcode))
            {
                return Json(new { success = false, message = "Barcode is required" });
            }

            var product = await _context.Products
                .Include(p => p.Unit)
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.IsActive && (p.Barcode == barcode.Trim() || p.SKU == barcode.Trim()));

            if (product == null)
            {
                return Json(new { success = false, message = "Product not found" });
            }

            return Json(new
            {
                success = true,
                product = new
                {
                    product.Id,
                    product.Name,
                    product.Barcode,
                    product.SKU,
                    product.SellingPrice,
                    product.CostPrice,
                    product.CurrentStock,
                    UnitName = product.Unit?.ShortCode ?? "pcs",
                    CategoryName = product.Category?.Name ?? ""
                }
            });
        }

        [HttpGet]
        public async Task<IActionResult> SearchProducts(string? query, int? categoryId)
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
                q = q.Where(p => p.Name.ToLower().Contains(term) || p.Barcode.ToLower().Contains(term) || p.SKU.ToLower().Contains(term));
            }

            var items = await q.OrderBy(p => p.Name).Take(40).Select(p => new
            {
                p.Id,
                p.Name,
                p.Barcode,
                p.SKU,
                p.SellingPrice,
                p.CostPrice,
                p.CurrentStock,
                p.MinAlertStock,
                UnitName = p.Unit != null ? p.Unit.ShortCode : "pcs",
                CategoryName = p.Category != null ? p.Category.Name : ""
            }).ToListAsync();

            return Json(new { success = true, items });
        }

        [HttpPost]
        [AuthorizePermission("PosTerminal", "Create")]
        public async Task<IActionResult> ProcessCheckout([FromBody] CheckoutRequestDto dto)
        {
            if (dto == null || dto.Items == null || !dto.Items.Any())
            {
                return Json(new { success = false, message = "Cart is empty." });
            }

            var customer = await _context.Customers.FindAsync(dto.CustomerId);
            if (customer == null)
            {
                dto.CustomerId = 1;
            }

            foreach (var item in dto.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product == null)
                {
                    return Json(new { success = false, message = $"Product ID {item.ProductId} not found." });
                }
                if (product.CurrentStock < item.Quantity)
                {
                    return Json(new { success = false, message = $"Insufficient stock for '{product.Name}'. Available: {product.CurrentStock}, Requested: {item.Quantity}." });
                }
            }

            var invoiceNumber = await _sequenceService.GetNextInvoiceNumberAsync();
            var nextSo = await _sequenceService.GetNextSaleOrderNumberAsync();

            int cashierId = 1;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out int uid))
            {
                cashierId = uid;
            }

            decimal effectivePaid = dto.PaidAmount > 0 ? dto.PaidAmount : dto.GrandTotal;
            decimal dues = Math.Max(0, dto.GrandTotal - effectivePaid);

            var sale = new Sale
            {
                InvoiceNumber = invoiceNumber,
                SaleDate = DateTime.UtcNow,
                CustomerId = dto.CustomerId > 0 ? dto.CustomerId : 1,
                CustomerType = "Walk-in",
                SaleOrderNo = nextSo,
                FundType = dto.PaymentMethod ?? "Cash",
                SubTotal = dto.SubTotal,
                TaxRate = dto.TaxRate,
                TaxAmount = dto.TaxAmount,
                DiscountPercent = dto.DiscountPercent,
                DiscountAmount = dto.DiscountAmount,
                FinalPayable = dto.GrandTotal,
                GrandTotal = dto.GrandTotal,
                PaidAmount = effectivePaid,
                DuesAmount = dues,
                ChangeAmount = dto.ChangeAmount,
                PaymentMethod = dto.PaymentMethod ?? "Cash",
                Status = "Unposted",
                IsPosted = false,
                Notes = dto.Notes,
                CashierId = cashierId
            };

            foreach (var item in dto.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                decimal cost = item.CostPrice > 0 ? item.CostPrice : (product?.CostPrice ?? 0);
                sale.SaleItems.Add(new SaleItem
                {
                    ProductId = item.ProductId,
                    ProductName = item.Name,
                    CostPrice = cost,
                    UnitPrice = item.UnitPrice,
                    Quantity = item.Quantity,
                    SubTotal = item.UnitPrice * item.Quantity,
                    DiscountAmount = item.DiscountAmount,
                    TotalAmount = (item.UnitPrice * item.Quantity) - item.DiscountAmount
                });
            }

            _context.Sales.Add(sale);
            await _context.SaveChangesAsync();
            await _sequenceService.UpdateLastInvoiceNumberAsync(sale.InvoiceNumber);

            await _inventoryService.DeductStockForSaleAsync(sale.Id, cashierId);

            if (dto.CustomerId > 1)
            {
                var cust = await _context.Customers.FindAsync(dto.CustomerId);
                if (cust != null)
                {
                    cust.LoyaltyPoints += (int)(sale.GrandTotal / 10);
                    await _context.SaveChangesAsync();
                }
            }

            return Json(new
            {
                success = true,
                message = "Sale processed successfully!",
                saleId = sale.Id,
                invoiceNumber = sale.InvoiceNumber,
                changeAmount = sale.ChangeAmount
            });
        }

        [HttpPost]
        public async Task<IActionResult> QuickAddCustomer([FromBody] QuickCustomerDto dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
            {
                return Json(new { success = false, message = "Customer name is required." });
            }

            var customer = new Customer
            {
                Name = dto.Name.Trim(),
                Phone = dto.Phone?.Trim() ?? "",
                Address = dto.Address?.Trim() ?? "",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            return Json(new { success = true, id = customer.Id, name = customer.Name, phone = customer.Phone });
        }

        [HttpGet]
        public async Task<IActionResult> PrintReceipt(int id)
        {
            var sale = await _context.Sales
                .Include(s => s.Customer)
                .Include(s => s.Cashier)
                .Include(s => s.SaleItems)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (sale == null)
            {
                return NotFound();
            }

            var company = await _companyService.GetActiveCompanyAsync();
            var model = new ReceiptViewModel
            {
                StoreName = company.CompanyName,
                StoreAddress = company.Address ?? "",
                StorePhone = company.Phone ?? "",
                Sale = sale,
                Items = sale.SaleItems.ToList()
            };

            return View(model);
        }
    }
}

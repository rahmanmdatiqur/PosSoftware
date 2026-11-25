using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using PosSoftware.Models.Entities;

namespace PosSoftware.Models.ViewModels
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "Username is required")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        [DataType(DataType.Password)]
        public string Password { get; set; } = string.Empty;

        public bool RememberMe { get; set; }
    }

    public class PosTerminalViewModel
    {
        public List<Category> Categories { get; set; } = new();
        public List<Product> Products { get; set; } = new();
        public List<Customer> Customers { get; set; } = new();
        public string DefaultInvoiceNumber { get; set; } = string.Empty;
    }

    public class CartItemDto
    {
        public int ProductId { get; set; }
        public string Barcode { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public decimal UnitPrice { get; set; }
        public decimal CostPrice { get; set; }
        public int Quantity { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal Total => (UnitPrice * Quantity) - DiscountAmount;
    }

    public class QuickCustomerDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Address { get; set; }
    }

    public class CheckoutRequestDto
    {
        public int CustomerId { get; set; }
        public decimal SubTotal { get; set; }
        public decimal TaxRate { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal GrandTotal { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal ChangeAmount { get; set; }
        public string PaymentMethod { get; set; } = "Cash";
        public string? Notes { get; set; }
        public List<CartItemDto> Items { get; set; } = new();
    }

    public class ReceiptViewModel
    {
        public string StoreName { get; set; } = "Smart POS & Retail Solutions";
        public string StoreAddress { get; set; } = "Plot 14, Commercial Zone, Tech Hub";
        public string StorePhone { get; set; } = "+1 (800) 555-0199";
        public string StoreEmail { get; set; } = "pos-support@smartpos.com";
        public Sale Sale { get; set; } = default!;
        public List<SaleItem> Items { get; set; } = new();
    }

    public class DashboardViewModel
    {
        public decimal TodaySales { get; set; }
        public int TodayOrdersCount { get; set; }
        public decimal MonthSales { get; set; }
        public int TotalProducts { get; set; }
        public int LowStockCount { get; set; }

        // Screenshot 1 Metrics
        public decimal TotalSalesPharmacy { get; set; }
        public int TotalInvoicesPharmacy { get; set; }
        public decimal TotalPurchasePharmacy { get; set; }
        public int TotalPurchasesCountPharmacy { get; set; }
        public decimal TotalSalesCanteen { get; set; } = 0;
        public decimal TotalPurchaseCanteen { get; set; } = 0;

        public List<string> SalesChartLabels { get; set; } = new();
        public List<decimal> SalesChartData { get; set; } = new();
        public List<string> PurchaseChartLabels { get; set; } = new();
        public List<decimal> PurchaseChartData { get; set; } = new();

        public List<Sale> RecentSales { get; set; } = new();
        public List<Product> LowStockProducts { get; set; } = new();
        public List<TopSellingProductDto> TopSellingProducts { get; set; } = new();
    }

    public class TopSellingProductDto
    {
        public string ProductName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public int TotalSoldQty { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class RolePermissionMatrixViewModel
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public List<AppRole> Roles { get; set; } = new();
        public List<AppModulePage> AllPages { get; set; } = new();
        public List<PagePermissionRowDto> Rows { get; set; } = new();
    }

    public class PagePermissionRowDto
    {
        public int AppModulePageId { get; set; }
        public string ModuleName { get; set; } = string.Empty;
        public string PageName { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string IconClass { get; set; } = string.Empty;
        public bool CanView { get; set; }
        public bool CanCreate { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
    }

    public class UserFormViewModel
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [EmailAddress]
        public string? Email { get; set; }

        public string? Phone { get; set; }

        [DataType(DataType.Password)]
        public string? Password { get; set; }

        [Required]
        public int RoleId { get; set; }

        public bool IsActive { get; set; } = true;
    }

    public class StockAdjustmentFormViewModel
    {
        public string AdjustmentNo { get; set; } = string.Empty;
        public string? Notes { get; set; }
        public List<StockAdjustmentItemInput> Items { get; set; } = new();
    }

    public class StockAdjustmentItemInput
    {
        public int ProductId { get; set; }
        public int AdjustedStock { get; set; }
        public string? Reason { get; set; }
    }

    public class SaleEntryViewModel
    {
        public int Id { get; set; }
        public string InvoiceNo { get; set; } = string.Empty;
        public DateTime SaleDate { get; set; } = DateTime.UtcNow;
        public int CustomerId { get; set; } = 1;
        public string CustomerType { get; set; } = "Walk-in";
        public string? AdmissionNo { get; set; }
        public string? SaleOrderNo { get; set; }
        public string FundType { get; set; } = "Cash";
        public string? MobileNumber { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal RoundUp { get; set; }
        public decimal FinalPayable { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DuesAmount { get; set; }
        public string PaymentMethod { get; set; } = "Cash";
        public string? Notes { get; set; }
        public List<SaleItemEntryInput> Items { get; set; } = new();
    }

    public class SaleItemEntryInput
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public string? BatchNo { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal SubTotal { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
    }

    public class PurchaseEntryViewModel
    {
        public int Id { get; set; }
        public string PurchaseNo { get; set; } = string.Empty;
        public int SupplierId { get; set; }
        public DateTime PurchaseDate { get; set; } = DateTime.UtcNow;
        public DateTime ReceiveDate { get; set; } = DateTime.UtcNow;
        public string? PurchaseOrderNo { get; set; }
        public decimal SubTotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal DueAmount { get; set; }
        public string? Notes { get; set; }
        public List<PurchaseItemEntryInput> Items { get; set; } = new();
    }

    public class PurchaseItemEntryInput
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal PurchasePrice { get; set; }
        public decimal TotalAmount { get; set; }
    }

    public class ProductModalDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? GenericName { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string UnitName { get; set; } = "PCS";
        public decimal PurchasePrice { get; set; }
        public decimal SalePrice { get; set; }
        public int CurrentStock { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class ProductFormViewModel
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string SKU { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Barcode { get; set; } = string.Empty;

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(150)]
        public string? GenericName { get; set; }

        [MaxLength(500)]
        public string? Description { get; set; }

        [Required]
        public int CategoryId { get; set; }

        [Required]
        public int UnitId { get; set; }

        public int? SupplierId { get; set; }

        [Required]
        public decimal CostPrice { get; set; }

        [Required]
        public decimal SellingPrice { get; set; }

        public int CurrentStock { get; set; } = 0;

        public int MinAlertStock { get; set; } = 5;

        public string? ExistingImageUrl { get; set; }

        public IFormFile? ImageFile { get; set; }

        public bool IsActive { get; set; } = true;
    }

    public class StockReportViewModel
    {
        public DateTime AsOfDate { get; set; } = DateTime.UtcNow;
        public int? SelectedCategoryId { get; set; }
        public string SelectedCategoryName { get; set; } = "All Categories";
        public List<Category> Categories { get; set; } = new();
        public List<StockReportItemDto> Items { get; set; } = new();

        public int TotalItems => Items.Count;
        public int TotalStockQty => Items.Sum(i => i.CurrentStock);
        public decimal TotalCostValue => Items.Sum(i => i.TotalCostValue);
        public decimal TotalSaleValue => Items.Sum(i => i.TotalSaleValue);
    }

    public class StockReportItemDto
    {
        public int ProductId { get; set; }
        public string SKU { get; set; } = string.Empty;
        public string Barcode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string? GenericName { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string UnitName { get; set; } = string.Empty;
        public decimal CostPrice { get; set; }
        public decimal SellingPrice { get; set; }
        public int CurrentStock { get; set; }
        public int MinAlertStock { get; set; }
        public decimal TotalCostValue => CurrentStock * CostPrice;
        public decimal TotalSaleValue => CurrentStock * SellingPrice;
        public string Status => CurrentStock <= 0 ? "Out of Stock" : (CurrentStock <= MinAlertStock ? "Low Stock" : "In Stock");
    }
}

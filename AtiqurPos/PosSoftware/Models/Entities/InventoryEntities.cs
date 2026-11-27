using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PosSoftware.Models.Entities
{
    public class Category
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }

    public class Unit
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(10)]
        public string ShortCode { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }

    public class Supplier
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? ContactPerson { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        [MaxLength(300)]
        public string? Address { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }

    public class Product
    {
        [Key]
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

        public int CategoryId { get; set; }
        [ForeignKey("CategoryId")]
        public virtual Category? Category { get; set; }

        public int UnitId { get; set; }
        [ForeignKey("UnitId")]
        public virtual Unit? Unit { get; set; }

        public int? SupplierId { get; set; }
        [ForeignKey("SupplierId")]
        public virtual Supplier? Supplier { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal CostPrice { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal SellingPrice { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal MRP { get; set; } = 0;

        public int CurrentStock { get; set; } = 0;

        public int MinAlertStock { get; set; } = 5;

        [MaxLength(255)]
        public string? ImageUrl { get; set; }

        public bool IsActive { get; set; } = true;

        public int SortOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<StockTransaction> StockTransactions { get; set; } = new List<StockTransaction>();
        public virtual ICollection<SaleItem> SaleItems { get; set; } = new List<SaleItem>();
    }

    public class StockTransaction
    {
        [Key]
        public int Id { get; set; }

        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public virtual Product? Product { get; set; }

        [Required]
        [MaxLength(30)]
        public string TransactionType { get; set; } = string.Empty;

        public int Quantity { get; set; }

        public int PreviousStock { get; set; }

        public int NewStock { get; set; }

        [MaxLength(50)]
        public string? ReferenceNo { get; set; }

        [MaxLength(255)]
        public string? Notes { get; set; }

        public int? CreatedByUserId { get; set; }
        [ForeignKey("CreatedByUserId")]
        public virtual AppUser? CreatedByUser { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class StockAdjustment
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string AdjustmentNo { get; set; } = string.Empty;

        public DateTime AdjustmentDate { get; set; } = DateTime.UtcNow;

        [MaxLength(255)]
        public string? Notes { get; set; }

        public int? CreatedByUserId { get; set; }
        [ForeignKey("CreatedByUserId")]
        public virtual AppUser? CreatedByUser { get; set; }

        public virtual ICollection<StockAdjustmentItem> Items { get; set; } = new List<StockAdjustmentItem>();
    }

    public class StockAdjustmentItem
    {
        [Key]
        public int Id { get; set; }

        public int StockAdjustmentId { get; set; }
        [ForeignKey("StockAdjustmentId")]
        public virtual StockAdjustment? StockAdjustment { get; set; }

        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public virtual Product? Product { get; set; }

        public int OldStock { get; set; }

        public int AdjustedStock { get; set; }

        public int DifferenceQty { get; set; }

        [MaxLength(100)]
        public string? Reason { get; set; }
    }
}

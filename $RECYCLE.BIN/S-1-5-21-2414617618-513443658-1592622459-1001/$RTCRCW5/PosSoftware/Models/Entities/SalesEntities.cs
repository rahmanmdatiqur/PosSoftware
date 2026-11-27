using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PosSoftware.Models.Entities
{
    public class Customer
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        [MaxLength(255)]
        public string? Address { get; set; }

        public int LoyaltyPoints { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<Sale> Sales { get; set; } = new List<Sale>();
    }

    public class Sale
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string InvoiceNumber { get; set; } = string.Empty;

        public DateTime SaleDate { get; set; } = DateTime.UtcNow;

        public int CustomerId { get; set; }
        [ForeignKey("CustomerId")]
        public virtual Customer? Customer { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal SubTotal { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TaxRate { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal TaxAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal DiscountPercent { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal DiscountAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal RoundUp { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal FinalPayable { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal GrandTotal { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal PaidAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal ChangeAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal DuesAmount { get; set; } = 0;

        [MaxLength(50)]
        public string? AdmissionNo { get; set; }

        [MaxLength(50)]
        public string? SaleOrderNo { get; set; }

        [MaxLength(50)]
        public string CustomerType { get; set; } = "Walk-in";

        [MaxLength(50)]
        public string FundType { get; set; } = "Cash";

        [MaxLength(30)]
        public string? MobileNumber { get; set; }

        public bool IsPosted { get; set; } = true;

        [Required]
        [MaxLength(30)]
        public string PaymentMethod { get; set; } = "Cash";

        [MaxLength(30)]
        public string Status { get; set; } = "Completed";

        [MaxLength(255)]
        public string? Notes { get; set; }

        public int? CashierId { get; set; }
        [ForeignKey("CashierId")]
        public virtual AppUser? Cashier { get; set; }

        public virtual ICollection<SaleItem> SaleItems { get; set; } = new List<SaleItem>();
    }

    public class SaleItem
    {
        [Key]
        public int Id { get; set; }

        public int SaleId { get; set; }
        [ForeignKey("SaleId")]
        public virtual Sale? Sale { get; set; }

        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public virtual Product? Product { get; set; }

        [Required]
        [MaxLength(150)]
        public string ProductName { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? BatchNo { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal CostPrice { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal SubTotal { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal DiscountAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PosSoftware.Models.Entities
{
    public class Purchase
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string PurchaseNo { get; set; } = string.Empty;

        public DateTime PurchaseDate { get; set; } = DateTime.UtcNow;

        public DateTime ReceiveDate { get; set; } = DateTime.UtcNow;

        public int SupplierId { get; set; }
        [ForeignKey("SupplierId")]
        public virtual Supplier? Supplier { get; set; }

        [MaxLength(50)]
        public string? PurchaseOrderNo { get; set; }

        public int TotalQty { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal SubTotal { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal DiscountAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal PaidAmount { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal DueAmount { get; set; } = 0;

        [MaxLength(30)]
        public string Status { get; set; } = "Posted";

        public bool IsPosted { get; set; } = true;

        [MaxLength(255)]
        public string? Notes { get; set; }

        public int? CreatedByUserId { get; set; }
        [ForeignKey("CreatedByUserId")]
        public virtual AppUser? CreatedByUser { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<PurchaseItem> PurchaseItems { get; set; } = new List<PurchaseItem>();
    }

    public class PurchaseItem
    {
        [Key]
        public int Id { get; set; }

        public int PurchaseId { get; set; }
        [ForeignKey("PurchaseId")]
        public virtual Purchase? Purchase { get; set; }

        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public virtual Product? Product { get; set; }

        [Required]
        [MaxLength(150)]
        public string ProductName { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? ProductCode { get; set; }

        public int Quantity { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal UnitPrice { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }
    }
}


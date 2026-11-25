using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PosSoftware.Models.Entities
{
    [Table("Company")]
    public class Company
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Company Short Code is required (e.g. ASM)")]
        [MaxLength(50)]
        [Display(Name = "Company Code / Short Name")]
        public string CompanyCode { get; set; } = string.Empty;

        [Required(ErrorMessage = "Company Name is required")]
        [MaxLength(200)]
        [Display(Name = "Company Full Name")]
        public string CompanyName { get; set; } = string.Empty;

        [MaxLength(500)]
        [Display(Name = "Office Address")]
        public string? Address { get; set; }

        [MaxLength(50)]
        [Display(Name = "Phone / Mobile")]
        public string? Phone { get; set; }

        [MaxLength(100)]
        [EmailAddress]
        [Display(Name = "Email Address")]
        public string? Email { get; set; }

        [MaxLength(100)]
        [Display(Name = "Website")]
        public string? Website { get; set; }

        [MaxLength(255)]
        [Display(Name = "Logo URL")]
        public string? LogoUrl { get; set; }

        [MaxLength(500)]
        [Display(Name = "Invoice Footer Note")]
        public string? InvoiceFooterNote { get; set; }

        [Display(Name = "Is Active")]
        public bool IsActive { get; set; } = true;

        [Display(Name = "Created At")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Display(Name = "Updated At")]
        public DateTime? UpdatedAt { get; set; }
    }
}

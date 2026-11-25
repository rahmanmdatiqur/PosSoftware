using System;
using System.ComponentModel.DataAnnotations;

namespace PosSoftware.Models.Entities
{
    public class Code
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string CodeGroup { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string CodeName { get; set; } = string.Empty;

        [Required]
        [StringLength(20)]
        public string Prefix { get; set; } = string.Empty;

        public int Length { get; set; } = 5;

        [StringLength(150)]
        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class CodeGenerate
    {
        public int Id { get; set; }

        public int? CodeId { get; set; }

        [Required]
        [StringLength(50)]
        public string CodeName { get; set; } = string.Empty;

        public int CurrentYear { get; set; } = DateTime.UtcNow.Year;

        [StringLength(20)]
        public string? Prefix { get; set; }

        public int LastId { get; set; } = 0;

        [StringLength(50)]
        public string? LastCode { get; set; }

        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

        public Code? Code { get; set; }
    }
}

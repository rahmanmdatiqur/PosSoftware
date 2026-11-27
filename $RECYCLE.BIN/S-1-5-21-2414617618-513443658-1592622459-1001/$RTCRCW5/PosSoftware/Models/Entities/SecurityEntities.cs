using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PosSoftware.Models.Entities
{
    public class AppRole
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string RoleName { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public virtual ICollection<AppUser> Users { get; set; } = new List<AppUser>();
        public virtual ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
    }

    public class AppUser
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Email { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        public string Salt { get; set; } = string.Empty;

        public int RoleId { get; set; }

        [ForeignKey("RoleId")]
        public virtual AppRole? Role { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastLoginAt { get; set; }
    }

    public class AppModulePage
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string ModuleName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string PageName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string DisplayName { get; set; } = string.Empty;

        [MaxLength(100)]
        public string ControllerName { get; set; } = string.Empty;

        [MaxLength(100)]
        public string ActionName { get; set; } = string.Empty;

        [MaxLength(50)]
        public string IconClass { get; set; } = "bi bi-circle";

        public int SortOrder { get; set; } = 0;

        public bool ShowInMenu { get; set; } = true;

        public bool IsActive { get; set; } = true;

        public virtual ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
    }

    public class RolePermission
    {
        [Key]
        public int Id { get; set; }

        public int RoleId { get; set; }

        [ForeignKey("RoleId")]
        public virtual AppRole? Role { get; set; }

        public int AppModulePageId { get; set; }

        [ForeignKey("AppModulePageId")]
        public virtual AppModulePage? AppModulePage { get; set; }

        public bool CanView { get; set; } = false;
        public bool CanCreate { get; set; } = false;
        public bool CanEdit { get; set; } = false;
        public bool CanDelete { get; set; } = false;
    }
}

using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Models.Entities;

namespace PosSoftware.Services
{
    public interface ICompanyService
    {
        Task<Company> GetActiveCompanyAsync();
    }

    public class CompanyService : ICompanyService
    {
        private readonly ApplicationDbContext _context;

        public CompanyService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Company> GetActiveCompanyAsync()
        {
            var company = await _context.Companies
                .AsNoTracking()
                .OrderByDescending(c => c.IsActive)
                .ThenBy(c => c.Id)
                .FirstOrDefaultAsync();

            return company ?? new Company();
        }
    }
}

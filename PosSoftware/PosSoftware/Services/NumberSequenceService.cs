using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using System.Text.RegularExpressions;

namespace PosSoftware.Services
{
    public interface INumberSequenceService
    {
        Task<string> GetNextInvoiceNumberAsync();
        Task<string> GetNextPurchaseNumberAsync();
        Task<string> GetNextSaleOrderNumberAsync();
        Task<string> GetNextPurchaseOrderNumberAsync();
    }

    public class NumberSequenceService : INumberSequenceService
    {
        private readonly ApplicationDbContext _context;

        public NumberSequenceService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<string> GetNextInvoiceNumberAsync()
        {
            var invoiceNumbers = await _context.Sales
                .Select(s => s.InvoiceNumber)
                .ToListAsync();

            int maxNum = 224; // Baseline starting number
            var regex = new Regex(@"\b(?:INV-)?(\d+)\b", RegexOptions.IgnoreCase);

            foreach (var inv in invoiceNumbers)
            {
                if (string.IsNullOrWhiteSpace(inv)) continue;
                var match = regex.Match(inv);
                if (match.Success)
                {
                    string numPart = match.Groups[1].Value;
                    if (int.TryParse(numPart, out int num))
                    {
                        if (num > maxNum) maxNum = num;
                    }
                }
            }

            return $"INV-{(maxNum + 1):D5}";
        }

        public async Task<string> GetNextPurchaseNumberAsync()
        {
            var purchaseNumbers = await _context.Purchases
                .Select(p => p.PurchaseNo)
                .ToListAsync();

            int maxNum = 37; // Baseline starting number
            var regex = new Regex(@"\b(?:PUR-)?(\d+)\b", RegexOptions.IgnoreCase);

            foreach (var pno in purchaseNumbers)
            {
                if (string.IsNullOrWhiteSpace(pno)) continue;
                var match = regex.Match(pno);
                if (match.Success)
                {
                    string numPart = match.Groups[1].Value;
                    if (int.TryParse(numPart, out int num))
                    {
                        if (num > maxNum) maxNum = num;
                    }
                }
            }

            return $"PUR-{(maxNum + 1):D5}";
        }

        public async Task<string> GetNextSaleOrderNumberAsync()
        {
            var soNumbers = await _context.Sales
                .Where(s => !string.IsNullOrEmpty(s.SaleOrderNo))
                .Select(s => s.SaleOrderNo!)
                .ToListAsync();

            int maxNum = 0;
            var regex = new Regex(@"\b(?:SO-)?(\d+)\b", RegexOptions.IgnoreCase);

            foreach (var so in soNumbers)
            {
                var match = regex.Match(so);
                if (match.Success)
                {
                    string numPart = match.Groups[1].Value;
                    if (int.TryParse(numPart, out int num))
                    {
                        if (num > maxNum) maxNum = num;
                    }
                }
            }

            return $"SO-{(maxNum + 1):D5}";
        }

        public async Task<string> GetNextPurchaseOrderNumberAsync()
        {
            var poNumbers = await _context.Purchases
                .Where(p => !string.IsNullOrEmpty(p.PurchaseOrderNo))
                .Select(p => p.PurchaseOrderNo!)
                .ToListAsync();

            int maxNum = 37;
            var regex = new Regex(@"\b(?:PO-\d{4}-)?(\d+)\b", RegexOptions.IgnoreCase);

            foreach (var po in poNumbers)
            {
                var match = regex.Match(po);
                if (match.Success)
                {
                    string numPart = match.Groups[1].Value;
                    if (int.TryParse(numPart, out int num))
                    {
                        if (num > maxNum) maxNum = num;
                    }
                }
            }

            return $"PO-{DateTime.Now.Year}-{(maxNum + 1):D4}";
        }
    }
}

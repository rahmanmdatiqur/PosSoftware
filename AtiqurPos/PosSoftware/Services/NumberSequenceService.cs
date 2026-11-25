using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Models.Entities;
using System.Text.RegularExpressions;

namespace PosSoftware.Services
{
    public interface INumberSequenceService
    {
        Task<string> GetNextInvoiceNumberAsync();
        Task<string> GetNextPurchaseNumberAsync();
        Task<string> GetNextSaleOrderNumberAsync();
        Task<string> GetNextPurchaseOrderNumberAsync();
        Task UpdateLastInvoiceNumberAsync(string invoiceNo);
        Task UpdateLastPurchaseNumberAsync(string purchaseNo);
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
            return await GenerateCodeAsync("Invoice", "Sales", "INV-", 5, async () =>
            {
                var invoiceNumbers = await _context.Sales.Select(s => s.InvoiceNumber).ToListAsync();
                return GetMaxNumberFromList(invoiceNumbers, @"\b(?:INV-)?(\d+)\b");
            });
        }

        public async Task<string> GetNextPurchaseNumberAsync()
        {
            return await GenerateCodeAsync("Purchase", "Purchase", "PUR-", 5, async () =>
            {
                var purchaseNumbers = await _context.Purchases.Select(p => p.PurchaseNo).ToListAsync();
                return GetMaxNumberFromList(purchaseNumbers, @"\b(?:PUR-)?(\d+)\b");
            });
        }

        public async Task<string> GetNextSaleOrderNumberAsync()
        {
            return await GenerateCodeAsync("SaleOrder", "Sales", "SO-", 5, async () =>
            {
                var soNumbers = await _context.Sales
                    .Where(s => !string.IsNullOrEmpty(s.SaleOrderNo))
                    .Select(s => s.SaleOrderNo!)
                    .ToListAsync();
                return GetMaxNumberFromList(soNumbers, @"\b(?:SO-)?(\d+)\b");
            });
        }

        public async Task<string> GetNextPurchaseOrderNumberAsync()
        {
            int year = DateTime.UtcNow.Year;
            string prefix = $"PO-{year}-";
            return await GenerateCodeAsync("PurchaseOrder", "Purchase", prefix, 4, async () =>
            {
                var poNumbers = await _context.Purchases
                    .Where(p => !string.IsNullOrEmpty(p.PurchaseOrderNo))
                    .Select(p => p.PurchaseOrderNo!)
                    .ToListAsync();
                return GetMaxNumberFromList(poNumbers, @"\b(?:PO-\d{4}-)?(\d+)\b");
            });
        }

        private async Task<string> GenerateCodeAsync(string codeName, string codeGroup, string defaultPrefix, int defaultLength, Func<Task<int>> getExistingMaxFallback)
        {
            try
            {
                var codeDef = await _context.Codes.FirstOrDefaultAsync(c => c.CodeName == codeName && c.IsActive);
                var codeGen = await _context.CodeGenerates.FirstOrDefaultAsync(g => g.CodeName == codeName);

                string prefix = codeDef?.Prefix ?? codeGen?.Prefix ?? defaultPrefix;
                int length = codeDef?.Length ?? defaultLength;
                int lastId = codeGen?.LastId ?? 0;

                int fallbackMax = await getExistingMaxFallback();
                int currentMax = Math.Max(lastId, fallbackMax);
                int nextId = currentMax + 1;

                return $"{prefix}{nextId.ToString().PadLeft(length, '0')}";
            }
            catch
            {
                int fallbackMax = await getExistingMaxFallback();
                return $"{defaultPrefix}{(fallbackMax + 1).ToString().PadLeft(defaultLength, '0')}";
            }
        }

        public async Task UpdateLastInvoiceNumberAsync(string invoiceNo)
        {
            await CommitCodeAsync("Invoice", invoiceNo, @"\b(?:INV-)?(\d+)\b");
        }

        public async Task UpdateLastPurchaseNumberAsync(string purchaseNo)
        {
            await CommitCodeAsync("Purchase", purchaseNo, @"\b(?:PUR-)?(\d+)\b");
        }

        private async Task CommitCodeAsync(string codeName, string codeValue, string regexPattern)
        {
            if (string.IsNullOrWhiteSpace(codeValue)) return;
            try
            {
                var regex = new Regex(regexPattern, RegexOptions.IgnoreCase);
                var match = regex.Match(codeValue);
                if (match.Success && int.TryParse(match.Groups[1].Value, out int currentNum))
                {
                    var codeGen = await _context.CodeGenerates.FirstOrDefaultAsync(g => g.CodeName == codeName);
                    if (codeGen == null)
                    {
                        var codeDef = await _context.Codes.FirstOrDefaultAsync(c => c.CodeName == codeName);
                        codeGen = new CodeGenerate
                        {
                            CodeId = codeDef?.Id,
                            CodeName = codeName,
                            CurrentYear = DateTime.UtcNow.Year,
                            Prefix = codeDef?.Prefix,
                            LastId = currentNum,
                            LastCode = codeValue,
                            LastUpdated = DateTime.UtcNow
                        };
                        _context.CodeGenerates.Add(codeGen);
                    }
                    else
                    {
                        if (currentNum > codeGen.LastId)
                        {
                            codeGen.LastId = currentNum;
                            codeGen.LastCode = codeValue;
                            codeGen.LastUpdated = DateTime.UtcNow;
                        }
                    }
                    await _context.SaveChangesAsync();
                }
            }
            catch { }
        }

        private static int GetMaxNumberFromList(IEnumerable<string> items, string regexPattern)
        {
            int maxNum = 0;
            var regex = new Regex(regexPattern, RegexOptions.IgnoreCase);
            foreach (var item in items)
            {
                if (string.IsNullOrWhiteSpace(item)) continue;
                var match = regex.Match(item);
                if (match.Success && int.TryParse(match.Groups[1].Value, out int num))
                {
                    if (num > maxNum) maxNum = num;
                }
            }
            return maxNum;
        }
    }
}

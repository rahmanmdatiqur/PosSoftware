using Microsoft.EntityFrameworkCore;
using PosSoftware.Data;
using PosSoftware.Models.Entities;

namespace PosSoftware.Services
{
    public interface IInventoryService
    {
        Task<bool> HasSufficientStockAsync(int productId, int quantity);
        Task DeductStockForSaleAsync(int saleId, int cashierId);
        Task<StockAdjustment> CreateStockAdjustmentAsync(StockAdjustment adjustment, int userId);
        Task AddStockAsync(int productId, int quantity, string referenceNo, string notes, int userId);
        Task<List<Product>> GetLowStockProductsAsync();
    }

    public class InventoryService : IInventoryService
    {
        private readonly ApplicationDbContext _context;

        public InventoryService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> HasSufficientStockAsync(int productId, int quantity)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return false;
            return product.CurrentStock >= quantity;
        }

        public async Task DeductStockForSaleAsync(int saleId, int cashierId)
        {
            var sale = await _context.Sales
                .Include(s => s.SaleItems)
                .FirstOrDefaultAsync(s => s.Id == saleId);

            if (sale == null) return;

            foreach (var item in sale.SaleItems)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    int prevStock = product.CurrentStock;
                    product.CurrentStock -= item.Quantity;

                    var transaction = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Sale",
                        Quantity = item.Quantity,
                        PreviousStock = prevStock,
                        NewStock = product.CurrentStock,
                        ReferenceNo = sale.InvoiceNumber,
                        Notes = $"Sale item deducted via Invoice #{sale.InvoiceNumber}",
                        CreatedByUserId = cashierId,
                        CreatedAt = DateTime.UtcNow
                    };

                    _context.StockTransactions.Add(transaction);
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task<StockAdjustment> CreateStockAdjustmentAsync(StockAdjustment adjustment, int userId)
        {
            adjustment.AdjustmentDate = DateTime.UtcNow;
            adjustment.CreatedByUserId = userId;

            _context.StockAdjustments.Add(adjustment);

            foreach (var item in adjustment.Items)
            {
                var product = await _context.Products.FindAsync(item.ProductId);
                if (product != null)
                {
                    item.OldStock = product.CurrentStock;
                    item.DifferenceQty = item.AdjustedStock - product.CurrentStock;

                    int prev = product.CurrentStock;
                    product.CurrentStock = item.AdjustedStock;

                    var tx = new StockTransaction
                    {
                        ProductId = product.Id,
                        TransactionType = "Adjustment",
                        Quantity = Math.Abs(item.DifferenceQty),
                        PreviousStock = prev,
                        NewStock = product.CurrentStock,
                        ReferenceNo = adjustment.AdjustmentNo,
                        Notes = $"Manual adjustment: {item.Reason}",
                        CreatedByUserId = userId,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.StockTransactions.Add(tx);
                }
            }

            await _context.SaveChangesAsync();
            return adjustment;
        }

        public async Task AddStockAsync(int productId, int quantity, string referenceNo, string notes, int userId)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return;

            int prev = product.CurrentStock;
            product.CurrentStock += quantity;

            var tx = new StockTransaction
            {
                ProductId = product.Id,
                TransactionType = "StockIn",
                Quantity = quantity,
                PreviousStock = prev,
                NewStock = product.CurrentStock,
                ReferenceNo = referenceNo,
                Notes = notes,
                CreatedByUserId = userId,
                CreatedAt = DateTime.UtcNow
            };

            _context.StockTransactions.Add(tx);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Product>> GetLowStockProductsAsync()
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Unit)
                .Where(p => p.IsActive && p.CurrentStock <= p.MinAlertStock)
                .OrderBy(p => p.CurrentStock)
                .ToListAsync();
        }
    }
}

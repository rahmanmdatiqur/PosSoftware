-- ============================================================
--  POS SOFTWARE — Seed Products & Categories
--  Target: DEV-1017  →  PosInventoryDb
--  Generated: 2026-11-23
-- ============================================================

USE PosInventoryDb;
GO

-- ============================================================
-- STEP 1: Clear dependent tables in FK order
-- ============================================================
DELETE FROM SaleItems;
DELETE FROM PurchaseItems;
DELETE FROM StockAdjustmentItems;
DELETE FROM StockTransactions;
DELETE FROM Products;
DELETE FROM StockAdjustments;
DELETE FROM Categories;
GO

DBCC CHECKIDENT ('SaleItems',           RESEED, 0);
DBCC CHECKIDENT ('PurchaseItems',       RESEED, 0);
DBCC CHECKIDENT ('StockAdjustmentItems',RESEED, 0);
DBCC CHECKIDENT ('StockTransactions',   RESEED, 0);
DBCC CHECKIDENT ('Products',            RESEED, 0);
DBCC CHECKIDENT ('Categories',          RESEED, 0);
GO

-- ============================================================
-- STEP 2: Insert Categories (brands)
-- ============================================================
INSERT INTO Categories (Name, Description, IsActive) VALUES
('Apple Bear',  'Apple Bear brand baby products',          1),
('Minitree',    'Minitree brand baby products',            1),
('Baby Smile',  'Baby Smile brand baby products',          1),
('Rovco',       'Rovco brand baby products',               1),
('Chioco',      'Chioco brand baby products',              1),
('Faarlin',     'Faarlin brand baby products',             1),
('Momeasy',     'Momeasy brand baby products',             1),
('Aveat',       'Aveat brand baby products',               1),
('Linco',       'Linco brand baby products',               1),
('Music',       'Music brand baby products',               1),
('Angel',       'Angel brand baby products',               1),
('Others',      'Other miscellaneous baby products',       1);
GO

-- ============================================================
-- STEP 3: Insert Products
--   SKU = Barcode = Code (or GEN-xxx if no code given)
--   UnitId → PCS (ShortCode='PCS')
--   CostPrice/SellingPrice = 0  (to be filled by user)
-- ============================================================

DECLARE @PCS INT = (SELECT Id FROM Units WHERE ShortCode = 'PCS');

DECLARE @AppleBear INT  = (SELECT Id FROM Categories WHERE Name = 'Apple Bear');
DECLARE @Minitree  INT  = (SELECT Id FROM Categories WHERE Name = 'Minitree');
DECLARE @BabySmile INT  = (SELECT Id FROM Categories WHERE Name = 'Baby Smile');
DECLARE @Rovco     INT  = (SELECT Id FROM Categories WHERE Name = 'Rovco');
DECLARE @Chioco    INT  = (SELECT Id FROM Categories WHERE Name = 'Chioco');
DECLARE @Faarlin   INT  = (SELECT Id FROM Categories WHERE Name = 'Faarlin');
DECLARE @Momeasy   INT  = (SELECT Id FROM Categories WHERE Name = 'Momeasy');
DECLARE @Aveat     INT  = (SELECT Id FROM Categories WHERE Name = 'Aveat');
DECLARE @Linco     INT  = (SELECT Id FROM Categories WHERE Name = 'Linco');
DECLARE @Music     INT  = (SELECT Id FROM Categories WHERE Name = 'Music');
DECLARE @Angel     INT  = (SELECT Id FROM Categories WHERE Name = 'Angel');
DECLARE @Others    INT  = (SELECT Id FROM Categories WHERE Name = 'Others');

INSERT INTO Products
    (SKU, Barcode, Name, CategoryId, UnitId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, IsActive)
VALUES

-- ── Apple Bear ──────────────────────────────────────────────
('AB-608',    'AB-608',    'Fruit Feeder 3 pcs',          @AppleBear, @PCS, 0, 0, 0, 5, 1),
('GEN-001',   'GEN-001',   'Fruit Feeder 6 pcs',          @AppleBear, @PCS, 0, 0, 0, 5, 1),
('AB-6038',   'AB-6038',   'Baby Care Kit',               @AppleBear, @PCS, 0, 0, 0, 5, 1),
('AB-28',     'AB-28',     'Liquid Silicon Pacifier',     @AppleBear, @PCS, 0, 0, 0, 5, 1),
('AB-605',    'AB-605',    'Silicon Tooth Brush',         @AppleBear, @PCS, 0, 0, 0, 5, 1),
('AB-230',    'AB-230',    'Silicon Tree Teether',        @AppleBear, @PCS, 0, 0, 0, 5, 1),
('AB-666',    'AB-666',    'Silicon Feeder',              @AppleBear, @PCS, 0, 0, 0, 5, 1),

-- ── Minitree ────────────────────────────────────────────────
('ZR-684-3',  'ZR-684-3',  'Glass Feeder 120ml',          @Minitree,  @PCS, 0, 0, 0, 5, 1),
('ZR-683-3',  'ZR-683-3',  'Glass Feeder 240ml',          @Minitree,  @PCS, 0, 0, 0, 5, 1),
('ZR-040FY',  'ZR-040FY',  'Glass Feeder',                @Minitree,  @PCS, 0, 0, 0, 5, 1),

-- ── Baby Smile ──────────────────────────────────────────────
-- BS-249/245 → normalised to BS-243245 | duplicate codes get -A/-B suffix
('BS-243245', 'BS-243245', 'Teether',                     @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-233',    'BS-233',    'Medicine Dropper',             @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-249-A',  'BS-249-A',  'Washable Breast Pads 4 pcs',  @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-240-A',  'BS-240-A',  'Tooth Brush',                 @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-268',    'BS-268',    'Feeding Bottle 240ml',        @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-249-B',  'BS-249-B',  'Wide Nipple',                 @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-240-B',  'BS-240-B',  'Manual Breast Pump',          @BabySmile, @PCS, 0, 0, 0, 5, 1),
('BS-264',    'BS-264',    'Breast Milk Collection Shells',@BabySmile, @PCS, 0, 0, 0, 5, 1),

-- ── Rovco ───────────────────────────────────────────────────
('RK-3057',   'RK-3057',   'Glass Feeder 80ml',           @Rovco,     @PCS, 0, 0, 0, 5, 1),
('RK-N1019',  'RK-N1019',  'Glass Feeder 150ml',          @Rovco,     @PCS, 0, 0, 0, 5, 1),
('RK-M1005',  'RK-M1005',  'Electric Breast Pump',        @Rovco,     @PCS, 0, 0, 0, 5, 1),

-- ── Chioco ──────────────────────────────────────────────────
('C29',       'C29',       'Electric Breast Pump',        @Chioco,    @PCS, 0, 0, 0, 5, 1),
('GEN-002',   'GEN-002',   'Baby Carrier',                @Chioco,    @PCS, 0, 0, 0, 5, 1),

-- ── Faarlin ─────────────────────────────────────────────────
('GEN-003',   'GEN-003',   'Nipple Size: L',              @Faarlin,   @PCS, 0, 0, 0, 5, 1),
('AB-41020',  'AB-41020',  'Feeding Bottle',              @Faarlin,   @PCS, 0, 0, 0, 5, 1),
('BF-638P',   'BF-638P',   'Manual Breast Pump',          @Faarlin,   @PCS, 0, 0, 0, 5, 1),
('BF-640',    'BF-640',    'Manual Breast Pump',          @Faarlin,   @PCS, 0, 0, 0, 5, 1),

-- ── Momeasy ─────────────────────────────────────────────────
('45812',     '45812',     'Breast Milk Collection Shells 2pcs', @Momeasy, @PCS, 0, 0, 0, 5, 1),
('45804',     '45804',     'Washable Nursing Pads 6pcs',  @Momeasy,   @PCS, 0, 0, 0, 5, 1),
('45800',     '45800',     'Breast Milk Storage Bag',     @Momeasy,   @PCS, 0, 0, 0, 5, 1),

-- ── Aveat ───────────────────────────────────────────────────
('AV-05',     'AV-05',     'Feeder 260ml',                @Aveat,     @PCS, 0, 0, 0, 5, 1),
('AV-06',     'AV-06',     'Feeder 330ml',                @Aveat,     @PCS, 0, 0, 0, 5, 1),

-- ── Linco ───────────────────────────────────────────────────
('L-22522',   'L-22522',   'Baby Soap Case',              @Linco,     @PCS, 0, 0, 0, 5, 1),
('GEN-004',   'GEN-004',   'Powder Puff',                 @Linco,     @PCS, 0, 0, 0, 5, 1),

-- ── Music ───────────────────────────────────────────────────
('GEN-005',   'GEN-005',   'Feeding Bottle 60ml',         @Music,     @PCS, 0, 0, 0, 5, 1),
('GEN-006',   'GEN-006',   'Feeding Bottle 120ml',        @Music,     @PCS, 0, 0, 0, 5, 1),
('GEN-007',   'GEN-007',   'Feeding Bottle 240ml',        @Music,     @PCS, 0, 0, 0, 5, 1),
('24640',     '24640',     'Training Cup Set',            @Music,     @PCS, 0, 0, 0, 5, 1),

-- ── Angel ───────────────────────────────────────────────────
('GEN-008',   'GEN-008',   'Feeder 60ml',                 @Angel,     @PCS, 0, 0, 0, 5, 1),
('GEN-009',   'GEN-009',   'Feeder 130ml',                @Angel,     @PCS, 0, 0, 0, 5, 1),
('GEN-010',   'GEN-010',   'Feeder 240ml',                @Angel,     @PCS, 0, 0, 0, 5, 1),

-- ── Others ──────────────────────────────────────────────────
('D30',       'D30',       'Baby Concert Toy',                     @Others, @PCS, 0, 0, 0, 5, 1),
('7701',      '7701',      'Steel Bowl',                           @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-011',   'GEN-011',   'Knee Pad',                            @Others, @PCS, 0, 0, 0, 5, 1),
('JM-A001-A', 'JM-A001-A', 'Bath Sponge',                         @Others, @PCS, 0, 0, 0, 5, 1),
('JM-A001-B', 'JM-A001-B', 'Bath Sponge Big',                     @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-012',   'GEN-012',   'Bath Stone Big',                      @Others, @PCS, 0, 0, 0, 5, 1),
('A6625-6',   'A6625-6',   'Nail Clipper',                        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-013',   'GEN-013',   'Key Holder',                          @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-014',   'GEN-014',   'Nail Clipper 1Dozen Big/Small',       @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-015',   'GEN-015',   'Two in One Drinking Bottle',          @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-016',   'GEN-016',   'Steel Silicon Spoon Shoe',            @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-017',   'GEN-017',   'Belt Shoe',                           @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-018',   'GEN-018',   'Premium Shoe',                        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-019',   'GEN-019',   'Thai Tooth Brush',                    @Others, @PCS, 0, 0, 0, 5, 1),
('7777',      '7777',      'Camera Pacifier',                     @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-020',   'GEN-020',   'Neha Soap Case',                      @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-021',   'GEN-021',   'Prime Baby Care Wipes',               @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-022',   'GEN-022',   'Dream Baby Wipes',                    @Others, @PCS, 0, 0, 0, 5, 1),
('ZZX-8015',  'ZZX-8015',  'Chain Nipple',                        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-023',   'GEN-023',   'Neha Powder Puff',                    @Others, @PCS, 0, 0, 0, 5, 1),
('ZZX-8291',  'ZZX-8291',  'Catheter Nasal Suction Device',       @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-024',   'GEN-024',   'Haney Tooth Brush',                   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-025',   'GEN-025',   'Dmete Tooth Brush',                   @Others, @PCS, 0, 0, 0, 5, 1),
('K001',      'K001',      'Cabey Tooth Brush',                   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-026',   'GEN-026',   'Bamboo Toothpick',                    @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-027',   'GEN-027',   'Baby Cotton Buds',                    @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-028',   'GEN-028',   'Baby Shampoo Cap',                    @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-029',   'GEN-029',   'Baby Blanket',                        @Others, @PCS, 0, 0, 0, 5, 1),
('A-240',     'A-240',     'Only Baby Manual Breast Pump',        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-030',   'GEN-030',   'Cap Towel',                           @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-031',   'GEN-031',   'Towel Big/Small',                     @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-032',   'GEN-032',   'Normal Baby Sheet Size: L/M',         @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-033',   'GEN-033',   'Nima for Baby',                       @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-034',   'GEN-034',   'Aiwibi Baby Liquid Cleanser 700ml',   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-035',   'GEN-035',   'Tinimini Liquid Cleanser 300ml',      @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-036',   'GEN-036',   'Tinimini Liquid Cleanser 500ml',      @Others, @PCS, 0, 0, 0, 5, 1),
('SB359',     'SB359',     'Drinking Bottle',                     @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-037',   'GEN-037',   'Drinking Bottle',                     @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-038',   'GEN-038',   'Capsule Finger Brush',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-039',   'GEN-039',   'Head Protector',                      @Others, @PCS, 0, 0, 0, 5, 1),
('N-24',      'N-24',      'Angel Silicon Nipple',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-040',   'GEN-040',   'Baby Cap Set',                        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-041',   'GEN-041',   'Childhood Baby Mosquito Net',         @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-042',   'GEN-042',   'Muaz Mosquito Net',                   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-043',   'GEN-043',   'Shoma Mosquito Net',                  @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-044',   'GEN-044',   'Super Jack Neck Feeder 330ml',        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-045',   'GEN-045',   'Silicon Spoon Feeder 90ml 3pcs',      @Others, @PCS, 0, 0, 0, 5, 1),
('MZ-602',    'MZ-602',    'Electric Breast Pump',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-046',   'GEN-046',   'Max Body Spray',                      @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-047',   'GEN-047',   'Wood Cotton Buds 200 pcs',            @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-048',   'GEN-048',   'Wood Cotton Buds 300 pcs',            @Others, @PCS, 0, 0, 0, 5, 1),
('8033',      '8033',      'Dmete Tooth Brush No. 8033',          @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-049',   'GEN-049',   'SSS Nail Clippers',                   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-050',   'GEN-050',   'Waterproof Urine Mat',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-051',   'GEN-051',   'Waterproof Urine Mat M/L',            @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-052',   'GEN-052',   'Will Baby Carrier',                   @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-053',   'GEN-053',   'Labubu Water Bottle',                 @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-054',   'GEN-054',   'Baby Winter Cotton Bed',              @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-055',   'GEN-055',   'Baby Winter Velvet Bed',              @Others, @PCS, 0, 0, 0, 5, 1),
('AB-29',     'AB-29',     'Baby Shampoo Brush',                  @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-056',   'GEN-056',   'Tooth Brush 4pcs/set',               @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-057',   'GEN-057',   'Lucky Angel Hand Towel',              @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-058',   'GEN-058',   'Foot Cleaner 4 in 1',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-059',   'GEN-059',   'Baby Toilet Seat',                    @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-060',   'GEN-060',   'Zakaria Feeder Brush',                @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-061',   'GEN-061',   'Super Jack Neck Feeder 260ml',        @Others, @PCS, 0, 0, 0, 5, 1),
('GEN-062',   'GEN-062',   'Smile Bear Nipple',                   @Others, @PCS, 0, 0, 0, 5, 1);
GO

-- ============================================================
-- STEP 4: Verify
-- ============================================================
SELECT
    c.Name          AS Category,
    COUNT(p.Id)     AS ProductCount
FROM Categories c
LEFT JOIN Products p ON p.CategoryId = c.Id
GROUP BY c.Name
ORDER BY c.Name;

SELECT COUNT(*) AS TotalProducts FROM Products;
GO

PRINT 'Products and Categories seeded successfully.';
GO

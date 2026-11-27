-- ============================================================
-- Insert User Categories & 132 Products with Stock = 100
-- ============================================================
USE PosInventoryDb;
GO
SET NOCOUNT ON;

DECLARE @UnitId INT = (SELECT TOP 1 Id FROM Units WHERE ShortCode = 'PCS');
IF @UnitId IS NULL SET @UnitId = (SELECT TOP 1 Id FROM Units);

-- Category: Avent
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Avent')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Avent', N'Avent brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AV-05')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AV-05', N'AV-05', N'Feeder 260ml', N'Code: AV-05', N'Avent - Feeder 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AV-06')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AV-06', N'AV-06', N'Feeder 260ml', N'Code: AV-06', N'Avent - Feeder 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY900/01')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY900/01', N'SCY900/01', N'Avent 125ml', N'Code: SCY900/01', N'Avent - Avent 125ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY903/01')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY903/01', N'SCY903/01', N'Avent 260ml', N'Code: SCY903/01', N'Avent - Avent 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY903/11')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY903/11', N'SCY903/11', N'Avent 260ml', N'Code: SCY903/11', N'Avent - Avent 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 5, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY903/21')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY903/21', N'SCY903/21', N'Avent 260ml', N'Code: SCY903/21', N'Avent - Avent 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 6, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY906/01')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY906/01', N'SCY906/01', N'Avent 330ml', N'Code: SCY906/01', N'Avent - Avent 330ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 7, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY900/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY900/02', N'SCY900/02', N'Avent 125ml 2x', N'Code: SCY900/02', N'Avent - Avent 125ml 2x', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 8, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY903/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY903/02', N'SCY903/02', N'Avent 260ml 2x', N'Code: SCY903/02', N'Avent - Avent 260ml 2x', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 9, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY906/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY906/02', N'SCY906/02', N'Avent 3300ml 2x', N'Code: SCY906/02', N'Avent - Avent 3300ml 2x', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 10, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY961/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY961/02', N'SCY961/02', N'Avent Nipple Natural', N'Code: SCY961/02', N'Avent - Avent Nipple Natural', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 11, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY962/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY962/02', N'SCY962/02', N'Avent Nipple Natural', N'Code: SCY962/02', N'Avent - Avent Nipple Natural', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 12, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY963/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY963/02', N'SCY963/02', N'Avent Nipple Natural', N'Code: SCY963/02', N'Avent - Avent Nipple Natural', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 13, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY964/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY964/02', N'SCY964/02', N'Avent Nipple Natural', N'Code: SCY964/02', N'Avent - Avent Nipple Natural', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 14, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY965/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY965/02', N'SCY965/02', N'Avent Nipple Natural', N'Code: SCY965/02', N'Avent - Avent Nipple Natural', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 15, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY762/02')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY762/02', N'SCY762/02', N'Avent Nipple Anti-colic', N'Code: SCY762/02', N'Avent - Avent Nipple Anti-colic', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 16, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY961/02-2')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY961/02-2', N'SCY961/02-2', N'Avent Nipple Anti-colic', N'Code: SCY961/02', N'Avent - Avent Nipple Anti-colic', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 17, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY961/02-3')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY961/02-3', N'SCY961/02-3', N'Avent Nipple Anti-colic', N'Code: SCY961/02', N'Avent - Avent Nipple Anti-colic', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 18, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY961/02-4')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY961/02-4', N'SCY961/02-4', N'Avent Nipple Anti-colic', N'Code: SCY961/02', N'Avent - Avent Nipple Anti-colic', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 19, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCY961/02-5')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCY961/02-5', N'SCY961/02-5', N'Avent Nipple Anti-colic', N'Code: SCY961/02', N'Avent - Avent Nipple Anti-colic', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 20, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCF085/59')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCF085/59', N'SCF085/59', N'Avent Soother 0-6', N'Code: SCF085/59', N'Avent - Avent Soother 0-6', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 21, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCF085/61')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCF085/61', N'SCF085/61', N'Avent Soother 6-18', N'Code: SCF085/61', N'Avent - Avent Soother 6-18', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 22, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCD417/20')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCD417/20', N'SCD417/20', N'Avent Manual Breast Pump', N'Code: SCD417/20', N'Avent - Avent Manual Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 23, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AVT-024')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AVT-024', N'AVT-024', N'Avent Electric Breast Pump', N'Avent', N'Avent - Avent Electric Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 24, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCF051/17')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCF051/17', N'SCF051/17', N'Avent Glass Bottle 120ml', N'Code: SCF051/17', N'Avent - Avent Glass Bottle 120ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 25, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SCF053/17')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SCF053/17', N'SCF053/17', N'Avent Glass Bottle 240ml', N'Code: SCF053/17', N'Avent - Avent Glass Bottle 240ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 26, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AVT-027')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AVT-027', N'AVT-027', N'Duck beak 280ml', N'Avent', N'Avent - Duck beak 280ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Avent'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 27, GETUTCDATE());
END
-- Category: Angel
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Angel')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Angel', N'Angel brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-001')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-001', N'ANG-001', N'Feeder 60ml', N'Angel', N'Angel - Feeder 60ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-002')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-002', N'ANG-002', N'Feeder 130ml', N'Angel', N'Angel - Feeder 130ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-003')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-003', N'ANG-003', N'Feeder 240ml', N'Angel', N'Angel - Feeder 240ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'7701')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'7701', N'7701', N'Steel Bowl', N'Code: 7701', N'Angel - Steel Bowl', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-005')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-005', N'ANG-005', N'Knee Pad', N'Angel', N'Angel - Knee Pad', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 5, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'JM-A001')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'JM-A001', N'JM-A001', N'Bath Sponge', N'Code: JM-A001', N'Angel - Bath Sponge', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 6, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'JM-A001-2')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'JM-A001-2', N'JM-A001-2', N'Bath Sponge Big', N'Code: JM-A001', N'Angel - Bath Sponge Big', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 7, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-008')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-008', N'ANG-008', N'Bath Stone Big', N'Angel', N'Angel - Bath Stone Big', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 8, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'A6625-6')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'A6625-6', N'A6625-6', N'Nail Clipper', N'Code: A6625-6', N'Angel - Nail Clipper', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 9, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-010')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-010', N'ANG-010', N'Key Holder', N'Angel', N'Angel - Key Holder', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 10, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-011')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-011', N'ANG-011', N'Nail Clipper 1Dozen Big/Small', N'Angel', N'Angel - Nail Clipper 1Dozen Big/Small', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 11, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-012')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-012', N'ANG-012', N'Two in One Drinking Bottle', N'Angel', N'Angel - Two in One Drinking Bottle', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 12, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-013')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-013', N'ANG-013', N'Steel Silicon Spoon Shoe', N'Angel', N'Angel - Steel Silicon Spoon Shoe', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 13, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-014')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-014', N'ANG-014', N'Belt Shoe', N'Angel', N'Angel - Belt Shoe', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 14, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-015')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-015', N'ANG-015', N'Premium Shoe', N'Angel', N'Angel - Premium Shoe', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 15, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-016')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-016', N'ANG-016', N'Thai Tooth Brush', N'Angel', N'Angel - Thai Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 16, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'7777')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'7777', N'7777', N'Camere Pacifier', N'Code: 7777', N'Angel - Camere Pacifier', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 17, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-018')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-018', N'ANG-018', N'Neha Soap Case', N'Angel', N'Angel - Neha Soap Case', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 18, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-019')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-019', N'ANG-019', N'Prime Baby Care Wipes', N'Angel', N'Angel - Prime Baby Care Wipes', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 19, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-020')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-020', N'ANG-020', N'Dream Baby Wipes', N'Angel', N'Angel - Dream Baby Wipes', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 20, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ZZX-8015')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ZZX-8015', N'ZZX-8015', N'Chain Nipple', N'Code: ZZX-8015', N'Angel - Chain Nipple', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 21, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-022')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-022', N'ANG-022', N'Neha Powder Puff', N'Angel', N'Angel - Neha Powder Puff', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 22, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ZZX-8291')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ZZX-8291', N'ZZX-8291', N'Catheter Nasal Suction Device', N'Code: ZZX-8291', N'Angel - Catheter Nasal Suction Device', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 23, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-024')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-024', N'ANG-024', N'Haney Tooth Brush', N'Angel', N'Angel - Haney Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 24, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-025')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-025', N'ANG-025', N'Dmete Tooth Brush', N'Angel', N'Angel - Dmete Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 25, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'K001')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'K001', N'K001', N'Cabey Tooth Brush', N'Code: K001', N'Angel - Cabey Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 26, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-027')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-027', N'ANG-027', N'Bamboo Toothpick', N'Angel', N'Angel - Bamboo Toothpick', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 27, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-028')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-028', N'ANG-028', N'Baby Cotton Buds', N'Angel', N'Angel - Baby Cotton Buds', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 28, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-029')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-029', N'ANG-029', N'Baby Shampoo Cap', N'Angel', N'Angel - Baby Shampoo Cap', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 29, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-030')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-030', N'ANG-030', N'Baby Blanket', N'Angel', N'Angel - Baby Blanket', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 30, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'A-240')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'A-240', N'A-240', N'Only Baby Manual Breast Pump', N'Code: A-240', N'Angel - Only Baby Manual Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 31, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-032')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-032', N'ANG-032', N'Cap Towel', N'Angel', N'Angel - Cap Towel', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 32, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-033')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-033', N'ANG-033', N'Towel Big/Small', N'Angel', N'Angel - Towel Big/Small', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 33, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-034')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-034', N'ANG-034', N'Normal Baby Sheet Size:L/M', N'Angel', N'Angel - Normal Baby Sheet Size:L/M', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 34, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-035')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-035', N'ANG-035', N'Nima for Baby', N'Angel', N'Angel - Nima for Baby', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 35, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-036')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-036', N'ANG-036', N'Aiwibi Baby Liquid Cleanser 700ml', N'Angel', N'Angel - Aiwibi Baby Liquid Cleanser 700ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 36, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-037')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-037', N'ANG-037', N'Tinimini Liquid Cleanser 300ml', N'Angel', N'Angel - Tinimini Liquid Cleanser 300ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 37, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-038')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-038', N'ANG-038', N'Tinimini Liquid Cleanser 500ml', N'Angel', N'Angel - Tinimini Liquid Cleanser 500ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 38, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'SB359')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'SB359', N'SB359', N'Drinking Bottle', N'Code: SB359', N'Angel - Drinking Bottle', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 39, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-040')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-040', N'ANG-040', N'Drinking Bottle', N'Angel', N'Angel - Drinking Bottle', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 40, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-041')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-041', N'ANG-041', N'Capsule Finger Brush', N'Angel', N'Angel - Capsule Finger Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 41, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-042')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-042', N'ANG-042', N'Head Protector', N'Angel', N'Angel - Head Protector', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 42, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'N-24')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'N-24', N'N-24', N'Angel Silicon Nipple', N'Code: N-24', N'Angel - Angel Silicon Nipple', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 43, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-044')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-044', N'ANG-044', N'Baby Cap Set', N'Angel', N'Angel - Baby Cap Set', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 44, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-045')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-045', N'ANG-045', N'Childhood Baby Mosquito Net', N'Angel', N'Angel - Childhood Baby Mosquito Net', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 45, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-046')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-046', N'ANG-046', N'Muaz Mosquito Net', N'Angel', N'Angel - Muaz Mosquito Net', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 46, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-047')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-047', N'ANG-047', N'Shoma Mosquito Net', N'Angel', N'Angel - Shoma Mosquito Net', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 47, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-048')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-048', N'ANG-048', N'Super Jack Neck Feeder 330ml', N'Angel', N'Angel - Super Jack Neck Feeder 330ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 48, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-049')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-049', N'ANG-049', N'Silicon Spoon Feeder 90ml 3pcs', N'Angel', N'Angel - Silicon Spoon Feeder 90ml 3pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 49, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'MZ-602')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'MZ-602', N'MZ-602', N'Electric Breast Pump', N'Code: MZ-602', N'Angel - Electric Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 50, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-051')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-051', N'ANG-051', N'Max Body Spray', N'Angel', N'Angel - Max Body Spray', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 51, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-052')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-052', N'ANG-052', N'Wood Cotton Buds 200 pcs', N'Angel', N'Angel - Wood Cotton Buds 200 pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 52, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-053')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-053', N'ANG-053', N'Wood Cotton Buds 300 pcs', N'Angel', N'Angel - Wood Cotton Buds 300 pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 53, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'8033')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'8033', N'8033', N'Dmete Tooth Brush No. 8033', N'Code: 8033', N'Angel - Dmete Tooth Brush No. 8033', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 54, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-055')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-055', N'ANG-055', N'SSS Nail Clippers', N'Angel', N'Angel - SSS Nail Clippers', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 55, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-056')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-056', N'ANG-056', N'Waterproof Urine Mat', N'Angel', N'Angel - Waterproof Urine Mat', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 56, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-057')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-057', N'ANG-057', N'Waterproof Urine Mat M/L', N'Angel', N'Angel - Waterproof Urine Mat M/L', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 57, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-058')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-058', N'ANG-058', N'Will Baby Carrier', N'Angel', N'Angel - Will Baby Carrier', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 58, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-059')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-059', N'ANG-059', N'Labubu Water Bottle', N'Angel', N'Angel - Labubu Water Bottle', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 59, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-060')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-060', N'ANG-060', N'Baby Winter Cotton Bed', N'Angel', N'Angel - Baby Winter Cotton Bed', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 60, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-061')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-061', N'ANG-061', N'Baby Winter Velvet Bed', N'Angel', N'Angel - Baby Winter Velvet Bed', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 61, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-29')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-29', N'AB-29', N'Baby Shampoo Brush No. AB-29', N'Code: AB-29', N'Angel - Baby Shampoo Brush No. AB-29', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 62, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-063')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-063', N'ANG-063', N'Tooth Brush 4pcs/set', N'Angel', N'Angel - Tooth Brush 4pcs/set', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 63, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-064')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-064', N'ANG-064', N'Lucky Angel Hand Towel', N'Angel', N'Angel - Lucky Angel Hand Towel', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 64, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-065')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-065', N'ANG-065', N'Foot Cleaner 4 in 1', N'Angel', N'Angel - Foot Cleaner 4 in 1', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 65, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-066')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-066', N'ANG-066', N'Baby Toilet Seat', N'Angel', N'Angel - Baby Toilet Seat', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 66, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-067')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-067', N'ANG-067', N'Zakaria Feeder Brush', N'Angel', N'Angel - Zakaria Feeder Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 67, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-068')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-068', N'ANG-068', N'Super Jack Neck Feeder 260ml', N'Angel', N'Angel - Super Jack Neck Feeder 260ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 68, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ANG-069')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ANG-069', N'ANG-069', N'Smile Bear Nipple', N'Angel', N'Angel - Smile Bear Nipple', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Angel'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 69, GETUTCDATE());
END
-- Category: Apple Bear
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Apple Bear')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Apple Bear', N'Apple Bear brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-608')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-608', N'AB-608', N'Fruit Feeder 3 pcs', N'Code: AB-608', N'Apple Bear - Fruit Feeder 3 pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'APB-002')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'APB-002', N'APB-002', N'Fruit Feeder 6 pcs', N'Apple Bear', N'Apple Bear - Fruit Feeder 6 pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-6038')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-6038', N'AB-6038', N'Baby Care Kit', N'Code: AB-6038', N'Apple Bear - Baby Care Kit', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-28')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-28', N'AB-28', N'Liquid Silicon Pacifier', N'Code: AB-28', N'Apple Bear - Liquid Silicon Pacifier', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-605')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-605', N'AB-605', N'Silicon Tooth Brush', N'Code: AB-605', N'Apple Bear - Silicon Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 5, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-230')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-230', N'AB-230', N'Silicon Tree Teether', N'Code: AB-230', N'Apple Bear - Silicon Tree Teether', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 6, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-666')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-666', N'AB-666', N'Silicon Feeder', N'Code: AB-666', N'Apple Bear - Silicon Feeder', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Apple Bear'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 7, GETUTCDATE());
END
-- Category: Minitree
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Minitree')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Minitree', N'Minitree brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ZR-684-3')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ZR-684-3', N'ZR-684-3', N'Glass Feeder 120ml', N'Code: ZR-684-3', N'Minitree - Glass Feeder 120ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Minitree'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ZR-683-3')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ZR-683-3', N'ZR-683-3', N'Glass Feeder 240ml', N'Code: ZR-683-3', N'Minitree - Glass Feeder 240ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Minitree'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'ZR-040FY')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'ZR-040FY', N'ZR-040FY', N'Glass Feeder', N'Code: ZR-040FY', N'Minitree - Glass Feeder', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Minitree'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
-- Category: Baby Smile
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Baby Smile')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Baby Smile', N'Baby Smile brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-243/245')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-243/245', N'BS-243/245', N'Teether', N'Code: BS-243/245', N'Baby Smile - Teether', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-233')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-233', N'BS-233', N'Medicine Dropper', N'Code: BS-233', N'Baby Smile - Medicine Dropper', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-249')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-249', N'BS-249', N'Washable Breast Pads 4 pcs', N'Code: BS-249', N'Baby Smile - Washable Breast Pads 4 pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-240')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-240', N'BS-240', N'Tooth Brush', N'Code: BS-240', N'Baby Smile - Tooth Brush', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-268')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-268', N'BS-268', N'Feeding Bottle 240ml', N'Code: BS-268', N'Baby Smile - Feeding Bottle 240ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 5, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-249-2')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-249-2', N'BS-249-2', N'Wide Nipple', N'Code: BS-249', N'Baby Smile - Wide Nipple', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 6, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-240-2')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-240-2', N'BS-240-2', N'Manual Breast Pump', N'Code: BS-240', N'Baby Smile - Manual Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 7, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BS-264')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BS-264', N'BS-264', N'Breast Milk Collection Shells', N'Code: BS-264', N'Baby Smile - Breast Milk Collection Shells', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Baby Smile'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 8, GETUTCDATE());
END
-- Category: Ravco
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Ravco')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Ravco', N'Ravco brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'RK-3057')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'RK-3057', N'RK-3057', N'Glass Feeder 80ml', N'Code: RK-3057', N'Ravco - Glass Feeder 80ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Ravco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'RK-N1019')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'RK-N1019', N'RK-N1019', N'Glass Feeder 150ml', N'Code: RK-N1019', N'Ravco - Glass Feeder 150ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Ravco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'RK-M1005')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'RK-M1005', N'RK-M1005', N'Electric Breast Pump', N'Code: RK-M1005', N'Ravco - Electric Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Ravco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
-- Category: Chioco
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Chioco')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Chioco', N'Chioco brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'C29')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'C29', N'C29', N'Electric Breast Pump', N'Code: C29', N'Chioco - Electric Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Chioco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'CHC-002')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'CHC-002', N'CHC-002', N'Baby Carrier', N'Chioco', N'Chioco - Baby Carrier', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Chioco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
-- Category: Farlin
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Farlin')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Farlin', N'Farlin brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'FRL-001')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'FRL-001', N'FRL-001', N'Nipple Size: L', N'Farlin', N'Farlin - Nipple Size: L', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Farlin'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'AB-41020')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'AB-41020', N'AB-41020', N'Feeding Bottle', N'Code: AB-41020', N'Farlin - Feeding Bottle', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Farlin'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BF-638P')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BF-638P', N'BF-638P', N'Manual Breast Pump', N'Code: BF-638P', N'Farlin - Manual Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Farlin'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'BF-640')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'BF-640', N'BF-640', N'Manual Breast Pump', N'Code: BF-640', N'Farlin - Manual Breast Pump', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Farlin'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END
-- Category: Momeasy
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Momeasy')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Momeasy', N'Momeasy brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'45812')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'45812', N'45812', N'Breast Milk Collection Shells 2pcs', N'Code: 45812', N'Momeasy - Breast Milk Collection Shells 2pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Momeasy'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'45804')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'45804', N'45804', N'Washable Nursing Pads 6pcs', N'Code: 45804', N'Momeasy - Washable Nursing Pads 6pcs', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Momeasy'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'45800')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'45800', N'45800', N'Breast Milk Storage Bag', N'Code: 45800', N'Momeasy - Breast Milk Storage Bag', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Momeasy'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
-- Category: Linco
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Linco')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Linco', N'Linco brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'L-22522')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'L-22522', N'L-22522', N'Baby Soap Case', N'Code: L-22522', N'Linco - Baby Soap Case', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Linco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'LNC-002')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'LNC-002', N'LNC-002', N'Powder Puff', N'Linco', N'Linco - Powder Puff', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Linco'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
-- Category: Music
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Music')
    INSERT INTO Categories (Name, Description, IsActive) VALUES (N'Music', N'Music brand baby products', 1);

IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'MSC-001')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'MSC-001', N'MSC-001', N'Feeding Bottle 60ml', N'Music', N'Music - Feeding Bottle 60ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Music'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 1, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'MSC-002')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'MSC-002', N'MSC-002', N'Feeding Bottle 120ml', N'Music', N'Music - Feeding Bottle 120ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Music'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 2, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'MSC-003')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'MSC-003', N'MSC-003', N'Feeding Bottle 240ml', N'Music', N'Music - Feeding Bottle 240ml', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Music'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 3, GETUTCDATE());
END
IF NOT EXISTS (SELECT 1 FROM Products WHERE SKU = N'24640')
BEGIN
    INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, SortOrder, CreatedAt)
    VALUES (N'24640', N'24640', N'Training Cup Set', N'Code: 24640', N'Music - Training Cup Set', (SELECT TOP 1 Id FROM Categories WHERE Name = N'Music'), @UnitId, NULL, 0.00, 0.00, 100, 10, '/uploads/products/pharma-item.svg', 1, 4, GETUTCDATE());
END

-- Set Stock = 100 for all products
UPDATE Products SET CurrentStock = 100;
GO


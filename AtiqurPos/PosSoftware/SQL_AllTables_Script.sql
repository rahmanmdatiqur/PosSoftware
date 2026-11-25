-- ==============================================================================
--  POS SOFTWARE — Complete Database & All Tables Schema Script
--  Target Server : Any Microsoft SQL Server (LocalDB / SQLEXPRESS / Enterprise)
--  Database Name : PosInventoryDb
--  Features      : Idempotent (IF NOT EXISTS), Data-Safe (No accidental drops),
--                  Dual Table Compatibility (Users & AppUsers via Synonyms),
--                  Full RBAC, Catalog, Inventory, Purchase & POS Sales.
-- ==============================================================================

USE master;
GO

-- 1. Create database if it does not already exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'PosInventoryDb')
BEGIN
    CREATE DATABASE PosInventoryDb COLLATE SQL_Latin1_General_CP1_CI_AS;
    PRINT 'Database PosInventoryDb created.';
END
ELSE
BEGIN
    PRINT 'Database PosInventoryDb already exists. Preserving existing database and data.';
END
GO

USE PosInventoryDb;
GO

-- ==============================================================================
-- 1. SECURITY MODULE (Roles, Users, ModulePages, RolePermissions)
-- ==============================================================================

-- 1.1 Roles Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE Roles (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        RoleName    NVARCHAR(50)  NOT NULL,
        Description NVARCHAR(200) NULL,
        IsActive    BIT           NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table Roles created.';
END
GO

-- 1.2 Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id           INT IDENTITY(1,1) PRIMARY KEY,
        Username     NVARCHAR(50)  NOT NULL,
        FullName     NVARCHAR(100) NOT NULL,
        Email        NVARCHAR(100) NULL,
        Phone        NVARCHAR(20)  NULL,
        PasswordHash NVARCHAR(MAX) NOT NULL,
        Salt         NVARCHAR(MAX) NOT NULL,
        RoleId       INT           NOT NULL,
        IsActive     BIT           NOT NULL DEFAULT 1,
        CreatedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        LastLoginAt  DATETIME2     NULL,
        CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId)
            REFERENCES Roles(Id) ON DELETE CASCADE
    );
    PRINT 'Table Users created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Users_Username' AND object_id = OBJECT_ID('Users'))
BEGIN
    CREATE UNIQUE INDEX UX_Users_Username ON Users(Username);
END
GO

-- 1.3 ModulePages Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ModulePages')
BEGIN
    CREATE TABLE ModulePages (
        Id             INT IDENTITY(1,1) PRIMARY KEY,
        ModuleName     NVARCHAR(50)  NOT NULL,
        PageName       NVARCHAR(100) NOT NULL,
        DisplayName    NVARCHAR(100) NOT NULL,
        ControllerName NVARCHAR(100) NOT NULL DEFAULT '',
        ActionName     NVARCHAR(100) NOT NULL DEFAULT '',
        IconClass      NVARCHAR(50)  NOT NULL DEFAULT 'bi bi-circle',
        SortOrder      INT           NOT NULL DEFAULT 0,
        ShowInMenu     BIT           NOT NULL DEFAULT 1,
        IsActive       BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Table ModulePages created.';
END
GO

-- 1.4 RolePermissions Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RolePermissions')
BEGIN
    CREATE TABLE RolePermissions (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        RoleId          INT NOT NULL,
        AppModulePageId INT NOT NULL,
        CanView         BIT NOT NULL DEFAULT 0,
        CanCreate       BIT NOT NULL DEFAULT 0,
        CanEdit         BIT NOT NULL DEFAULT 0,
        CanDelete       BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleId)
            REFERENCES Roles(Id) ON DELETE CASCADE,
        CONSTRAINT FK_RolePermissions_Pages FOREIGN KEY (AppModulePageId)
            REFERENCES ModulePages(Id) ON DELETE CASCADE
    );
    PRINT 'Table RolePermissions created.';
END
GO

-- 1.5 Compatibility Synonyms (Allows queries to AppUsers, AppRoles, AppModulePages to seamlessly work)
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppUsers') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppUsers')
    CREATE SYNONYM AppUsers FOR dbo.Users;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppRoles') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppRoles')
    CREATE SYNONYM AppRoles FOR dbo.Roles;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppModulePages') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppModulePages')
    CREATE SYNONYM AppModulePages FOR dbo.ModulePages;
GO

-- ==============================================================================
-- 2. CATALOG & INVENTORY MODULE
-- ==============================================================================

-- 2.1 Categories Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categories')
BEGIN
    CREATE TABLE Categories (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        Name        NVARCHAR(100) NOT NULL,
        Description NVARCHAR(250) NULL,
        IsActive    BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Table Categories created.';
END
GO

-- 2.2 Units Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Units')
BEGIN
    CREATE TABLE Units (
        Id        INT IDENTITY(1,1) PRIMARY KEY,
        Name      NVARCHAR(50) NOT NULL,
        ShortCode NVARCHAR(10) NOT NULL,
        IsActive  BIT          NOT NULL DEFAULT 1
    );
    PRINT 'Table Units created.';
END
GO

-- 2.3 Suppliers Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Suppliers')
BEGIN
    CREATE TABLE Suppliers (
        Id            INT IDENTITY(1,1) PRIMARY KEY,
        Name          NVARCHAR(150) NOT NULL,
        ContactPerson NVARCHAR(100) NULL,
        Phone         NVARCHAR(20)  NULL,
        Email         NVARCHAR(100) NULL,
        Address       NVARCHAR(300) NULL,
        IsActive      BIT           NOT NULL DEFAULT 1,
        CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table Suppliers created.';
END
GO

-- 2.4 Products Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE Products (
        Id            INT IDENTITY(1,1) PRIMARY KEY,
        SKU           NVARCHAR(50)  NOT NULL,
        Barcode       NVARCHAR(50)  NOT NULL,
        Name          NVARCHAR(150) NOT NULL,
        GenericName   NVARCHAR(150) NULL,
        Description   NVARCHAR(500) NULL,
        CategoryId    INT           NOT NULL,
        UnitId        INT           NOT NULL,
        SupplierId    INT           NULL,
        CostPrice     DECIMAL(18,2) NOT NULL DEFAULT 0,
        SellingPrice  DECIMAL(18,2) NOT NULL DEFAULT 0,
        CurrentStock  INT           NOT NULL DEFAULT 0,
        MinAlertStock INT           NOT NULL DEFAULT 5,
        ImageUrl      NVARCHAR(255) NULL,
        IsActive      BIT           NOT NULL DEFAULT 1,
        SortOrder     INT           NOT NULL DEFAULT 0,
        CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId)
            REFERENCES Categories(Id),
        CONSTRAINT FK_Products_Units FOREIGN KEY (UnitId)
            REFERENCES Units(Id),
        CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierId)
            REFERENCES Suppliers(Id)
    );
    PRINT 'Table Products created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Products_Barcode' AND object_id = OBJECT_ID('Products'))
    CREATE UNIQUE INDEX UX_Products_Barcode ON Products(Barcode);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Products_SKU' AND object_id = OBJECT_ID('Products'))
    CREATE UNIQUE INDEX UX_Products_SKU ON Products(SKU);
GO

-- 2.5 StockTransactions Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StockTransactions')
BEGIN
    CREATE TABLE StockTransactions (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        ProductId       INT           NOT NULL,
        TransactionType NVARCHAR(30)  NOT NULL,
        Quantity        INT           NOT NULL,
        PreviousStock   INT           NOT NULL,
        NewStock        INT           NOT NULL,
        ReferenceNo     NVARCHAR(50)  NULL,
        Notes           NVARCHAR(255) NULL,
        CreatedByUserId INT           NULL,
        CreatedAt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_StockTx_Products FOREIGN KEY (ProductId)
            REFERENCES Products(Id),
        CONSTRAINT FK_StockTx_Users FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id) ON DELETE SET NULL
    );
    PRINT 'Table StockTransactions created.';
END
GO

-- 2.6 StockAdjustments Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StockAdjustments')
BEGIN
    CREATE TABLE StockAdjustments (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        AdjustmentNo    NVARCHAR(50)  NOT NULL,
        AdjustmentDate  DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        Notes           NVARCHAR(255) NULL,
        CreatedByUserId INT           NULL,
        CONSTRAINT FK_StockAdj_Users FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id) ON DELETE SET NULL
    );
    PRINT 'Table StockAdjustments created.';
END
GO

-- 2.7 StockAdjustmentItems Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StockAdjustmentItems')
BEGIN
    CREATE TABLE StockAdjustmentItems (
        Id                INT IDENTITY(1,1) PRIMARY KEY,
        StockAdjustmentId INT           NOT NULL,
        ProductId         INT           NOT NULL,
        OldStock          INT           NOT NULL,
        AdjustedStock     INT           NOT NULL,
        DifferenceQty     INT           NOT NULL,
        Reason            NVARCHAR(100) NULL,
        CONSTRAINT FK_SAItems_Adj FOREIGN KEY (StockAdjustmentId)
            REFERENCES StockAdjustments(Id) ON DELETE CASCADE,
        CONSTRAINT FK_SAItems_Products FOREIGN KEY (ProductId)
            REFERENCES Products(Id)
    );
    PRINT 'Table StockAdjustmentItems created.';
END
GO

-- ==============================================================================
-- 3. CUSTOMER & POS SALES MODULE
-- ==============================================================================

-- 3.1 Customers Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
BEGIN
    CREATE TABLE Customers (
        Id            INT IDENTITY(1,1) PRIMARY KEY,
        Name          NVARCHAR(100) NOT NULL,
        Phone         NVARCHAR(20)  NULL,
        Email         NVARCHAR(100) NULL,
        Address       NVARCHAR(255) NULL,
        LoyaltyPoints INT           NOT NULL DEFAULT 0,
        IsActive      BIT           NOT NULL DEFAULT 1,
        CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table Customers created.';
END
GO

-- 3.2 SalesMaster Table (Master)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesMaster')
BEGIN
    CREATE TABLE SalesMaster (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        InvoiceNumber   NVARCHAR(50)  NOT NULL,
        SaleDate        DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        CustomerId      INT           NOT NULL,
        SubTotal        DECIMAL(18,2) NOT NULL DEFAULT 0,
        TaxRate         DECIMAL(18,2) NOT NULL DEFAULT 0,
        TaxAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
        DiscountPercent DECIMAL(18,2) NOT NULL DEFAULT 0,
        DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
        RoundUp         DECIMAL(18,2) NOT NULL DEFAULT 0,
        FinalPayable    DECIMAL(18,2) NOT NULL DEFAULT 0,
        GrandTotal      DECIMAL(18,2) NOT NULL DEFAULT 0,
        PaidAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
        ChangeAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
        DuesAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
        AdmissionNo     NVARCHAR(50)  NULL,
        SaleOrderNo     NVARCHAR(50)  NULL,
        CustomerType    NVARCHAR(50)  NOT NULL DEFAULT 'Walk-in',
        FundType        NVARCHAR(50)  NOT NULL DEFAULT 'Cash',
        MobileNumber    NVARCHAR(30)  NULL,
        IsPosted        BIT           NOT NULL DEFAULT 1,
        PaymentMethod   NVARCHAR(30)  NOT NULL DEFAULT 'Cash',
        Status          NVARCHAR(30)  NOT NULL DEFAULT 'Completed',
        Notes           NVARCHAR(255) NULL,
        CashierId       INT           NULL,
        CONSTRAINT FK_SalesMaster_Customers FOREIGN KEY (CustomerId)
            REFERENCES Customers(Id),
        CONSTRAINT FK_SalesMaster_Cashier FOREIGN KEY (CashierId)
            REFERENCES Users(Id) ON DELETE SET NULL
    );
    PRINT 'Table SalesMaster created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_SalesMaster_InvoiceNumber' AND object_id = OBJECT_ID('SalesMaster'))
    CREATE UNIQUE INDEX UX_SalesMaster_InvoiceNumber ON SalesMaster(InvoiceNumber);
GO

-- 3.3 SalesDetails Table (Details)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesDetails')
BEGIN
    CREATE TABLE SalesDetails (
        Id             INT IDENTITY(1,1) PRIMARY KEY,
        SaleId         INT           NOT NULL,
        ProductId      INT           NOT NULL,
        ProductName    NVARCHAR(150) NOT NULL,
        BatchNo        NVARCHAR(50)  NULL,
        CostPrice      DECIMAL(18,2) NOT NULL DEFAULT 0,
        UnitPrice      DECIMAL(18,2) NOT NULL DEFAULT 0,
        Quantity       INT           NOT NULL DEFAULT 1,
        SubTotal       DECIMAL(18,2) NOT NULL DEFAULT 0,
        DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
        CONSTRAINT FK_SalesDetails_SalesMaster FOREIGN KEY (SaleId)
            REFERENCES SalesMaster(Id) ON DELETE CASCADE,
        CONSTRAINT FK_SalesDetails_Products FOREIGN KEY (ProductId)
            REFERENCES Products(Id)
    );
    PRINT 'Table SalesDetails created.';
END
GO

-- Synonyms for Sales / SalseDetails compatibility
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Sales') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sales')
    CREATE SYNONYM Sales FOR dbo.SalesMaster;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'SaleItems') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SaleItems')
    CREATE SYNONYM SaleItems FOR dbo.SalesDetails;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'SalseDetails') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalseDetails')
    CREATE SYNONYM SalseDetails FOR dbo.SalesDetails;
GO

-- ==============================================================================
-- 4. PURCHASE MODULE (PurchaseMaster & PurchaseDetails)
-- ==============================================================================

-- 4.1 PurchaseMaster Table (Master)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseMaster')
BEGIN
    CREATE TABLE PurchaseMaster (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        PurchaseNo      NVARCHAR(50)  NOT NULL,
        PurchaseDate    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        ReceiveDate     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        SupplierId      INT           NOT NULL,
        PurchaseOrderNo NVARCHAR(50)  NULL,
        TotalQty        INT           NOT NULL DEFAULT 0,
        SubTotal        DECIMAL(18,2) NOT NULL DEFAULT 0,
        DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalAmount     DECIMAL(18,2) NOT NULL DEFAULT 0,
        PaidAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
        DueAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
        Status          NVARCHAR(30)  NOT NULL DEFAULT 'Posted',
        IsPosted        BIT           NOT NULL DEFAULT 1,
        Notes           NVARCHAR(255) NULL,
        CreatedByUserId INT           NULL,
        CreatedAt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_PurchaseMaster_Suppliers FOREIGN KEY (SupplierId)
            REFERENCES Suppliers(Id) ON DELETE NO ACTION,
        CONSTRAINT FK_PurchaseMaster_Users FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id) ON DELETE SET NULL
    );
    PRINT 'Table PurchaseMaster created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_PurchaseMaster_PurchaseNo' AND object_id = OBJECT_ID('PurchaseMaster'))
    CREATE UNIQUE INDEX UX_PurchaseMaster_PurchaseNo ON PurchaseMaster(PurchaseNo);
GO

-- 4.2 PurchaseDetails Table (Details)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseDetails')
BEGIN
    CREATE TABLE PurchaseDetails (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        PurchaseId  INT           NOT NULL,
        ProductId   INT           NOT NULL,
        ProductName NVARCHAR(150) NOT NULL,
        ProductCode NVARCHAR(50)  NULL,
        Quantity    INT           NOT NULL DEFAULT 1,
        UnitPrice   DECIMAL(18,2) NOT NULL DEFAULT 0,
        TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        CONSTRAINT FK_PurchaseDetails_PurchaseMaster FOREIGN KEY (PurchaseId)
            REFERENCES PurchaseMaster(Id) ON DELETE CASCADE,
        CONSTRAINT FK_PurchaseDetails_Products FOREIGN KEY (ProductId)
            REFERENCES Products(Id)
    );
    PRINT 'Table PurchaseDetails created.';
END
GO

-- Synonyms for Purchases / PurcghaseDetails compatibility
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Purchases') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Purchases')
    CREATE SYNONYM Purchases FOR dbo.PurchaseMaster;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'PurchaseItems') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseItems')
    CREATE SYNONYM PurchaseItems FOR dbo.PurchaseDetails;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'PurcghaseDetails') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurcghaseDetails')
    CREATE SYNONYM PurcghaseDetails FOR dbo.PurchaseDetails;
GO

-- ==============================================================================
-- 5. AUTO CODE GENERATION MODULE (Code & CodeGenerate)
-- ==============================================================================

-- 5.1 Code Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Code')
BEGIN
    CREATE TABLE Code (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        CodeGroup   NVARCHAR(50)  NOT NULL,
        CodeName    NVARCHAR(50)  NOT NULL,
        Prefix      NVARCHAR(20)  NOT NULL,
        Length      INT           NOT NULL DEFAULT 5,
        Description NVARCHAR(150) NULL,
        IsActive    BIT           NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
    CREATE UNIQUE INDEX UX_Code_CodeName ON Code(CodeName);
    PRINT 'Table Code created.';
END
GO

-- 5.2 CodeGenerate Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CodeGenerate')
BEGIN
    CREATE TABLE CodeGenerate (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        CodeId      INT           NULL,
        CodeName    NVARCHAR(50)  NOT NULL,
        CurrentYear INT           NOT NULL DEFAULT YEAR(GETUTCDATE()),
        Prefix      NVARCHAR(20)  NULL,
        LastId      INT           NOT NULL DEFAULT 0,
        LastCode    NVARCHAR(50)  NULL,
        LastUpdated DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT FK_CodeGenerate_Code FOREIGN KEY (CodeId)
            REFERENCES Code(Id) ON DELETE SET NULL
    );
    CREATE UNIQUE INDEX UX_CodeGenerate_CodeName ON CodeGenerate(CodeName);
    PRINT 'Table CodeGenerate created.';
END
GO

-- Synonyms for plural names
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Codes') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Codes')
    CREATE SYNONYM Codes FOR dbo.Code;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'CodeGenerations') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CodeGenerations')
    CREATE SYNONYM CodeGenerations FOR dbo.CodeGenerate;
GO

-- ==============================================================================
-- 6. MASTER SEED DATA (Only inserted if tables are empty)
-- ==============================================================================

-- 5.1 Roles Seed
IF NOT EXISTS (SELECT 1 FROM Roles)
BEGIN
    INSERT INTO Roles (RoleName, Description, IsActive)
    VALUES
        ('SuperAdmin',       'Full system administrative rights',                1),
        ('Admin',            'Store Administrator with full operational rights', 1),
        ('Cashier',          'Front desk cashier with POS access',               1),
        ('InventoryManager', 'Manages stocks, adjustments, and products',       1);
    PRINT 'Seed data for Roles inserted.';
END
GO

-- 5.2 Users Seed (Passwords: Admin@123 / Cashier@123 / Manager@123)
IF NOT EXISTS (SELECT 1 FROM Users)
BEGIN
    INSERT INTO Users (Username, FullName, Email, Phone, PasswordHash, Salt, RoleId, IsActive)
    VALUES
        ('admin',   'System Administrator', 'admin@smartpos.com',   '+1 555-0101', 'Jzm4iop46jau0m2Pocjfur/Vb9wfW/rY1KncMAaYSX4=', 'C9t4sXZWALx4EJVtMySY7w==', 1, 1),
        ('cashier', 'John Cashier',         'cashier@smartpos.com', '+1 555-0102', '7VZGTIwI6vgUXCb/22q13WtrlKTrjOFrWTlpgp4C2Y4=', 'OZjMwzmun5TAfDBFAv6arQ==', 3, 1),
        ('manager', 'Robert Stock Manager', 'manager@smartpos.com', '+1 555-0103', 'KxPP0w/la6kxJBzmTUdEtWWqH3gRwE6XdW1M/+oA0lE=', '05atjwtlYF3I5GUDh3rMNA==', 4, 1);
    PRINT 'Seed data for Users inserted.';
END
GO

-- 5.3 Module Pages Seed
IF NOT EXISTS (SELECT 1 FROM ModulePages)
BEGIN
    INSERT INTO ModulePages (ModuleName, PageName, DisplayName, ControllerName, ActionName, IconClass, SortOrder, ShowInMenu)
    VALUES
        ('Main',      'Dashboard',       'Dashboard',            'Dashboard',      'Index',   'bi bi-speedometer2', 1,  1),
        ('POS',       'PosTerminal',     'POS Terminal',         'Pos',            'Index',   'bi bi-cart4',        2,  1),
        ('POS',       'SalesOrders',     'Sales Invoices',       'Sales',          'Index',   'bi bi-receipt',      3,  1),
        ('Purchase',  'Purchase',        'Purchase List',        'Purchase',       'Index',   'bi bi-bag-check',    4,  1),
        ('Inventory', 'InventoryList',   'Stock Overview',       'Inventory',      'Index',   'bi bi-boxes',        5,  1),
        ('Inventory', 'StockAdjustment', 'Stock Adjustment',     'Inventory',      'Adjust',  'bi bi-sliders',      6,  1),
        ('Catalog',   'Products',        'Products',             'Product',        'Index',   'bi bi-box-seam',     7,  1),
        ('Catalog',   'Categories',      'Categories',           'Category',       'Index',   'bi bi-tags',         8,  1),
        ('Catalog',   'Suppliers',       'Suppliers',            'Supplier',       'Index',   'bi bi-truck',        9,  1),
        ('Catalog',   'Customers',       'Customers',            'Customer',       'Index',   'bi bi-people',       10, 1),
        ('Security',  'Users',           'User Management',      'User',           'Index',   'bi bi-person-gear',  11, 1),
        ('Security',  'RolePermissions', 'Role & Permissions',   'RolePermission', 'Index',   'bi bi-shield-lock',  12, 1),
        ('Reports',   'Reports',         'Sales & Stock Reports','Sales',          'Reports', 'bi bi-graph-up',     13, 1);
    PRINT 'Seed data for ModulePages inserted.';
END
GO

-- 5.4 Role Permissions Seed
IF NOT EXISTS (SELECT 1 FROM RolePermissions)
BEGIN
    -- SuperAdmin -> full access to all pages
    INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
    SELECT 1, Id, 1, 1, 1, 1 FROM ModulePages;

    -- Admin -> full access except Delete on Users/RolePermissions
    INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
    SELECT 2, Id, 1, 1, 1,
        CASE WHEN PageName IN ('Users','RolePermissions') THEN 0 ELSE 1 END
    FROM ModulePages;

    -- Cashier -> POS Terminal, Sales, Customers, Dashboard
    INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
    SELECT 3, Id,
        CASE WHEN PageName IN ('Dashboard','PosTerminal','SalesOrders','Customers') THEN 1 ELSE 0 END,
        CASE WHEN PageName IN ('PosTerminal','Customers')                           THEN 1 ELSE 0 END,
        0, 0
    FROM ModulePages;

    -- InventoryManager
    INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
    SELECT 4, Id,
        CASE WHEN PageName IN ('Dashboard','InventoryList','StockAdjustment','Products','Categories','Suppliers','Reports') THEN 1 ELSE 0 END,
        CASE WHEN PageName IN ('StockAdjustment','Products','Categories','Suppliers')                                       THEN 1 ELSE 0 END,
        CASE WHEN PageName IN ('StockAdjustment','Products','Categories','Suppliers','InventoryList')                       THEN 1 ELSE 0 END,
        0
    FROM ModulePages;

    PRINT 'Seed data for RolePermissions inserted.';
END
GO

-- 5.5 Categories & Units Seed
IF NOT EXISTS (SELECT 1 FROM Categories)
BEGIN
    INSERT INTO Categories (Name, Description, IsActive)
    VALUES
        ('Beverages',        'Soft drinks, juices, bottled water, tea & coffee',    1),
        ('Bakery & Snacks',  'Bread, cookies, chips, biscuits and snacks',          1),
        ('Grocery & Staples','Rice, flour, cooking oil, spices, pulses',            1),
        ('Dairy & Eggs',     'Milk, cheese, butter, yogurt, fresh eggs',            1),
        ('Personal Care',    'Soap, shampoo, toothpaste, cosmetics',                1),
        ('Pharmacy',         'Prescription and OTC medicines, healthcare products', 1);
    PRINT 'Seed data for Categories inserted.';
END
GO

IF NOT EXISTS (SELECT 1 FROM Units)
BEGIN
    INSERT INTO Units (Name, ShortCode, IsActive)
    VALUES
        ('Pieces',   'PCS', 1),
        ('Kilogram', 'kg',  1),
        ('Box',      'box', 1),
        ('Packet',   'pkt', 1),
        ('Litre',    'ltr', 1);
    PRINT 'Seed data for Units inserted.';
END
GO

-- 6.6 Customers Seed
IF NOT EXISTS (SELECT 1 FROM Customers)
BEGIN
    INSERT INTO Customers (Name, Phone, Email, Address, LoyaltyPoints, IsActive)
    VALUES
        ('Walk-in', '01XXXXXXXXX', 'walkin@willows.org', 'Counter Front', 0, 1);
    PRINT 'Seed data for Customers inserted.';
END
GO

-- 6.7 Auto Code Generation Seed
IF NOT EXISTS (SELECT 1 FROM Code)
BEGIN
    INSERT INTO Code (CodeGroup, CodeName, Prefix, Length, Description, IsActive)
    VALUES 
        ('Sales',    'Invoice',       'INV-', 5, 'Sales Invoice Auto Numbering', 1),
        ('Purchase', 'Purchase',      'PUR-', 5, 'Purchase Number Auto Numbering', 1),
        ('Sales',    'SaleOrder',     'SO-',  5, 'Sales Order Auto Numbering', 1),
        ('Purchase', 'PurchaseOrder', 'PO-',  4, 'Purchase Order Auto Numbering', 1);
    PRINT 'Seed data for Code inserted.';
END
GO

IF NOT EXISTS (SELECT 1 FROM CodeGenerate)
BEGIN
    DECLARE @CurMaxSales INT = 0;
    SELECT @CurMaxSales = ISNULL(MAX(TRY_CAST(REPLACE(InvoiceNumber, 'INV-', '') AS INT)), 0) FROM Sales WHERE InvoiceNumber LIKE 'INV-%';
    
    DECLARE @CurMaxPur INT = 0;
    SELECT @CurMaxPur = ISNULL(MAX(TRY_CAST(REPLACE(PurchaseNo, 'PUR-', '') AS INT)), 0) FROM Purchases WHERE PurchaseNo LIKE 'PUR-%';

    INSERT INTO CodeGenerate (CodeId, CodeName, CurrentYear, Prefix, LastId, LastCode, LastUpdated)
    VALUES 
        ((SELECT Id FROM Code WHERE CodeName = 'Invoice'),       'Invoice',       YEAR(GETUTCDATE()), 'INV-', @CurMaxSales, 'INV-' + RIGHT('00000' + CAST(@CurMaxSales AS VARCHAR), 5), GETUTCDATE()),
        ((SELECT Id FROM Code WHERE CodeName = 'Purchase'),      'Purchase',      YEAR(GETUTCDATE()), 'PUR-', @CurMaxPur,   'PUR-' + RIGHT('00000' + CAST(@CurMaxPur AS VARCHAR), 5), GETUTCDATE()),
        ((SELECT Id FROM Code WHERE CodeName = 'SaleOrder'),     'SaleOrder',     YEAR(GETUTCDATE()), 'SO-',  0,            'SO-00000', GETUTCDATE()),
        ((SELECT Id FROM Code WHERE CodeName = 'PurchaseOrder'), 'PurchaseOrder', YEAR(GETUTCDATE()), 'PO-' + CAST(YEAR(GETUTCDATE()) AS VARCHAR) + '-', 0, 'PO-0000', GETUTCDATE());
    PRINT 'Seed data for CodeGenerate inserted.';
END
GO

PRINT '==============================================================================';
PRINT 'PosInventoryDb Schema & Table Script verified and ready for production use.';
PRINT '==============================================================================';
GO

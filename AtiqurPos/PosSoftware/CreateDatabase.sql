-- ==============================================================================
--  POS SOFTWARE — Database Creation & Initialization Script
--  Target Server : SQL Server (.\SQLEXPRESS or LocalDB)
--  Database Name : PosInventoryDb
-- ==============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'PosInventoryDb')
BEGIN
    CREATE DATABASE PosInventoryDb COLLATE SQL_Latin1_General_CP1_CI_AS;
END
GO

USE PosInventoryDb;
GO

-- 1. Roles Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE Roles (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        RoleName    NVARCHAR(50)  NOT NULL,
        Description NVARCHAR(200) NULL,
        IsActive    BIT           NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- 2. Users Table
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
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Users_Username' AND object_id = OBJECT_ID('Users'))
    CREATE UNIQUE INDEX UX_Users_Username ON Users(Username);
GO

-- 3. ModulePages Table
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
END
GO

-- 4. RolePermissions Table
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
END
GO

-- Synonyms for compatibility between Users <-> AppUsers, Roles <-> AppRoles, ModulePages <-> AppModulePages
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppUsers') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppUsers')
    CREATE SYNONYM AppUsers FOR dbo.Users;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppRoles') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppRoles')
    CREATE SYNONYM AppRoles FOR dbo.Roles;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'AppModulePages') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppModulePages')
    CREATE SYNONYM AppModulePages FOR dbo.ModulePages;
GO

-- 5. Categories
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categories')
BEGIN
    CREATE TABLE Categories (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        Name        NVARCHAR(100) NOT NULL,
        Description NVARCHAR(250) NULL,
        IsActive    BIT           NOT NULL DEFAULT 1
    );
END
GO

-- 6. Units
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Units')
BEGIN
    CREATE TABLE Units (
        Id        INT IDENTITY(1,1) PRIMARY KEY,
        Name      NVARCHAR(50) NOT NULL,
        ShortCode NVARCHAR(10) NOT NULL,
        IsActive  BIT          NOT NULL DEFAULT 1
    );
END
GO

-- 7. Suppliers
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
END
GO

-- 8. Products
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
        CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
        CONSTRAINT FK_Products_Units FOREIGN KEY (UnitId) REFERENCES Units(Id),
        CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierId) REFERENCES Suppliers(Id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Products_Barcode' AND object_id = OBJECT_ID('Products'))
    CREATE UNIQUE INDEX UX_Products_Barcode ON Products(Barcode);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Products_SKU' AND object_id = OBJECT_ID('Products'))
    CREATE UNIQUE INDEX UX_Products_SKU ON Products(SKU);
GO

-- 9. StockTransactions
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
        CONSTRAINT FK_StockTx_Products FOREIGN KEY (ProductId) REFERENCES Products(Id),
        CONSTRAINT FK_StockTx_Users FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id) ON DELETE SET NULL
    );
END
GO

-- 10. StockAdjustments
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StockAdjustments')
BEGIN
    CREATE TABLE StockAdjustments (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        AdjustmentNo    NVARCHAR(50)  NOT NULL,
        AdjustmentDate  DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
        Notes           NVARCHAR(255) NULL,
        CreatedByUserId INT           NULL,
        CONSTRAINT FK_StockAdj_Users FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id) ON DELETE SET NULL
    );
END
GO

-- 11. StockAdjustmentItems
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
        CONSTRAINT FK_SAItems_Adj FOREIGN KEY (StockAdjustmentId) REFERENCES StockAdjustments(Id) ON DELETE CASCADE,
        CONSTRAINT FK_SAItems_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
END
GO

-- 12. Customers
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
END
GO

-- 13. SalesMaster Table (Master)
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
        CONSTRAINT FK_SalesMaster_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
        CONSTRAINT FK_SalesMaster_Cashier FOREIGN KEY (CashierId) REFERENCES Users(Id) ON DELETE SET NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_SalesMaster_InvoiceNumber' AND object_id = OBJECT_ID('SalesMaster'))
    CREATE UNIQUE INDEX UX_SalesMaster_InvoiceNumber ON SalesMaster(InvoiceNumber);
GO

-- 14. SalesDetails Table (Details)
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
        CONSTRAINT FK_SalesDetails_SalesMaster FOREIGN KEY (SaleId) REFERENCES SalesMaster(Id) ON DELETE CASCADE,
        CONSTRAINT FK_SalesDetails_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
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

-- 15. PurchaseMaster Table (Master)
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
        CONSTRAINT FK_PurchaseMaster_Suppliers FOREIGN KEY (SupplierId) REFERENCES Suppliers(Id) ON DELETE NO ACTION,
        CONSTRAINT FK_PurchaseMaster_Users FOREIGN KEY (CreatedByUserId) REFERENCES Users(Id) ON DELETE SET NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_PurchaseMaster_PurchaseNo' AND object_id = OBJECT_ID('PurchaseMaster'))
    CREATE UNIQUE INDEX UX_PurchaseMaster_PurchaseNo ON PurchaseMaster(PurchaseNo);
GO

-- 16. PurchaseDetails Table (Details)
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
        CONSTRAINT FK_PurchaseDetails_PurchaseMaster FOREIGN KEY (PurchaseId) REFERENCES PurchaseMaster(Id) ON DELETE CASCADE,
        CONSTRAINT FK_PurchaseDetails_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
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

-- 17. Code (Auto Code Generation Definition)
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
END
GO

-- 18. CodeGenerate (Auto Sequence State)
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
        CONSTRAINT FK_CodeGenerate_Code FOREIGN KEY (CodeId) REFERENCES Code(Id) ON DELETE SET NULL
    );
    CREATE UNIQUE INDEX UX_CodeGenerate_CodeName ON CodeGenerate(CodeName);
END
GO

-- Synonyms for plural names
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'Codes') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Codes')
    CREATE SYNONYM Codes FOR dbo.Code;

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'CodeGenerations') AND NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CodeGenerations')
    CREATE SYNONYM CodeGenerations FOR dbo.CodeGenerate;
GO

PRINT 'PosInventoryDb tables initialized successfully.';
GO

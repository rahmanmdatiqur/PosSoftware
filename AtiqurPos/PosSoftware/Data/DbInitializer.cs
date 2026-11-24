using PosSoftware.Models.Entities;
using PosSoftware.Services;

namespace PosSoftware.Data
{
    public static class DbInitializer
    {
        public static void Initialize(ApplicationDbContext context)
        {
            context.Database.EnsureCreated();

            // 1. Roles & Users
            if (!context.Roles.Any())
            {
                var superAdminRole = new AppRole { RoleName = "SuperAdmin", Description = "Full system administrative rights", IsActive = true };
                var adminRole = new AppRole { RoleName = "Admin", Description = "Store Administrator with full operational rights", IsActive = true };
                var cashierRole = new AppRole { RoleName = "Cashier", Description = "Front desk cashier with POS access", IsActive = true };
                var managerRole = new AppRole { RoleName = "InventoryManager", Description = "Manages stocks, adjustments, and products", IsActive = true };

                context.Roles.AddRange(superAdminRole, adminRole, cashierRole, managerRole);
                context.SaveChanges();

                var (adminHash, adminSalt) = PasswordHasher.HashPassword("Admin@123");
                var (cashierHash, cashierSalt) = PasswordHasher.HashPassword("Cashier@123");
                var (managerHash, managerSalt) = PasswordHasher.HashPassword("Manager@123");

                var users = new List<AppUser>
                {
                    new()
                    {
                        Username = "admin",
                        FullName = "System Administrator",
                        Email = "admin@smartpos.com",
                        Phone = "+1 555-0101",
                        PasswordHash = adminHash,
                        Salt = adminSalt,
                        RoleId = superAdminRole.Id,
                        IsActive = true
                    },
                    new()
                    {
                        Username = "cashier",
                        FullName = "John Cashier",
                        Email = "cashier@smartpos.com",
                        Phone = "+1 555-0102",
                        PasswordHash = cashierHash,
                        Salt = cashierSalt,
                        RoleId = cashierRole.Id,
                        IsActive = true
                    },
                    new()
                    {
                        Username = "manager",
                        FullName = "Robert Stock Manager",
                        Email = "manager@smartpos.com",
                        Phone = "+1 555-0103",
                        PasswordHash = managerHash,
                        Salt = managerSalt,
                        RoleId = managerRole.Id,
                        IsActive = true
                    }
                };
                context.Users.AddRange(users);
                context.SaveChanges();
            }
            else
            {
                // Auto-fix placeholder passwords if any exist in the database
                var placeholderUsers = context.Users.Where(u => u.PasswordHash == "PLACEHOLDER").ToList();
                if (placeholderUsers.Any())
                {
                    foreach (var u in placeholderUsers)
                    {
                        string defaultPass = u.Username.ToLower() switch
                        {
                            "admin" => "Admin@123",
                            "cashier" => "Cashier@123",
                            "manager" => "Manager@123",
                            _ => "Admin@123"
                        };
                        var (h, s) = PasswordHasher.HashPassword(defaultPass);
                        u.PasswordHash = h;
                        u.Salt = s;
                    }
                    context.SaveChanges();
                }
            }

            // 2. AppModulePages
            if (!context.ModulePages.Any())
            {
                var pages = new List<AppModulePage>
                {
                    new() { ModuleName = "Main", PageName = "Dashboard", DisplayName = "Dashboard", ControllerName = "Dashboard", ActionName = "Index", IconClass = "bi bi-speedometer2", SortOrder = 1, ShowInMenu = true },
                    new() { ModuleName = "POS", PageName = "PosTerminal", DisplayName = "POS Terminal", ControllerName = "Pos", ActionName = "Index", IconClass = "bi bi-cart4", SortOrder = 2, ShowInMenu = true },
                    new() { ModuleName = "POS", PageName = "SalesOrders", DisplayName = "Sales Invoices", ControllerName = "Sales", ActionName = "Index", IconClass = "bi bi-receipt", SortOrder = 3, ShowInMenu = true },
                    new() { ModuleName = "Purchase", PageName = "Purchase", DisplayName = "Purchase List", ControllerName = "Purchase", ActionName = "Index", IconClass = "bi bi-bag-check", SortOrder = 4, ShowInMenu = true },
                    new() { ModuleName = "Inventory", PageName = "InventoryList", DisplayName = "Stock Overview", ControllerName = "Inventory", ActionName = "Index", IconClass = "bi bi-boxes", SortOrder = 5, ShowInMenu = true },
                    new() { ModuleName = "Inventory", PageName = "StockAdjustment", DisplayName = "Stock Adjustment", ControllerName = "Inventory", ActionName = "Adjust", IconClass = "bi bi-sliders", SortOrder = 6, ShowInMenu = true },
                    new() { ModuleName = "Catalog", PageName = "Products", DisplayName = "Products", ControllerName = "Product", ActionName = "Index", IconClass = "bi bi-box-seam", SortOrder = 7, ShowInMenu = true },
                    new() { ModuleName = "Catalog", PageName = "Categories", DisplayName = "Categories", ControllerName = "Category", ActionName = "Index", IconClass = "bi bi-tags", SortOrder = 8, ShowInMenu = true },
                    new() { ModuleName = "Catalog", PageName = "Suppliers", DisplayName = "Suppliers", ControllerName = "Supplier", ActionName = "Index", IconClass = "bi bi-truck", SortOrder = 9, ShowInMenu = true },
                    new() { ModuleName = "Catalog", PageName = "Customers", DisplayName = "Customers", ControllerName = "Customer", ActionName = "Index", IconClass = "bi bi-people", SortOrder = 10, ShowInMenu = true },
                    new() { ModuleName = "Security", PageName = "Users", DisplayName = "User Management", ControllerName = "User", ActionName = "Index", IconClass = "bi bi-person-gear", SortOrder = 11, ShowInMenu = true },
                    new() { ModuleName = "Security", PageName = "RolePermissions", DisplayName = "Role & Permissions", ControllerName = "RolePermission", ActionName = "Index", IconClass = "bi bi-shield-lock", SortOrder = 12, ShowInMenu = true },
                    new() { ModuleName = "Reports", PageName = "Reports", DisplayName = "Sales & Stock Reports", ControllerName = "Sales", ActionName = "Reports", IconClass = "bi bi-graph-up", SortOrder = 13, ShowInMenu = true }
                };
                context.ModulePages.AddRange(pages);
                context.SaveChanges();
            }

            // 3. Role Permissions
            if (!context.RolePermissions.Any())
            {
                var permissions = new List<RolePermission>();
                var pages = context.ModulePages.ToList();
                var roles = context.Roles.ToList();

                var superAdmin = roles.FirstOrDefault(r => r.RoleName == "SuperAdmin");
                var admin = roles.FirstOrDefault(r => r.RoleName == "Admin");
                var cashier = roles.FirstOrDefault(r => r.RoleName == "Cashier");
                var manager = roles.FirstOrDefault(r => r.RoleName == "InventoryManager");

                if (superAdmin != null)
                {
                    foreach (var p in pages)
                    {
                        permissions.Add(new RolePermission { RoleId = superAdmin.Id, AppModulePageId = p.Id, CanView = true, CanCreate = true, CanEdit = true, CanDelete = true });
                    }
                }

                if (admin != null)
                {
                    foreach (var p in pages)
                    {
                        bool canDelete = p.PageName != "Users" && p.PageName != "RolePermissions";
                        permissions.Add(new RolePermission { RoleId = admin.Id, AppModulePageId = p.Id, CanView = true, CanCreate = true, CanEdit = true, CanDelete = canDelete });
                    }
                }

                if (cashier != null)
                {
                    foreach (var p in pages)
                    {
                        bool canView = p.PageName == "Dashboard" || p.PageName == "PosTerminal" || p.PageName == "SalesOrders" || p.PageName == "Customers";
                        bool canCreate = p.PageName == "PosTerminal" || p.PageName == "Customers";
                        permissions.Add(new RolePermission { RoleId = cashier.Id, AppModulePageId = p.Id, CanView = canView, CanCreate = canCreate, CanEdit = false, CanDelete = false });
                    }
                }

                if (manager != null)
                {
                    foreach (var p in pages)
                    {
                        bool canView = p.PageName == "Dashboard" || p.PageName == "InventoryList" || p.PageName == "StockAdjustment" || p.PageName == "Products" || p.PageName == "Categories" || p.PageName == "Suppliers" || p.PageName == "Reports";
                        bool canCreate = p.PageName == "StockAdjustment" || p.PageName == "Products" || p.PageName == "Categories" || p.PageName == "Suppliers";
                        bool canEdit = canCreate || p.PageName == "InventoryList";
                        permissions.Add(new RolePermission { RoleId = manager.Id, AppModulePageId = p.Id, CanView = canView, CanCreate = canCreate, CanEdit = canEdit, CanDelete = false });
                    }
                }

                context.RolePermissions.AddRange(permissions);
                context.SaveChanges();
            }

            // 4. Categories, Units, Suppliers, Customers
            if (!context.Categories.Any())
            {
                var cat1 = new Category { Name = "Beverages", Description = "Soft drinks, juices, bottled water, tea & coffee", IsActive = true };
                var cat2 = new Category { Name = "Bakery & Snacks", Description = "Bread, cookies, chips, biscuits and snacks", IsActive = true };
                var cat3 = new Category { Name = "Grocery & Staples", Description = "Rice, flour, cooking oil, spices, pulses", IsActive = true };
                var cat4 = new Category { Name = "Dairy & Eggs", Description = "Milk, cheese, butter, yogurt, fresh eggs", IsActive = true };
                var cat5 = new Category { Name = "Personal Care", Description = "Soap, shampoo, toothpaste, cosmetics", IsActive = true };
                var catPharmacy = new Category { Name = "Pharmacy", Description = "Prescription and OTC medicines, healthcare products", IsActive = true };
                context.Categories.AddRange(cat1, cat2, cat3, cat4, cat5, catPharmacy);

                var u1 = new Unit { Name = "Pieces", ShortCode = "PCS", IsActive = true };
                var u2 = new Unit { Name = "Kilogram", ShortCode = "kg", IsActive = true };
                var u3 = new Unit { Name = "Box", ShortCode = "box", IsActive = true };
                var u4 = new Unit { Name = "Packet", ShortCode = "pkt", IsActive = true };
                var u5 = new Unit { Name = "Litre", ShortCode = "ltr", IsActive = true };
                context.Units.AddRange(u1, u2, u3, u4, u5);

                var s1 = new Supplier { Name = "Jawdan Pharmacy", ContactPerson = "Dave Miller", Phone = "+1 555-0211", Email = "orders@jawdanpharma.com", Address = "Sylhet", IsActive = true };
                var s2 = new Supplier { Name = "Incepta Pharmaceuticals Ltd.", ContactPerson = "Sarah Jenkins", Phone = "+1 555-0212", Email = "contact@inceptapharma.com", Address = "Dhaka", IsActive = true };
                var s3 = new Supplier { Name = "Nipro JMI Pharma Ltd.", ContactPerson = "Ali Rahman", Phone = "+1 555-0213", Email = "sales@niprojmi.com", Address = "Dhaka", IsActive = true };
                var s4 = new Supplier { Name = "SK+F (Transcom)", ContactPerson = "Kamal Hossain", Phone = "+1 555-0214", Email = "orders@skfbd.com", Address = "Transcom Industrial Park", IsActive = true };
                context.Suppliers.AddRange(s1, s2, s3, s4);

                var c1 = new Customer { Name = "Walk-in", Phone = "01XXXXXXXXX", Email = "walkin@willows.org", Address = "Counter Front", LoyaltyPoints = 0, IsActive = true };
                var c2 = new Customer { Name = "Michael Anderson", Phone = "+1 555-0301", Email = "m.anderson@example.com", Address = "742 Evergreen Terrace", LoyaltyPoints = 120, IsActive = true };
                var c3 = new Customer { Name = "Emma Watson", Phone = "+1 555-0302", Email = "e.watson@example.com", Address = "221B Baker Street", LoyaltyPoints = 85, IsActive = true };
                context.Customers.AddRange(c1, c2, c3);
                context.SaveChanges();

                var products = new List<Product>
                {
                    new() { SKU = "PH-00001", Barcode = "PH-00001", Name = "Montiva 10 Tablet", GenericName = "Montelukast", Description = "10mg chewable / film-coated tablet", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s1.Id, CostPrice = 9.17m, SellingPrice = 16.00m, CurrentStock = 50, MinAlertStock = 10, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00002", Barcode = "PH-00002", Name = "Starcal D Tablet", GenericName = "Calcium + Vit D3", Description = "Calcium 500mg + Vitamin D3 200IU", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s1.Id, CostPrice = 5.00m, SellingPrice = 8.00m, CurrentStock = 3, MinAlertStock = 5, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00003", Barcode = "PH-00003", Name = "Avamist Nasal Spray", GenericName = "Fluticasone", Description = "Metered dose nasal suspension spray", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s2.Id, CostPrice = 350.00m, SellingPrice = 450.00m, CurrentStock = 10, MinAlertStock = 5, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00004", Barcode = "PH-00004", Name = "Bilfast Kids Tablet", GenericName = "Bilastine", Description = "10mg orodispersible allergy tablets", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s2.Id, CostPrice = 12.00m, SellingPrice = 18.00m, CurrentStock = 30, MinAlertStock = 10, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00005", Barcode = "PH-00005", Name = "Bilfast Oral Solution", GenericName = "Bilastine 120ml", Description = "2.5mg/ml antihistamine syrup", CategoryId = catPharmacy.Id, UnitId = u5.Id, SupplierId = s2.Id, CostPrice = 85.00m, SellingPrice = 110.00m, CurrentStock = 2, MinAlertStock = 5, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00006", Barcode = "PH-00006", Name = "Bilfast Tablet", GenericName = "Bilastine 20mg", Description = "20mg non-sedating antihistamine", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s2.Id, CostPrice = 14.00m, SellingPrice = 20.00m, CurrentStock = 30, MinAlertStock = 10, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00007", Barcode = "PH-00007", Name = "Doxiva Syrup", GenericName = "Doxofylline", Description = "100mg/5ml bronchodilator syrup", CategoryId = catPharmacy.Id, UnitId = u5.Id, SupplierId = s3.Id, CostPrice = 65.00m, SellingPrice = 85.00m, CurrentStock = 2, MinAlertStock = 5, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00008", Barcode = "PH-00008", Name = "Dermasol Oint 20g T", GenericName = "Clobetasol", Description = "0.05% topical corticosteroid ointment", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s1.Id, CostPrice = 55.00m, SellingPrice = 75.50m, CurrentStock = 25, MinAlertStock = 5, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "PH-00009", Barcode = "PH-00009", Name = "LOSECTIL 20MG CAP", GenericName = "Omeprazole", Description = "20mg gastro-resistant capsule", CategoryId = catPharmacy.Id, UnitId = u1.Id, SupplierId = s4.Id, CostPrice = 3.50m, SellingPrice = 5.00m, CurrentStock = 100, MinAlertStock = 20, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true },
                    new() { SKU = "BEV-001", Barcode = "8901001", Name = "Coca Cola Can 330ml", GenericName = "Carbonated Soft Drink", Description = "Classic sparkling soft drink", CategoryId = cat1.Id, UnitId = u1.Id, SupplierId = s1.Id, CostPrice = 0.85m, SellingPrice = 1.50m, CurrentStock = 120, MinAlertStock = 20, ImageUrl = "/uploads/products/pharma-item.svg", IsActive = true }
                };
                context.Products.AddRange(products);
                context.SaveChanges();
            }

            // 5. Seed Purchases if empty
            if (!context.Purchases.Any())
            {
                var s1 = context.Suppliers.FirstOrDefault(s => s.Name.Contains("Jawdan")) ?? context.Suppliers.First();
                var s2 = context.Suppliers.FirstOrDefault(s => s.Name.Contains("Incepta")) ?? context.Suppliers.First();
                var s3 = context.Suppliers.FirstOrDefault(s => s.Name.Contains("Nipro")) ?? context.Suppliers.First();
                var s4 = context.Suppliers.FirstOrDefault(s => s.Name.Contains("Transcom") || s.Name.Contains("SK+F")) ?? context.Suppliers.First();

                var p1 = context.Products.FirstOrDefault(x => x.SKU == "PH-00008") ?? context.Products.First();
                var p2 = context.Products.FirstOrDefault(x => x.SKU == "PH-00001") ?? context.Products.First();

                var pur1 = new Purchase
                {
                    PurchaseNo = "PUR-00037",
                    SupplierId = s1.Id,
                    PurchaseDate = DateTime.UtcNow.AddDays(-4),
                    ReceiveDate = DateTime.UtcNow.AddDays(-4),
                    PurchaseOrderNo = "PO-2026-0037",
                    TotalQty = 4,
                    SubTotal = 2300.00m,
                    DiscountAmount = 0.00m,
                    TotalAmount = 2300.00m,
                    PaidAmount = 2300.00m,
                    DueAmount = 0.00m,
                    Status = "Posted",
                    IsPosted = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-4)
                };
                pur1.PurchaseItems.Add(new PurchaseItem
                {
                    ProductId = p1.Id,
                    ProductName = p1.Name,
                    ProductCode = p1.SKU,
                    Quantity = 4,
                    UnitPrice = 575.00m,
                    TotalAmount = 2300.00m
                });

                var pur2 = new Purchase
                {
                    PurchaseNo = "PUR-00036",
                    SupplierId = s2.Id,
                    PurchaseDate = DateTime.UtcNow.AddDays(-4),
                    ReceiveDate = DateTime.UtcNow.AddDays(-4),
                    PurchaseOrderNo = "PO-2026-0036",
                    TotalQty = 710,
                    SubTotal = 7260.10m,
                    DiscountAmount = 0.00m,
                    TotalAmount = 7260.10m,
                    PaidAmount = 7260.10m,
                    DueAmount = 0.00m,
                    Status = "Posted",
                    IsPosted = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-4)
                };
                pur2.PurchaseItems.Add(new PurchaseItem
                {
                    ProductId = p2.Id,
                    ProductName = p2.Name,
                    ProductCode = p2.SKU,
                    Quantity = 710,
                    UnitPrice = 10.22m,
                    TotalAmount = 7260.10m
                });

                var pur3 = new Purchase
                {
                    PurchaseNo = "PUR-00035",
                    SupplierId = s3.Id,
                    PurchaseDate = DateTime.UtcNow.AddDays(-4),
                    ReceiveDate = DateTime.UtcNow.AddDays(-4),
                    PurchaseOrderNo = "PO-2026-0035",
                    TotalQty = 10,
                    SubTotal = 2420.20m,
                    DiscountAmount = 0.00m,
                    TotalAmount = 2420.20m,
                    PaidAmount = 2420.20m,
                    DueAmount = 0.00m,
                    Status = "Posted",
                    IsPosted = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-4)
                };

                var pur4 = new Purchase
                {
                    PurchaseNo = "PUR-00034",
                    SupplierId = s4.Id,
                    PurchaseDate = DateTime.UtcNow.AddDays(-4),
                    ReceiveDate = DateTime.UtcNow.AddDays(-4),
                    PurchaseOrderNo = "PO-2026-0034",
                    TotalQty = 1208,
                    SubTotal = 20985.44m,
                    DiscountAmount = 0.00m,
                    TotalAmount = 20985.44m,
                    PaidAmount = 20985.44m,
                    DueAmount = 0.00m,
                    Status = "Posted",
                    IsPosted = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-4)
                };

                context.Purchases.AddRange(pur1, pur2, pur3, pur4);
                context.SaveChanges();
            }

            // 6. Seed Sales matching screenshot
            if (!context.Sales.Any())
            {
                var walkIn = context.Customers.FirstOrDefault(c => c.Name == "Walk-in") ?? context.Customers.First();
                var pDermasol = context.Products.FirstOrDefault(p => p.SKU == "PH-00008") ?? context.Products.First();
                var pLosectil = context.Products.FirstOrDefault(p => p.SKU == "PH-00009") ?? context.Products.First();

                var sale1 = new Sale
                {
                    InvoiceNumber = "INV-00224",
                    SaleDate = DateTime.UtcNow.AddDays(-1),
                    CustomerId = walkIn.Id,
                    CustomerType = "Walk-in",
                    FundType = "Cash",
                    SubTotal = 85.50m,
                    TaxRate = 0,
                    TaxAmount = 0,
                    DiscountPercent = 0,
                    DiscountAmount = 0,
                    RoundUp = 0.50m,
                    FinalPayable = 85.00m,
                    GrandTotal = 85.00m,
                    PaidAmount = 85.00m,
                    ChangeAmount = 0,
                    DuesAmount = 0,
                    PaymentMethod = "Cash",
                    Status = "Completed",
                    IsPosted = true
                };
                sale1.SaleItems.Add(new SaleItem
                {
                    ProductId = pDermasol.Id,
                    ProductName = "Dermasol Oint 20g T",
                    UnitPrice = 75.50m,
                    CostPrice = 55.00m,
                    Quantity = 1,
                    SubTotal = 75.50m,
                    DiscountAmount = 0,
                    TotalAmount = 75.50m
                });
                sale1.SaleItems.Add(new SaleItem
                {
                    ProductId = pLosectil.Id,
                    ProductName = "LOSECTIL 20MG CAP",
                    UnitPrice = 5.00m,
                    CostPrice = 3.50m,
                    Quantity = 2,
                    SubTotal = 10.00m,
                    DiscountAmount = 0,
                    TotalAmount = 10.00m
                });

                var sale2 = new Sale
                {
                    InvoiceNumber = "INV-00223",
                    SaleDate = DateTime.UtcNow.AddDays(-1),
                    CustomerId = walkIn.Id,
                    CustomerType = "Walk-in",
                    SubTotal = 288.50m,
                    GrandTotal = 288.00m,
                    FinalPayable = 288.00m,
                    PaidAmount = 288.00m,
                    DuesAmount = 0.00m,
                    PaymentMethod = "Cash",
                    Status = "Completed",
                    IsPosted = true
                };

                var sale3 = new Sale
                {
                    InvoiceNumber = "INV-00222",
                    SaleDate = DateTime.UtcNow.AddDays(-2),
                    CustomerId = walkIn.Id,
                    CustomerType = "Walk-in",
                    SubTotal = 24.00m,
                    GrandTotal = 24.00m,
                    FinalPayable = 24.00m,
                    PaidAmount = 24.00m,
                    DuesAmount = 0.00m,
                    PaymentMethod = "Cash",
                    Status = "Completed",
                    IsPosted = true
                };

                var sale4 = new Sale
                {
                    InvoiceNumber = "INV-00221",
                    SaleDate = DateTime.UtcNow.AddDays(-2),
                    CustomerId = walkIn.Id,
                    CustomerType = "Walk-in",
                    SubTotal = 174.00m,
                    GrandTotal = 174.00m,
                    FinalPayable = 174.00m,
                    PaidAmount = 174.00m,
                    DuesAmount = 0.00m,
                    PaymentMethod = "Cash",
                    Status = "Completed",
                    IsPosted = true
                };

                context.Sales.AddRange(sale1, sale2, sale3, sale4);
                context.SaveChanges();
            }
        }
    }
}

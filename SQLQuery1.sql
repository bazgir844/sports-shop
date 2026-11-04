-- ساخت پایگاه داده
CREATE DATABASE SportsShop;
GO

USE SportsShop;
GO

-- جدول محصولات
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price INT NOT NULL CHECK (Price > 0),
    Stock INT NOT NULL CHECK (Stock >= 0)
);

-- جدول مشتریان
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20)
);

-- جدول سفارش‌ها
CREATE TABLE SalesOrders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- جدول محصولات داخل هر سفارش
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice INT NOT NULL CHECK (UnitPrice > 0),

    FOREIGN KEY (OrderID) REFERENCES SalesOrders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- ثبت چند محصول نمونه
INSERT INTO Products (ProductName, Price, Stock)
VALUES
    (N'توپ فوتبال', 850000, 10),
    (N'مت یوگا', 450000, 15),
    (N'طناب ورزشی', 180000, 8);

-- ثبت چند مشتری نمونه
INSERT INTO Customers (FullName, Phone)
VALUES
    (N'علی رضایی', '09120000001'),
    (N'سارا محمدی', '09120000002');
GO

-- ثبت یک سفارش نمونه:
-- مشتری شماره 1، دو توپ فوتبال و یک مت یوگا می‌خرد.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO SalesOrders (CustomerID)
VALUES (1);

DECLARE @NewOrderID INT;
SET @NewOrderID = SCOPE_IDENTITY();

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
VALUES
    (@NewOrderID, 1, 2, 850000),
    (@NewOrderID, 2, 1, 450000);

-- کم‌کردن تعداد کالاهای فروخته‌شده از موجودی
UPDATE Products
SET Stock = Stock - 2
WHERE ProductID = 1;

UPDATE Products
SET Stock = Stock - 1
WHERE ProductID = 2;

COMMIT TRANSACTION;
GO

-- نمایش همه محصولات و موجودی آن‌ها
SELECT * FROM Products;

-- نمایش همه مشتریان
SELECT * FROM Customers;

-- نمایش جزئیات سفارش‌ها
SELECT
    so.OrderID,
    c.FullName AS CustomerName,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS ItemTotal
FROM SalesOrders AS so
JOIN Customers AS c ON so.CustomerID = c.CustomerID
JOIN OrderDetails AS od ON so.OrderID = od.OrderID
JOIN Products AS p ON od.ProductID = p.ProductID;

-- نمایش مبلغ کل هر سفارش
SELECT
    so.OrderID,
    c.FullName AS CustomerName,
    SUM(od.Quantity * od.UnitPrice) AS OrderTotal
FROM SalesOrders AS so
JOIN Customers AS c ON so.CustomerID = c.CustomerID
JOIN OrderDetails AS od ON so.OrderID = od.OrderID
GROUP BY so.OrderID, c.FullName;
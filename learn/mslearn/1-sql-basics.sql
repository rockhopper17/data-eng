-- set the database in bottom right in vscode

CREATE DATABASE TestData
GO

USE TestData
GO

CREATE TABLE dbo.Products
(
    ProductId int PRIMARY KEY NOT NULL,
    ProductName varchar(25),
    Price money NULL,
    ProductDescription varchar(max) NULL
)
GO

-- delete all rows
TRUNCATE TABLE dbo.Products
GO

------------------------------
-- INSERT --
------------------------------
INSERT INTO dbo.Products (ProductId, ProductName, Price, ProductDescription)
VALUES (1, 'Clamp', 12.48, 'workbench clamp')
GO

INSERT INTO dbo.Products (ProductName, ProductId, Price, ProductDescription)
VALUES ('screwdriver', 50, 3.17, 'flat head')
GO

-- can skip column list but keep values in order
INSERT INTO dbo.Products
VALUES (75, 'tire bar', NULL, 'tool for changing tires')
GO

INSERT INTO Products (ProductId, ProductName, Price)
VALUES (3000, '3mm bracket', 0.52)
GO

------------------------------
-- UPDATE --
------------------------------
UPDATE Products
SET ProductName = 'flat head screwdriver'
WHERE ProductId = 50
GO

------------------------------
-- SELECT --
------------------------------
SELECT ProductId, ProductName, Price, ProductDescription
FROM Products
GO

SELECT * FROM Products
GO

SELECT ProductId, ProductName, Price, ProductDescription
FROM Products
WHERE ProductId < 60
GO

SELECT ProductName, Price * 1.07 as CustomerPays
FROM Products
GO

------------------------------
-- Views and Stored Procedures --
------------------------------
CREATE VIEW vw_Names AS
SELECT ProductName, Price FROM Products
GO

SELECT * FROM vw_Names
GO

CREATE PROCEDURE pr_Names @VarPrice money AS
BEGIN
    -- print statement returns text to user
    PRINT 'Product less than ' + CAST(@VarPrice as varchar(10));
    -- second statement here
    SELECT ProductName, Price FROM vw_Names WHERE Price < @VarPrice;
END
GO

EXECUTE pr_Names 10.00;
GO

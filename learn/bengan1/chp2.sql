-- chp2: single-table queries
USE TSQLV6;

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders
WHERE custid = 71;

SELECT empid, YEAR(orderdate) AS orderyear, SUM(freight) AS totalfreight, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);

-- this just returns orderid aliased as orderdate with the forgotten comma
SELECT orderid orderdate
FROM Sales.Orders;

SELECT DISTINCT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

-- SELECT TOP(5) orderid, orderdate, custid, empid
SELECT TOP(5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
-- ORDER BY orderdate DESC, orderid DESC;

SELECT TOP(1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid ORDER BY val) as rownum
FROM Sales.OrderValues
ORDER BY custid, val;

SELECT orderid, empid, orderdate
FROM Sales.Orders
-- WHERE orderid IN (10248, 10249, 10250);
WHERE orderid BETWEEN 10300 AND 10310;

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20220101'
    AND empid NOT IN(1,3,5);

SELECT orderid, productid, qty, unitprice, discount,
    qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

SELECT supplierid, COUNT(*) as numproducts,
  CASE COUNT(*) % 2
    WHEN 0 THEN 'even'
    WHEN 1 THEN 'odd'
    ELSE 'unknown'
  END AS countparity
FROM Production.Products
GROUP BY supplierid;

SELECT orderid, custid, val,
  CASE
    WHEN val < 1000.00  THEN 'less than 1000'
    WHEN val <= 3000.00 THEN 'between 1000 and 3000'
    WHEN val > 3000.00  THEN  'more than 3000'
    ELSE 'unknown'
  END AS valuecategory
FROM Sales.OrderValues;

SELECT custid, country, region, city
FROM Sales.Customers
-- WHERE region = N'WA';
-- WHERE region IS NOT DISTINCT FROM N'WA';
-- WHERE region <> N'WA';
-- WHERE region = NULL;
-- WHERE region IS NULL;
-- WHERE region <> N'WA' OR region IS NULL;
WHERE region IS DISTINCT FROM N'WA';

SELECT orderid, requireddate, shippeddate,
  GREATEST(requireddate, shippeddate) AS latestdate,
  LEAST(requireddate, shippeddate) AS  earliestdate
FROM Sales.Orders
WHERE custid = 8;

SELECT name, [description]
FROM sys.fn_helpcollations();

SELECT empid, firstname + N' ' + lastname as fullname
FROM HR.Employees;

SELECT custid, country, region, city,
  -- country + COALESCE(N',' + region, N'') + N',' + city AS location
  -- CONCAT(country, N',' + region, N',' + city) AS location
  CONCAT_WS(N',', country, region, city) AS location
FROM Sales.Customers;

SELECT TRANSLATE('123.456.789,00', '.,',',.');

-- add leading zeros to a number to get all the same length
SELECT supplierid,
  RIGHT(REPLICATE('0',9) + CAST(supplierid AS varchar(10)), 10) AS str_supplier_id
FROM Production.Suppliers;

SELECT CAST(value AS int) as myvalue, ordinal
FROM string_split('10248,10249,10250',',', 1) AS S;

SELECT custid,
  STRING_AGG(CAST(orderid AS varchar(10)), ',')
    WITHIN GROUP(ORDER BY orderdate DESC, orderid DESC) as custorders
FROM Sales.Orders
GROUP BY custid;

SELECT empid, lastname
FROM HR.Employees
-- WHERE lastname LIKE N'D%';
WHERE lastname LIKE N'_e%';

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
-- WHERE orderdate = '20220212';
WHERE orderdate = CAST('20220212' AS DATE);

SET LANGUAGE British;
SELECT CAST('02/12/2022' AS DATE);
SET LANGUAGE us_english;
SELECT CAST('02/12/2022' AS DATE);

------------------
DROP TABLE IF EXISTS Sales.Orders2;
SELECT orderid, custid, empid, CAST(orderdate AS DATETIME) AS orderdate
INTO Sales.Orders2
FROM Sales.Orders;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders2
WHERE orderdate = '20220212';

ALTER TABLE Sales.Orders2
  ADD CONSTRAINT CHK_Orders2_orderdate
  CHECK( CONVERT(CHAR(12), orderdate, 114) = '00:00:00:000');

DROP TABLE IF EXISTS Sales.Orders2;
------------------

SELECT
GETDATE() AS [GETDATE],
CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP],
GETUTCDATE() AS [GETUTCDATE],
SYSDATETIME() AS [SYSDATETIME],
SYSUTCDATETIME() AS [SYSUTCDATETIME],
SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT [value]
FROM GENERATE_SERIES(1, 10) AS N;

DECLARE @startdate AS DATE = '20260101', @enddate AS DATE = '20261231';
SELECT DATEADD(day, value, @startdate) AS dt
FROM generate_series(0, DATEDIFF(day, @startdate, @enddate)) AS N;

SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables;

SELECT
  name AS column_name,
  TYPE_NAME(system_type_id) AS column_type,
  max_length,
  collation_name,
  is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.Orders');

EXEC sys.sp_tables;

EXEC sys.sp_help @objname = N'Sales.Orders';

SELECT SERVERPROPERTY('Collation');

---------------------------------------------------------------------
-- exercises --
---------------------------------------------------------------------

-- (1) --
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20210601' AND orderdate < '20210701';

-- (2) --
SELECT orderid, orderdate, custid, empid, EOMONTH(orderdate)
FROM Sales.Orders
-- WHERE DATEPART(day, orderdate) = 1;
WHERE DATEDIFF(day, orderdate, DATEADD(day, -1, EOMONTH(orderdate))) = 0;

-- (3) --
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) >= 2;

-- (4) --
SELECT orderid, (qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
WHERE (qty * unitprice) > 10000
ORDER BY totalvalue;

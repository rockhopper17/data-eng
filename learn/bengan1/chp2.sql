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

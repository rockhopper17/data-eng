SET STATISTICS IO ON;
SET STATISTICS TIME ON;
go

EXEC dbo.usp_MonthlyPerformance @Year = 2025;
go

select COUNT(*) from trades_gold
go
-- table coming from spark etl will not have a PK, and it drops and recreates the table
ALTER TABLE dbo.trades_gold
ADD trade_id INT IDENTITY(1,1) NOT NULL;

ALTER TABLE dbo.trades_gold
ADD CONSTRAINT PK_trades_gold PRIMARY KEY CLUSTERED (trade_id);

go

-- ******************************************************************************************************
CREATE OR ALTER PROCEDURE dbo.usp_MonthlyPerformance
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DATEFROMPARTS(YEAR(t.exit_time), MONTH(t.exit_time), 1)     AS trade_month,
        COUNT(*)                                                    AS trade_count,
        SUM(t.profit)                                                AS monthly_profit,
        AVG(CAST(t.is_win AS FLOAT))                                 AS win_rate,
        AVG(CASE WHEN t.profit > 0 THEN t.profit END)                AS avg_win,
        AVG(CASE WHEN t.profit < 0 THEN t.profit END)                AS avg_loss,
        MIN(t.drawdown)                                              AS worst_drawdown,
        SUM(SUM(t.profit)) OVER (
            ORDER BY DATEFROMPARTS(YEAR(t.exit_time), MONTH(t.exit_time), 1)
            ROWS UNBOUNDED PRECEDING)                                AS cumulative_profit,
        RANK() OVER (ORDER BY SUM(t.profit) ASC)                     AS worst_month_rank
    FROM dbo.trades_gold t

-- leave this in to test perf tuning in the execution plan
WHERE YEAR(t.exit_time) = @Year
-- fixed predicate, sargable
-- WHERE t.exit_time >= DATEFROMPARTS(@Year, 1, 1)
--   AND t.exit_time <  DATEFROMPARTS(@Year + 1, 1, 1)

    GROUP BY DATEFROMPARTS(YEAR(t.exit_time), MONTH(t.exit_time), 1)
    ORDER BY trade_month;
END;

go

-- leave this commented out to test the bad tunable execution plan
-- CREATE INDEX ix_trades_gold_exit_time
-- ON dbo.trades_gold (exit_time)
-- INCLUDE (profit, is_win, drawdown);
-- go

-- ******************************************************************************************************
-- create a bunch more rows on top of the original 158
-- ******************************************************************************************************
;WITH nums AS (
    SELECT TOP (500000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.trades_gold (qty, side, entry_price, exit_price, entry_time, exit_time,
    duration_minutes, bars, exit_name, profit, mae, mfe, is_win, cum_net_profit, running_max_equity, drawdown)
SELECT
    1 + (n % 3),
    CASE WHEN n % 2 = 0 THEN N'Long' ELSE N'Short' END,
    5000 + (n % 200),
    5000 + ((n + 3) % 200),
    DATEADD(MINUTE, -n * 5, SYSDATETIME()),
    DATEADD(MINUTE, -n * 5 + 10, SYSDATETIME()),
    10,
    12,
    N'Target',
    CASE WHEN n % 2 = 0 THEN 62.50 ELSE -37.50 END,
    -10, 15, CASE WHEN n % 2 = 0 THEN 1 ELSE 0 END,
    0, 0, 0
FROM nums;
-- ******************************************************************************************************
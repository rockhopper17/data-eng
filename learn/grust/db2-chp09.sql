-- Grust - DB2 course (database systems II)
-- still use the docker db AdvSqlGrust

DROP TABLE IF EXISTS indexed;
CREATE TABLE indexed (
  a INT CONSTRAINT PK_indexed PRIMARY KEY,
  b VARCHAR(256),
  c NUMERIC(3,2)
);
GO

-- PostgreSQL version
-- INSERT INTO indexed(a,b,c)
  -- SELECT i, md5(CAST(i as VARCHAR(256))), SIN(i)
  -- FROM GENERATE_SERIES(1, 1000000) AS i;
INSERT INTO indexed(a,b,c)
  SELECT
    i.value,
    LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5', CAST(i.value AS VARCHAR(256))), 2)),
    SIN(i.value)
  FROM GENERATE_SERIES(1, 1000000) AS i;
GO
SELECT TOP 100 * FROM indexed;
GO

EXEC sys.sp_help N'dbo.indexed';
EXEC sys.sp_helpindex N'dbo.indexed';
GO

---------------------------------------------------------------------------------------------------
-- storage info about the index and table --
---------------------------------------------------------------------------------------------------
SELECT
  OBJECT_NAME(i.object_id) AS table_name,
  i.name AS index_name,
  i.type_desc AS index_type,
  SUM(p.row_count) AS approximate_rows,
  SUM(p.in_row_data_page_count) AS table_data_pages,
  SUM(p.used_page_count) AS total_used_pages,
  CAST(SUM(p.used_page_count) * 8.0 / 1024 AS DECIMAL(12,2)) AS total_used_mb
FROM sys.indexes AS i
JOIN sys.dm_db_partition_stats AS p
  ON p.object_id = i.object_id
  AND p.index_id = i.index_id
WHERE i.object_id = OBJECT_ID(N'dbo.indexed')
GROUP BY i.object_id, i.index_id, i.name, i.type_desc;
GO

SELECT COUNT_BIG(*) AS exact_rows
FROM dbo.indexed WITH (INDEX(PK_indexed));
GO

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

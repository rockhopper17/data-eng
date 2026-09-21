USE AdvSqlGrust;

DROP TABLE IF EXISTS T;

CREATE TABLE T (
  a INT PRIMARY KEY,
  b CHAR(1),
  c BIT,
  d INT
  );

INSERT INTO T VALUES
(1, 'x', 1, 10),
(2, 'y', 1, 40),
(3, 'x', 0, 30),
(4, 'y', 0, 20),
(5, 'x', 1, NULL);

SELECT * FROM T;
SELECT t.* FROM T AS t;

-- can't do this in t-sql, it's postgres only
-- DROP TABLE IF EXISTS T1;
-- DROP TYPE IF EXISTS tau;
-- CREATE TYPE tau AS (a INT, b CHAR(1), c BIT, d INT);

-- SELECT 1+41 as "the answer", 'hello world' as "from", 'Gla' || 'DOS' as Portal;
SELECT 1+41 as [The Answer], 'hello world' as [from], 'Gla' + 'DOS' as Portal;

SELECT v.*
FROM (VALUES (1), (2)) as v(x);
-- FROM (VALUES (1), ('x')) as v(x); -- syntax error, need to be same type
-- FROM (VALUES (1, 2)) as v(x,y);
-- FROM (VALUES (0,0),(1,1),(NULL,NULL)) as v(x,y);

SELECT t1.*, t2.*
-- FROM  T as t1, T as t2; -- same as CROSS JOIN T as t2
-- FROM  T as t1 CROSS JOIN T as t2;
-- FROM  T as t1, T as t2(a2, b2, c2, d2); -- postgresql only
FROM T as t1, (SELECT a as a2, b as b2, c as c2, d as d2 FROM T) as t2;

SELECT onetwo.num, t.*
FROM (VALUES ('1'), ('2')) AS onetwo(num), T as t
WHERE onetwo.num = '2';

SELECT t.*
FROM T as t
-- WHERE t.a * 10 = t.d;
-- WHERE t.c; -- postgresql only, it has a boolean type
-- WHERE t.c = 1;
WHERE t.d IS NULL;

-- SELECT t.d, t.d IS NULL, t.d = NULL -- postgresql only
-- FROM T as t;
-- NOTE: t.d = NULL -> always UNKNOWN (NULL), regardless of t.d 
SELECT
    t.d,
    CASE WHEN t.d IS NULL THEN 1 ELSE 0 END AS [d_is_null],
    CASE
        WHEN t.d = NULL THEN 1
        WHEN NOT (t.d = NULL) THEN 0
        ELSE NULL
    END AS [d_equals_null]
FROM T AS t;

SELECT t1.a, t1.b + ',' + t2.b as b1b2, t2.a
FROM T as t1, T as t2
WHERE t1.a BETWEEN t2.a - 1 AND t2.a + 1;

SELECT 2 + (SELECT t.d AS _
            FROM T as t
            WHERE t.a = 2) AS "The Answer";

SET SHOWPLAN_TEXT ON;
GO

-- EXPLAIN -- postgresql
SELECT t1.*
FROM T as t1
WHERE t1.b <> (SELECT t2.b
               FROM T as t2
               WHERE t1.a = t2.a);
GO

SET SHOWPLAN_TEXT OFF;
GO

SELECT t.*
FROM T as t
-- ORDER BY t.d ASC;
-- ORDER BY t.d ASC NULLS FIRST; -- postgresql only
ORDER BY t.b DESC, t.c;

SELECT t.*, t.d / t.a AS ratio
FROM T as t
ORDER BY ratio;

SELECT t.*
FROM T as t
ORDER BY t.a DESC
OFFSET 1 ROWS
FETCH NEXT 3 ROWS ONLY;
-- OFFSET 1 LIMIT 3; --postgresql only

-- SELECT DISTINCT ON (t.c) t.* -- postgresql only
-- FROM T as t
-- ORDER BY t.c, t.d;
WITH ranked AS (
  SELECT t.*,
         ROW_NUMBER() OVER (
            PARTITION BY t.c
            ORDER BY t.d
         ) AS rn
  FROM T as t
)
SELECT a,b,c,d
FROM ranked
WHERE rn = 1;

SELECT COUNT(*)       AS [#rows],
       COUNT(t.d)     AS [#d],
       SUM(t.d)       AS [sum_d],
       MAX(t.b)       AS [max(b)],
      --  bool_and(t.c)  AS "all_c",
      MIN(CAST(t.c as INT)) AS [all_c], -- t.c is bit, so if any bits are 0 meaning the and will be false, min returns 0 which is false
      --  bool_or(t.d = 30) AS "some_d=30"
      MAX(
        CASE
          WHEN t.d = 30 THEN 1
          WHEN t.c <> 30 THEN 0
          ELSE NULL
        END
      ) AS [some_d=30]
FROM T as t
WHERE 1 = 1;
-- WHERE 1 = 0;

-- SELECT string_agg(t.a :: text, ',' ORDER BY t.d) AS "all a" -- postgresql
SELECT STRING_AGG(CAST(t.a AS VARCHAR(MAX)), ',')
       WITHIN GROUP (ORDER BY t.d) AS [all a]
FROM T as t;

SELECT * from T;

-- SELECT SUM(t.d) FILTER (WHERE t.c = 1) AS [picky], -- postgresql
SELECT SUM(CASE WHEN t.c = 1 THEN t.d END) AS [picky],
       SUM(t.d)                        AS [don't care]
FROM T as t;

-- simple pivoting (swap rows for columns)
SELECT SUM(CASE WHEN t.b = 'x' THEN t.d END) AS [sum_d in region x],
       SUM(CASE WHEN t.b = 'y' THEN t.d END) AS [sum_d in region y],
       SUM(CASE WHEN t.b NOT IN ('x','y') THEN t.d END) AS [sum_d elsewhere]
FROM T as t;

SELECT COUNT(DISTINCT t.c) AS [distinct non-null],
       COUNT(t.c)          AS [non-null]
FROM T as t;

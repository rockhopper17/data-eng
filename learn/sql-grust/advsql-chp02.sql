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

SELECT t.b                 AS [group],
       COUNT(*)            AS [size],
       SUM(t.d)            AS [sum_d],
       CASE WHEN MAX(t.a % 2) = 0 THEN 1 ELSE 0 END AS [all_even], -- max a mod 2 returns 0 iff all a's mod 2 are 0 hence all even
       STRING_AGG(CAST(t.a AS VARCHAR(MAX)), ';') AS [all_a]
FROM T as t
GROUP BY t.b
-- HAVING COUNT(*) > 2;

SELECT t.a % 2 AS [a_odd],
       COUNT(*) AS [size]
FROM T as t
GROUP BY t.a % 2;

SELECT t.b AS [group],
       t.a % 2 AS [a_odd]
FROM T as t
GROUP BY t.b, t.a % 2; -- could be more groups but all x's are even and all y's are odd so still only two rows in results

-- SELECT t.*
SELECT t.b
-- SELECT 1 as q, t.b
FROM T as t
WHERE t.c = 1
  -- UNION ALL  -- all rows included (bag semantics)
  -- UNION       -- this removes duplicates (set semantics)
  -- EXCEPT ALL -- postgresql only
  EXCEPT
-- SELECT t.*
SELECT t.b
-- SELECT 2 as q, t.b
FROM T as t
WHERE NOT t.c = 1;

DROP TABLE IF EXISTS prehistoric;
CREATE TABLE prehistoric (class        VARCHAR(256),
                          [herbivore?] BIT,
                          legs         INT,
                          species      VARCHAR(256));

INSERT INTO prehistoric VALUES
  ('mammalia',  1, 2, 'Megatherium'),
  ('mammalia',  1, 4, 'Paraceratherium'),
  ('mammalia', 0, 2, NULL),           -- no known bipedal carnivores
  ('mammalia', 0, 4, 'Sabretooth'),
  ('reptilia',  1, 2, 'Iguanodon'),
  ('reptilia',  1, 4, 'Brachiosaurus'),
  ('reptilia', 0, 2, 'Velociraptor'),
  ('reptilia', 0, 4, NULL);           -- no known quadropedal carnivores

SELECT * FROM prehistoric;

-- postgresql allows the string_agg in the grouping sets, sql server doesn't
-- SELECT p.class,
--        p.[herbivore?],
--        p.legs,
--        STRING_AGG(p.species, ', ') AS species
-- FROM prehistoric as p
-- GROUP BY GROUPING SETS ((class), ([herbivore?]), [legs]);

-- idomatic UNION ALL method
SELECT p.class,
       NULL AS [herbivore?],
       NULL AS legs,
       STRING_AGG(p.species, ', ') AS species
FROM prehistoric as p
GROUP BY p.class

UNION ALL

SELECT NULL,
       p.[herbivore?],
       NULL,
       STRING_AGG(p.species, ', ')
FROM prehistoric as p
GROUP BY p.[herbivore?]

UNION ALL

SELECT NULL,
       NULL,
       p.legs,
       STRING_AGG(p.species, ', ')
FROM prehistoric as p
GROUP BY p.legs;

-- CTE way from Gemini
-- caveat: species is deduplicated w the grouping by, so if there are multiple rows of the same species
--         in the table this will not be totally accurate
WITH GroupedData AS (
  SELECT class,
         [herbivore?],
         legs,
         species
        --  GROUPING(class) AS is_class_null,
        --  GROUPING([herbivore?]) AS is_herbivore_null,
        --  GROUPING(legs) AS is_legs_null
  FROM prehistoric
  GROUP BY GROUPING SETS ((class), ([herbivore?]), (legs)), species
)
SELECT class,
       [herbivore?],
       legs,
       STRING_AGG(species, ', ') AS species
FROM GroupedData
GROUP BY class, [herbivore?], legs;

-- ROLLUP, same aggrgate issue with string_agg so this way is postgresql only
-- SELECT p.class,
--        p.[herbivore?],
--        p.legs,
--        STRING_AGG(p.species, ', ') AS species
-- FROM prehistoric as p
-- GROUP BY ROLLUP (class, [herbivore?], legs);

-- ROLLUP with the CTE and GROUPING columns
WITH GroupedData AS (
  SELECT class,
         [herbivore?],
         legs,
         species,
         GROUPING(class) AS g_class,
         GROUPING([herbivore?]) AS g_herbivore,
         GROUPING(legs) AS g_legs
  FROM prehistoric
  GROUP BY ROLLUP ((class), ([herbivore?]), (legs)), species
)
SELECT class,
       [herbivore?],
       legs,
       STRING_AGG(species, ', ') AS species
FROM GroupedData
GROUP BY class, [herbivore?], legs, g_class, g_herbivore, g_legs;


SELECT STRING_AGG(species, ', ') AS species
FROM prehistoric as p
GROUP BY (); -- same as no group by

-- ROLLUP, same aggrgate issue with string_agg so this way is postgresql only
-- SELECT p.class,
--        p.[herbivore?],
--        p.legs,
--        STRING_AGG(p.species, ', ') AS species
-- FROM prehistoric as p
-- GROUP BY CUBE (class, [herbivore?], legs);

WITH GroupedData AS (
  SELECT class,
         [herbivore?],
         legs,
         species,
         GROUPING(class) AS g_class,
         GROUPING([herbivore?]) AS g_herbivore,
         GROUPING(legs) AS g_legs
  FROM prehistoric
  GROUP BY CUBE ((class), ([herbivore?]), (legs)), species
)
SELECT class,
       [herbivore?],
       legs,
       STRING_AGG(species, ', ') AS species
FROM GroupedData
GROUP BY class, [herbivore?], legs, g_class, g_herbivore, g_legs;

--------------------------------------------------------------------------------------
-- asignment 1
--------------------------------------------------------------------------------------

-- (2)
DROP TABLE IF EXISTS R;
CREATE TABLE R(a INT, b INT);

INSERT INTO R VALUES
  -- (1,2),
  (2,2),
  (1,2),
  (2,3),
  (2,1);

SELECT * FROM R;

-- Q1 --
SELECT r.a, COUNT(*) as c
FROM R as r
WHERE r.b <> 3
GROUP BY r.a;

-- Q2 --
SELECT r.a, COUNT(*) as c
FROM R as r
GROUP BY r.a
-- HAVING EVERY(r.b <> 3)  -- postgresql only
HAVING COUNT(CASE WHEN r.b = 3 THEN 1 END) = 0;
-- HAVING MAX(CASE WHEN r.b = 3 THEN 1 ELSE 0 END) = 0;

-- (3) --
DROP TABLE IF EXISTS production_steps;
CREATE TABLE production_steps (
  -- product_name     CHAR(20) NOT NULL,
  product_name     NVARCHAR(20) NOT NULL, -- need this for the space representation char U+2423 OPEN BOX in DS␣II
  step             INT      NOT NULL,
  completion_date  DATE,  -- null means incomplete
  PRIMARY KEY (product_name, step)
);
INSERT INTO production_steps VALUES
('TIE', 1, '1977/03/02'), ('AT-AT', 1, '1978/01/03' ), (N'DS␣II', 1, NULL ),
('TIE', 2, '1977/12/29'), ('AT-AT', 2, NULL         ), (N'DS␣II', 2, '1979/05/26'),
                                                       (N'DS␣II', 3, '1979/04/04');
SELECT * FROM production_steps;

SELECT p.product_name AS [complete]
FROM production_steps AS p
GROUP BY p.product_name
HAVING COUNT(CASE WHEN p.completion_date IS NULL THEN 1 END) = 0;

-- (4) --
DROP TABLE IF EXISTS A, B;
CREATE TABLE A (
  [row] INT,
  [col] INT,
  [val] INT,
  PRIMARY KEY([row], [col])
);
-- CREATE TABLE B (LIKE A); -- postgresql only
CREATE TABLE B (
  [row] INT,
  [col] INT,
  [val] INT,
  PRIMARY KEY([row], [col])
);

-- INSERT INTO A ([row],[col],[val])
-- VALUES (1,1,1), (1,2,2),
--        (2,1,3), (2,2,4);
-- INSERT INTO B ([row],[col],[val])
-- VALUES (1,1,1), (1,2,2), (1,3,1),
--        (2,1,2), (2,2,1), (2,3,2);

-- missing entries
INSERT INTO A ([row],[col],[val])
VALUES (1,1,1), (1,2,3),
       (2,3,7);
INSERT INTO B ([row],[col],[val])
VALUES (1,1,4),          (1,3,8),
       (2,1,1), (2,2,1), (2,3,10),
       (3,1,3), (3,2,6);

SELECT * FROM A;
SELECT * FROM B;

WITH IndividualOps AS (
  SELECT a.[row] AS i,
        a.[col] as k,
        b.[col] as j,
        a.[val] as Aik,
        b.[val] as Bkj,
        a.[val] * b.[val] as AikBkj
  FROM A AS a INNER JOIN B AS b
    ON a.[col] = b.[row]
)
SELECT res.i, res.j, SUM(res.AikBkj) as [val]
FROM IndividualOps AS res
GROUP BY res.i, res.j
ORDER BY res.i, res.j;
-- ======================================================================
-- ======================================================================

-- PostgreSQL only --
-- SELECT DISTINCT ON ([∑d]) 1 AS branch, NOT t.c AS [¬c], SUM(t.d) AS [∑d]
-- FROM   T AS t
-- WHERE  t.b = 'x'
-- GROUP BY [¬c]
-- HAVING SUM(t.d) > 0

--   UNION ALL

-- SELECT DISTINCT ON ([∑d]) 2 AS branch, NOT t.c AS [¬c], SUM(t.d) AS [∑d]
-- FROM   T AS t
-- WHERE  t.b = 'x'
-- GROUP BY [¬c]
-- HAVING SUM(t.d) > 0

-- ORDER BY branch
-- OFFSET 0
-- LIMIT  7;

-- SET SHOWPLAN_TEXT ON;
SET SHOWPLAN_TEXT OFF;
GO

WITH CombinedBranches AS (
  -- branch 1 --
  SELECT
    1 AS branch,
    ~t.c AS [¬c],
    SUM(t.d) AS [∑d],
    ROW_NUMBER() OVER (
      PARTITION BY SUM(t.d)
      ORDER BY (SELECT NULL)
    ) AS rn
  FROM T as t
  WHERE t.b = 'x'
  GROUP BY ~t.c
  HAVING SUM(t.d) > 0

  UNION ALL

  -- branch 2 --
  SELECT
    2 AS branch,
    ~t.c AS [¬c],
    SUM(t.d) AS [∑d],
    ROW_NUMBER() OVER (
      PARTITION BY SUM(t.d)
      ORDER BY (SELECT NULL)
    ) AS rn
  FROM T as t
  WHERE t.b = 'x'
  GROUP BY ~t.c
  HAVING SUM(t.d) > 0
)
SELECT branch, [¬c], [∑d]
FROM CombinedBranches
WHERE rn = 1
ORDER BY branch
OFFSET 0 ROWS FETCH NEXT 7 ROWS ONLY;


DROP TABLE IF EXISTS dinosaurs;
CREATE TABLE dinosaurs (species text, height float, length float, legs int);

INSERT INTO dinosaurs(species, height, length, legs) VALUES
  ('Ceratosaurus',      4.0,   6.1,  2),
  ('Deinonychus',       1.5,   2.7,  2),
  ('Microvenator',      0.8,   1.2,  2),
  ('Plateosaurus',      2.1,   7.9,  2),
  ('Spinosaurus',       2.4,  12.2,  2),
  ('Tyrannosaurus',     7.0,  15.2,  2),
  ('Velociraptor',      0.6,   1.8,  2),
  ('Apatosaurus',       2.2,  22.9,  4),
  ('Brachiosaurus',     7.6,  30.5,  4),
  ('Diplodocus',        3.6,  27.1,  4),
  ('Supersaurus',      10.0,  30.5,  4),
  ('Albertosaurus',     4.6,   9.1,  NULL),  -- Bi-/quadropedality is
  ('Argentinosaurus',  10.7,  36.6,  NULL),  -- unknown for these species.
  ('Compsognathus',     0.6,   0.9,  NULL),  --
  ('Gallimimus',        2.4,   5.5,  NULL),  -- Try to infer pedality from
  ('Mamenchisaurus',    5.3,  21.0,  NULL),  -- their ratio of body height
  ('Oviraptor',         0.9,   1.5,  NULL),  -- to length.
  ('Ultrasaurus',       8.1,  30.5,  NULL);  --

SELECT * FROM dinosaurs;

WITH bodies(legs, shape) AS (
  SELECT d.legs, AVG(d.height / d.length) AS shape
  FROM dinosaurs AS d
  WHERE d.legs IS NOT NULL
  GROUP BY d.legs
)
-- SELECT * FROM bodies;
SELECT d.species, d.height, d.length,
  (SELECT TOP 1 b.legs
   FROM bodies AS b
   ORDER BY abs(b.shape - d.height / d.length)) AS legs
FROM dinosaurs AS d
WHERE d.legs IS NULL

  UNION ALL

SELECT d.*
FROM dinosaurs AS d
WHERE d.legs IS NOT NULL;

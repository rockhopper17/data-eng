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

DROP TABLE POINT_01;
CREATE TABLE point_01
(
id INTEGER PRIMARY KEY AUTOINCREMENT,
x DOUBLE,
y DOUBLE
);
-- popolo ID tabella
INSERT INTO point_01
WITH RECURSIVE
  cnt(id) AS (
     SELECT 1
     UNION ALL
     SELECT id + 1
     FROM cnt
     LIMIT 100000)
SELECT id,0,0 FROM cnt;
-- aggiorno tabella con i punti casuali usando bounding box del poligono
UPDATE point_01
SET x = x +(select (0.5 - RANDOM()/CAST(-9223372036854775808 AS REAL)/ 2)*(extent_max_x - extent_min_x) + extent_min_x
FROM "vector_layers_statistics" WHERE id=point_01.id AND table_name = 'poly');
UPDATE point_01
SET y = y +(select (0.5 - RANDOM()/CAST(-9223372036854775808 AS REAL)/ 2)*(extent_max_y - extent_min_y) + extent_min_y
FROM "vector_layers_statistics" WHERE id=point_01.id AND table_name = 'poly');
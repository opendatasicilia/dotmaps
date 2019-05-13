SELECT DropGeoTable('point');

create table x as
WITH RECURSIVE
  cnt(x) AS (
     SELECT (0.5 - RANDOM() / CAST(-9223372036854775808 AS REAL) / 2)*(13.452028 - 13.243295 ) + 13.243295
     UNION ALL
     SELECT (0.5 - RANDOM() / CAST(-9223372036854775808 AS REAL) / 2)*(13.452028 - 13.243295 ) + 13.243295
     FROM cnt
     LIMIT 10000
  )
SELECT x FROM cnt;

create table y as
WITH RECURSIVE
  cnt(y) AS (
     SELECT (0.5 - RANDOM() / CAST(-9223372036854775808 AS REAL) / 2)*(38.224614 - 38.049991 ) + 38.049991
     UNION ALL
     SELECT (0.5 - RANDOM() / CAST(-9223372036854775808 AS REAL) / 2)*(38.224614 - 38.049991 ) + 38.049991 
     FROM cnt
     LIMIT 10000
  )
SELECT y FROM cnt;

CREATE TABLE "point" AS 
SELECT makepoint ( CAST (x AS FLOAT), CAST (y AS float), 4326) FROM x,y WHERE x.rowid=y.rowid;
SELECT RecoverGeometryColumn('point', 'geom',4326, 'POINT', 'XY');

SELECT DropGeoTable('x');
SELECT DropGeoTable('y');

-- https://stackoverflow.com/questions/23785143/need-help-adding-random-float-in-sqlite/23785593#23785593

-- creo SpatialIndex
SELECT 'Creazione indice spaziale su ', 'point','geom',
coalesce(checkspatialindex('point','geom'),CreateSpatialIndex('point','geom'));
SELECT 'Creazione indice spaziale su ', 'poly','geom',
coalesce(checkspatialindex('poly','geom'),CreateSpatialIndex('poly','geom'));

-- creo tabella clippata e assegnare cir_id ai punti circa 8 sec
CREATE TABLE point_cir_id AS
SELECT pt.*,pl."cir_id"
FROM poly pl, point pt
WHERE ST_Intersects (pl.geom, pt.geom) = 1 AND pt.rowid IN (SELECT rowid 
			FROM SpatialIndex 
			WHERE f_table_name = 'point' AND search_frame = pl.geom);
SELECT RecoverGeometryColumn('point_clip', 'geom',4326, 'POINT', 'XY');

SELECT UpdateLayerStatistics('poly');
-- creo una tabella vuota che conterrà i random point
CREATE TABLE point_01
(id INTEGER PRIMARY KEY AUTOINCREMENT,cir_id INTEGER);
-- popolo ID tabella
INSERT INTO point_01
WITH RECURSIVE
  cnt(id) AS ( SELECT 1 UNION ALL SELECT id + 1 FROM cnt LIMIT 1000)
SELECT id,0 FROM cnt;
-- aggiorno tabella con i punti casuali usando bounding box del poligono
SELECT AddGeometryColumn ('point_01','geom',4326,'POINT','XY');
UPDATE point_01 SET
geom = (SELECT makepoint (
CAST ((select (0.5 - RANDOM()/CAST(-9223372036854775808 AS REAL)/ 2)*(extent_max_x - extent_min_x) + extent_min_x
FROM "vector_layers_statistics" WHERE id=point_01.id AND table_name = 'poly') AS REAL),
CAST ((select (0.5 - RANDOM()/CAST(-9223372036854775808 AS REAL)/ 2)*(extent_max_y - extent_min_y) + extent_min_y
FROM "vector_layers_statistics" WHERE id=point_01.id AND table_name = 'poly') AS REAL), 4326) WHERE id=point_01.id);
SELECT 'Creazione indice spaziale su ', 'point_01','geom',
coalesce(checkspatialindex('point_01','geom'),CreateSpatialIndex('point_01','geom'));
-- associo cir_id ad ogni punto
UPDATE point_01 SET
cir_id = (SELECT pl.cir_id
FROM poly pl, point_01 pt
WHERE id=point_01.id AND pt.rowid IN (SELECT rowid FROM SpatialIndex 
			WHERE f_table_name = 'point_01' AND search_frame = pl.geom)
                  and ST_Intersects (pl.geom, pt.geom) = 1);
-- calcello i punti fuori poligono
DELETE FROM point_01 WHERE CIR_ID IS NULL;
-- conteggio punti nel poligono
SELECT count(*) FROM point_01;
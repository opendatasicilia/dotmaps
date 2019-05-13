#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# bounding box
xmin=13.243295
xmax=13.452028
ymin=38.049991
ymax=38.224614

numeroPunti=100000
numeroPuntiRandom=$(echo "$numeroPunti *3" | bc)

# numero di punti totale da produrre
result=$(
    python3 <<EOF
import numpy
# genera una matrice di numeroPuntiRandom di righe per una colonna, per le x
random_float_arrayLon = numpy.random.uniform($xmin, $xmax, size=($numeroPuntiRandom, 1))
numpy.savetxt("$folder/x.csv", random_float_arrayLon, delimiter=",",fmt='%1.6f')
# genera una matrice di numeroPuntiRandom di righe per una colonna, per le y
random_float_arrayLat = numpy.random.uniform($ymin, $ymax, size=($numeroPuntiRandom, 1))
numpy.savetxt("$folder/y.csv", random_float_arrayLat, delimiter=",",fmt='%1.6f')
EOF
)

rm "$folder"/punti.csv
echo "longitude,latitude" >>"$folder"/punti.csv
paste -d "," "$folder"/x.csv "$folder"/y.csv >>"$folder"/punti.csv
rm $folder/x.csv
rm $folder/y.csv

mapshaper -i format=csv "$folder"/punti.csv -points x=longitude y=latitude -clip "$folder"/poly.shp -o format=csv "$folder"/puntiClip.csv

mlr -I --csv head -n "$numeroPunti" "$folder"/puntiClip.csv


#ogr2ogr -f "ESRI Shapefile" selection_point.shp punti.shp -dialect sqlite -sql "SELECT * FROM punti LIMIT $numeroPunti"

#ogr2ogr -f "ESRI Shapefile" selection_point.shp punti.geojson -dialect sqlite -sql "SELECT point.Geometry FROM punti point, 'poly.shp'.poly polygon WHERE ST_Contains(polygon.geometry, point.geometry) LIMIT $numeroPunti"

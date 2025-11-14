#!/bin/bash
# Génère les gabarits gpkg pour chacune des zones de projection couvertes à partir :
# - du fichier GPKG vide : typeppr_codegasparppr-vide.gpkg
# - du fichier SQL template de génération des tables du standard : typeppr_codegasparppr.sql


for srs_id in 2154 2975 4471 2972 4467 5490
do
  echo "Generating gabarits-$srs_id ..."
  cat prefixeppr.sql | sed -e "s/\$SRS_ID/$srs_id/g" > $srs_id/prefixeppr-$srs_id.sql
  cp prefixeppr-vide.gpkg $srs_id/prefixeppr-$srs_id.gpkg
  cd $srs_id
  echo "exec sqlite3 prefixeppr-$srs_id.gpkg < prefixeppr-$srs_id.sql"
  sqlite3 prefixeppr-$srs_id.gpkg < prefixeppr-$srs_id.sql
  cd ..
done

/**
 * # ANNEXE E - Code SQL pour la création du gabarit Geopackage
 *
 * Cette annexe comporte les instructions SQL permettant de créer les tables de données [décrites dans ce standard](#tables-du-standard) et de les indexer dans un fichier Geopackage.
 * La variable 4467 doit être remplacé par l'indentifiant du srs correspondant à la zone de projection du jeu de données (ex: "2154" pour la France Métropolitaine )
 * 
 */
/**
 * création de la structure GeoPackage de référence (1.2)
 */
PRAGMA application_id = 1196437808;
PRAGMA user_version = 10200;

/**
 * Création des tables de métadonnées du GeoPackage
 */ 

/* Table: gpkg_spatial_ref_sys */
CREATE TABLE gpkg_spatial_ref_sys (
  srs_name TEXT NOT NULL,
  srs_id INTEGER NOT NULL PRIMARY KEY,
  organization TEXT NOT NULL,
  organization_coordsys_id INTEGER NOT NULL,
  definition TEXT NOT NULL,
  description TEXT
);

/* Table: gpkg_contents */
CREATE TABLE gpkg_contents (
  table_name TEXT NOT NULL PRIMARY KEY,
  data_type TEXT NOT NULL,
  identifier TEXT UNIQUE,
  description TEXT DEFAULT '',
  last_change DATETIME NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  min_x DOUBLE,
  min_y DOUBLE,
  max_x DOUBLE,
  max_y DOUBLE,
  srs_id INTEGER,
  CONSTRAINT fk_gc_r_srs_id FOREIGN KEY (srs_id)
    REFERENCES gpkg_spatial_ref_sys(srs_id)
);

/* Table: gpkg_geometry_columns */
CREATE TABLE gpkg_geometry_columns (
  table_name TEXT NOT NULL,
  column_name TEXT NOT NULL,
  geometry_type_name TEXT NOT NULL,
  srs_id INTEGER NOT NULL,
  z TINYINT NOT NULL,
  m TINYINT NOT NULL,
  CONSTRAINT pk_geom_cols PRIMARY KEY (table_name, column_name),
  CONSTRAINT fk_gc_tn FOREIGN KEY (table_name)
    REFERENCES gpkg_contents(table_name),
  CONSTRAINT fk_gc_srs FOREIGN KEY (srs_id)
    REFERENCES gpkg_spatial_ref_sys(srs_id)
);


/* Table: gpkg_extensions */
CREATE TABLE gpkg_extensions (
  table_name TEXT,
  column_name TEXT,
  extension_name TEXT NOT NULL,
  definition TEXT NOT NULL,
  scope TEXT NOT NULL,
  CONSTRAINT ge_pk PRIMARY KEY (table_name, column_name, extension_name)
);


/* Table: gpkg_metadata */
CREATE TABLE gpkg_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  md_scope TEXT NOT NULL DEFAULT 'dataset',
  md_standard_uri TEXT NOT NULL,
  mime_type TEXT NOT NULL DEFAULT 'text/xml',
  metadata TEXT NOT NULL DEFAULT ''
);

/* Table: gpkg_metadata_reference */
CREATE TABLE gpkg_metadata_reference (
  reference_scope TEXT NOT NULL,
  table_name TEXT,
  column_name TEXT,
  row_id_value INTEGER,
  timestamp DATETIME NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  md_file_id INTEGER NOT NULL,
  md_parent_id INTEGER,
  CONSTRAINT fk_gmr_md FOREIGN KEY (md_file_id)
    REFERENCES gpkg_metadata(id),
  CONSTRAINT fk_gmr_parent FOREIGN KEY (md_parent_id)
    REFERENCES gpkg_metadata(id)
);

/* Ajout des tables gpkg_metadata et gpkg_metadata_reference dans la table gpkg_extensions */
INSERT INTO gpkg_extensions VALUES 
  /* (table_name,column_name,extension_name,definition,scope) */
  ('gpkg_metadata',null,'gpkg_metadata','http://www.geopackage.org/spec140/#extension_metadata','read-write'),
  ('gpkg_metadata_reference',null,'gpkg_metadata','http://www.geopackage.org/spec140/#extension_metadata','read-write')
 ;
DELETE from gpkg_metadata ;
DELETE from gpkg_metadata_reference ;



/**
 * Insertion des systèmes de coordonnées dans la table gpkg_spatial_ref_sys
 */

INSERT INTO gpkg_spatial_ref_sys VALUES 
  /* "EPSG:4326" imposé par GeoPackage*/
  ('WGS84',4326,'EPSG',4326, 'GEOGCRS["WGS 84",ENSEMBLE["World Geodetic System 1984 ensemble",MEMBER["World Geodetic System 1984 (Transit)",ID["EPSG",1166]],MEMBER["World Geodetic System 1984 (G730)",ID["EPSG",1152]],MEMBER["World Geodetic System 1984 (G873)",ID["EPSG",1153]],MEMBER["World Geodetic System 1984 (G1150)",ID["EPSG",1154]],MEMBER["World Geodetic System 1984 (G1674)",ID["EPSG",1155]],MEMBER["World Geodetic System 1984 (G1762)",ID["EPSG",1156]],MEMBER["World Geodetic System 1984 (G2139)",ID["EPSG",1309]],MEMBER["World Geodetic System 1984 (G2296)",ID["EPSG",1383]],ELLIPSOID["WGS 84",6378137,298.257223563,LENGTHUNIT["metre",1,ID["EPSG",9001]],ID["EPSG",7030]],ENSEMBLEACCURACY[2],ID["EPSG",6326]],CS[ellipsoidal,2,ID["EPSG",6422]],AXIS["Geodetic latitude (Lat)",north],AXIS["Geodetic longitude (Lon)",east],ANGLEUNIT["degree",0.0174532925199433,ID["EPSG",9102]],ID["EPSG",4326]]','Monde'),
  /* "-1" imposé par GeoPackage pour les systèmes de référence cartésiens non définis*/
  ('Undefined cartesian',-1,'NONE',-1, 'undefined','undefined Cartesian coordinate reference system'),
  /* "0" imposé par GeoPackage pour les systèmes de référence géographiques non définis*/
  ('Undefined geographic',0,'NONE',0, 'undefined','undefined geographic coordinate reference system'),
  /* valeurs pour le système de référence de coordonnées du territoire*/
  ('Universal transverse Mercator fuseau 21 nord (RGSPM06U21)',4467,'EPSG',4467, 'PROJCRS["RGSPM06 / UTM zone 21N",BASEGEOGCRS["RGSPM06",DATUM["Reseau Geodesique de Saint Pierre et Miquelon 2006",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]],ID["EPSG",4463]],CONVERSION["UTM zone 21N",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433],ID["EPSG",8801]],PARAMETER["Longitude of natural origin",-57,ANGLEUNIT["degree",0.0174532925199433],ID["EPSG",8802]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1],ID["EPSG",8805]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1],ID["EPSG",8806]],PARAMETER["False northing",0,LENGTHUNIT["metre",1],ID["EPSG",8807]]],CS[Cartesian,2],AXIS["(E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["(N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["St Pierre and Miquelon - onshore and offshore."],BBOX[43.41,-57.1,47.37,-55.9]],ID["EPSG",4467]]','Saint-Pierre-et-Miquelon')
 ;


/** 
 * 
 * Création de la table `[PrefixePPR]_procedure`
 */

CREATE TABLE prefixeppr_procedure ( 
  
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codeprocedure TEXT(22) NOT NULL UNIQUE, 
  libelleprocedure TEXT NOT NULL, 
  typeprocedure TEXT(10) NOT NULL,
  CONSTRAINT fk_procedure_typeprocedure FOREIGN KEY (typeprocedure) REFERENCES typeprocedure(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_procedure','attributes','prefixeppr_procedure','Table Procedure PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))/*(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')*/,NULL,NULL,NULL,NULL,NULL)
 ;

/**
 * 
 * Création de la table `[PrefixePPR]_revise`
 */



CREATE TABLE prefixeppr_revise ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codeprocrevisante TEXT(22) NOT NULL, 
  codeprocrevisee TEXT(22) NOT NULL,
  /* CONSTRAINT pk_revise PRIMARY KEY (codeprocrevisante,codeprocrevisee),*/
  CONSTRAINT fk_revise_codeprocrevisante FOREIGN KEY (codeprocrevisante) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_revise_codeprocrevisee FOREIGN KEY (codeprocrevisee) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_revise','attributes','prefixeppr_revise','Table Revise PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;

/**
 * 
 * Création de la table `[PrefixePPR]_perimetre_s`
 */
CREATE TABLE prefixeppr_perimetre_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  idperimetre TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  etatprocedure TEXT(10) NOT NULL, 
  dateetat DATE NOT NULL,
  geom MULTIPOLYGON NOT NULL,
  CONSTRAINT fk_perimetre_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_perimetre_s_etatprocedure FOREIGN KEY (etatprocedure) REFERENCES typeetatprocedure(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_perimetre_s','features','prefixeppr_perimetre_s','Table Perimetre Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns  */
INSERT INTO gpkg_geometry_columns VALUES 
  ('prefixeppr_perimetre_s','geom','MULTIPOLYGON',4467,0,0)
 ;


/**
 * 
 * Création de la table `[PrefixePPR]_perimetreetude_s`
 */

CREATE TABLE prefixeppr_perimetreetude_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idperimetre TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  etatprocedure TEXT(10) NOT NULL, 
  dateetat DATE NOT NULL,
  geom MULTIPOLYGON NOT NULL,
  CONSTRAINT fk_perimetreetude_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_perimetreetude_s_etatprocedure FOREIGN KEY (etatprocedure) REFERENCES typeetatprocedure(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_perimetreetude_s','features','prefixeppr_perimetreetude_s','Table PerimetreEtude Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns  */
INSERT INTO gpkg_geometry_columns VALUES 
  ('prefixeppr_perimetreetude_s','geom','MULTIPOLYGON',4467,0,0)
 ;

/**
 * 
 * Création de la table `[PrefixePPR]_referenceinternet`
 */


CREATE TABLE prefixeppr_referenceinternet ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  adresse TEXT NOT NULL UNIQUE, 
  codeprocedure TEXT(22) NOT NULL, 
  nomressource TEXT, 
  typereference TEXT(2) NOT NULL,
  description TEXT, 
  CONSTRAINT fk_referenceinternet_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_referenceinternet_typereference FOREIGN KEY (typereference) REFERENCES typereference(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_referenceinternet','attributes','prefixeppr_referenceinternet','Table Référence Internet PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;

/**
 * Création de la table `[PrefixePPR]_zonealeareference_[CodeAlea]_s`
 */



CREATE TABLE prefixeppr_zonealeareference_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2) NOT NULL,
  occurrence INTEGER, 
  description TEXT, 
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeareference_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeareference_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeareference_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeareference_codealea_s','features','prefixeppr_zonealeareference_codealea_s','Table Zone Alea de Reference Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeareference_codealea_s','geom','POLYGON',4467,0,0)
 ;

/**
 *
 * Création de la table `[PrefixePPR]_zonealeaecheance100ans_[CodeAlea]_s`
 */
CREATE TABLE prefixeppr_zonealeaecheance100ans_117_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2) NOT NULL,
  occurrence INTEGER, 
  description TEXT, 
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeaecheance100ans_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeaecheance100ans_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeaecheance100ans_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeaecheance100ans_117_s','features','prefixeppr_zonealeaecheance100ans_117_s','Table Zone Alea Echéance 100 ans Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeaecheance100ans_117_s','geom','POLYGON',4467,0,0)
 ;

/**
 *
 * Création de la table `[PrefixePPR]_zonealeaexceptionnel_[CodeAlea]_s`
 */
CREATE TABLE prefixeppr_zonealeaexceptionnel_14_s ( 
  
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2),
  occurrence INTEGER, 
  description TEXT, 
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeaexceptionnel_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeaexceptionnel_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeaexceptionnel_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeaexceptionnel_14_s','features','prefixeppr_zonealeaexceptionnel_14_s','Table Zone Alea Exceptionnel Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeaexceptionnel_14_s','geom','POLYGON',4467,0,0)
 ;

/**
 *
 * Création de la table `[PrefixePPR]_zonealeanaturelsynthese_s`
 */
CREATE TABLE prefixeppr_zonealeanaturelsynthese_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2),
  occurrence INTEGER, 
  description TEXT, 
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeanaturelsynthese_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeanaturelsynthese_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeanaturelsynthese_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeanaturelsynthese_s','features','prefixeppr_zonealeanaturelsynthese_s','Table Zone Alea Naturel Synthese Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeanaturelsynthese_s','geom','POLYGON',4467,0,0)
 ;

/**
  * Création de la table `[PrefixePPR]_zonemultialeanaturel`
  */
CREATE TABLE prefixeppr_zonemultialeanaturel (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  typealea TEXT(3) NOT NULL,
  idzonealea TEXT(15) NOT NULL,
  niveaualea TEXT(2),
  occurrence INTEGER,
  CONSTRAINT uk_zonemultialeanaturel_typealea_idzonealea UNIQUE (typealea,idzonealea),
  CONSTRAINT fk_zonemultialeanaturel_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonemultialeanaturel_zonealea FOREIGN KEY (idzonealea) REFERENCES prefixeppr_zonealeanaturelsynthese_s(idzonealea),
  CONSTRAINT fk_zonemultialeanaturel_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_zonemultialeanaturel','attributes','prefixeppr_zonemultialeanaturel','Table des aléas naturels multiples',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/** 
  * Création de la table `[PrefixePPR]_zonealeatechnorapide_[CodeAlea]_s`
  */
CREATE TABLE prefixeppr_zonealeatechnorapide_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2) NOT NULL,
  occurrence TEXT(1), 
  description TEXT, 
  intensite TEXT(2),
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeatechnorapide_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeatechnorapide_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeatechnorapide_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonealeatechnorapide_codealea_occurrence FOREIGN KEY (occurrence) REFERENCES typeclasseprobatechno(code),
  CONSTRAINT fk_zonealeatechnorapide_codealea_intensite FOREIGN KEY (intensite) REFERENCES typeintensitetechno(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeatechnorapide_codealea_s','features','prefixeppr_zonealeatechnorapide_codealea_s','Table Zone Alea Technologique Rapide Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeatechnorapide_codealea_s','geom','POLYGON',4467,0,0)
 ;



/**
  * Création de la table `[PrefixePPR]_zonealeatechnolent_[CodeAlea]_s`
  */
CREATE TABLE prefixeppr_zonealeatechnolent_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2),
  occurrence TEXT(1), 
  description TEXT, 
  intensite TEXT(2) NOT NULL,
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeatechnolent_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeatechnolent_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeatechnolent_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonealeatechnolent_codealea_occurrence FOREIGN KEY (occurrence) REFERENCES typeclasseprobatechno(code),
  CONSTRAINT fk_zonealeatechnolent_codealea_intensite FOREIGN KEY (intensite) REFERENCES typeintensitetechno(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeatechnolent_codealea_s','features','prefixeppr_zonealeatechnolent_codealea_s','Table Zone Alea technologique Lent Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeatechnolent_codealea_s','geom','POLYGON',4467,0,0)
 ;


/**
  * Création de la table `[PrefixePPR]_zonealeatechnoprojection_[CodeAlea]_s`
  */
CREATE TABLE prefixeppr_zonealeatechnoprojection_214_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2),
  occurrence TEXT(1), 
  description TEXT, 
  intensite TEXT(2) NOT NULL,
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeatechnoprojection_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeatechnoprojection_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeatechnoprojection_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonealeatechnoprojection_codealea_occurrence FOREIGN KEY (occurrence) REFERENCES typeclasseprobatechno(code),
  CONSTRAINT fk_zonealeatechnoprojection_codealea_intensite FOREIGN KEY (intensite) REFERENCES typeintensitetechno(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeatechnoprojection_214_s','features','prefixeppr_zonealeatechnoprojection_214_s','Table Zone Alea Technologique Projection Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeatechnoprojection_214_s','geom','POLYGON',4467,0,0)
 ;

/**
 *
 * Création de la table `[PrefixePPR]_zonealeatechnosynthese_s`
 */
CREATE TABLE prefixeppr_zonealeatechnosynthese_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonealea TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2),
  occurrence TEXT(1), 
  description TEXT, 
  intensite TEXT(2),
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonealeatechnosynthese_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonealeatechnosynthese_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonealeatechnosynthese_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonealeatechnosynthese_occurrence FOREIGN KEY (occurrence) REFERENCES typeclasseprobatechno(code),
  CONSTRAINT fk_zonealeatechnosynthese_intensite FOREIGN KEY (intensite) REFERENCES typeintensitetechno(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonealeatechnosynthese_s','features','prefixeppr_zonealeatechnosynthese_s','Table Zone Alea Technologique Synthese Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonealeatechnosynthese_s','geom','POLYGON',4467,0,0)
 ;

/**
  * Création de la table `[PrefixePPR]_zonemultialeatechno`
  */
CREATE TABLE prefixeppr_zonemultialeatechno (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  typealea TEXT(3) NOT NULL,
  idzonealea TEXT(15) NOT NULL,
  niveaualea TEXT(2), 
  occurrence TEXT(1), 
  intensite TEXT(2),
  CONSTRAINT uk_zonemultialeatechno_typealea_idzonealea UNIQUE (typealea,idzonealea),
  CONSTRAINT fk_zonemultialeatechno_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonemultialeatechno_zonealea FOREIGN KEY (idzonealea) REFERENCES prefixeppr_zonealeatechnosynthese_s(idzonealea),
  CONSTRAINT fk_zonemultialeatechno_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonemultialeatechno_occurrence FOREIGN KEY (occurrence) REFERENCES typeclasseprobatechno(code),
  CONSTRAINT fk_zonemultialeatechno_intensite FOREIGN KEY (intensite) REFERENCES typeintensitetechno(code)

);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_zonemultialeatechno','attributes','prefixeppr_zonemultialeatechno','Table des aléas technologiques multiples',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;




/**
 * Création de la table `[PrefixePPR]_zoneprotegee_[CodeAlea]_s`
 */
CREATE TABLE prefixeppr_zoneprotegee_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzoneprotegee TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveauprotection TEXT,
  occurrence TEXT, 
  description TEXT, 
  idouvrageprotecteur_s TEXT(50),
  idouvrageprotecteur_l TEXT(50),
  idouvrageprotecteur_p TEXT(50),
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zoneprotegee_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zoneprotegee_codealea_idouvrageprotecteur_s FOREIGN KEY (idouvrageprotecteur_s) REFERENCES prefixeppr_ouvrageprotecteur_codealea_s(idouvrageprotecteur),
  CONSTRAINT fk_zoneprotegee_codealea_idouvrageprotecteur_l FOREIGN KEY (idouvrageprotecteur_l) REFERENCES prefixeppr_ouvrageprotecteur_codealea_l(idouvrageprotecteur),
  CONSTRAINT fk_zoneprotegee_codealea_idouvrageprotecteur_p FOREIGN KEY (idouvrageprotecteur_p) REFERENCES prefixeppr_ouvrageprotecteur_codealea_p(idouvrageprotecteur),
  CONSTRAINT fk_zoneprotegee_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zoneprotegee_codealea_s','features','prefixeppr_zoneprotegee_codealea_s','Table Zone Protégée Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zoneprotegee_codealea_s','geom','POLYGON',4467,0,0)
 ;

/**
 * Création de la table `[PrefixePPR]_zonedangerspecifique_[CodeAlea]_s`
 */
CREATE TABLE prefixeppr_zonedangerspecifique_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonedanger TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  typealea TEXT(3) NOT NULL,
  niveaualea TEXT(2) NOT NULL,
  typesuralea TEXT(2) NOT NULL,
  description TEXT, 
  idouvrageprotecteur_s TEXT(50),
  idouvrageprotecteur_l TEXT(50),
  idouvrageprotecteur_p TEXT(50),
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonedangerspecifique_codealea_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonedangerspecifique_codealea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zonedangerspecifique_codealea_niveaualea FOREIGN KEY (niveaualea) REFERENCES typeniveaualea(code),
  CONSTRAINT fk_zonedangerspecifique_codealea_idouvrageprotecteur_s FOREIGN KEY (idouvrageprotecteur_s) REFERENCES prefixeppr_ouvrageprotecteur_codealea_s(idouvrageprotecteur),
  CONSTRAINT fk_zonedangerspecifique_codealea_idouvrageprotecteur_l FOREIGN KEY (idouvrageprotecteur_l) REFERENCES prefixeppr_ouvrageprotecteur_codealea_l(idouvrageprotecteur),
  CONSTRAINT fk_zonedangerspecifique_codealea_idouvrageprotecteur_p FOREIGN KEY (idouvrageprotecteur_p) REFERENCES prefixeppr_ouvrageprotecteur_codealea_p(idouvrageprotecteur),
  CONSTRAINT fk_zonedangerspecifique_codealea_typesuralea FOREIGN KEY (typesuralea) REFERENCES typesuralea(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonedangerspecifique_codealea_s','features','prefixeppr_zonedangerspecifique_codealea_s','Table Zone de danger Spécifique Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonedangerspecifique_codealea_s','geom','POLYGON',4467,0,0)
 ;


/**
 * Création des tables `[PrefixePPR]_ouvrageprotecteur_[CodeAlea]_s|l|p`
 */

/* Table Multipolygon */
CREATE TABLE prefixeppr_ouvrageprotecteur_codealea_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  idouvrageprotecteur TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT(2) NOT NULL,
  refexterneautre TEXT,
  typeouvrageprotecteur TEXT(2), 
  roleprotection BOOLEAN,
  occurrence TEXT,
  geom MULTIPOLYGON NOT NULL,
  CONSTRAINT fk_ouvrageprotecteur_codealea_s_refexterne FOREIGN KEY (refexterne) REFERENCES typerefexterneouvrage(code),
  CONSTRAINT fk_ouvrageprotecteur_codealea_s_typeouvrage FOREIGN KEY (typeouvrageprotecteur) REFERENCES typeouvrageprotecteur(code)
);
/* Table Linestring */
CREATE TABLE prefixeppr_ouvrageprotecteur_codealea_l ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idouvrageprotecteur TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT(2) NOT NULL,
  refexterneautre TEXT,
  typeouvrageprotecteur TEXT(2), 
  roleProtection BOOLEAN,
  occurrence TEXT,
  geom MULTILINESTRING NOT NULL,
  CONSTRAINT fk_ouvrageprotecteur_codealea_l_refexterne FOREIGN KEY (refexterne) REFERENCES typerefexterneouvrage(code),
  CONSTRAINT fk_ouvrageprotecteur_codealea_l_typeouvrage FOREIGN KEY (typeouvrageprotecteur) REFERENCES typeouvrageprotecteur(code)
);
/* Table Point */
CREATE TABLE prefixeppr_ouvrageprotecteur_codealea_p ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idouvrageprotecteur TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT(2) NOT NULL,
  refexterneautre TEXT,
  typeouvrageprotecteur TEXT(2), 
  roleprotection BOOLEAN,
  occurrence TEXT,
  geom MULTIPOINT NOT NULL,
  CONSTRAINT fk_ouvrageprotecteur_codealea_p_refexterne FOREIGN KEY (refexterne) REFERENCES typerefexterneouvrage(code),
  CONSTRAINT fk_ouvrageprotecteur_codealea_p_typeouvrage FOREIGN KEY (typeouvrageprotecteur) REFERENCES typeouvrageprotecteur(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_ouvrageprotecteur_codealea_s','features','prefixeppr_ouvrageprotecteur_codealea_s','Table Ouvrage de protection Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_ouvrageprotecteur_codealea_l','features','prefixeppr_ouvrageprotecteur_codealea_l','Table Ouvrage de protection Linéaire PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_ouvrageprotecteur_codealea_p','features','prefixeppr_ouvrageprotecteur_codealea_p','Table Ouvrage de protection Ponctuel PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_ouvrageprotecteur_codealea_s','geom','MULTIPOLYGON',4467,0,0),
  ('prefixeppr_ouvrageprotecteur_codealea_l','geom','MULTILINESTRING',4467,0,0),
  ('prefixeppr_ouvrageprotecteur_codealea_p','geom','MULTIPOINT',4467,0,0)
 ;


/**
 * Création des tables `[PrefixePPR]_originerisque_s|l|p`
 */

/* Table Multipolygon */
CREATE TABLE prefixeppr_originerisque_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idoriginerisque TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  nom TEXT NOT NULL, 
  geom MULTIPOLYGON NOT NULL,
  CONSTRAINT fk_originerisque_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Table Linestring */
CREATE TABLE prefixeppr_originerisque_l ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idoriginerisque TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  nom TEXT NOT NULL, 
  geom MULTILINESTRING NOT NULL,
  CONSTRAINT fk_originerisque_l_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Table Point */
CREATE TABLE prefixeppr_originerisque_p ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idoriginerisque TEXT(15) NOT NULL UNIQUE,
  /* idoriginerisque TEXT(15) NOT NULL PRIMARY KEY, */
  codeprocedure TEXT(22) NOT NULL,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  nom TEXT NOT NULL, 
  geom MULTIPOINT NOT NULL,
  CONSTRAINT fk_originerisque_p_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_originerisque_s','features','prefixeppr_originerisque_s','Table Origine du risque Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_originerisque_l','features','prefixeppr_originerisque_l','Table Origine du risque Linéaire PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_originerisque_p','features','prefixeppr_originerisque_p','Table Origine du risque Ponctuel PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_originerisque_s','geom','MULTIPOLYGON',4467,0,0),
  ('prefixeppr_originerisque_l','geom','MULTILINESTRING',4467,0,0),
  ('prefixeppr_originerisque_p','geom','MULTIPOINT',4467,0,0)
 ;


/**
 * Création des tables `[PrefixePPR]_enjeu_s|l|p`
 */

/* Table Multipolygon */
CREATE TABLE prefixeppr_enjeu_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idenjeu TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  codeprocedure TEXT(22) NOT NULL,
  nomenjeu TEXT NOT NULL, 
  codeenjeu TEXT NOT NULL, 
  nomenclatureenjeu TEXT NOT NULL,
  dateenjeu DATE NOT NULL, 
  geom MULTIPOLYGON NOT NULL,
  CONSTRAINT fk_enjeu_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Table Linestring */
CREATE TABLE prefixeppr_enjeu_l ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idenjeu TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  codeprocedure TEXT(22) NOT NULL,
  nomenjeu TEXT NOT NULL, 
  codeenjeu TEXT NOT NULL, 
  nomenclatureenjeu TEXT NOT NULL,
  dateenjeu DATE NOT NULL, 
  geom MULTILINESTRING NOT NULL,
  CONSTRAINT fk_enjeu_l_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Table Point */
CREATE TABLE prefixeppr_enjeu_p ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idenjeu TEXT(15) NOT NULL UNIQUE,
  idrefexterne TEXT(50), 
  refexterne TEXT,
  codeprocedure TEXT(22) NOT NULL,
  nomenjeu TEXT NOT NULL, 
  codeenjeu TEXT NOT NULL, 
  nomenclatureenjeu TEXT NOT NULL,
  dateenjeu DATE NOT NULL, 
  geom MULTIPOINT NOT NULL,
  CONSTRAINT fk_enjeu_p_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_enjeu_s','features','prefixeppr_enjeu_s','Table Enjeux Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_enjeu_l','features','prefixeppr_enjeu_l','Table Enjeux Linéaire PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_enjeu_p','features','prefixeppr_enjeu_p','Table Enjeux Ponctuel PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_enjeu_s','geom','MULTIPOLYGON',4467,0,0),
  ('prefixeppr_enjeu_l','geom','MULTILINESTRING',4467,0,0),
  ('prefixeppr_enjeu_p','geom','MULTIPOINT',4467,0,0)
 ;


/**
 * Création de la table `[PrefixePPR]_typevulnerabilite`
 */
CREATE TABLE prefixeppr_typevulnerabilite ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idenjeu_s TEXT(15),
  idenjeu_l TEXT(15),
  idenjeu_p TEXT(15),
  nom TEXT NOT NULL, 
  description TEXT, 
  valeur TEXT NOT NULL,
  CONSTRAINT fk_typevulnerabilite_idenjeu_s FOREIGN KEY (idenjeu_s) REFERENCES prefixeppr_enjeu_s(idenjeu),
  CONSTRAINT fk_typevulnerabilite_idenjeu_l FOREIGN KEY (idenjeu_l) REFERENCES prefixeppr_enjeu_l(idenjeu),
  CONSTRAINT fk_typevulnerabilite_idenjeu_p FOREIGN KEY (idenjeu_p) REFERENCES prefixeppr_enjeu_p(idenjeu)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_typevulnerabilite','attributes','prefixeppr_typevulnerabilite','Table Type Vulnerabilites PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Création des tables `[PrefixePPR]_zonereglementaireurba_s|l|p`
 */
/* Table Multipolygon */
CREATE TABLE prefixeppr_zonereglementaireurba_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  existemesuresobligatoires BOOLEAN, 
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonereglementaireurba_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementaireurba_s_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementurba(code)
);
/* Table Linestring */
CREATE TABLE prefixeppr_zonereglementaireurba_l ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  existemesuresobligatoires BOOLEAN, 
  geom LINESTRING NOT NULL,
  CONSTRAINT fk_zonereglementaireurba_l_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementaireurba_l_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementurba(code)
);
/* Table Point */
CREATE TABLE prefixeppr_zonereglementaireurba_p ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  existemesuresobligatoires BOOLEAN, 
  geom POINT NOT NULL,
  CONSTRAINT fk_zonereglementaireurba_p_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementaireurba_p_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementurba(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonereglementaireurba_s','features','prefixeppr_zonereglementaireurba_s','Table Zone Réglementaire Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_zonereglementaireurba_l','features','prefixeppr_zonereglementaireurba_l','Table Zone Réglementaire Linéaire PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_zonereglementaireurba_p','features','prefixeppr_zonereglementaireurba_p','Table Zone Réglementaire Ponctuel PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonereglementaireurba_s','geom','POLYGON',4467,0,0),
  ('prefixeppr_zonereglementaireurba_l','geom','LINESTRING',4467,0,0),
  ('prefixeppr_zonereglementaireurba_p','geom','POINT',4467,0,0)
 ;


/**
 * Création des tables `[PrefixePPR]_zonereglementairefoncier_s|l|p`
 */
/* Table Multipolygon */
CREATE TABLE prefixeppr_zonereglementairefoncier_s ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  geom POLYGON NOT NULL,
  CONSTRAINT fk_zonereglementairefoncier_s_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementairefoncier_s_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementfoncier(code)
);
/* Table Linestring */
CREATE TABLE prefixeppr_zonereglementairefoncier_l ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  geom LINESTRING NOT NULL,
  CONSTRAINT fk_zonereglementairefoncier_l_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementairefoncier_l_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementfoncier(code)
);
/* Table Point */
CREATE TABLE prefixeppr_zonereglementairefoncier_p ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idzonereglementaire TEXT(15) NOT NULL UNIQUE,
  codeprocedure TEXT(22) NOT NULL, 
  codezonereglement TEXT NOT NULL, 
  libellezonereglement TEXT NOT NULL, 
  typereglement TEXT(2) NOT NULL,
  geom POINT NOT NULL,
  CONSTRAINT fk_zonereglementairefoncier_p_codeprocedure FOREIGN KEY (codeprocedure) REFERENCES prefixeppr_procedure(codeprocedure),
  CONSTRAINT fk_zonereglementairefoncier_p_typereglement FOREIGN KEY (typereglement) REFERENCES typereglementfoncier(code)
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES
  ('prefixeppr_zonereglementairefoncier_s','features','prefixeppr_zonereglementairefoncier_s','Table Zone Réglementaire Foncier Surfacique PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_zonereglementairefoncier_l','features','prefixeppr_zonereglementairefoncier_l','Table Zone Réglementaire Foncier Linéaire PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467),
  ('prefixeppr_zonereglementairefoncier_p','features','prefixeppr_zonereglementairefoncier_p','Table Zone Réglementaire Foncier Ponctuel PPR : typeppr codegaspar',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,4467)
 ;
/* Ajout à la table gpkg_geometry_columns */
INSERT INTO gpkg_geometry_columns VALUES
  ('prefixeppr_zonereglementairefoncier_s','geom','POLYGON',4467,0,0),
  ('prefixeppr_zonereglementairefoncier_l','geom','LINESTRING',4467,0,0),
  ('prefixeppr_zonereglementairefoncier_p','geom','POINT',4467,0,0)
 ;

/**
  * Création de la table `[PrefixePPR]_zoneregmultialea`
  */
CREATE TABLE prefixeppr_zoneregmultialea (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  idzoneregmultialea TEXT(15) NOT NULL UNIQUE,
  typealea TEXT(3) NOT NULL,
  idzonereglementaire_u_s TEXT(15), 
  idzonereglementaire_u_l TEXT(15),
  idzonereglementaire_u_p TEXT(15),
  idzonereglementaire_f_s TEXT(15),
  idzonereglementaire_f_l TEXT(15),
  idzonereglementaire_f_p TEXT(15),
  CONSTRAINT fk_zoneregmultialea_typealea FOREIGN KEY (typealea) REFERENCES typealea(code),
  CONSTRAINT fk_zoneregmultialea_zonereg_us FOREIGN KEY (idzonereglementaire_u_s) REFERENCES prefixeppr_zonereglementaireurba_s(idzonereglementaire),
  CONSTRAINT fk_zoneregmultialea_zonereg_ul FOREIGN KEY (idzonereglementaire_u_l) REFERENCES prefixeppr_zonereglementaireurba_l(idzonereglementaire),
  CONSTRAINT fk_zoneregmultialea_zonereg_up FOREIGN KEY (idzonereglementaire_u_p) REFERENCES prefixeppr_zonereglementaireurba_p(idzonereglementaire),
  CONSTRAINT fk_zoneregmultialea_zonereg_fs FOREIGN KEY (idzonereglementaire_f_s) REFERENCES prefixeppr_zonereglementairefoncier_s(idzonereglementaire),
  CONSTRAINT fk_zoneregmultialea_zonereg_fl FOREIGN KEY (idzonereglementaire_f_l) REFERENCES prefixeppr_zonereglementairefoncier_l(idzonereglementaire),
  CONSTRAINT fk_zoneregmultialea_zonereg_fp FOREIGN KEY (idzonereglementaire_f_p) REFERENCES prefixeppr_zonereglementairefoncier_p(idzonereglementaire),
  CHECK (
    (idzonereglementaire_u_s IS NOT NULL AND idzonereglementaire_u_l IS NULL AND idzonereglementaire_u_p IS NULL AND idzonereglementaire_f_s IS NULL AND idzonereglementaire_f_l IS NULL AND idzonereglementaire_f_p IS NULL ) OR
    (idzonereglementaire_u_s IS NULL AND idzonereglementaire_u_l IS NOT NULL AND idzonereglementaire_u_p IS NULL AND idzonereglementaire_f_s IS NULL AND idzonereglementaire_f_l IS NULL AND idzonereglementaire_f_p IS NULL ) OR
    (idzonereglementaire_u_s IS NULL AND idzonereglementaire_u_l IS NULL AND idzonereglementaire_u_p IS NOT NULL AND idzonereglementaire_f_s IS NULL AND idzonereglementaire_f_l IS NULL AND idzonereglementaire_f_p IS NULL ) OR
    (idzonereglementaire_u_s IS NULL AND idzonereglementaire_u_l IS NULL AND idzonereglementaire_u_p IS NULL AND idzonereglementaire_f_s IS NOT NULL AND idzonereglementaire_f_l IS NULL AND idzonereglementaire_f_p IS NULL ) OR
    (idzonereglementaire_u_s IS NULL AND idzonereglementaire_u_l IS NULL AND idzonereglementaire_u_p IS NULL AND idzonereglementaire_f_s IS NULL AND idzonereglementaire_f_l IS NOT NULL AND idzonereglementaire_f_p IS NULL ) OR
    (idzonereglementaire_u_s IS NULL AND idzonereglementaire_u_l IS NULL AND idzonereglementaire_u_p IS NULL AND idzonereglementaire_f_s IS NULL AND idzonereglementaire_f_l IS NULL AND idzonereglementaire_f_p IS NOT NULL )
  )
);
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('prefixeppr_zoneregmultialea','attributes','prefixeppr_zoneregmultialea','Table des zonages reglementaires multi aléas',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Création de la table d'enumeration `typeprocedure`
 */
CREATE TABLE typeprocedure (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(10) NOT NULL UNIQUE,
  libelle TEXT(80) NOT NULL
);
INSERT INTO typeprocedure VALUES 
  (1,'PPRN','Plan de Prévention des Risques Naturels'),
  (2,'PPRN-I','Plan de Prévention des Risques Naturels Inondation'),
  (3,'PPRN-L','Plan de Prévention des Risques Naturels Littoral'),
  (4,'PPRN-Mvt','Plan de Prévention des Risques Naturels Mouvement de Terrain'),
  (5,'PPRN-Multi','Plan de Prévention des Risques Naturels Multirisques'),
  (6,'PPRN-S','Plan de Prévention des Risques Naturels Séisme'),
  (7,'PPRN-Av','Plan de Prévention des Risques Naturels Avalanches'),
  (8,'PPRN-Ev','Plan de Prévention des Risques Naturels Eruption volcanique'),
  (9,'PPRN-If','Plan de Prévention des Risques Naturels Incendie de forêt'),
  (10,'PPRN-Cy','Plan de Prévention des Risques Naturels Cyclone'),
  (11,'PPRN-Rad','Plan de Prévention des Risques Naturels Radon'),
  (12,'PPRT','Plan de Prévention des Risques Technologiques')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeprocedure','attributes','typeprocedure','Enumeration valeurs possibles de types de procédures',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typeetatprocedure`
 */
CREATE TABLE typeetatprocedure (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(10) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typeetatprocedure VALUES 
  (1,'DEB_PRG','Programmation'),
  (2,'DEB_MTG','Montage'),
  (3,'PRESCRIT','Prescrit'),
  (4,'PAC','Porté à connaissance'),
  (5,'PROROGE','Prorogé'),
  (6,'ANTICIPE','Anticipé'),
  (7,'APPROUVE','Approuvé'),
  (8,'ANNULE','Annulé'),
  (9,'ABROGE','Abrogé')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeetatprocedure','attributes','typeetatprocedure','Enumeration valeurs possibles des états de procédures',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Création de la table d'enumeration `typereference`
 */
CREATE TABLE typereference (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typereference VALUES 
  (1,'01','Règlement non approuvé'),
  (2,'02','Règlement approuvé'),
  (3,'03','Zonage réglementaire non approuvé'),
  (4,'04','Zonage réglementaire approuvé'),
  (5,'05','Cartes approuvées'),
  (6,'06','Autres cartes'),
  (7,'99','Autres')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typereference','attributes','typereference','Enumeration valeurs possibles de types de références internet',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Création de la table d'enumeration `typealea`
 */
CREATE TABLE typealea (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(3) NOT NULL UNIQUE,
  libelle TEXT(150) NOT NULL
);
INSERT INTO typealea VALUES 
  (1,'112','Risque Naturel ; Inondation ; Par une crue à débordement lent de cours d''eau'),
  (2,'113','Risque Naturel ; Inondation ; Par une crue torrentielle ou à montée rapide de cours d''eau'),
  (3,'114','Risque Naturel ; Inondation ; Par ruissellement et coulée de boue'),
  (4,'115','Risque Naturel ; Inondation ; Par lave torrentielle (torrent et talweg) '),
  (5,'116','Risque Naturel ; Inondation ; Par remontées de nappes naturelles'),
  (6,'117','Risque Naturel ; Inondation ; Par submersion marine'),
  (7,'121','Risque Naturel ; Mouvement de terrain ; Affaissement et effondrements d''origine anthropique (anciennes carrières souterraines, hors mines)'),
  (8,'122','Risque Naturel ; Mouvement de terrain ; Affaissement et effondrements d''origine naturelle (cavités souterraines)'),
  (9,'123','Risque Naturel ; Mouvement de terrain ; Eboulement ou chutes de pierres et de blocs'),
  (10,'124','Risque Naturel ; Mouvement de terrain ; Glissement de terrain'),
  (11,'125','Risque Naturel ; Mouvement de terrain ; Avancée dunaire'),
  (12,'126','Risque Naturel ; Mouvement de terrain ; Recul du trait de côte et de falaises'),
  (13,'127','Risque Naturel ; Mouvement de terrain ; Tassement différentiels'),
  (14,'13','Risque Naturel ; Séisme'),
  (15,'14','Risque Naturel ; Avalanche'),
  (16,'15','Risque Naturel ; Eruption volcanique'),
  (17,'16','Risque Naturel ; Feu de forêt'),
  (18,'171','Risque Naturel ; Phénomène lié à l''atmosphère ; Cyclone / Ouragan'),
  (19,'172','Risque Naturel ; Phénomène lié à l''atmosphère ; Tempête et grains (vent)'),
  (20,'174','Risque Naturel ; Phénomène lié à l''atmosphère ; Foudre'),
  (21,'175','Risque Naturel ; Phénomène lié à l''atmosphère ; Grêle'), 
  (22,'176','Risque Naturel ; Phénomène lié à l''atmosphère ; Neige et pluies verglaçantes'),
  (23,'18','Risque Naturel ; Radon'),
  (24,'19','Risque Naturel ; Tsunami'),
  (25,'211','Risque technologique ; Risque Industriel ; Effet thermique'),
  (26,'212','Risque technologique ; Risque Industriel ; Effet de surpression'), 
  (27,'213','Risque technologique ; Risque Industriel ; Effet toxique '),
  (28,'214','Risque technologique ; Risque Industriel ; Effet de projection'),
  (29,'22','Risque technologique ; Nucléaire'),
  (30,'23','Risque technologique ; Rupture de barrage'),
  (31,'24','Risque technologique ; Transport de marchandises dangereuses'),
  (32,'25','Risque technologique ; Engins de guerre'),
  (33,'311','Risque minier ; Affaissement minier ; Effondrements généralisés'), 
  (34,'312','Risque minier ; Affaissement minier ; Effondrements localisés'), 
  (35,'313','Risque minier ; Affaissement minier ; Affaissements progressifs'), 
  (36,'314','Risque minier ; Affaissement minier ; Tassements'), 
  (37,'315','Risque minier ; Affaissement minier ; Glissements ou mouvements de pente'), 
  (38,'316','Risque minier ; Affaissement minier ; Coulées'), 
  (39,'317','Risque minier ; Affaissement minier ; Ecroulements rocheux'), 
  (40,'321','Risque minier ; Inondations de terrains miniers ; Pollution des eaux souterraines et de surface'),
  (41,'322','Risque minier ; Inondations de terrains miniers ; Pollution des sédiments et des sols'),
  (42,'33','Risque minier ; Emissions en surface de gaz de mine'),
  (43,'34','Risque minier ; Echauffement des terrains de dépôts'),
  (44,'999','Risques multiples')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typealea','attributes','typealea','Enumeration valeurs possibles de types d''aléas',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typeniveaualea`
 */
CREATE TABLE typeniveaualea (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typeniveaualea VALUES 
  (1,'00','Nul ou négligeable'),
  (2,'01','Faible'),
  (3,'02','Moyen ou Modéré'),
  (4,'03','Moyen plus'),
  (5,'04','Fort'),
  (6,'05','Fort plus'),
  (7,'06','Très fort ou Majeur'),
  (8,'07','Très fort plus ou aggravé'),
  (9,'99','Autre')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeniveaualea','attributes','typeniveaualea','Enumeration valeurs possibles des niveaux d''aléas',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typesuralea`
 */
CREATE TABLE typesuralea (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typesuralea VALUES 
  (1,'01','bande de précaution'), 
  (2,'02','Bande particulière'),
  (3,'03','Bande particulière chocs de vagues'),
  (4,'04','Bande particulière projection de matériaux'),
  (5,'99','autre')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typesuralea','attributes','typesuralea','Enumeration valeurs possibles de types de suraléas',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typeouvrageprotecteur`
 */
CREATE TABLE typeouvrageprotecteur (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(3) NOT NULL UNIQUE,
  libelle TEXT(100) NOT NULL
);
INSERT INTO typeouvrageprotecteur VALUES 
  (1,'1','Ouvrage ou installation pouvant influencer les inondations'), 
  (2,'11','Ouvrage de protection contre les inondations'),
  (3,'111','Ouvrage appartenant à un systeme d''endiguement'), 
  (4,'112','Amenagement hydraulique'), 
  (5,'119','Autre ouvrage de protection contre les inondations'), 
  (6,'12','Ouvrage ou installation influencant les ecoulements sans fonction de protection'), 
  (7,'2','Ouvrage ou installation pouvant influencer les mouvements de terrain'), 
  (8,'3','Ouvrage ou installation pouvant influencer les chutes de blocs'), 
  (9,'4','Ouvrage ou installation pouvant influencer les avalanches'), 
  (10,'999','Autre ouvrage ou installation pouvant influencer les aléas') 
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeouvrageprotecteur','attributes','typeouvrageprotecteur','Enumeration valeurs possibles de types d''ouvrages de protection',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typerefexterneouvrage`
 */
CREATE TABLE typerefexterneouvrage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typerefexterneouvrage VALUES 
  (1,'01','ROE'), 
  (2,'02','SIOUH II'), 
  (3,'99','autre')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typerefexterneouvrage','attributes','typerefexterneouvrage','Enumeration valeurs possibles de types de référentiels externes pour les ouvrages de protection',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
 * Création de la table d'enumeration `typereglementurba`
 */
CREATE TABLE typereglementurba (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typereglementurba VALUES 
  (1,'01','Prescriptions hors zone d''aléa'),
  (2,'02','Prescriptions'),
  (3,'03','Interdiction'),
  (4,'04','Interdiction stricte'),
  (5,'05','Recommandations'),
  (6,'06','Zones grisées'),
  (7,'07','Zones d''aléa exceptionnel (AE)')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typereglementurba','attributes','typereglementurba','Enumeration valeurs possibles de types de reglementation d''urbanisme',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Création de la table d'enumeration `typereglementfoncier`
 */
CREATE TABLE typereglementfoncier (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typereglementfoncier VALUES 
  (1,'01','Délaissement possible'),
  (2,'02','Expropriation possible')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typereglementfoncier','attributes','typereglementfoncier','Enumeration valeurs possibles de types de reglementation foncières',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/** 
  * Création de la table d'enumeration `typeintensitetechno`
  */
CREATE TABLE typeintensitetechno (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(2) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typeintensitetechno VALUES 
  (1,'Z1','Extrèmement grave'),
  (2,'Z2','Très grave'),
  (3,'Z3','Grave'),
  (4,'Z4','Significatif'),
  (5,'Z5','Indirect')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeintensitetechno','attributes','typeintensitetechno','Enumeration valeurs possibles de types d''instensité technologique',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/** 
  * Création de la table d'enumeration `typeclasseprobatechno`
  */
CREATE TABLE typeclasseprobatechno (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(1) NOT NULL UNIQUE,
  libelle TEXT(50) NOT NULL
);
INSERT INTO typeclasseprobatechno VALUES 
  (1,'A','Evènement courant'),
  (2,'B','Evènement probable'),
  (3,'C','Evènement improbable'),
  (4,'D','Evènement très improbable'),
  (5,'E','Evènement possible mais extrêment peu probable')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeclasseprobatechno','attributes','typeclasseprobatechno','Enumeration valeurs possibles de classes de probabilité technologique',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;

/**
  * Création de la table d'énumération `typeenjeupprn`
  */
CREATE TABLE typeenjeupprn (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(6) NOT NULL UNIQUE,
  libelle TEXT(100) NOT NULL
);
INSERT INTO typeenjeupprn VALUES 
  (1,'010000','Espaces urbanisés'),
  (2,'010100','Centres urbains'),
  (3,'010200','Espaces urbanisés hors centres urbains'),
  (4,'020000','Espaces non urbanisés'), 
  (5,'030000','Espaces spécifiques au type d''aléa étudié'),
  (6,'030100','Espaces spécifiques d''activités'),
  (7,'030101','Ports, zones d''activités portuaires et d''activités balnéaires'),
  (8,'030102','Campings et hôtellerie de plein air'),
  (9,'030103','Zones d''activités agricoles spécifiques'),
  (10,'030200','Espaces participants à la limitation des aléas'),
  (11,'030201','Zones d''expansion des crues'),
  (12,'030202','Zones d''atterrissement'),
  (13,'030203','Zones d''interfaces habitat-forêt'),
  (14,'030204','Zones de maintien d''une forêt'),
  (15,'040000','Projets d''aménagement futurs du territoire'),
  (16,'050000','Zone d''habitat'),
  (17,'050100','Zone d''habitat individuel'),
  (18,'050200','Zone d''habitat collectif'),
  (19,'060100','Zone d''activité'),
  (20,'060101','Zone d''industrie'),
  (21,'060102','Service'),
  (22,'060103','Artisanat'),
  (23,'070000','Infrastructures et équipements particuliers'),
  (24,'070100','Etablissements sensibles ou difficilement évacuables'),
  (25,'070200','Equipements stratégiques pour la gestion de crise'),
  (26,'070300','Equipements collectifs de type ERP ou espaces publics ouverts'),
  (27,'070400','Campings et hôtellerie de plein air'),
  (28,'070500','Infrastructures de transport'),
  (29,'070600','Réseaux et équipements sensibles'),
  (30,'080000','Enjeux patrimoniaux, culturels et environnementaux'),
  (31,'999999','Autre') 
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeenjeupprn','attributes','typeenjeupprn','Enumeration valeurs possibles nomenclature enjeux PPRN',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
  * Table d'énumération `typeenjeupprt`
  */
CREATE TABLE typeenjeupprt (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(6) NOT NULL UNIQUE,
  libelle TEXT(100) NOT NULL
);
INSERT INTO typeenjeupprt VALUES 
  (1,'010000','Urbanisation existante'),
  (2,'010100','Habitats'),
  (3,'010200','Activités'),
  (4,'010300','Etablissements à l''origine du risque'),
  (5,'010400','Espaces non urbanisés'),
  (6,'010500','Espaces agricoles'),
  (7,'020000','Etablissements recevant du public (ERP)'),
  (8,'020100','Services de secours'),
  (9,'020200','Bâtiments d''enseignement'),
  (10,'020300','Bâtiments de services publics'),
  (11,'020400','Bâtiments et équipements de loisirs'),
  (12,'020500','Bâtiments de soins'),
  (13,'020600','Grands centres commerciaux'),
  (14,'020700','Petits commerces et services aux particuliers'),
  (15,'020800','Bâtiments religieux'),
  (16,'030000','Infrastructures de transports'),
  (17,'030100','Routes'),
  (18,'030101','Grandes voies structurantes'),
  (19,'030102','Autres voies structurantes'),
  (20,'030103','Voies de dessertes'),
  (21,'030200','Voies ferrées'),
  (22,'030300','Voies navigables '),
  (23,'030400','Itinéraires et stationnements de TMD (Transport de Matières Dangereuses)'),
  (24,'030500','Aéroports'),
  (25,'030600','Gares (routières, ferroviaires, portuaires)'),
  (26,'030700','Modes doux de déplacement (piétons, vélos) '),
  (27,'030800','Transports collectifs (bus, métros, etc.) '),
  (28,'040000','Espaces publics ouverts'),
  (29,'040100','Espaces à usage permanent'),
  (30,'040200','Espaces à usage périodique ou occasionnel'),
  (31,'050000','Ouvrages et équipements d''intérêt général'),
  (32,'050100','Poste EDF'),
  (33,'050200','Central téléphonique'),
  (34,'050300','Poste de détente GDF'),
  (35,'050400','Antenne de téléphonie mobile'),
  (36,'050500','Point de captage d’eau'),
  (37,'050600','Château d''eau, réservoir'),
  (38,'060000','Projets de développement de la commune'),
  (39,'070000','Enjeux environnementaux et patrimoniaux'),
  (40,'999999','Autre')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeenjeupprt','attributes','typeenjeupprt','Enumeration valeurs possibles nomenclature enjeux technologiques',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;



/**
  * Table d'énumération `typeenjeucovadis`
  */
CREATE TABLE typeenjeucovadis (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT(5) NOT NULL UNIQUE,
  libelle TEXT(100) NOT NULL
);
INSERT INTO typeenjeucovadis VALUES 
  (1,'0100','Espace urbanisé'),
  (2,'0101','Espace urbanisé - habitat dense'),
  (3,'0102','Espace urbanisé - habitat peu dense'),
  (4,'0103','Espace urbanisé - habitat diffus'),
  (5,'0104','Espace urbanisé - projet d''urbanisation future'),
  (6,'0105','Espace urbanisé - réserve foncière'),
  (7,'0200','Établissement recevant du public (ERP) '),
  (8,'0201c','ERP J : Structures d''accueil pour personnes âgées et handicapées'),
  (9,'0202c','ERP L : Salles à usage d''audition, de conférences, de réunions, de spectacles'),
  (10,'0203c','ERP M : Magasins de vente, centres commerciaux'),
  (11,'0204c','ERP N : Restaurants et débits de boissons'),
  (12,'0205c','ERP O : Hôtels et pensions de famille'),
  (13,'0206c','ERP P : Salles de danse et salles de jeux'),
  (14,'0207c','ERP R : Établissements d''enseignement, colonies de vacances'),
  (15,'0208c','ERP S : Bibliothèques, centres de documentation et de consultation d''archives'),
  (16,'0209c','ERP T : Salles d''expositions'),
  (17,'0210c','ERP U : Établissements de soins'),
  (18,'0211c','ERP V : Établissements de culte'),
  (19,'0212c','ERP W : Administrations, banques, bureaux'),
  (20,'0213c','ERP X : Établissements sportifs couverts'),
  (21,'0214c','ERP Y : Musées'),
  (22,'0215c','ERP PA : Établissements de plein air'),
  (23,'0216c','ERP CST : Chapiteaux, tentes et structures'),
  (24,'0217c','ERP CG : Structures gonflables'),
  (25,'0218c','ERP OA : Hôtels, restaurants d''altitude'),
  (26,'0219c','ERP REF : Refuges de montagne'),
  (27,'0220c','ERP PS : Parcs de stationnement couverts'),
  (28,'0221c','ERP GA : Gares accessibles au public'),
  (29,'0222c','ERP EF : Établissements flottants'),
  (30,'0300','Espace économique'),
  (31,'0301','Espace économique - zone d''activité industrielle'),
  (32,'0302','Espace économique - zone d''activité commerciale'),
  (33,'0303','Espace économique - zone d''activité future'),
  (34,'0304','Espace économique - zone agricole, ostréicole, mytiliculture, élevage, pisciculture'),
  (35,'0305','Espace économique - zone de camping, mobil-home'),
  (36,'0306','Espace économique - zone aéroportuaire, portuaire'),
  (37,'0307','Espace économique - carrière, gravière'),
  (38,'0308','Établissement employeur'),
  (39,'0400','Espace ouvert recevant du public'),
  (40,'0401','Espace ouvert recevant du public - sport'),
  (41,'0402','Espace ouvert recevant du public - tourisme'),
  (42,'0403','Espace ouvert recevant du public - parking'),
  (43,'0404','Espace ouvert recevant du public - parc d''exposition, foires, rassemblements divers'),
  (44,'0405','Espace ouvert recevant du public - cimetière'),
  (45,'0500','Infrastructure de transport de personnes ou de marchandise'),
  (46,'0501','Infrastructure linéaire - route, voie ferrée, canal'),
  (47,'0502','Infrastructure linéaire en projet'),
  (48,'0503','Infrastructure linéaire - ligne de bus'),
  (49,'0504','Infrastructure linéaire - piste cyclable, voie verte'),
  (50,'0505','Infrastructure linéaire - ligne électrique'),
  (51,'0506','Infrastructure surfacique - gare, aéroport, aérodrome, port'),
  (52,'0507','Infrastructure ponctuelle - gare, arrêt, stationnement TMD'),
  (53,'0600','Ouvrage ou équipement d''intérêt général'),
  (54,'0601','Ouvrage ou équipement d''intérêt général - zone, station de captage'),
  (55,'0602','Ouvrage ou équipement d''intérêt général - station de pompage'),
  (56,'0603','Ouvrage ou équipement d''intérêt général - réservoir, château d''eau'),
  (57,'0604','Ouvrage ou équipement d''intérêt général - canalisation eau'),
  (58,'0605','Ouvrage ou équipement d''intérêt général - poste de relèvement'),
  (59,'0606','Ouvrage ou équipement d''intérêt général - station de traitement, de lagunage'),
  (60,'0607','Ouvrage ou équipement d''intérêt général - barrage, vanne, écluse'),
  (61,'0608','Ouvrage ou équipement d''intérêt général - poste de transformation EDF'),
  (62,'0609','Ouvrage ou équipement d''intérêt général - canalisation matière dangereuse'),
  (63,'0610','Ouvrage ou équipement d''intérêt général - téléphonique, relai, antenne'),
  (64,'0611','Ouvrage ou équipement d''intérêt général - caserne de pompier'),
  (65,'0612','Ouvrage ou équipement d''intérêt général - poste de détente gaz'),
  (66,'0613','Ouvrage ou équipement d''intérêt général - station hydrocarbure'),
  (67,'0614','Ouvrage ou équipement d''intérêt général - décharge, usine d''incinération'),
  (68,'0700','Enjeu environnemental ou patrimonial'),
  (69,'0701','Zone naturelle protégée'),
  (70,'0702','Monument inscrit ou classé au répertoire des monuments historiques'),
  (71,'0703','Parc naturel national, régional'),
  (72,'0704','Zone d''expansion des crues pour les inondations'),
  (73,'0705','Zone naturelle de mouvements de terrain'),
  (74,'9999','Autre enjeu : nature à préciser')
 ;
/* Ajout à la table gpkg_contents */
INSERT INTO gpkg_contents VALUES 
  ('typeenjeucovadis','attributes','typeenjeucovadis','Enumeration valeurs possibles nomenclature enjeux COVADIS',(strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),NULL,NULL,NULL,NULL,NULL)
 ;


/**
 * Métadonnées 
 */

/**
 * Exemple d'insertion de métadonnées de PPR
 */
INSERT INTO gpkg_metadata VALUES (
  1,'dataset','http://www.isotc211.org/2005/gmd', 'text/xml', '<gmd:MD_Metadata><!-- contenu des métadonnées --></gmd:MD_Metadata>'
) ;
INSERT INTO gpkg_metadata_reference VALUES (
  'geopackage', NULL, NULL, NULL, (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')), 1, NULL
);



/**
 * Exemple d'insertion de métadonnées de table
 */
INSERT INTO gpkg_metadata VALUES (
  2,'dataset','http://www.isotc211.org/2005/gmd', 'text/xml', '<gmd:MD_Metadata><!-- contenu des métadonnées --></gmd:MD_Metadata>'
) ;
INSERT INTO gpkg_metadata_reference VALUES (
  'table', 'prefixeppr_zonealeareference_codealea_s', NULL, NULL, (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')), 2, 1
);



# FAQ Standard PPR

Cette page rassemble quelques indications pratiques relatives au standard et l'utilisation des ressources associées.

* [Utilisation des gabarits GeoPackage](#utilisation-des-gabarits-geopackage)
  * [Personnalisation des gabarits pour constituer un PPR](#personnalisation-des-gabarits-pour-constituer-un-ppr)
    * [Méthode 1 : Modification dans le code SQL](#méthode-1--modification-dans-le-code-sql)
    * [Méthode 2 : En utilisant QGiS](#méthode-2--en-utilisant-qgis)
  * [Utilisation des gabarits dans QGiS](#utilisation-des-gabarits-dans-qgis)
* [Conversion COVADIS PPR vers nouveau standard](#conversion-covadis-ppr-vers-nouveau-standard)
* [Erreurs du validateur](#erreurs-du-validateur)

## Utilisation des gabarits GeoPackage

### Personnalisation des gabarits pour constituer un PPR

Les gabarits proposés au format GeoPackage contiennent l'ensemble des tables décrites par le standard et avec un nommage générique :

* pour le nom du gabarit : [prefixeppr]-[code-epsg-territoire].gpkg
* pour les noms de table : \[prefixeppr\]\_nom_de_la_table\_\[suffixe-eventuel-codalea\]\_\[suffixe-type-de- geometrie\]

Pour créer le fichier PPR et les tables souhaitées qu'il va contenir, il convient donc de personnaliser le gabarit en :

1. renommant le fichier à l'aide de l'identifiant GASPAR du PPR comme indiqué [ici](../standard/Document.md#nom-du-fichier-de-livraison) dans le standard ;
2. supprimant les tables qui ne seront pas nécessaire pour le PPR concerné ;
3. renommant les tables qui seront utilisés par le PPR concerné à l'aide du code GASPAR et du code aléa si besoin comme indiqué [ici](../standard/Document.md#nomenclature-des-tables) dans le standard
4. Pour les PPR multi aléas, il pourra aussi être nécessaire de dupliquer certaines tables ayant un suffixe \[codealea\] des gabarits.

Si le renommage du fichier gabarit est facilement réalisable, le renommage et la duplication des tables est plus délicat si l'on veut conserver l'intégrité du fichier GeoPackage et les relations entre tables. On expose ici deux méthodes pour le faire, à privilégier selon l'outillage et les connaissances techniques dont on dispose : (1) directement dans le fichier SQL de création des gabarits ou (2) en utilisant QGiS.

A noter qu'il peut être possible de faire autrement, mais cela n'a pas été testé.

#### Méthode 1 : Modification dans le code SQL

C'est la méthode à privilégier si vous êtes à l'aise en SQL et avez la possibilité de faire tourner le [script de génération des gabarits](./gabarits/genGabarits.sh) qui est sur le github.

Pour cela, la méthode générale est la suivante :

1. clonez le dépot github sur votre machine
2. dans la copie locale du dépot rendez vous dans le répertoire `./ressources/gabarits`
3. ouvrez le fichier [prefixeppr.sql](./gabarits/prefixeppr.sql) qui est le script qui génère toutes les tables des gabarits.
   1. recherchez/remplacez "prefixeppr" par le prefixe de votre PPR ;
   2. supprimez les blocs de code qui créent les tables (et les insère dans les tables gpkg_content et gpkg_geometry_columns) dont vous n'avez pas besoin.
   3. Dupliquez les blocs de code des tables que vous avez besoin de dupliquer (tables d'aléas) et remplacez le suffixe `codealea` par le code alea gaspar correspondant au type d'aléa que vous avez à décrire (112, 117, ...)
4. Une fois le fichier modifié, lancez le script [genGabarits.sh](./gabarits/genGabarits.sh). Celui-ci devrait générer les gabarits GeoPackage avec les noms et les tables que vous avez conservés dans les répertoires 2154, 2972, etc... correspondant au code EPSG du territoire français associé. NB : cette opération nécessite l'installation d'un client bash ([Git bash](https://about.gitlab.com/fr-fr/blog/git-bash/) par exemple) et de [sqlite3](https://sqlite.org/).
5. Prenez le fichier gabarit correspondant au territoire qui vous concerne, renommez le et utilisez le !

#### Méthode 2 : En utilisant QGiS

Si vous avez des difficultés à mettre en oeuvre la méthode précédente, vous pouvez manipuler les tables du gabarit à l'aide de QGiS.

Ce qui suit a été testé avec QGiS v3.44, il conviendra le cas échéant d'adapter les instructions en fonction de la version utilisée.

1. Téléchargez le gabarit qui correspondant à votre territoire depuis le [dépôt Github](./gabarits/) ;
2. Renommez le fichier en fonction du code GASPAR de votre PPR ;
3. Chargez le dans QGiS (drag n drop par exemple) ; sélectionnez toutes les couches proposées et ajoutez les au projet ;

La difficulté avec QGiS est que la manipulation des couches (renommage, copie, suppression) dans le gestionnaire de couches ne modifie pas le fichier GeoPackage sous-jacent (et inversement). Par ailleurs, les contraintes et les relations existantes entre tables (clés étrangères) seront perdues lorsqu'on renomme les tables (cf. [Utilisation des gabarits dans QGiS](#utilisation-des-gabarits-dans-qgis)). La mise à jour des tables de métadonnées du fichier GeoPackage (gpkg_contents, etc...) n'est pas forcément assurée si on ne fait pas attention et le fichier GeoPackage résultant risque d'être incohérent au final. L'outil "Base de données / Gestionnaire BD..." de QGiS permet de réaliser certaines opérations correctement de ce point de vue.

![alt text](./images/db-manager.png)

Je n'ai pas trouvé de méthode plus simple avec QGiS. Si vous en avez n'hésitez pas à l'indiquer en PR ou Issue dans le github pour l'intégrer ici.

4. Avec le Gestionnaire BD, dépliez la partie GeoPackage/nom-gabarit.gpkg et vous retrouvez l'ensemble des tables du fichier. C'est ici que vous allez pouvoir les manipuler de façon pérenne dans le fichier.

![alt text](./images/db-manager-geopackage.png)

   1. **Supprimer une table** : clic droit sur le nom de la table sélectionnez "Effacer..."

   ![alt text](./images/db-manager-effacer.png)

   Cette opération retire bien la table du fichier GeoPackage et la déréférence des tables de métadonnées de GeoPackage.

   **NB** : cette opération ne supprime pas la couche du gestionnaire de couches QGiS. Vous allez devoir aussi la supprimer de ce dernier avec un clic droit > "Supprimer la couche".

   2. **Renommer une table** : clic droit sur le nom de la table sélectionnez "Renommer..." et saisissez le nom de la table.

   Cette opération renomme bien la table du fichier GeoPackage et référence bien le nouveau nom dans les tables de métadonnées de GeoPackage.

   **NB** : cette opération ne renomme pas la couche correspondante dans le gestionnaire de couche. Pour cela, il faut faire à nouveau clic droit > "Ajouter au canevas" pour la couche renommée apparaisse dans le gestionnaire de couche. Ensuite, dans ce dernier, vous devrez supprimer la couche portant encore l'ancien nom avec un clic droit > "Supprimer la couche".

   **NB** : après cette opération, **les relations et contraintes existantes entre la table modifiée et les autres tables du gabarit sont perdues** : la saisie d'entités dans la nouvelle table ne bénéficiera plus de ces contraintes (par exemple choix de valeurs parmi celles déjà présentes dans les tables liées : par exemple table d'énumération).

5. **Dupliquer et renommer une table**" : cette opération nécessite de revenir d'abord au gestionnaire de couches de QGiS.

   1. Dans le gestionnaire de couche : clic droit et choisissez "Dupliquer la couche"
   ![alt text](./images/dupliquer-couche.png)

   2. Pour pérenniser la couche qui a été créée dans le gestionnaire de couches il vous faut l'enregistrer dans le fichier geopackage. Pour cela : clic droit, choisissez "Exporter... > Sauvegarder les Entités sous..."
   ![alt text](./images/sauvegarder-sous.png)

   3. Dans la boite de dialogue qui apparaît, sélectionnez le fichier GeoPackage du gabarit pour y enregistrer la nouvelle couche. A priori il n'y a rien d'autre à modifier dans les options proposées. Cliquez sur OK.
   ![alt text](./images/bdd-enregistrer.png)

   Vous pouvez ensuite retourner dans le gestionnaire de bases de donnés de QGiS pour renommer la table dans le GeoPackage (cf. étapes précédentes).

   **NB** : Ici aussi, après cette opération, **les relations et contraintes existantes entre la couche dupliquée et les autres tables du gabarit sont perdues** : la saisie d'entités dans la nouvelle table ne bénéficiera plus de ces contraintes (par exemple choix de valeurs parmi celles déjà présentes dans les tables liées : par exemple table d'énumération).

### Utilisation des gabarits dans QGiS

Ls gabarits fournis implémentent les liens entre les tables sous forme de clés étrangères. Dans QGiS (mais certainement dans d'autres SIG), ces relations existantes entre tables implémentées dans le gabarit vont imposer un certain ordre pour la saisie :

Presque toutes les tables ont un lien via la clef étrangère `codeProcedure` avec la table `procedure`, il faut en premier saisir
une entité dans la table procedure avec un codeProcedure que vous pourrez saisir sans difficulté.

![alt text](./images/saisie-procedure.png)

Ensuite, la saisie des autres entités fonctionnera car la valeur de codeProcedure de la table Procedure sera proposée, ce qui permettra de faire le lien.

![alt text](./images/fk-procedure.png)

Cela peut apparaître contraignant mais cela permet de conserver le contrôle de cette contrainte lors de la saisie.

Par ailleurs les gabarits comprennent les tables d’énumérations, avec les liens de clefs étrangères des champs énumérés vers ces tables, ce qui facilite la saisie des valeurs énumérées depuis les tables de gabarits.

**NB** : Ces facilités de saisie inhérentes aux contraintes implémentées dans les gabarits sont perdues dès lors que l'on renomme les couches du gabarits dans QGiS (cf. [Personnalisation des gabarits > méthode 2 en utilisant QGiS](#méthode-2--en-utilisant-qgis)). Si on veut les conserver, il convient d'utiliser les couches du gabarit telles quelles pour saisir les entités, puis exporter les entités dans une couche du GeoPackage portant le nom final.

## Conversion COVADIS PPR vers nouveau standard

### Existe-t-il des outils pour convertir des anciens PPR vers le nouveau standard ?

Il n'existe pas d'outil sur étagère permettant de faire la conversion de données PPR conformes au standard COVADIS vers le nouveau standard CNIG PPR.

Cependant :

* Des règles de correspondances entre les deux standards sont documentées dans [l'annexe A du nouveau standard](https://github.com/cnigfr/Geostandards-risques-ppr/blob/master/standard/Document.md#annexe-a---correspondances-avec-les-standards-covadis-ppr-n-et-t) ;
* Des bouts de code (SQL) ou benchmark FME, élaborés lors de la conception du nouveau standard sont disponibles sur le [github du GT Risques](https://github.com/cnigfr/Geostandards-Risques/tree/main/ressources/traduction). Ils sont expérimentaux et nécessitent une adaptation pour être réutilisés.

## Erreurs du validateur

A compléter
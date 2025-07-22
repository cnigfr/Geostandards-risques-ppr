# GéoStandards Risques - Profil applicatif PPR

Ce répertoire contient les éléments constitutifs du standard définissant le profil applicatif des Géostandards Risques pour les procédures d'élaboration de Plans de Prévention des Risques.

- Le fichier [Document.md](./Document.md) contient le contenu littéral du document ;
- le répertoire [ressources/](./ressources) contient les ressources graphiques à inclure dans le document
- le répertoire [modele/](./modele) contient le modèle de document word utilisé pour l'export du standard
- le répertoire [bin/](./bin) comprend les binaires permettant de générer le standard au format word à l'aide de l'outil pandoc.
- le répertoire [diffusion](./diffusion) contient les versions du standard exportées dans les formats de diffusion (docx, pdf, ...)

## Génération d'un document word à partir du dépôt

Avec l'outil [pandoc](https://github.com/jgm/pandoc/releases/tag/3.7.0.2), associé à l'extension [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref/releases/tag/v0.3.20) la ligne de commande suivante permet de générer le standard au format .docx en s'appuyant sur les styles du modèle de document [Modele-styles.docx](./modele/Modele-styles.docx). Le filtre [move-toc.lua](./modele/move-toc.lua) permet de positionner la table des matières à l'endroit voulu dans le document.

```bash
pandoc -s -f markdown -t docx --toc --toc-depth=3 --lua-filter=./modele/move-toc.lua --filter pandoc-crossref -o Geostandards-Risques-PPR-vx.y.docx --reference-doc=./modele/Modele-styles.docx Document.md
```

Le script python suivant permet de supprimer la table des matières intempestive qui a été générée au début du document.

```bash
python ./modele/post-traitement.py Document.docx
```

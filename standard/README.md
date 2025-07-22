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
pandoc -s -f markdown -t docx --toc --toc-depth=3 --lua-filter=./modele/move-toc.lua --filter pandoc-crossref -o Document.docx --reference-doc=./modele/Modele-styles.docx Document.md
```

Le script python suivant permet de supprimer la table des matières intempestive qui a été générée au début du document.

```bash
python ./modele/post-traitement.py Document.docx
```

## Génération du document PDF final

Avec Word (ou OpenOffice), on peut affiner la mise en page et enregistrer le document au format PDF (en n'oubliant pas de générer les signets à partir des titres).

### Ajout de la page de garde

Le fichier [page_de_garde.tex](./page_de_garde.tex) contient la page de garde du document au format LaTex avec une bonne mise en page.

La suite de commandes suivante permet de générer la page de garde au format PDF, et de la fusionner avec le document PDF généré précédemment, à l'aide des outils xelatex et pdfunite de la suite [MikTeX](https://miktex.org/download).

````bash
# Page de garde en PDF
xelatex page_de_garde.tex
# Suppression fichiers temporaires
rm -f page_de_garde.{aux,log,out}
# Fusion des PDFs
pdfunite page_de_garde.pdf Document.pdf Geostandards-Risques-PPR-vx.y.docx
````

Pour plus d'information sur le processus de génération voir la documentation complète [ici](https://github.com/cnigfr/FabriqueStandards/blob/main/StandardsDesStandards/template/templateMarkdown/README.md).

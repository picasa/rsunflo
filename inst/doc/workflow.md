---
title: "Notice d'utilisation du modèle SUNFLO"
output:
  html_document:
    toc: yes
    toc_depth: 2
  pdf_document:
    toc: yes
bibliography: ./files/bibliography.bib
---

Cette notice présente les principales étapes nécessaires pour réaliser une expérimentation numérique avec le modèle SUNFLO.
Selon les questions abordées (démonstration, simulation de réseaux d'essais multilocaux, exploration, ...) le type de plan d'expérience conçu et les outils logiciels utilisés varient considérablement.   

Différentes procédures sont proposées selon le volume de simulation : 
* utilisation locale via une interface graphique (1-10 simulations : [GVLE](#utilisation-locale-via-une-interface-graphique-1-10))
* utilisation distance via une interface web (10-500 simulations : [websim](#utilisation-distance-via-une-interface-web-10-500))
* utilisation locale via un langage de script (10-1M simulations: [rsunflo](#utilisation-locale-via-un-langage-de-script-10-1m))

Pour chacune des ces procédures, 4 étapes successives sont nécessaires : 

1. rassembler les données d'entrées et de paramétrage ([paramétrage](#paramtrage))
2. concevoir le plan de l'expérimentation numérique ([planification](#planification))
3. réaliser les simulations ([simulation](#simulation))
4. organiser les sorties et analyser les données ([analyse](#analyse))

![workflow](files/workflow.png)
**Procédures d'utilisation** : Les traits gris représentent les différentes procédures d'utilisation des outils logiciels. Les cadres gris nécessitent une installation locale des logiciels mentionnés, le cadre bleu permet une utilisation distante, via une interface web. Les chevrons représentent des logiciels et les rectangles, des packages. Les formes arrondies représentent des jeux de données.


# Paramétrage
L'utilisation par défaut de sunflo nécessite 42 paramètres et 5 variables d'entrées répartis en 4 volets : variétes, pédoclimat, conduite de culture et initialisation. Si une partie de ces informations n'est pas renseignée, la simulation échoue.  
Les outils de multi-simulation (rsunflo, websim) fonctionnent avec un ensemble {données d'entrée, version du modèle, type de sorties} fixé.  
L'interface *websim* permet de créer différentes version d'un même modèle informatique utilisant [*VLE+RECORD*](http://www.vle-project.org/wiki/Main_Page). A chaque usage correspond donc une version *ad hoc*,  nommée *patrons de simulation* dans *websim*. Bien que ces patrons peuvent être créés par les utilisateurs dans l'interface, trois patrons sont utilisables pour SUNFLO :

modèle | patron |                 usage                        | paramètres
-------|--------|----------------------------------------------|-----------
SUNFLO | varieto|version par défaut, evaluation variétale      | 42
SUNFLO | gem    |version simplifiée, experimentation numérique | 21
SUNFLO | genotype|paramétrage variétal uniquement |12

Ce mode d'emploi se base sur le patron *varieto*. Le fichier [parameterization.xlsx](parameterization.xlsx) détaille le contenu des patrons de simulation, le détail du paramétrage et propose des valeurs par défaut. 

## Variété
nom | label | unité | référence
----|-------|-------|----------
TDE1|Durée de la phase levée (A2) - initiation florale (E1|°Cd|[@Lecoeur2011]
TDF1|Durée de la phase levée (A2) - floraison (F1)|°Cd|[@Lecoeur2011]
TDM0|Durée de la phase levée (A2) - debut maturité (M0)|°Cd|[@Lecoeur2011]
TDM3|Durée de la phase levée (A2) - maturité (M3)|°Cd|[@Lecoeur2011]
TLN|Nombre de feuille potentiel|feuilles|[@Lecoeur2011]
LLH|Rang (depuis le sol) de la plus grande feuille du profil foliaire à la floraison|feuilles|[@Lecoeur2011]
LLS|Surface de la plus grande feuille du profil foliaire à la floraison|cm2|[@Lecoeur2011]
K|Coefficient d'extinction du rayonnement lors de la phase végétative (E1-F1)|-|[@Lecoeur2011]
LE|Seuil de réponse de l'expansion foliaire à une contrainte hydrique|-|[@Casadebaig2008]
TR|Seuil de réponse de la conductance stomatique à une contrainte hydrique|-|[@Casadebaig2008]
HI|Indice de récolte potentiel|-|[@Casadebaig2011]
OC|Teneur en huile dans l'akène en conditions potentielles|%, 0% humidité|[@Casadebaig2011]

**table des paramètres : variétés**


## Pédoclimat
nom | label | unité | référence
----|-------|-------|----------
file| Nom du fichier climatique|-|
root_depth|Profondeur d'enracinement maximale|mm|[@Lecoeur2011]
field_capacity_1|Humidité massique à la capacité au champ dans l'horizon de surface (0 - 30 cm)|%|
wilting_point_1|Humidité massique au point de flétrissement dans l'horizon de surface (0 - 30 cm)|%|
field_capacity_2|Humidité massique à la capacité au champ dans l'horizon inférieur (30 cm - profondeur)|%|
wilting_point_2|Humidité massique au point de flétrissement dans l'horizon inférieur (30 cm - profondeur)|%|
soil_density_1|Densité apparente du sol dans l'horizon de surface (0 - 30 cm)|g.cm-3|
soil_density_2|Densité apparente du sol dans l'horizon inférieur (30 cm - profondeur)|g.cm-3|
stone_content|Taux de cailloux|[0; 1]|
mineralization|Vitesse potentielle de minéralisation|kg/ha/jour normalise|[@Vale2007]

**table des paramètres : pédoclimat**


### Données climatiques
Sunflo utilise des données climatiques disponibles dans des fichiers texte. Chaque fichier représente une année avec l'enregistrement de 5 variables (colonnes) au pas de temps journalier (lignes).  
La fonction `rsunflo::climate` permet de créer ces fichiers depuis les principaux formats (meteo-france, INRA climatik). Sinon, un exemple de fichier climatique formaté pour sunflo est disponible sur websim.

nom | label | unité
----|-------|-----
TN|Température minimale|°C
TX|Température maximale|°C
GR|Rayonnement global incident|MJ/m2
ETP|Evapotranspiration de référence|mm
RR|Précipitations|mm

**table des variables climatique d'entrée**

## Conduite
nom | label | unité
----|-------|-----
crop_sowing |Date de semis|jj/mm
crop_harvest|Date de récolte|jj/mm
crop_density|Densité du peuplement à la levée|plantes/m2
nitrogen_date_1|Fertilisation (date)|jj/mm
nitrogen_dose_1|Fertilisation (dose)|kg/ha eq. azote minéral
nitrogen_date_2|Fertilisation (date)|jj/mm
nitrogen_dose_2|Fertilisation (dose)|kg/ha eq. azote minéral
water_date_1|Irrigation (date)|jj/mm
water_dose_1|Irrigation (dose)|mm
water_date_2|Irrigation (date)|jj/mm
water_dose_2|Irrigation (dose)|mm
water_date_3|Irrigation (date)|jj/mm
water_dose_3|Irrigation (dose)|mm

**table des paramètres : conduite**

## Initialisation
nom | label | unité
----|-------|-----
begin |Date de début de la simulation|jj/mm/aaaa
duration|Durée de la simulation|jour
crop_emergence|Date de levée (forçage)|jj/mm
nitrogen_initial_1|Reliquats azotés dans l'horizon de surface (0 - 30 cm)|kg/ha eq. azote minéral
nitrogen_initial_2|Reliquats azotés dans l'horizon inférieur (30 cm - profondeur)|kg/ha eq. azote minéral
water_initial_1|Humidité massique initiale dans l'horizon de surface  (0 - 30 cm)|%
water_initial_2|Humidité massique initiale dans l'horizon inférieur  (30 cm - profondeur)|%

**table des paramètres : initialisation**


# Planification
Cette étape consiste à concevoir une plan d'expérience numérique et à en préparer une représentation informatique (fichier ou objet) en vue de la simulation. Ce plan se présente comme une matrice, chaque simulation (ligne) est représentée par un vecteur de paramètres (colonnes). La longueur de ce vecteur est déterminée par le patron de simulation utilisé (par défaut, 42).  
Ce plan peut être créé manuellement (séquentiellement, ligne après ligne) ou bien automatiquement, en combinant de manière définie les niveaux de différents facteurs étudiés.   
La première solution correspond souvent à la simulation d'expérimentations réelles (MET). Dans ce cas, l'utilisation d'un tableur pour créer un fichier est préférable. Les entêtes des colonnes du fichier sont les noms des paramètres présentés dans les tableaux précédents.  
La deuxième solution est utilisée plutôt pour l'exploration du modèle, les plans créés peuvent être des combinaisons factorielles de paramètres (s'ils sont peu nombreux) ou des plans issus de méthodes d'analyse de sensibilité.  

Dans tout les cas, les plans créés peuvent être utilisés soit avec le simulateur local (rsunflo) ou distant (websim). Si ce dernier est utilisé, le format du fichier du plan est crucial (type et format des colonnes). La fonction `rsunflo::design` permet de convertir le fichier créé vers le format de websim (cf. aide de websim).

## Exemple
Le plan (fichier [design.xlsx](design.xlsx)) a été initialement créé avec un tableur en utilisant en entête les noms des paramètres et variables d'entrée présenté dans les tables précédentes. Le fichier du plan est simplement lu, assemblé, et ré-écrit dans le format utilisé par websim. Le nom d'utilisateur utilisé dans websim doit être passé en argument à la fonction `rsunflo::design`. Les fichiers et données pour reproduire cet exemple sont fournis avec le paquet.

```R
# Import des données
## Essais (n=2)
d <- readWorksheetFromFile(file="inst/doc/design.xlsx", sheet="essais")
## Genotypes (n=3)
g <- readWorksheetFromFile(file="inst/doc/design.xlsx", sheet="genotype")

# Plan factoriel complet
p <- expand.grid(carol=d$carol, genotype=g$genotype)
p <- join(join(p, d), g)

# Ecriture au format websim
design(p, file="inst/doc/design_websim.xls", format="websim", user="casadebaig")
```


# Simulation
Une fois le plan conçu et créé au format adapté au simulateur utilisé, les simulations sont effectuées en série. Les variables de sorties sont celles définies dans le patron de simulation. Selon la vue utilisée lors de la simulation, les sorties sont disponibles à chaque pas de temps (vue dynamique) ou bien seulement à la fin de la simulation (vue statique). Les deux tables suivantes résument le contenu de ces vues.

## Utilisation locale via une interface graphique (1-10)
Cette utilisation ne fonctionne pas avec un plan d'expérience défini. Elle est donc adaptée à un faible nombre de simulation, car il faut changer chaque paramètre séquentiellement dans l'interface graphique GVLE. Cette solution permet par contre de facilement changer les variables de sorties observées lors de la simulation. L'utilisation de l'interface GVLE n'est pas documentée pour sunflo (cf. notices de l'équipe RECORD).

## Utilisation distance via une interface web (10-500)
L'interface web *websim* permet, outre la création manuelle de simulations, d'automatiser le processus de simulation quand un fichier de plan d'expérience est disponible.  

1. `Patrons de simulation | Utiliser` : choix du patron de simulation ([lien direct](http://147.99.107.100/sunflo/choose_pattern_to_use/8/))
2. `Simulations | Gerer via des tableaux` : lecture du fichier de plan et création des simulations correspondantes
3. `Plan d'expérience | Gerer` : assemblage et simulation du contenu du plan
4. `Plan d'expérience | Acceder aux fichiers` : export des résultas (format excel, un fichier par simulation).

## Utilisation locale via un langage de script (10-1E6)
L'utilisation de sunflo via R est plus abstraite que l'utilisation d'interfaces utilisateurs, mais constitue à la fois une procédure parfaitement reproductible et plus rapide (facteur ~10) pour réaliser des expérimentations numériques.  
La fonction `rsunflo::play` permet de simuler une ligne d'une matrice qui représente le plan d'expérience créé via un tableur. 
La fonction `rsunflo::shape` met en forme et renomme les variables de sorties.
La fonction `rsunflo::display` représente chaque variable de sortie en fonction du temps.
Le package `plyr` est utilisé pour itérer les simulations sur l'ensemble des lignes du plan. Ce calcul peut facilement être distribué sur plusieurs coeurs ou processeurs à l'aide du package `doMC` (cf aide de `plyr`). A cette étape, le résultat de chaque simulation est stocké dans un élément de liste. Les simulations qui échouent retournent un élément vide, les fonctions `Filter` et `compact` permettent de filtrer les simulations réussies. Pour l'instant, les causes de l'erreur ne sont pas remontées dans R (voir les logs de VLE).

### Exemple
```R
# Modèle et plan
sunflo <- new("Rvle", file = "sunflo_web.vpz", pkg = "sunflo")
design <- as.list(p)

# Test
shape(results(run(sunflo)), view = "timed")
shape(play(sunflo, design, unit=1), view="timed")
display(shape(play(sunflo, design, unit=1), view="timed"))

# Simulation
d <- mlply(
  design$id,
  function(x){failwith(NULL, shape)(play(sunflo, design, unit=x), view="timed")}
)
# Filter(is.null, d)
d <- ldply(compact(d))
```

## Variables de sorties et indicateurs

nom | label | unité
----|-------|-----
TN|Température minimale|°C
TX|Température maximale|°C
TM|Température moyenne|°C
GR|Rayonnement global incident|MJ/m2
ETP|Evapotranspiration de référence|mm
RR|Précipitations|mm
TTA2|Temps thermique cumulé depuis la levée|°C.j
PhenoStage|Index de phénologie|-
FTSW|Facteur de contrainte hydrique|-
FHTR|Facteur de réponse de la transpiration à la contrainte hydrique|-
FHRUE|Facteur de réponse de la photosynthèse à la contrainte hydrique|-
ETRETM|Ratio ETR/ETM|-
FTRUE|Facteur de réponse de la photosynthèse à la contrainte thermique|-
NAB|Azote absorbé|kg/ha/j
NNI|Indice de nutrition azoté|-
FNRUE|Facteur de réponse de la photosynthèse à la contrainte azote|-
LAI|Indice foliaire|-
RIE|Efficience d'interception de la lumière|-
RUE|Efficience d'utilisation de la lumière|-
TDM|Biomasse aérienne|g/m2
GY|Rendement en grain|q/ha
OC|Teneur en huile|%, grain à 0% humidite

**table des variables de sorties dynamiques**

nom|label|unité
---|-----|------
JSE|Nombre de jours de stress hydrique (ETR/ETM < 0.6) pour la période initiation florale - début floraison|jours
JSF|Nombre de jours de stress hydrique (ETR/ETM < 0.6) pour la période début floraison - début maturité|jours
JSM|Nombre de jours de stress hydrique (ETR/ETM < 0.6) pour la période début maturité - fin maturité|jours
GY|Rendement en grain|q/ha
OC|Teneur en huile|%, grain 0% humidité

**table des variables de sortie statique**




# Analyse
## Assemblage et traitements post-simulation  
Le package `plyr` permet également d'appliquer un même traitement sur un ensemble d'éléments, qu'il s'agisse simplement d'un assemblage (exemple ci-dessus) ou d'une opération statistique (description, régression...). C'est cette possibilité qui est utilisée pour calculer un panel pré-défini d'indicateurs depuis des sorties dynamiques brutes (cf. fonction `rsunflo::indicate`).

nom|position|label|calcul|unité
----|-------|-----|------|------
SGR|cycle|Rayonnement incident (PAR)|sum(0.48\*GR)|MJ/m2
SRR|cycle|Précipitations|sum(RR)|mm
SETP|cycle|Evapotranspiration|sum(ETP)|mm
SCWD|cycle|Déficit hydrique climatique|sum(P-ETP)|mm
SFTSW|cycle|Déficit hydrique édaphique (quantitatif)|sum(1-FTSW)|-
NETR|cycle|Déficit hydrique édaphique (qualitatif)|sum(ETR/ETM < 0.6)|jours
SFHTR|cycle|Effet de la contrainte hydrique sur la transpiration|sum(1-FHTR)|-
SFHRUE|cycle|Effet de la contrainte hydrique sur la photosynthèse|sum(1-FHRUE)|-
SNNI|cycle|Déficit azoté|sum(1-NNI)|-
SNAB|cycle|Azote absorbé|diff(range(NAB))|kg/ha
SFNRUE|cycle|Effet de la contrainte azote sur la photosynthèse|sum(1-FNRUE)|-
SFTRUE|cycle|Effet de la contrainte thermique sur la photosynthèse|sum(1-FTRUE)|-
LAI|cycle|LAI maximum|max(LAI)|-
DSF|cycle|Durée de surface foliaire|sum(LAI)|-
SIR|cycle|Rayonnement intercepté (PAR)|sum(RIE*GR*0.48)|MJ/m2
MRUE|cycle|Photosynthèse|mean(RUE)|g/MJ/m2
STDM|cycle|Biomasse|max(TDM)|g/m2
TT|cycle|Temps thermique (base 4.8°C)|max(TTA2)|°C.j
GY|cycle|Rendement en grain|max(GY)|q/ha
OC|cycle|Teneur en huile|max(OC)|%

**table des indicateurs calculés depuis des variables dynamiques**


## Méthodes d'analyse  
L'import des données dans R permet de profiter de ses outils statistiques. 
Pour une question plus orientée vers le développement, l'analyse des données peut s'envisager dans l'outil web de simulation. Le framework de websim peut ainsi être installé pour servir de support à la construction d'un outil d'aide à la décision.


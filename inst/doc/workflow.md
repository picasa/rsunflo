# SUNFLO en 10 minutes.
Cette notice présente les principales étapes nécessaires pour réaliser une expérimentation numérique avec le modèle SUNFLO.
Selon les utilisations envisagées du modèle (démonstration, simulation de réseaux d'essais multilocaux, exploration, ...) les outils utilisés et le volume de simulation varient considérablement.   
Différentes stratégies d'utilisation sont proposées : 
* utilisation locale via une interface graphique (1-10)
* utilisation distance via une interface web (10-500)
* utilisation locale via un langage de script (10-1M)

![workflow](figures/workflow.png)
**Stratégies d'utilisation** : 4 étapes successives sont nécessaires : rassembler les données de paramétrage, concevoir le plan de l'expérimentation numérique, réaliser les simulations et analyser les données. Les cadres gris nécessitent une installation locale des logiciels mentionnés, le cadre bleu permet une utilisation distante, via une interface web.

## Paramétrage
le modèle nécessite 42 paramètres et 5 variables d'entrées répartis en 4 volets : variétes, pédoclimat, conduite de culture et initialisation. Si une partie de ces informations n'est pas renseignée, la simulation échoue.  
Les outils de multi-simulation (rsunflo, websim) fonctionnent avec un ensemble {données d'entrée, version du modèle, type de sorties} fixe qui constituent un *patron de simulation*. Ce mode d'emploi se base sur un patron existant (varieto), mais il est possible d'en créer d'autre pour adapter l'utilisation du modèle à la quantité de données d'entrées disponibles (ou étudiées). Le fichier [parameterization.xlsx](parameterization.xlsx) détaille le contenu des patrons de simulation, le détail du paramétrage et propose des valeurs par défaut. 

### Variété
nom | label | unité
----|-------|-----
LE  |Seuil de réponse de l'expansion foliaire à une contrainte hydrique|-
TR|Seuil de réponse de la conductance stomatique à une contrainte hydrique|-
LLH|Rang (depuis le sol) de la plus grande feuille du profil foliaire à la floraison|feuilles
LLS|Surface de la plus grande feuille du profil folaire à la floraison|cm2
TDE1|Durée de la phase levée (A2) - initiation florale (E1|°Cd
TDF1|Durée de la phase levée (A2) - floraison (F1)|°Cd
TDM0|Durée de la phase levée (A2) - debut maturité (M0)|°Cd
TDM3|Durée de la phase levée (A2) - maturité (M3)|°Cd
K|Coefficient d’extinction du rayonnement lors de la phase végétative (E1-F1)|-
HI|Indice de récolte potentiel|-
OC|Teneur en huile dans l’akène en conditions potentielles|%, (grain 0% humidité)
TLN|Nombre de feuille potentiel|-

### Pédoclimat
nom | label | unit
----|-------|-----
file|Nom du fichier climatique|-
soil_density_1|Densité apparente du sol dans l'horizon de surface (0 - 30 cm)|g.cm-3
soil_density_2|Densité apparente du sol dans l'horizon inférieur (30 cm - profondeur)|g.cm-3
field_capacity_1|Humidité massique à la capacité au champ dans l'horizon de surface (0 - 30 cm)|%
field_capacity_2|Humidité massique à la capacité au champ dans l'horizon inférieur (30 cm - profondeur)|%
wilting_point_1|Humidité massique au point de flétrissement dans l'horizon de surface (0 - 30 cm)|%
wilting_point_2|Humidité massique au point de flétrissement dans l'horizon inférieur (30 cm - profondeur)|%
root_depth|Profondeur d'enracinement maximale|mm
stone_content|Taux de cailloux|[0;1]
mineralization|Vitesse potentielle de minéralisation|kg/ha/jour normalise

### Conduite
nom | label | unit
----|-------|-----
nitrogen_dose_1|Fertilisation (dose)|kg/ha eq. azote mineral
nitrogen_dose_2|Fertilisation (dose)|kg/ha eq. azote mineral
water_dose_1|Irrigation (dose)|mm
water_dose_2|Irrigation (dose)|mm
water_dose_3|Irrigation (dose)|mm
nitrogen_date_1|Fertilisation (date)|jj/mm
nitrogen_date_2|Fertilisation (date)|jj/mm
water_date_1|Irrigation (date)|jj/mm
water_date_2|Irrigation (date)|jj/mm
water_date_3|Irrigation (date)|jj/mm
crop_density|Densité du peuplement à la levée|plantes/m2
crop_harvest|Date de récolte|jj/mm
crop_sowing|Date de semis|jj/mm

### Initialisation
nom | label | unit
----|-------|-----
crop_emergence|Date de levée (forçage)|
water_initial_1|Humidité massique initiale dans l'horizon de surface  (0 - 30 cm)|%
water_initial_2|Humidité massique initiale dans l'horizon inférieur  (30 cm - profondeur)|%
nitrogen_initial_1|Reliquats azotés dans l'horizon de surface (0 - 30 cm)|
nitrogen_initial_2|Reliquats azotés dans l'horizon inférieur (30 cm - profondeur)|
soil_density_1|Densité apparente du sol dans l'horizon de surface (0 - 30 cm)|g.cm-3
soil_density_2|Densité apparente du sol dans l'horizon inférieur (30 cm - profondeur)|g.cm-3
field_capacity_1|Humidité massique à la capacité au champ dans l'horizon de surface (0 - 30 cm)|%
field_capacity_2|Humidité massique à la capacité au champ dans l'horizon inférieur (30 cm - profondeur)|%
wilting_point_1|Humidité massique au point de flétrissement dans l'horizon de surface (0 - 30 cm)|%
wilting_point_2|Humidité massique au point de flétrissement dans l'horizon inférieur (30 cm - profondeur)|%
root_depth|Profondeur d'enracinement maximale|mm
stone_content|Taux de cailloux|[0 ; 1]
mineralization|Vitesse potentielle de minéralisation|kg/ha/jour normalise


## Plannification
Cette étape consiste à concevoir le plan d'expérience numérique à réaliser et à en préparer une représentation informatique (fichier ou objet). Ce plan se présente comme une matrice, chaque simulation (ligne) est représentée par un vecteur de paramètres (colonnes). La longeur de ce vecteur est déterminée par le patron de simulation utilisé (par défaut, 42).  
Ce plan peut être créé manuellement (séquentiellement, ligne après ligne) ou bien automatiquement, en combinant de manière définie les niveaux de différents facteurs étudiés.   
La première solution correspond souvent à la simulation d'expérimentations réelles (MET). Dans ce cas, l'utilisation d'un tableur pour créer un fichier est préférable. Les entêtes des colonnes du fichier sont les noms des paramètres présentés dans les tableaux précédents.  
La deuxième solution est utilisée plutôt pour l'exploration du modèle, les plans créés peuvent être des combinaisons factorielles de paramètres (s'ils sont peu nombreux) ou des plans issus de méthodes d'analyse de sensibilité.  

Dans tout les cas, les plans créés peuvent être utilisés soit avec le simulateur local (rsunflo) ou distant (websim). Si ce dernier est utilisé, le format du fichier du plan est crucial (type des colonnes). La fonction `rsunflo::design` permet de convertir le fichier créé vers le format de websim (cf. aide de websim).
### Exemples
Dans ces deux exemples, le plan (2 années du réseau d'essai post-inscription) a été initialement créé avec un tableur en utilisant les noms des paramètres en entête.
#### websim
#### rsunflo


## Simulation
Une fois le plan conçu et créé au format adapté au simulateur utilisé, les simulations sont effectuées en série. Les variables de sorties sont celles définies dans le patron de simulation. 

**table des variables de sortie**

### Utilisation locale via une interface graphique (1-10)
Cette utilisation ne permet pas l'utilisation d'un plan d'expérience défini. Elle est donc adaptée à un faible nombre de simulation, car il faut changer chaque paramètre séquentiellement dans l'interface graphique GVLE. Cette solution permet par contre de faciement changer les variables de sorties observées lors de la simulation. L'utilisation de l'interface GVLE n'est pas documentée pour sunflo (cf. notices de l'équipe RECORD).

### Utilisation distance via une interface web (10-500)


### Utilisation locale via un langage de script (10-1M)


## Analyse

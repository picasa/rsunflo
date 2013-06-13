# SUNFLO en 10 minutes.
Cette notice présente les principales étapes nécessaires pour réaliser une expérimentation numérique avec le modèle SUNFLO.
Selon les utilisations envisagées du modèle (démonstration, simulation de réseaux d'essais multilocaux, exploration, ...) les outils utilisés et le volume de simulation varie considérablement.   
Différentes stratégies d'utilisation sont proposées, l'usage du modèle est résumé par le volume de simulation : 
* utilisation locale via une interface graphique (1-10)
* utilisation distance via une interface web (10-500)
* utilisation locale via un langage de script (10-1M)

![workflow](figures/workflow.png)
**Stratégies d'utilisation** : 4 étapes successives sont nécessaires : rassembler les données de paramétrage, concevoir le plan de l'expérimentation numérique, réaliser les simulation et analyser les données. Les cadres gris nécessisent une installation locale des logiciels mentionnés, le cadre bleu permet une utilisation via une interface web.

## Paramétrage
le modèle nécessite 42 paramètres et 4 variables d'entrées répartis dans 4 sources de données d'entrées : variétes, pédoclimat, conduite de culture et initialisation. Si une partie de ces informations ne sont pas renseignées, la simulation ne peut s'effectuer avec les outils d'automatisation (rsunflo, websim).  
Ces outils fonctionnent avec un ensemble {données d'entrée, version du modèle, type de sorties} fixe qui constituent un *patron de simulation*. Ce mode d'emploi se base sur un patron existant (varieto), mais il est possible d'en créer d'autre pour adapter l'utilisation du modèle à la quantité de données d'entrées disponibles (ou étudiées). Le fichier `parametrization.xlsx` détaille le paramétrage du modèle, le contenu des patrons de simulation et propose des valeurs par défaut. 

### Variété
nom | label | unité
----|-------|-----
LE  |Seuil de réponse de l'expansion foliaire à une contrainte hydrique|
TR|Seuil de réponse de la conductance stomatique à une contrainte hydrique|
LLH|Rang (depuis le sol) de la plus grande feuille du profil foliaire à la floraison|feuilles
LLS|Surface de la plus grande feuille du profil folaire à la floraison|cm2
TDE1|Durée de la phase levée (A2) - initiation florale (E1|°Cd
TDF1|Durée de la phase levée (A2) - floraison (F1)|°Cd
TDM0|Durée de la phase levée (A2) - debut maturité (M0)|°Cd
TDM3|Durée de la phase levée (A2) - maturité (M3)|°Cd
K|Coefficient d’extinction du rayonnement lors de la phase végétative (E1-F1)|
HI|Indice de récolte potentiel|
OC|Teneur en huile dans l’akène en conditions potentielles|%, (grain 0% humidité)
TLN|Nombre de feuille potentiel|

### Pédoclimat
nom | label | unit
----|-------|-----
file  Nom du fichier climatique
soil_density_1|Densité apparente du sol dans l'horizon de surface (0 - 30 cm)|g.cm-3
soil_density_2|Densité apparente du sol dans l'horizon inférieur (30 cm - profondeur)|g.cm-3
field_capacity_1|Humidité massique à la capacité au champ dans l'horizon de surface (0 - 30 cm)|%
field_capacity_2|Humidité massique à la capacité au champ dans l'horizon inférieur (30 cm - profondeur)|%
wilting_point_1|Humidité massique au point de flétrissement dans l'horizon de surface (0 - 30 cm)|%
wilting_point_2|Humidité massique au point de flétrissement dans l'horizon inférieur (30 cm - profondeur)|%
root_depth|Profondeur d'enracinement maximale|mm
stone_content|Taux de cailloux|[0 ; 1]
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
* entetes
* formats

## Simulation

## Analyse
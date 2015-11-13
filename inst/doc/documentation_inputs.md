


# Inputs


|category       |symbol             |description                                                                         |unit                              |reference         |
|:--------------|:------------------|:-----------------------------------------------------------------------------------|:---------------------------------|:-----------------|
|Genotype       |TDE1               |Temperature sum to floral initiation                                                |$°C.d$                            |[@Lecoeur2011]    |
|Genotype       |TDF1               |Temperature sum from emergence to the beginning of flowering                        |$°C.d$                            |[@Lecoeur2011]    |
|Genotype       |TDM0               |Temperature sum from emergence to the beginning of grain filling                    |$°C.d$                            |[@Lecoeur2011]    |
|Genotype       |TDM3               |Temperature sum from emergence to seed physiological maturity                       |$°C.d$                            |[@Lecoeur2011]    |
|Genotype       |TLN                |Potential number of leaves at flowering                                             |$leaf$                            |[@Lecoeur2011]    |
|Genotype       |LLH                |Potential rank of the plant largest leaf at flowering                               |$leaf$                            |[@Lecoeur2011]    |
|Genotype       |LLS                |Potential area of the plant largest leaf at flowering                               |$cm^{-2}$                         |[@Lecoeur2011]    |
|Genotype       |K                  |Light extinction coefficient during vegetative growth                               |-                                 |[@Lecoeur2011]    |
|Genotype       |LE                 |Threshold for leaf expansion response to water stress                               |-                                 |[@Casadebaig2008] |
|Genotype       |TR                 |Threshold for stomatal conductance response to water stress                         |-                                 |[@Casadebaig2008] |
|Genotype       |HI                 |Potential harvest index                                                             |-                                 |[@Casadebaig2011] |
|Genotype       |OC                 |Potential seed oil content                                                          |$\% dry mass$                     |[@Casadebaig2011] |
|Environment    |file               |Climate file path                                                                   |-                                 |NA                |
|Environment    |root_depth         |Potential rooting depth                                                             |$mm$                              |[@Lecoeur2011]    |
|Environment    |field_capacity_1   |Water content at field capacity (0-30 cm)                                           |$\%$                              |NA                |
|Environment    |wilting_point_1    |Water content at wilting point (0-30cm)                                             |$\%$                              |NA                |
|Environment    |field_capacity_2   |Water content at field capacity (30 cm-rooting depth)                               |$\%$                              |NA                |
|Environment    |wilting_point_2    |Water content at wilting point (30 cm-rooting depth)                                |$\%$                              |NA                |
|Environment    |soil_density_1     |Soil bulk density, sieved < 5mm, 0-30cm layer                                       |$g.cm^{-3}$                       |NA                |
|Environment    |soil_density_2     |Soil bulk density, sieved < 5mm, 30 cm-rooting depth layer                          |$g.cm^{-3}$                       |NA                |
|Environment    |stone_content      |Stone content (0-rooting depth)                                                     |$[0,1]$                           |NA                |
|Environment    |mineralization     |Potential nitrogen mineralization rate                                              |$kg.ha^{-1}.day^{-1}$             |[@Vale2007]       |
|Management     |crop_sowing        |Sowing date                                                                         |$date (dd/mm)$                    |NA                |
|Management     |crop_harvest       |Harvest date                                                                        |$date (dd/mm)$                    |NA                |
|Management     |crop_density       |Plant density                                                                       |$plant.m^{-2}$                    |NA                |
|Management     |nitrogen_date_1    |Fertilization (date 1)                                                              |$date (dd/mm)$                    |NA                |
|Management     |nitrogen_dose_1    |Fertilization (amount 1)                                                            |$kg.ha^{-1}$ eq. mineral nitrogen |NA                |
|Management     |nitrogen_date_2    |Fertilization (date 2)                                                              |$date (dd/mm)$                    |NA                |
|Management     |nitrogen_dose_2    |Fertilization (amount 2)                                                            |$kg.ha^{-1}$ eq. mineral nitrogen |NA                |
|Management     |water_date_1       |Irrigation (date 1)                                                                 |$date (dd/mm)$                    |NA                |
|Management     |water_dose_1       |Irrigation (amount 1)                                                               |$mm$                              |NA                |
|Management     |water_date_2       |Irrigation (date 2)                                                                 |$date (dd/mm)$                    |NA                |
|Management     |water_dose_2       |Irrigation (amount 2)                                                               |$mm$                              |NA                |
|Management     |water_date_3       |Irrigation (date 3)                                                                 |$date (dd/mm)$                    |NA                |
|Management     |water_dose_3       |Irrigation (amount 3)                                                               |$mm$                              |NA                |
|Initialization |begin              |Date for simulation start                                                           |$date (dd/mm/aaaa)$               |NA                |
|Initialization |duration           |Duration of the simulation                                                          |$day$                             |NA                |
|Initialization |crop_emergence     |Date for emergence, which can also be simulated (default)                           |$date (dd/mm)$                    |NA                |
|Initialization |nitrogen_initial_1 |Initial value for nitrogen residuals in surface layer  (0-30 cm)                    |$kg.ha^{-1}$ eq. mineral nitrogen |NA                |
|Initialization |nitrogen_initial_2 |Initial value for nitrogen residuals in root layer (30 cm-rooting depth)            |$kg.ha^{-1}$ eq. mineral nitrogen |NA                |
|Initialization |water_initial_1    |Intial value for soil gravimetric water content in surface layer  (0-30 cm)         |$\%$                              |NA                |
|Initialization |water_initial_2    |Intial value for soil gravimetric water content in root layer (30 cm-rooting depth) |$\%$                              |NA                |

# References 

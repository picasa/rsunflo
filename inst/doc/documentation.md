


# Documentation for the SUNFLO crop model

## Model structure
![structure](./files/structure.png) 
## Crop potential growth
### Phenology
### Leaf Area
### Light interception
### Biomass production
### Crop performance

## Environmental factors
### Thermal stress




$$
ThermalStressRUE = \left\{ 
  \begin{array}{ll}
  T_m \cdot \frac{1}{T_{ol} - T_b} - \frac{T_b}{T_{ol} - T_b} & \textrm{if $T_b < T_m < T_{ol}$} \\  
	1 & \textrm{if $T_{ol} < T_m < T_{ou}$} \\
  T_m \cdot \frac{1}{T_{ou} - tc} - \frac{tc}{T_{ou} - tc} & \textrm{if $T_{ou} < T_m < tc$} \\
  0 & \textrm{else}
	\end{array} \right.
$$




### Water stress

### Nitrogen stress

### Radiation stress

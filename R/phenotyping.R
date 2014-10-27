# Tools for phenotyping and genotypic parameterisation

# Climate ####
# 1 watt/day = 86400 joule

# Soil ####

# Fonction de pédotransfert : estimer la capacité de rétention en eau volumique depuis une analyse de sol
# θ = a + (b×%Ar) + (c×%Li) + (d×%CO) + (e×Da)
#' @export soil_water_capacity_type

soil_water_capacity_type <- function(
  Argile, # %MS
  LimonFin, # %MS
  LimonGrossier, # %MS
  SableFin, # %MS
  SableGrossier, # %MS
  CaCO3, # %MS
  MatiereOrganique, # %MS
  Profondeur, # mm
  Cailloux # %MS
) {
  # [Vale2007]
  (CaCO3 + 2*Argile + LimonFin + LimonGrossier + 0.7*(SableFin+SableGrossier)) *
    ((100-Cailloux)/100)*(Profondeur/1000)*(1 + 0.05*MatiereOrganique - 0.1)
}

# estimer la réserve utile (mm) depuis la capacité de rétention en eau volumique et la profondeur
#' @export soil_water_capacity
soil_water_capacity <- function(
  RootDepth = 1800, # length (mm)
  FieldCapacity = 19.7, # % weight
  WiltingPoint = 9.7, # % weight
  SoilDensity = 1.4, # mass/volume (g/cm3)
  StoneContent = 0 # 
) {(FieldCapacity/100 - WiltingPoint/100) * RootDepth * SoilDensity * (1 - StoneContent)}



# Phenology ####
# Somme de temps thermique entre deux bornes : climat, date1, date2
#' @export thermal_time
thermal_time <- function(climate, eID, start, end, Tb = 4.8){
  if (is.na(start) | is.na(end)) {
    return(NA)
  } else {
    # Selection du vecteur de température moyenne
    s <- climate[climate$eID == eID,"TM"][start:end] 
    # Somme conditionnelle
    r <- sum(ifelse(s - Tb < 0, 0, s - Tb))
    return(r)
  }
}

# Calcul de stades phénologiques secondaires depuis la date de floraison
#' @export phenostage
phenostage <- function(flowering) {
  r <- data.frame(
    TDF1 = flowering,
    TDE1 = 0.576 * flowering,
    TDM0 = flowering + 246.5
  )
  return(r)
}



# Architecture ####

# Modèle de surface de feuille = f(Longeur, Largeur) cm
#' @export leaf_size
leaf_size <- function(length, width, a0=0.7, a=0.736, b=-8.86, c=0.684, shape="simple"){
  
  switch(
    shape,
    
    # default to simple linear model, c.f Heliaphen_platform repository
    simple = {
      area <- a0 * length * width
    },
    
    bilinear = {
      area <- ifelse(length * width < (b/(c - a)),
                     c * length * width,
                     a * length * width + b
      )
    }
  )
  return(area)
}


# Modèle de profil foliaire
#' @export leaf_profile
leaf_profile <- function(TLN, LLS, LLH, a=-2.05, b=0.049, shape="fixed", output="profile") {
  
  # Nombre de phytomères
  n <- 1:TLN
  
  # Calcul du profil foliaire selon deux méthodes pour les coefficients de forme
  switch(
    shape,
    fixed = {
      # a = -2.110168, b = 0.01447336 [Casadebaig2013] : moyenne du modèle linéaire sur la DB
      # a = -2.049676, b = 0.04937692 [Casadebaig2013] : moyenne ajustements sur la DB observée
      r <- LLS * exp(a*((n-LLH)/(LLH-1))^2 + b*((n-LLH)/(LLH-1))^3)    
    },
    model = {
      b <- 1.5 -0.2210304*LLH -0.0003529*LLS + 0.0825307*length(n)
      a <- -2.313409 + 0.018158*LLH -0.001637*LLS + 0.019968*length(n) + 0.920874*b          
      r <- LLS * exp(a*((n-LLH)/(LLH-1))^2 + b*((n-LLH)/(LLH-1))^3)    
    }
  )
  
  # Sortie
  switch(
    output,
    profile = return(data.frame(leaf=n, size=r)),
    shape = return(data.frame(a=a, b=b))
  )
}



# Modèle de coefficient d'extinction = f(TLN, LLS, LLH)
# Coeff_k = -1,11.10-2 x n_Fmax – 1,09.10-2 x NF – 1,12.10-3 x SFimax – 0,11 x H + 6,5.10-5 x (0,5 x NF x SFimax + 30 x NF) + 1,58
#' @export coefficient_extinction
coefficient_extinction <- function(TLN, LLH, LLS, H) {  
  # Methode Pouzet-Bugat [Pouzet1985]
  TPA <- 0.5*TLN*LLS +30*TLN  
  
  # [Casadebaig2008]
  K <- -1.11E-2*LLH -1.09E-2*TLN -1.12E-3*LLS -0.11E-2*H +6.5E-5*TPA +1.58
  return(K)
}



# Allocation ####

# Conversion de teneur en huile aux normes (9% eau, 2% impureté) vers la teneur GPS
#' @export conversion_oilcontent
conversion_oilcontent <- function(x, humidity=9, impurity=2) {
  r <- (1-impurity/100) * (1-humidity/100)
  return(x * 1/r)
}



# Response ####
# Réponse de la transpiration plante / conductance stomatique à la contrainte hydrique
#' @export curve_conductance
curve_conductance <- function(x, a) {
   t = 1.05 / (1 + 4.5 * exp(a * x))
   return(t)
}

# Réponse de l'expansion à la contrainte hydrique
#' @export curve_expansion
curve_expansion <- function(x, a) {
  t = (2 /(1 + exp(a * x))) -1
  return(t)
}

# Fonction bi-linéaire
#' @export curve_breaklinear
curve_breaklinear <- function(x, a, b) {
  t=NULL
  for (i in 1:length(x)) {
    if (x[i] < a) y = (1-b)/a * x[i] + b else y = 1
    t=c(t,y)
  }
  return(t)        
}

# Phenotypage réponse : Extraire un dataframe du paramétrage d'un objet nls 
#' @export extract_parameters_response
extract_parameters_response <- function(x) {
  t <- data.frame(summary(x)$parameters)
  colnames(t) <- c("value","sd","t","pr")
  return(t)
}


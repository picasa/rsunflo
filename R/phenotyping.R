# Tools for phenotyping and genotypic parameterisation

# Phenologie
## Somme de temps thermique entre deux bornes : climat, date1, date2
ThermalTime <- function(climate, eID, start, end, Tb = 4.8){
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

## Calcul de stades phénologiques secondaires depuis la date de floraison
PhenoStage <- function(flowering) {
  r <- data.frame(
    TDF1 = flowering,
    TDE1 = 0.576 * flowering,
    TDM0 = flowering + 246.5
  )
  return(r)
}

# Architecture
## Modèle de surface de feuille = f(Longeur, Largeur) cm
LeafSize <- function(length, width, a=0.736, b=-8.86, c=0.684){
	ifelse(length * width < (b/(c - a)),
		c * length * width,
		a * length * width + b
	)
}

## Modèle de profil foliaire
LeafProfile <- function(TLN, LLS, LLH, a=-2.05, b=0.049, shape="fixed", output="profile") {
  
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


## Modèle de coefficient d'extinction = f(TLN, LLS, LLH)
# Coeff_k = -1,11.10-2 x n_Fmax – 1,09.10-2 x NF – 1,12.10-3 x SFimax – 0,11 x H + 6,5.10-5 x (0,5 x NF x SFimax + 30 x NF) + 1,58
ExtCoef <- function(TLN, LLH, LLS, H) {  
  # Methode Pouzet-Bugat [Pouzet1985]
  TPA <- 0.5*TLN*LLS +30*TLN  
  
  # [Casadebaig2008]
  K <- -1.11E-2*LLH -1.09E-2*TLN -1.12E-3*LLS -0.11E-2*H +6.5E-5*TPA +1.58
  return(K)
}

# Allocation
## Conversion de teneur en huile aux normes (9% eau, 2% impureté) vers la teneur GPS
OilContentGPS <- function(x, humidity=9, impurity=2) {
  r <- (1-impurity/100) * (1-humidity/100)
  return(x * 1/r)
}

# Réponse
## Réponse de la transpiration plante / conductance stomatique à la contrainte hydrique
# TR ~ (1.05/(1+4.5*exp(a*FTSW)))
Conductance <- function(x, a) {
   t = 1.05 / (1 + 4.5 * exp(a * x))
   return(t)
}

## Réponse de l'expansion à la contrainte hydrique
# LE ~ (-1 + 2/(1+exp(a*FTSW)))
Expansion <- function(x, a) {
  t = (2 /(1 + exp(a * x))) -1
  return(t)
}

## Fonction bi-linéaire
BreakLinear <- function(x, a, b) {
  t=NULL
  for (i in 1:length(x)) {
    if (x[i] < a) y = (1-b)/a * x[i] + b else y = 1
    t=c(t,y)
  }
  return(t)        
}

## Phenotypage réponse : Extraire un dataframe du paramétrage d'un objet nls 
ExtractParametersResponse <- function(x) {
  t <- data.frame(summary(x)$parameters)
  colnames(t) <- c("value","sd","t","pr")
  return(t)
}


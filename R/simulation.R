# Tools for input, simulation and output data.

# Sol ####
## Fonction de pédotransfert : estimer la capacité de rétention en eau volumique depuis une analyse de sol
# θ = a + (b×%Ar) + (c×%Li) + (d×%CO) + (e×Da)

PotentialWaterContent <- function(
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
  

# Climat ####
## Fonction pour la gestion des données climatiques
climate <- function(x, 
	input.format,
	input.labels,
	output.labels = c("JourJ","Annee","Mois","Jour","Tmin","Tmax","ETP","RAD","Pluie"), 
	output.prefix = "TMP")
	{

	switch(input.format,
		
		diagvar = {
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))
			
			# Test sur l'unité de rayonnement global (MJ/m2)
			if (mean(o$RAD) > 100) 
				{o$RAD <- o$RAD/100} else {} 
			
			# Ecriture des fichiers de sortie
			filename <- paste(unique(x$NomFichierMeteo),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(file=unique(x$NomFichierMeteo), o))
		},
		
		cetiom = {
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))

			# Test sur l'unité de rayonnement global (MJ/m2)
			if (mean(o$RAD) > 100) 
				{o$RAD <- o$RAD/100} else {} 
			
			# Ecriture des fichiers de sortie
			filename <- paste(output.prefix,"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		},
		
		climatik = {
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			# Ajout colonne Jour calendaires et renommage
			o <- cbind(JourJ = 1:dim(o)[1], o)
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))
			
			# Test sur l'unité de rayonnement global (MJ/m2)
			if (mean(o$RAD) > 500) 
				{o$RAD <- o$RAD/100} else {} 
			
			# Ecriture des fichiers de sortie
			filename <- paste(output.prefix,"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		},
		
    # Format id, site, [RECORD]
		simple = {	
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			# Renommage au format RECORD 
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))
			
			# Test sur l'unité de rayonnement global (MJ/m2)
			if (mean(o$RAD) > 500) 
				{o$RAD <- o$RAD/100} else {} 
			
			# Ecriture des fichiers de sortie
			filename <- paste(unique(x$site),"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		}
	)
}

# Simulation ####
# TODO : adaptation de la fonction au plan : 
#   switch 
#   automatique selon les infos du plan : non renseigné = defaut du vpz

# TODO : noms standardisés
# Climate : ClimateFile
# Soil : RootingDepth  WCFC	WCWP	StoneContent	SoilDensity	
# Initialization : Ni1	Ni2	Wi1	Wi2	
# Management : genotype PlantDensity	begin sowing	emergence harvest	

## Simulation unitaire depuis une ligne d'un plan d'expérience
play <- function(model, design, unit, template="default") 
{
  
  switch(template,
         
    # default : cas d'utilisation le plus courant     
    default = {
      r <- results(
        run(
          model,
          begin  							                = design[["begin"]][unit],
          duration					              		= design[["duration"]][unit],
          CONFIG_ClimatNomFichier.datas_file	= design[["meteo"]][unit],
          CONFIG_SimuInit.rh1                 = design[["ninit1"]][unit],
          CONFIG_SimuInit.rh2                 = design[["ninit2"]][unit],
          CONFIG_SimuInit.Hini_C1             = design[["hinit1"]][unit],
          CONFIG_SimuInit.Hini_C2             = design[["hinit2"]][unit],
          CONFIG_SimuInit.dateLevee_casForcee = format(design[["levee"]][unit], "%d/%m"),
          CONFIG_Sol.profondeur               = design[["profondeur"]][unit],
          CONFIG_Sol.Vp  		                  = design[["mineralisation"]][unit],
          CONFIG_Sol.Hcc_C1 		              = design[["hcc1"]][unit],
          CONFIG_Sol.Hcc_C2 		              = design[["hcc2"]][unit],
          CONFIG_Sol.Hpf_C1 		              = design[["hpf1"]][unit],
          CONFIG_Sol.Hpf_C2 		              = design[["hpf2"]][unit],
          CONFIG_Sol.da_C1 		 	              = design[["da1"]][unit],
          CONFIG_Sol.da_C2 		    	          = design[["da2"]][unit],
          CONFIG_Sol.TC 		                  = design[["cailloux"]][unit],
          CONFIG_Conduite.jsemis    		    	= format(design[["semis"]][unit], "%d/%m"),
          CONFIG_Conduite.jrecolte            = format(design[["recolte"]][unit], "%d/%m"),
          CONFIG_Conduite.densite        	    = design[["densite"]][unit],
          CONFIG_Conduite.date_ferti_1       	= format(design[["azote_date1"]][unit], "%d/%m"),
          CONFIG_Conduite.date_ferti_2        = format(design[["azote_date2"]][unit], "%d/%m"),
          CONFIG_Conduite.apport_ferti_1     	= design[["azote_dose1"]][unit],
          CONFIG_Conduite.apport_ferti_2      = design[["azote_dose2"]][unit],
          CONFIG_Conduite.date_irrig_1        = format(design[["eau_date1"]][unit], "%d/%m"),
          CONFIG_Conduite.date_irrig_2        = format(design[["eau_date2"]][unit], "%d/%m"),
          CONFIG_Conduite.date_irrig_3        = format(design[["eau_date3"]][unit], "%d/%m"),
          CONFIG_Conduite.apport_irrig_1     	= design[["eau_dose1"]][unit],
          CONFIG_Conduite.apport_irrig_2      = design[["eau_dose2"]][unit],
          CONFIG_Conduite.apport_irrig_3      = design[["eau_dose3"]][unit],
          CONFIG_Variete.date_TT_E1  		    	= design[["TDE1"]][unit],
          CONFIG_Variete.date_TT_F1  			    = design[["TDF1"]][unit],
          CONFIG_Variete.date_TT_M0  			    = design[["TDM0"]][unit],
          CONFIG_Variete.date_TT_M3  			    = design[["TDM3"]][unit],
          CONFIG_Variete.TLN     			        = design[["TLN"]][unit],
          CONFIG_Variete.ext     			        = design[["K"]][unit],
          CONFIG_Variete.bSF   				        = design[["LLH"]][unit],
          CONFIG_Variete.cSF   				        = design[["LLS"]][unit],
          CONFIG_Variete.a_LE  				        = design[["LE"]][unit],
          CONFIG_Variete.a_TR  				        = design[["TR"]][unit],
          CONFIG_Variete.IRg   				        = design[["HI"]][unit],
          CONFIG_Variete.PHS   				        = design[["PHS"]][unit],
          CONFIG_Variete.thp   				        = design[["OC"]][unit]
        )
      ) 
    }
  )
  
  # Retour 
  return(r)
}

## Mise en forme des données brutes de sortie
shape <- function(x, view) {
  
	switch(view,
		
		timed = {
		  # Nettoyage des noms de colonne
      x <- x[[1]]
		  colnames(x) <- sub(".*\\.","", colnames(x))
      
      # Conversion de date VLE (JDN cf. http://en.wikipedia.org/wiki/Julian_day)
      # to JDN as.numeric(as.Date(x, format= "%m/%d/%Y")) + 2440588
      # delta = julian(x = 01, d = 01, y = 1970, origin = c(month=11, day=24, year=-4713))
      x <- mutate(x, time = as.Date(time, origin = "1970-01-01") - 2440588)
      
			# viewDynamic : utilisation noms de variables en
			colnames(x) <- c("time","RUE","LUE","LAI","TDM",
	                   "PhenoStage","TTA2","TM","NNI","NAB",
	                   "ETRETM","FTSW","FT","OC","GY","ETP","RR","GR","TN","TX")
	    },
	             
    end = {
		  # Nettoyage des noms de colonne
		  x <- x[[1]]
		  colnames(x) <- sub(".*\\.","", colnames(x))
		  
      # viewStatic
			longnames <- c(
				"photo_TH_aFinMATURATION",
				"photo_RDT_aFinMATURATION")
			colnames(x)[match(longnames, colnames(x))] <- c("OC","GY")
		},
         
    indicators = {
      # Nettoyage des noms de colonne
      x <- x[[1]]
      colnames(x) <- sub(".*\\.","", colnames(x))
      
      # viewStatic
      longnames <- c(
        "photo_TH_aFinMATURATION",
        "photo_INN_CROISSANCEACTIVE_A_FLORAISON",
        "photo_RDT_aFinMATURATION")
      colnames(x)[match(longnames, colnames(x))] <- c("OC","NNI","GY")
    }
	)
	return(x)
}


## Fonction de synthèse des covariables (1 valeur par usm)
indicate <- function(x, view) {
  
  switch(view,
    
    timed = {
      # Définition des périodes d'intégration
      # levée - récolte
      EH <- (x$PhenoStage > 1 & x$PhenoStage < 6)
      # levée - floraison
      # EF <- (x$PhenoStage == 2 | x$PhenoStage == 3)
      # initiation florale - début maturité
      # FIM <- (x$PhenoStage == 3 | x$PhenoStage == 4)
      # floraison - début maturité
      # FM <- x$PhenoStage == 4
      # début maturité - récolte
      # MH <- x$PhenoStage == 5
      # fenetre remplissage
      # PFW <- (x$TTF1 >= 250 & x$TTF1 <= 450)
      
      # Calcul des indicateurs
      o <- data.frame(
        # Graphes
        # xm <- melt(x, id.vars=c("time","TTA2"))
        # xyplot(value ~ time | variable, data=xm, type="l", scale="free")
        
        # Ressources environnementales
        SGR = sum(x$GR[EH] * 0.48), # PAR
        SRR = sum(x$RR[EH]),
        SETP = sum(x$ETP[EH]),
        SCWD = sum(x$RR[EH] - x$ETP[EH]),
        
        # Contraintes hydriques
        ## basés sur FTSW
        SFTSW = sum(1 - x$FTSW[EH]),
        NETR = sum(x$ETRETM[EH] < 0.6),
        
        # Contraintes azotées
        # NNIF = x[x$PhasePhenoPlante==4,"NNI"][1], # INN floraison
        SNNI = sum(1 - x$NNI[EH & x$NNI <1]), #  déficit d'azote sur initiation florale - récolte
        SNAB = diff(range(x$NAB[EH])),  # quantité d'azote absorbé sur début maturité - récolte
        
        # Contraintes thermiques
        SFT = sum(1 - x$FT[EH]),
        
        # Évolution de la surface foliaire
        LAI = max(x$LAI[EH]),
        DSF = sum(x$LAI[EH]), # levée - récolte
        
        # Rayonnement intercepté (PAR)
        SIR = sum(x$LUE[EH] * x$GR[EH] * 0.48),
        
        # Photosynthèse
        MRUE = mean(x$RUE[EH]),
        
        # Biomasse accumulée
        STDM = max(x$TDM[EH]),
        
        # Performances
        TT = max(x$TTA2[EH]),
        GY = max(x$GY),
        OC = max(x$OC)
      ) 
    }
  )
  return(o)
}

## Dynamique de FTSW sur la période de culture
indicate.ftsw <- function(x) {
  
  # Période de culture (levée - maturité)
  crop = (x$PhenoStage >1 & x$PhenoStage <6)
  
  # Variable dynamique
  o <- data.frame(
    t = 1:length(crop[crop==TRUE]),
    ftsw = x$FTSW[crop]
  )
  return(o)
}

## Visualisation  des simulations
display <- function(x, view="timed") {
  switch(
    view,
    timed = {
      d <- melt(x, id.vars=c("time", "TTA2"))
      ggplot(d, aes(x=time, y=value)) +
        geom_line() +
        facet_wrap(~ variable, scale="free") +
        theme_bw()
    }
  )
}

# Analyse ####

## Calculer erreur de prédiction
evaluate.error <- function(data, formula, output="numeric") {
  
  # Calcul de l'erreur d'ajustement
  error <- ddply(
    data,
    as.formula(formula), summarise, 
    rmse = rmse(simulated, observed),
    efficiency = efficience(simulated, observed),
    bias = biais(simulated, observed)
  )
  
  # Labels pour l'erreur d'ajustement
  label <- ddply(
    error,
    as.formula(formula), summarise, 
    label = paste(
      "rmse =", rmse,
      ";",
      "bias =",bias
    )
  )
  
  switch(
    output,
    numeric = {return(error)},
    label = {return(label)}
  )
}

## Graphes simulés / observés
evaluate <- function(data, formula, color) {
  # Graphes
  ggplot(data=data, aes(x=observed, y=simulated)) + 
    geom_point(aes_string(color=color)) +
    facet_wrap(as.formula(formula), scale="free") +
    stat_smooth(method="lm", se=FALSE, linetype=2, color="black") +
    geom_abline(intercept=0, slope=1) +
    geom_text(
      data=evaluate.error(data, formula, output="label"),
      aes(x=Inf, y=-Inf, label=label),
      colour="black", hjust=1.1, vjust=-1, size=4
    ) +
    theme_bw() + labs(x="Observed data", y="Simulated data")
}

## Impact d'un trait sur le rendement moyen
impact <- function(x) {
	# Y_T - Y_t / mean(Y)
	r <- data.frame(
		precocity = (x[x$precocity=="L","RDT"] - x[x$precocity=="l","RDT"]) / mean(x$RDT) * 100,
		leaf = (x[x$leaf=="N","RDT"] - x[x$leaf=="n","RDT"]) / mean(x$RDT) * 100,
		profile = (x[x$profile=="H","RDT"] - x[x$profile=="h","RDT"]) / mean(x$RDT) * 100,
		area = (x[x$area=="A","RDT"] - x[x$area=="a","RDT"]) / mean(x$RDT) * 100,
		extinction = (x[x$extinction=="K","RDT"] - x[x$extinction=="k","RDT"]) / mean(x$RDT) * 100,
		expansion = (x[x$expansion=="E","RDT"] - x[x$expansion=="e","RDT"]) / mean(x$RDT) * 100,
		conductance = (x[x$conductance=="C","RDT"] - x[x$conductance=="c","RDT"]) / mean(x$RDT) * 100
	)
	return(r)
}

# Tools for input, simulation and output data.

# Climate ####
# Fonction pour la gestion des données climatiques
#' @export climate
climate <- function(x, 
	input.format,
	input.labels,
	output.labels = c("JourJ","Annee","Mois","Jour","Tmin","Tmax","ETP","RAD","Pluie"), 
	output.prefix = "TMP")
	{

	switch(
    input.format,
    
    # Format site, date, [mesures]
    date={
      # Ajout des colonnes utilisées par RECORD
      x <- mutate(
        x,
        JourJ = yday(date),
        Annee = year(date),
        Mois = month(date),
        Jour = day(date), 
      )
      
      # Mise en forme du fichier de sortie
      o <- cbind(
        x[,c("JourJ","Annee","Mois","Jour")],
        x[,match(input.labels, colnames(x))]
      )
      # Renomme les colonnes au format RECORD
      colnames(o) <- output.labels
      
      # Test sur la présence de données manquantes
      try(na.fail(o))
      
      # Ecriture des fichiers de sortie
      filename <- paste(unique(x$id),".txt", sep="")
      write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
      
      # Sortie
      return(data.frame(o))
    },
		
		climatik = {
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			# Ajout colonne Jour calendaires 
			o <- cbind(JourJ = 1:dim(o)[1], o)
			# Renomme les colonnes au format RECORD
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))
					
			# Ecriture des fichiers de sortie
			filename <- paste(output.prefix,"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		},
		
    # Format id, site, [mesures]
		simple = {	
			# Selection des colonnes utilisées pour la simulation
			o <- x[,match(input.labels, colnames(x))]
			
      # Renommage au format RECORD 
			colnames(o) <- output.labels
			
			# Test sur la présence de données manquantes
			try(na.fail(o))
					
			# Ecriture des fichiers de sortie
			filename <- paste(unique(x$id),"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		}
	)
}

# Simulation ####

# Mise en forme de plan d'expérience spécifique des différents outils (rsunflo, websim, varieto)
#' @export design
design <- function(design, file, template="default", format="websim", user="casadebaig") {
  switch(
    template,
    
    default = {
      switch(
        format,
      
        websim = {
          
          # Mise en forme des champs de date, duration.
          p <- plyr::mutate(
            design,
            id = paste(carol, genotype, sep="_"),
            file = paste(user,"/meteo/", carol, ".txt", sep=""),
            duration = as.character(crop_harvest - begin + 5),
            begin = format(begin, "%Y-%m-%d"),
            crop_sowing = format(crop_sowing, "%d/%m"),
            crop_emergence = ifelse(
              format(crop_emergence, "%m") == "01",
              "00/00",
              format(crop_emergence, "%d/%m")
            ),
            crop_harvest = format(crop_harvest, "%d/%m"),
            nitrogen_date_1 = format(nitrogen_date_1, "%d/%m"),
            nitrogen_date_2 = format(nitrogen_date_2, "%d/%m"),
            water_date_1 = format(water_date_1, "%d/%m"),
            water_date_2 = format(water_date_2, "%d/%m"),
            water_date_3 = format(water_date_3, "%d/%m"),
          )
          
          # Mise en forme du fichier 
          # Entetes depuis fichier csv websim
          names.websim <- c("Nom","Debut","Duree","date_TT_E1/77","date_TT_F1/78",
                            "date_TT_M0/79","date_TT_M3/80","TLN/72","bSF/75",
                            "cSF/76","ext/81","a_LE/73","a_TR/74","IRg/69",
                            "thp/82","datas_file/1","profondeur/68","Hcc_C1/59",
                            "Hpf_C1/61","Hcc_C2/60","Hpf_C2/62","da_C1/66",
                            "da_C2/67","TC/64","Vp/65","dateLevee_casForcee/54",
                            "rh1/55","rh2/56","Hini_C1/51","Hini_C2/52","jsemis/25",
                            "jrecolte/24","densite/23","date_ferti_1/13","apport_ferti_1/3",
                            "date_ferti_2/14","apport_ferti_2/4","date_irrig_1/17",
                            "apport_irrig_1/7","date_irrig_2/18","apport_irrig_2/8",
                            "date_irrig_3/19","apport_irrig_3/9")
          
          # Entetes depuis fichier xls ou r pour rsunflo (ordre de websim)
          names.rsunflo <- c("id","begin","duration","TDE1","TDF1","TDM0","TDM3",
                             "TLN","LLH","LLS","K","LE","TR","HI","OC","file",
                             "root_depth","field_capacity_1","wilting_point_1",
                             "field_capacity_2","wilting_point_2", "soil_density_1",
                             "soil_density_2","stone_content","mineralization",
                             "crop_emergence","nitrogen_initial_1","nitrogen_initial_2",
                             "water_initial_1","water_initial_2","crop_sowing",
                             "crop_harvest","crop_density","nitrogen_date_1",
                             "nitrogen_dose_1","nitrogen_date_2","nitrogen_dose_2",
                             "water_date_1","water_dose_1","water_date_2","water_dose_2",
                             "water_date_3","water_dose_3")
          
          p <- p[,names.rsunflo]
          names(p) <- names.websim
          
          # Ecriture
          writeWorksheetToFile(file=file, data=p, sheet="Feuille1")
          
        }
      )
    }
  )
}



# Simulation unitaire depuis une ligne d'un plan d'expérience
# TODO : adaptation de la fonction au plan : 
#   automatique selon les infos du plan : non renseigné = defaut du vpz
#' @export play

play <- function(model, design, unit, template="default") 
{
  
  switch(template,
         
    # default : 2 horizons de sol, tout paramètres variétaux, conduite intensive, levée forcée (n=42)
    default = {
      r <- results(
        run(
          model,
          begin  							                = design[["begin"]][unit],
          duration					              		= design[["duration"]][unit],
          CONFIG_ClimatNomFichier.meteo_file	= as.character(design[["file"]][unit]),
          CONFIG_SimuInit.rh1                 = design[["nitrogen_initial_1"]][unit],
          CONFIG_SimuInit.rh2                 = design[["nitrogen_initial_2"]][unit],
          CONFIG_SimuInit.Hini_C1             = design[["water_initial_1"]][unit],
          CONFIG_SimuInit.Hini_C2             = design[["water_initial_2"]][unit],
          CONFIG_SimuInit.dateLevee_casForcee = ifelse(format(design[["crop_emergence"]][unit], "%m") == "01",
                                                      "00/00", format(design[["crop_emergence"]][unit], "%d/%m")
                                                ),
          CONFIG_Sol.profondeur               = design[["root_depth"]][unit],
          CONFIG_Sol.Vp  		                  = design[["mineralization"]][unit],
          CONFIG_Sol.Hcc_C1 		              = design[["field_capacity_1"]][unit],
          CONFIG_Sol.Hcc_C2 		              = design[["field_capacity_2"]][unit],
          CONFIG_Sol.Hpf_C1 		              = design[["wilting_point_1"]][unit],
          CONFIG_Sol.Hpf_C2 		              = design[["wilting_point_2"]][unit],
          CONFIG_Sol.da_C1 		 	              = design[["soil_density_1"]][unit],
          CONFIG_Sol.da_C2 		    	          = design[["soil_density_2"]][unit],
          CONFIG_Sol.TC 		                  = design[["stone_content"]][unit],
          CONFIG_Conduite.jsemis    		    	= format(design[["crop_sowing"]][unit], "%d/%m"),
          CONFIG_Conduite.jrecolte            = format(design[["crop_harvest"]][unit], "%d/%m"),
          CONFIG_Conduite.densite        	    = design[["crop_density"]][unit],
          CONFIG_Conduite.date_ferti_1       	= format(design[["nitrogen_date_1"]][unit], "%d/%m"),
          CONFIG_Conduite.date_ferti_2        = format(design[["nitrogen_date_2"]][unit], "%d/%m"),
          CONFIG_Conduite.apport_ferti_1     	= design[["nitrogen_dose_1"]][unit],
          CONFIG_Conduite.apport_ferti_2      = design[["nitrogen_dose_2"]][unit],
          CONFIG_Conduite.date_irrig_1        = format(design[["water_date_1"]][unit], "%d/%m"),
          CONFIG_Conduite.date_irrig_2        = format(design[["water_date_2"]][unit], "%d/%m"),
          CONFIG_Conduite.date_irrig_3        = format(design[["water_date_3"]][unit], "%d/%m"),
          CONFIG_Conduite.apport_irrig_1     	= design[["water_dose_1"]][unit],
          CONFIG_Conduite.apport_irrig_2      = design[["water_dose_2"]][unit],
          CONFIG_Conduite.apport_irrig_3      = design[["water_dose_3"]][unit],
          CONFIG_Variete.date_TT_E1  		      = design[["TDE1"]][unit],
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
          CONFIG_Variete.thp   				        = design[["OC"]][unit]
        )
      ) 
    },
    
    # gem : profondeur de sol, conduite extensive, tout paramètres variétaux (n=21)
    gem = {
      r <- results(
        run(
          model,
          begin    						                = design[["begin"]][unit],
          duration					              		= design[["duration"]][unit],
          CONFIG_ClimatNomFichier.meteo_file	= as.character(design[["file"]][unit]),
          CONFIG_Sol.profondeur               = design[["root_depth"]][unit],
          CONFIG_Conduite.jsemis    		    	= format(design[["crop_sowing"]][unit], "%d/%m"),
          CONFIG_Conduite.jrecolte            = format(design[["crop_harvest"]][unit], "%d/%m"),
          CONFIG_Conduite.densite        	    = design[["crop_density"]][unit],
          CONFIG_Conduite.date_ferti_1       	= format(design[["nitrogen_date_1"]][unit], "%d/%m"),
          CONFIG_Conduite.apport_ferti_1     	= design[["nitrogen_dose_1"]][unit],
          CONFIG_Variete.date_TT_E1  		      = design[["TDE1"]][unit],
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
          CONFIG_Variete.thp   				        = design[["OC"]][unit]
        )
      ) 
    },

  # genotype : année, paramètres variétaux réduits ()
   genotype = {
     r <- results(
       run(
         model,
         begin      					                = design[["begin"]][unit],
         CONFIG_ClimatNomFichier.meteo_file	= as.character(design[["file"]][unit]),
         CONFIG_Variete.date_TT_E1  		      = 0.576 * design[["TDF1"]][unit],
         CONFIG_Variete.date_TT_F1  			    = design[["TDF1"]][unit],
         CONFIG_Variete.date_TT_M0  			    = 246.5 + design[["TDF1"]][unit],
         CONFIG_Variete.date_TT_M3  			    = design[["TDM3"]][unit],
         CONFIG_Variete.TLN     			        = design[["TLN"]][unit],
         CONFIG_Variete.ext     			        = design[["K"]][unit],
         CONFIG_Variete.bSF   				        = design[["LLH"]][unit],
         CONFIG_Variete.cSF   				        = design[["LLS"]][unit],
         CONFIG_Variete.a_LE  				        = design[["LE"]][unit],
         CONFIG_Variete.a_TR  				        = design[["TR"]][unit],
         CONFIG_Variete.IRg   				        = design[["HI"]][unit],
         CONFIG_Variete.thp   				        = design[["OC"]][unit]
       )
     ) 
   }
  )
  
  # Retour 
  return(r)
}


# Mise en forme des données brutes de sortie
#' @export shape
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
			colnames(x) <- c("time","RUE","RIE","LAI","TDM",
	                   "PhenoStage","TTA2","TM","FNRUE","NNI","NAB",
	                   "ETRETM","FHRUE","FHTR","FTSW","FTRUE",
                       "OC","GY","ETP","RR","GR","TN","TX")
	    },
	             
    end = {
		  # Nettoyage des noms de colonne
		  x <- x[[1]]
		  colnames(x) <- sub(".*\\.","", colnames(x))
      
		  # Conversion de date VLE (JDN cf. http://en.wikipedia.org/wiki/Julian_day)
		  x <- mutate(x, time = as.Date(time, origin = "1970-01-01") - 2440588)
      
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
      
      # Conversion de date VLE (JDN cf. http://en.wikipedia.org/wiki/Julian_day)
      x <- mutate(x, time = as.Date(time, origin = "1970-01-01") - 2440588)
      
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


# Fonction de synthèse des covariables (1 valeur par usm)
#' @export indicate
indicate <- function(x, view="timed") {
  
  switch(view,
    
    timed = {
      # Définition des périodes d'intégration
      # levée - fin maturité
      EH <- (x$PhenoStage > 1 & x$PhenoStage < 6)
      # levée - floraison
      #EF <- (x$PhenoStage == 2 | x$PhenoStage == 3)
      # initiation florale - début maturité
      #FIM <- (x$PhenoStage == 3 | x$PhenoStage == 4)
      # floraison - début maturité
      #FM <- x$PhenoStage == 4
      # début maturité - fin maturité
      #MH <- x$PhenoStage == 5
      
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
        SFHTR = sum(1 - x$FHTR[EH]),
        SFHRUE = sum(1 - x$FHRUE[EH]), 
        
        # Contraintes azotées
        # NNIF = x[x$PhasePhenoPlante==4,"NNI"][1], # INN floraison
        SNNI = sum(1 - x$NNI[EH & x$NNI <1]), #  déficit d'azote 
        SNAB = diff(range(x$NAB[EH])),  # quantité totale d'azote absorbé 
        SFNRUE = sum(1 - x$FNRUE[EH]),
        
        # Contraintes thermiques
        SFTRUE = sum(1 - x$FTRUE[EH]),
        
        # Évolution de la surface foliaire
        LAI = max(x$LAI[EH]),
        DSF = sum(x$LAI[EH]), 
        
        # Rayonnement intercepté (PAR)
        SIR = sum(x$RIE[EH] * x$GR[EH] * 0.48),
        
        # Photosynthèse
        MRUE = mean(x$RUE[EH]),
        
        # Biomasse accumulée
        STDM = max(x$TDM[EH]),
        
        # Performances
        TT = max(x$TTA2[EH]),
        GY = max(x$GY),
        OC = max(x$OC)
      ) 
    },
         
    diagvar = {
       # Définition des périodes d'intégration
       # levée - fin maturité
       EH <- (x$PhenoStage > 1 & x$PhenoStage < 6)
       # semis - levée
       SE <- (x$PhenoStage == 1)
       # levée - floraison
       EF <- (x$PhenoStage == 2 | x$PhenoStage == 3)
       # initiation florale - début maturité
       FIM <- (x$PhenoStage == 3 | x$PhenoStage == 4)
       # floraison - début maturité
       FM <- x$PhenoStage == 4
       # début maturité - fin maturité
       MH <- x$PhenoStage == 5
           
       # Calcul des indicateurs
       o <- data.frame(
         # Ressources environnementales
         # Cumul de précipitations
         P_TOT = sum(x$RR[EH]),
         P_VEG = sum(x$RR[EF]),
         P_FLO = sum(x$RR[FM]),
         P_REM = sum(x$RR[MH]),
         
         # Déficit hydrique climatique : sum(P-ETP)
         PE_TOT = sum((x$RR-x$ETP)[EH]),
         PE_VEG = sum((x$RR-x$ETP)[EF]),
         PE_FLO = sum((x$RR-x$ETP)[FM]),
         PE_REM = sum((x$RR-x$ETP)[MH]),
         
         # Déficit hydrique édaphique : mean(ETR/ETM)
         DH_TOT = mean(x$ETRETM[EH]),
         DH_VEG = mean(x$ETRETM[EF]),
         DH_FLO = mean(x$ETRETM[FM]),
         DH_REM = mean(x$ETRETM[MH]),
         
         # Déficit hydrique édaphique qualitatif : length(ETR/ETM < 0.6)
         ISH_TOT = length(x$ETRETM[EH & x$ETRETM < 0.6]),
         ISH_VEG = length(x$ETRETM[EF & x$ETRETM < 0.6]), 
         ISH_FLO = length(x$ETRETM[FM & x$ETRETM < 0.6]),
         ISH_REM = length(x$ETRETM[MH & x$ETRETM < 0.6]),
         
         # Déficit hydrique édaphique quantitatif : sum(1-FTSW)
         FTSW_TOT = sum(1 - x$FTSW[EH]),
         FTSW_VEG = sum(1 - x$FTSW[EF]), 
         FTSW_FLO = sum(1 - x$FTSW[FM]),
         FTSW_REM = sum(1 - x$FTSW[MH]),
         
         # Somme de température (base 6°C)
         ST_TOT = sum((x$TM[EH] - 6)[(x$TM[EH] - 6) > 0]),
         ST_VEG = sum((x$TM[EF] - 6)[(x$TM[EF] - 6) > 0]),
         ST_FLO = sum((x$TM[FM] - 6)[(x$TM[FM] - 6) > 0]),
         ST_REM = sum((x$TM[MH] - 6)[(x$TM[MH] - 6) > 0]),
         
         # Somme de rayonnement
         SR_TOT = sum(x$GR[EH]),
         SR_VEG = sum(x$GR[EF]),
         SR_FLO = sum(x$GR[FM]),
         SR_REM = sum(x$GR[MH]),
         
         # Somme de température à la levée (semis - levée)
         ST_A2 = sum((x$TM[SE] - 6)[(x$TM[SE] - 6) > 0]),
         
         # Température basse en debut de cycle (jours Tmin < 15)
         BT_VEG = length(x$TN[EF][x$TN[EF] < 15]),
         
         # Température haute en fin de cycle
         HT_REM = length(x$TX[FM][x$TX[FM] > 32]),
         
         # Azote absorbé avant maturité (Nabs / Rendement ?)
         N_TOT = max(x$NAB[EF | FM]),
         
         # INN à la floraison
         INN_F1 = x$NNI[FM][1],
         
         # Nombre de jours INN < 0.8 jusqu'à M0
         ISN_M0 = length(x$NNI[EF | FM][x$NNI[EF | FM] < 0.8]),
         IEN_M0 = length(x$NNI[EF | FM][(x$NNI[EF | FM] > 1.2) & (x$NNI[EF | FM] < 2)]),
         
         # Indice foliaire maximum
         IF_MAX = max(x$LAI),
         
         # Durée de surface foliaire : sum(x$LAI)
         DSF = sum(x$LAI[EH]),
         
         # Biomasse
         PS_TOT = max(x$TDM[EH]),
         PS_F1 = x$TDM[FM][1],
         
         # Performance
         RDT_SIM = max(x$GY),
         TH_SIM = max(x$OC)
       ) 
     }         
  )
  return(o)
}


# Dynamique de FTSW sur la période de culture
#' @export indicate_ftsw
indicate_ftsw <- function(x) {
  
  # Période de culture (levée - maturité)
  crop = (x$PhenoStage >1 & x$PhenoStage <6)
  
  # Variable dynamique
  o <- data.frame(
    t = 1:length(crop[crop==TRUE]),
    ftsw = x$FTSW[crop]
  )
  return(o)
}

# Visualisation  des simulations
#' @export display
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

# Analysis ####

# Calculer erreur de prédiction
#' @export evaluate_error
evaluate_error <- function(data, formula, output="numeric") {
  
  # Calcul de l'erreur d'ajustement
  error <- ddply(
    data,
    as.formula(formula), summarise, 
    rmse = rmse(simulated, observed),
    rrmse = round(rmse(simulated, observed)/mean(observed, na.rm=TRUE)*100, 1),
    efficiency = efficience(simulated, observed),
    bias = biais(simulated, observed)
  )
  
  # Labels ggplot2 pour l'erreur d'ajustement
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


# Graphes simulés / observés
#' @export evaluate
evaluate <- function(data, formula, color, scale="free", ...) {
  # Graphes
  ggplot(data=data, aes(x=observed, y=simulated)) + 
    geom_point(aes_string(color=color), ...) +
    facet_wrap(as.formula(formula), scale=scale) +
    stat_smooth(method="lm", se=FALSE, linetype=2, color="black") +
    geom_abline(intercept=0, slope=1) +
    geom_text(
      data=evaluate_error(data, formula, output="label"),
      aes(x=Inf, y=-Inf, label=label),
      colour="black", hjust=1.1, vjust=-1, size=4
    ) +
    theme_bw() + labs(x="Observed data", y="Simulated data")
}


# Impact d'un trait sur le rendement moyen
#' @export impact
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

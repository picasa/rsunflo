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
        Jour = day(date) 
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
		
	   debug = {
	     # Nettoyage des noms de colonne
	     x <- x[[1]]
	     colnames(x) <- sub(".*\\.","", colnames(x))
	     
	     # Conversion de date VLE (JDN cf. http://en.wikipedia.org/wiki/Julian_day)
	     # to JDN as.numeric(as.Date(x, format= "%m/%d/%Y")) + 2440588
	     # delta = julian(x = 01, d = 01, y = 1970, origin = c(month=11, day=24, year=-4713))
	     x <- mutate(x, time = as.Date(time, origin = "1970-01-01") - 2440588)
	   },
	       
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
indicate <- function(x, integration="crop", Tb=4.8) {
  
  # Définition des périodes d'intégration
  # semis - levee
  SE <- x$PhenoStage == 1
  # levée - fin maturité
  EH <- (x$PhenoStage > 1 & x$PhenoStage < 6)
  # levée - debut maturité
  EM <- (x$PhenoStage > 1 & x$PhenoStage < 5)
  # levée - floraison
  EF <- (x$PhenoStage == 2 | x$PhenoStage == 3)
  # initiation florale - début maturité
  FIM <- (x$PhenoStage == 3 | x$PhenoStage == 4)
  # floraison - début maturité
  FM <- x$PhenoStage == 4
  # floraison - fin maturité
  FH <- (x$PhenoStage == 4 | x$PhenoStage == 5)
  # début maturité - fin maturité
  MH <- x$PhenoStage == 5
  
  
  switch(integration,
    
    crop = {
      # Calcul des indicateurs
      o <- data.frame(
        # Graphes
        # xm <- melt(x, id.vars=c("time","TTA2"))
        # xyplot(value ~ time | variable, data=xm, type="l", scale="free")
        
        # Phenologie
        D_SE = sum(SE),
        D_EF = sum(EF),
        D_FM = sum(FM),
        D_MH = sum(MH),
        TT = sum((x$TM[EH] - Tb)[(x$TM[EH] - Tb) > 0]),
        
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
        SNAB = last(x$NAB[EH]),  # quantité totale d'azote absorbé 
        SFNRUE = sum(1 - x$FNRUE[EH]),
        
        # Contraintes thermiques
        SFTRUE = sum(1 - x$FTRUE[EH]),
        NHT = sum(x$TM[EH] > 28),
        NLT = sum(x$TM[EH] < 20),
        SHT = sum(1 - curve_thermal_high(x$TM[EH])),
        SLT = sum(1 - curve_thermal_low(x$TM[EH])),
        
        # Évolution de la surface foliaire
        LAI = max(x$LAI[EH]),
        LAD = sum(x$LAI[EH]), 
        
        # Rayonnement intercepté (PAR)
        SIR = sum(x$RIE[EH] * x$GR[EH] * 0.48),
        
        # Photosynthèse
        MRUE = mean(x$RUE[EH]),
        
        # Biomasse accumulée
        STDM = max(x$TDM[EH]),
        
        # Performances
        GY = max(x$GY),
        OC = max(x$OC)
      ) 
    },
         
    phase = {       
       # Calcul des indicateurs
       o <- data.frame(
         
         # Phenologie
         D_SE = sum(SE),
         D_EF = sum(EF),
         D_FM = sum(FM),
         D_MH = sum(MH),
         
         # Ressources environnementales
         # Somme de rayonnement
         SGR = sum(x$GR[EH]),
         SGR_EF = sum(x$GR[EF]),
         SGR_FM = sum(x$GR[FM]),
         SGR_MH = sum(x$GR[MH]),
         
         # Cumul de précipitations
         SRR = sum(x$RR[EH]),
         SRR_EF = sum(x$RR[EF]),
         SRR_FM = sum(x$RR[FM]),
         SRR_MH = sum(x$RR[MH]),
         
         # Cumul d'évapotranspiration potentielle
         SETP = sum(x$ETP[EH]),
         SETP_EF = sum(x$ETP[EF]),
         SETP_FM = sum(x$ETP[FM]),
         SETP_MH = sum(x$ETP[MH]),
         
         # Déficit hydrique climatique : sum(P-ETP)
         SCWD = sum((x$RR-x$ETP)[EH]),
         SCWD_EF = sum((x$RR-x$ETP)[EF]),
         SCWD_FM = sum((x$RR-x$ETP)[FM]),
         SCWD_MH = sum((x$RR-x$ETP)[MH]),
         
         # Déficit hydrique édaphique : mean(ETR/ETM)
         METR = mean(x$ETRETM[EH]),
         METR_EF = mean(x$ETRETM[EF]),
         METR_FM = mean(x$ETRETM[FM]),
         METR_MH = mean(x$ETRETM[MH]),
         
         # Déficit hydrique édaphique qualitatif : sum(ETR/ETM < 0.6)
         NETR = sum(x$ETRETM[EH] < 0.6),
         NETR_EF = sum(x$ETRETM[EF] < 0.6), 
         NETR_FM = sum(x$ETRETM[FM] < 0.6),
         NETR_MH = sum(x$ETRETM[MH] < 0.6),
         
         # Déficit hydrique édaphique quantitatif : sum(1-FTSW)
         SFTSW = sum(1 - x$FTSW[EH]),
         SFTSW_EF = sum(1 - x$FTSW[EF]), 
         SFTSW_FM = sum(1 - x$FTSW[FM]),
         SFTSW_MH = sum(1 - x$FTSW[MH]),
         
         # Effet de la contrainte hydrique sur la photosynthèse : sum(1-FHRUE)
         SFHRUE = sum(1 - x$FHRUE[EH]),
         SFHRUE_EF = sum(1 - x$FHRUE[EF]), 
         SFHRUE_FM = sum(1 - x$FHRUE[FM]),
         SFHRUE_MH = sum(1 - x$FHRUE[MH]),
         
         # Effet de la contrainte hydrique sur la transpiration : sum(1-FHTR)
         SFHTR = sum(1 - x$FHTR[EH]),
         SFHTR_EF = sum(1 - x$FHTR[EF]), 
         SFHTR_FM = sum(1 - x$FHTR[FM]),
         SFHTR_MH = sum(1 - x$FHTR[MH]),
         
         # Somme de température 
         TT = sum((x$TM[EH] - Tb)[(x$TM[EH] - Tb) > 0]),
         TT_SE = sum((x$TM[SE] - Tb)[(x$TM[SE] - Tb) > 0]),
         TT_EF = sum((x$TM[EF] - Tb)[(x$TM[EF] - Tb) > 0]),
         TT_FM = sum((x$TM[FM] - Tb)[(x$TM[FM] - Tb) > 0]),
         TT_MH = sum((x$TM[MH] - Tb)[(x$TM[MH] - Tb) > 0]),       
         
         # Contraintes thermiques
         SFTRUE = sum(1 - x$FTRUE[EH]),
         SFTRUE_EF = sum(1 - x$FTRUE[EF]), 
         SFTRUE_FM = sum(1 - x$FTRUE[FM]),
         SFTRUE_MH = sum(1 - x$FTRUE[MH]),
         
         # Chaud
         NHT = sum(x$TM[EH] > 28),
         NHT_EF = sum(x$TM[EF] > 28),
         NHT_FM = sum(x$TM[FM] > 28),
         NHT_MH = sum(x$TM[MH] > 28),
         SHT = sum(1 - curve_thermal_high(x$TM[EH])),
         SHT_EF = sum(1 - curve_thermal_high(x$TM[EF])),
         SHT_FM = sum(1 - curve_thermal_high(x$TM[FM])),
         SHT_MH = sum(1 - curve_thermal_high(x$TM[MH])),
         
         # Froid
         NLT = sum(x$TM[EH] < 20),
         NLT_EF = sum(x$TM[EF] < 20),
         NLT_FM = sum(x$TM[FM] < 20),
         NLT_MH = sum(x$TM[MH] < 20),
         SLT = sum(1 - curve_thermal_low(x$TM[EH])),
         SLT_EF = sum(1 - curve_thermal_low(x$TM[EF])),
         SLT_FM = sum(1 - curve_thermal_low(x$TM[FM])),
         SLT_MH = sum(1 - curve_thermal_low(x$TM[MH])),
         
         # Contraintes azotées
         # NNIF = x[x$PhasePhenoPlante==4,"NNI"][1], # INN floraison
         # Azote absorbé
         SNAB = max(x$NAB[EH]),
         SNAB_EF = max(x$NAB[EF]),
         SNAB_FM = max(x$NAB[FM]),
         SNAB_EM = max(x$NAB[EM]),
         SNAB_MH = max(x$NAB[MH]),
         
         # Indice de nutrition azoté (deficit azoté)
         SNNI = sum(1 - x$NNI[EH & x$NNI <1]),
         SNNI_EF = sum(1 - x$NNI[EF & x$NNI <1]),
         SNNI_FM = sum(1 - x$NNI[FM & x$NNI <1]),
         SNNI_MH = sum(1 - x$NNI[MH & x$NNI <1]),
         
         # Effet contrainte azoté sur la photosynthèse
         SFNRUE = sum(1 - x$FNRUE[EH]),
         SFNRUE_EF = sum(1 - x$FNRUE[EF]),
         SFNRUE_FM = sum(1 - x$FNRUE[FM]),
         SFNRUE_MH = sum(1 - x$FNRUE[MH]),
      
         # INN à la floraison
         NNI_F = x$NNI[FM][1],
         
         # Nombre de jours INN < 0.8 jusqu'à M0
         NNNID_EM = sum(x$NNI[EM] < 0.8),
         NNNIE_EM = sum((x$NNI[EM] > 1.2) & (x$NNI[EM] < 2)),
         
         # Indice foliaire maximum
         LAI = max(x$LAI),
         
         # Durée de surface foliaire : sum(x$LAI)
         LAD = sum(x$LAI[EH]),
         
         # Rayonnement intercepté (PAR)
         SIR = sum(x$RIE[EH] * x$GR[EH] * 0.48),
         SIR_EF = sum(x$RIE[EF] * x$GR[EF] * 0.48),
         SIR_FM = sum(x$RIE[FM] * x$GR[FM] * 0.48),
         SIR_MH = sum(x$RIE[MH] * x$GR[MH] * 0.48),
         
         # Photosynthèse
         MRUE = mean(x$RUE[EH]),
         
         # Biomasse
         STDM = max(x$TDM[EH]),
         STDM_F = x$TDM[FM][1],
         
         # Performance
         GY = max(x$GY),
         OC = max(x$OC)
       ) 
     }         
  )
  return(o)
}


# Visualisation  des simulations
#' @export display
display <- function(x, view="timed") {
  switch(
    view,
    timed = {
      d <- reshape2::melt(x, id.vars=c("time", "TTA2"))
      ggplot(d, aes(x=time, y=value)) +
        geom_line() +
        facet_wrap(~ variable, scale="free") +
        theme_bw()
    }
  )
}

# Analysis ####

# compute metrics for goodness of fit [@Wallach2014]
# TODO : use data argument and non standard evaluation ?
#' @export evaluate_error
evaluate_error <- function(data, observed="observed", simulated="simulated", output="numeric") {
  
  metrics <- data %>% 
    filter(complete.cases(.)) %>% 
    select_(observed=observed, simulated=simulated) %>%
    summarise(
      
      # general metrics
      n = n(),
      mean_observed = mean(observed),
      mean_simulated = mean(simulated),
      bias = mean_observed - mean_simulated,
      bias_squared = bias^2,
      SSE = sum((observed - simulated)^2),
      MSE = SSE/n,
      RMSE = MSE^0.5,
      RRMSE = RMSE/mean_observed,
      MAE = mean(abs(observed - simulated)),
      RMAE = MAE/mean(abs(observed)),
      RMAEP = mean(abs(observed - simulated)/abs(observed)),
      EF = 1 - sum((observed - simulated)^2)/sum((observed - mean_observed)^2),
      index_willmott = 1 - sum((observed - simulated)^2)/sum((abs(simulated - mean(observed)) + abs(observed - mean(observed)))^2),
      
      # MSE decomposition
      SDSD = (sd(simulated) - sd(observed))^2 * (n - 1)/n,
      LCS = 2 * sd(observed) * sd(simulated) * (1 - cor(observed, simulated)) * (n - 1)/n,
      NU = (1 - (cov(observed, simulated)/var(simulated)))^2 * var(simulated) * (n - 1)/n,
      LC = (1 - cor(observed, simulated)^2) * var(observed) * (n - 1)/n,
      
      # correlation index
      r_pearson=cor(simulated, observed, method="pearson"),
      p_pearson=cor.test(simulated, observed, method="pearson")$p.value,
      r_kendall=cor(simulated, observed, method="kendall"),
      p_kendall=cor.test(simulated, observed, method="kendall")$p.value,
      r_squared=cor(simulated, observed, method="pearson")^2
    )
   
  labels <- data.frame(
    label = paste(
      "RMSE =", format(metrics$RMSE, digits=2),
      ";",
      "bias =", format(metrics$bias, digits=2)
    )
  )
  
  switch(
    output,
    numeric = {return(metrics)},
    label = {return(labels)}
  )
}


# observed=f(simulated) evaluation graphs
#' @export evaluate_plot
evaluate_plot <- function(data, formula, color, scale="free", size_label=4, ...) {
  
  ggplot(data=data, aes(x=simulated, y=observed)) +
    geom_point(aes_string(color=color, ...)) +
    facet_wrap(as.formula(formula), scale=scale) +
    # stat_smooth(method="lm", se=FALSE, linetype=2, color="black") +
    geom_abline(intercept=0, slope=1) +
    geom_text(
      data=data %>% group_by_(formula) %>% do(evaluate_error(., output="label")),
      aes(x=Inf, y=-Inf, label=label),
      colour="black", hjust=1.1, vjust=-1, size=size_label
    ) +
    theme_bw() + labs(x="Simulated data", y="Observed data")
}


# residuals evaluation graphs
#' @export evaluate_residuals
evaluate_residuals <- function(data, formula, color, scale="free", size_label=4, ...) {
  
  data %>%
    mutate(residuals=observed-simulated) %>%
    ggplot(aes(simulated, residuals)) +
    geom_point(aes_string(color=color), ...) + 
    facet_wrap(as.formula(formula), scale=scale) +
    geom_hline(yintercept = 0) +
    geom_text(
      data=data %>% group_by_(formula) %>% do(evaluate_error(., output="label")),
      aes(x=Inf, y=-Inf, label=label),
      colour="black", hjust=1.1, vjust=-1, size=size_label
    ) +
    theme_bw() + labs(x="Simulated data", y="Residuals")
}



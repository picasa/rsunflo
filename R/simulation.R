# Tools for input, simulation and output data.

#' @import ggplot2
#' @import dplyr

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
        JourJ = lubridate::yday(date),
        Annee = lubridate::year(date),
        Mois = lubridate::month(date),
        Jour = lubridate::day(date) 
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

# Test design object for default column name and missing data
#' @export test_design
test_design <- function(object){
  
  # list default inputs for simulation
  list_inputs <- c(
    "file", "root_depth", "stone_content", "field_capacity_1", "wilting_point_1",
    "field_capacity_2", "wilting_point_2", "soil_density_1", "soil_density_2",
    "mineralization", "crop_sowing", "crop_harvest", "crop_density",
    "nitrogen_date_1", "nitrogen_dose_1", "nitrogen_date_2", "nitrogen_dose_2",
    "water_date_1", "water_dose_1", "water_date_2", "water_dose_2", "water_date_3",
    "water_dose_3", "crop_emergence", "water_initial_1", "water_initial_2",
    "nitrogen_initial_1", "nitrogen_initial_2", "TDE1", "TDF1", "TDM0", "TDM3",
    "TLN", "LLH", "LLS", "K", "LE", "TR", "HI", "OC", "begin", "end",
    "duration", "file")
  
  # test for default set of input names in object headers 
  testthat::expect_true(all(list_inputs %in% names(object)))
  
  # test for missing values in object columns
  # TODO : better test by returning positions object %>% filter_at(.vars=list_inputs, any_vars(is.na(.)))
  testthat::expect_false(any(object %>% select(!!list_inputs) %>% is.na()))
  
  # TODO test for formatting and units
  
  # TODO test for existence of files in indicated path
  # list_files <- paste0("~/.vle/pkgs-2.0/sunflo/data/", design %>% distinct(file) %>% pull(file))
  # file.exists(list_files)
  
  # TODO more test ideas
  # range(design$stone_content)
  # error_soil <- design %>% filter(field_capacity_1 <= wilting_point_1)
  # error_date <- design %>% mutate(cycle = crop_harvest - crop_sowing) %>% filter(cycle < 100)
  # error_climate : test year length in climate files
}


# run sunflo VLE model as a function of experimental design

#' @export play

play <- function(data, model=sunflo, unit) {
  
  # get parameters from design
  # TODO : get default parameter values from model
  data <- data %>% slice(unit)
  
  # run model with new parameters  
  output <- model %>% 
    run(
      cBegin.begin_date                   = as.character(data$begin),
      simulation_engine.duration          = as.numeric(data$duration),
      sunflo_climat.meteo_file            = as.character(data$file),
      itk.jsemis                          = as.character(data$crop_sowing),
      itk.jrecolte                        = as.character(data$crop_harvest),
      itk.densite                         = as.numeric(data$crop_density),
      itk.fertilization_1                 = paste0("date=",as.character(data$nitrogen_date_1),"$dose=",data$nitrogen_dose_1),
      itk.fertilization_2                 = paste0("date=",as.character(data$nitrogen_date_2),"$dose=",data$nitrogen_dose_2),
      itk.irrigation_1                    = paste0("date=",as.character(data$water_date_1),"$dose=",data$water_dose_1),
      itk.irrigation_2                    = paste0("date=",as.character(data$water_date_2),"$dose=",data$water_dose_2),
      CONFIG_SimuInit.init_value_N1       = as.numeric(data$nitrogen_initial_1),
      CONFIG_SimuInit.init_value_N3       = as.numeric(data$nitrogen_initial_2),
      CONFIG_Sol.Hini_C1                  = as.numeric(data$water_initial_1),
      CONFIG_Sol.Hini_C2                  = as.numeric(data$water_initial_2),
      CONFIG_Sol.profondeur               = as.numeric(data$root_depth),
      CONFIG_Sol.Vp  		                  = as.numeric(data$mineralization),
      CONFIG_Sol.Hcc_C1 		              = as.numeric(data$field_capacity_1),
      CONFIG_Sol.Hcc_C2 		              = as.numeric(data$field_capacity_2),
      CONFIG_Sol.Hpf_C1 		              = as.numeric(data$wilting_point_1),
      CONFIG_Sol.Hpf_C2 		              = as.numeric(data$wilting_point_2),
      CONFIG_Sol.da_C1 		 	              = as.numeric(data$soil_density_1),
      CONFIG_Sol.da_C2 		    	          = as.numeric(data$soil_density_2),
      CONFIG_Sol.TC 		                  = as.numeric(data$stone_content),
      CONFIG_Variete.date_TT_E1  		      = as.numeric(data$TDE1),
      CONFIG_Variete.date_TT_F1  			    = as.numeric(data$TDF1),
      CONFIG_Variete.date_TT_M0  			    = as.numeric(data$TDM0),
      CONFIG_Variete.date_TT_M3  			    = as.numeric(data$TDM3),
      CONFIG_Variete.TLN     			        = as.numeric(data$TLN),
      CONFIG_Variete.ext     			        = as.numeric(data$K),
      CONFIG_Variete.bSF   				        = as.numeric(data$LLH),
      CONFIG_Variete.cSF   				        = as.numeric(data$LLS),
      CONFIG_Variete.a_LE  				        = as.numeric(data$LE),
      CONFIG_Variete.a_TR  				        = as.numeric(data$TR),
      CONFIG_Variete.IRg   				        = as.numeric(data$HI),
      CONFIG_Variete.thp   				        = as.numeric(data$OC)
    ) %>%
    results()
  
  return(output) 
}

# call to rvle::run to expose all conditions for potential optimization, with fixed values listed in design (list)
#' @export play_optimize

play_optimize <- function(
  model, design, unit,
  
  # set parameters default value from design (from vpz ?)
  begin = design[["begin"]][unit],
  duration = design[["duration"]][unit],
  file = as.character(design[["file"]][unit]),
  nitrogen_initial_1 = design[["nitrogen_initial_1"]][unit],
  nitrogen_initial_2 = design[["nitrogen_initial_2"]][unit],
  water_initial_1 = design[["water_initial_1"]][unit],
  water_initial_2 = design[["water_initial_2"]][unit],
  crop_emergence = as.POSIXct("2016-01-01"),
  root_depth = design[["root_depth"]][unit],
  mineralization = design[["mineralization"]][unit],
  field_capacity_1 = design[["field_capacity_1"]][unit],
  field_capacity_2 = design[["field_capacity_2"]][unit],
  wilting_point_1 = design[["wilting_point_1"]][unit],
  wilting_point_2 = design[["wilting_point_2"]][unit],
  soil_density_1 = design[["soil_density_1"]][unit],
  soil_density_2 = design[["soil_density_2"]][unit],
  stone_content = design[["stone_content"]][unit],
  crop_sowing = design[["crop_sowing"]][unit],
  crop_harvest = design[["crop_harvest"]][unit],
  crop_density = design[["crop_density"]][unit],
  nitrogen_date_1 = design[["nitrogen_date_1"]][unit],
  nitrogen_date_2 = design[["nitrogen_date_2"]][unit],
  nitrogen_dose_1 = design[["nitrogen_dose_1"]][unit],
  nitrogen_dose_2 = design[["nitrogen_dose_2"]][unit],
  water_date_1 = design[["water_date_1"]][unit],
  water_date_2 = design[["water_date_2"]][unit],
  water_date_3 = design[["water_date_3"]][unit],
  water_dose_1 = design[["water_dose_1"]][unit],
  water_dose_2 = design[["water_dose_2"]][unit],
  water_dose_3 = design[["water_dose_3"]][unit],
  TDE1 = design[["TDE1"]][unit],
  TDF1 = design[["TDF1"]][unit],
  TDM0 = design[["TDM0"]][unit],
  TDM3 = design[["TDM3"]][unit],
  TLN = design[["TLN"]][unit],
  K = design[["K"]][unit],
  LLH = design[["LLH"]][unit],
  LLS = design[["LLS"]][unit],
  LE = design[["LE"]][unit],
  TR = design[["TR"]][unit],
  HI = design[["HI"]][unit],
  OC = design[["OC"]][unit],
  ...
){
  
  # set defaults conditions : 2 soils layers, all genotype-dependant parameters, high input management, emergence (n=42)
  setDefault(
    model,
    begin  							                = begin,
    duration					              		= duration,
    CONFIG_ClimatNomFichier.meteo_file	= file,
    CONFIG_SimuInit.rh1                 = nitrogen_initial_1,
    CONFIG_SimuInit.rh2                 = nitrogen_initial_2,
    CONFIG_SimuInit.Hini_C1             = water_initial_1,
    CONFIG_SimuInit.Hini_C2             = water_initial_2,
    CONFIG_SimuInit.dateLevee_casForcee = ifelse(
      format(crop_emergence,"%m") == "01",
      "00/00", format(crop_emergence, "%d/%m")),
    CONFIG_Sol.profondeur               = root_depth,
    CONFIG_Sol.Vp  		                  = mineralization,
    CONFIG_Sol.Hcc_C1 		              = field_capacity_1,
    CONFIG_Sol.Hcc_C2 		              = field_capacity_2,
    CONFIG_Sol.Hpf_C1 		              = wilting_point_1,
    CONFIG_Sol.Hpf_C2 		              = wilting_point_2,
    CONFIG_Sol.da_C1 		 	              = soil_density_1,
    CONFIG_Sol.da_C2 		    	          = soil_density_2,
    CONFIG_Sol.TC 		                  = stone_content,
    CONFIG_Conduite.jsemis    		    	= format(crop_sowing, format="%d/%m"),
    CONFIG_Conduite.jrecolte            = format(crop_harvest, format="%d/%m"),
    CONFIG_Conduite.densite        	    = crop_density,
    CONFIG_Conduite.date_ferti_1       	= format(nitrogen_date_1, format="%d/%m"),
    CONFIG_Conduite.date_ferti_2        = format(nitrogen_date_2, format="%d/%m"),
    CONFIG_Conduite.apport_ferti_1     	= nitrogen_dose_1,
    CONFIG_Conduite.apport_ferti_2      = nitrogen_dose_2,
    CONFIG_Conduite.date_irrig_1        = format(water_date_1, format="%d/%m"),
    CONFIG_Conduite.date_irrig_2        = format(water_date_2, format="%d/%m"),
    CONFIG_Conduite.date_irrig_3        = format(water_date_3, format="%d/%m"),
    CONFIG_Conduite.apport_irrig_1     	= water_dose_1,
    CONFIG_Conduite.apport_irrig_2      = water_dose_2,
    CONFIG_Conduite.apport_irrig_3      = water_dose_3,
    CONFIG_Variete.date_TT_E1  		      = TDE1,
    CONFIG_Variete.date_TT_F1  			    = TDF1,
    CONFIG_Variete.date_TT_M0  			    = TDM0,
    CONFIG_Variete.date_TT_M3  			    = TDM3,
    CONFIG_Variete.TLN     			        = TLN,
    CONFIG_Variete.ext     			        = K,
    CONFIG_Variete.bSF   				        = LLH,
    CONFIG_Variete.cSF   				        = LLS,
    CONFIG_Variete.a_LE  				        = LE,
    CONFIG_Variete.a_TR  				        = TR,
    CONFIG_Variete.IRg   				        = HI,
    CONFIG_Variete.thp   				        = OC
  )
  
  # save vpz image
  # saveVpz(model, "model.vpz")
  
  # evaluate the model
  r <- results(run(model))
  
  return(r)
}



# Mise en forme des données brutes de sortie
#' @export shape
shape <- function(data, view="generic") {
  
	switch(view,
		
	       generic = {
	         # shorten colums names
	         names(data[[1]]) <- sub(".*\\.","", names(data[[1]]))
	         
	         # rename output variables and
	         # convert VLE time format (JDN cf. http://en.wikipedia.org/wiki/Julian_day) to date
	         # delta = julian(x = 01, d = 01, y = 1970, origin = c(month=11, day=24, year=-4713))
	         output <- data %>% .[[1]] %>%
	           select(-time) %>% 
	           rename(time=current_date) %>% 
	           mutate(time=as.Date(time, origin="1970-01-01") - 2440588) 
	       },

	       timed = {
	         names(data[[1]]) <- sub(".*\\.","", names(data[[1]]))
	        
	         output <- data %>% .[[1]] %>% 
	           select(
	             time=current_date, TTA2=TT_A2, PhenoStage=PhasePhenoPlante,
	             TN=Tmin, TM=Mean, TX=Tmax, GR=RAD, PET=ETP, RR=Pluie,
	             FTSW, FHTR, FHRUE, ETPET=ETRETM, FTRUE=FT, NAB=Nabs, NNI=INN, FNRUE=FNIRUE, 
	             LAI, RIE=Ei, RUE=Eb, TDM, GY=photo_RDT_aFinMATURATION, OC=photo_TH_aFinMATURATION
	           ) %>% 
	           mutate(time=as.Date(time, origin="1970-01-01") - 2440588)
	       },
	       
	       end = {
	         names(data[[1]]) <- sub(".*\\.","", names(data[[1]]))
	         
	         output <- data %>% .[[1]] %>% 
	           select(time=current_date, GY=photo_RDT_aFinMATURATION, OC=photo_TH_aFinMATURATION) %>% 
	           mutate(time=as.Date(time, origin="1970-01-01") - 2440588) 
	       },
	)
  return(as_tibble(output))
}


# summarise timed output variables 
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

        # Phenologie
        D_SE = sum(SE),
        D_EF = sum(EF),
        D_FM = sum(FM),
        D_MH = sum(MH),
        TT = sum((x$TM[EH] - Tb)[(x$TM[EH] - Tb) > 0]),
        
        # Ressources environnementales
        SGR = sum(x$GR[EH] * 0.48), # PAR
        SRR = sum(x$RR[EH]),
        SPET = sum(x$PET[EH]),
        SCWD = sum(x$RR[EH] - x$PET[EH]),
        
        # Contraintes hydriques
        ## basés sur FTSW
        SFTSW = sum(1 - x$FTSW[EH]),
        NET = sum(x$ETPET[EH] < 0.6),
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
        SHT = sum(1 - curve_thermal_rue(x$TM[EH], type="high")),
        SLT = sum(1 - curve_thermal_rue(x$TM[EH], type="low")),
        
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
         SPET = sum(x$PET[EH]),
         SPET_EF = sum(x$PET[EF]),
         SPET_FM = sum(x$PET[FM]),
         SPET_MH = sum(x$PET[MH]),
         
         # Déficit hydrique climatique : sum(P-PET)
         SCWD = sum((x$RR-x$PET)[EH]),
         SCWD_EF = sum((x$RR-x$PET)[EF]),
         SCWD_FM = sum((x$RR-x$PET)[FM]),
         SCWD_MH = sum((x$RR-x$PET)[MH]),
         
         # Déficit hydrique édaphique : mean(ET/PET)
         MET = mean(x$ETPET[EH]),
         MET_EF = mean(x$ETPET[EF]),
         MET_FM = mean(x$ETPET[FM]),
         MET_MH = mean(x$ETPET[MH]),
         
         # Déficit hydrique édaphique qualitatif : sum(ET/PET < 0.6)
         NET = sum(x$ETPET[EH] < 0.6),
         NET_EF = sum(x$ETPET[EF] < 0.6), 
         NET_FM = sum(x$ETPET[FM] < 0.6),
         NET_MH = sum(x$ETPET[MH] < 0.6),
         
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
         
         # heat stress
         NHT = sum(x$TM[EH] > 28),
         NHT_EF = sum(x$TM[EF] > 28),
         NHT_FM = sum(x$TM[FM] > 28),
         NHT_MH = sum(x$TM[MH] > 28),
         SHT = sum(1 - curve_thermal_rue(x$TM[EH], type="high")),
         SHT_EF = sum(1 - curve_thermal_rue(x$TM[EF], type="high")),
         SHT_FM = sum(1 - curve_thermal_rue(x$TM[FM], type="high")),
         SHT_MH = sum(1 - curve_thermal_rue(x$TM[MH], type="high")),
         
         # cold stress
         NLT = sum(x$TM[EH] < 20),
         NLT_EF = sum(x$TM[EF] < 20),
         NLT_FM = sum(x$TM[FM] < 20),
         NLT_MH = sum(x$TM[MH] < 20),
         SLT = sum(1 - curve_thermal_rue(x$TM[EH], type="low")),
         SLT_EF = sum(1 - curve_thermal_rue(x$TM[EF], type="low")),
         SLT_FM = sum(1 - curve_thermal_rue(x$TM[FM], type="low")),
         SLT_MH = sum(1 - curve_thermal_rue(x$TM[MH], type="low")),
         
         # nitrogen stress 
         # NNIF = x[x$PhasePhenoPlante==4,"NNI"][1], # INN floraison
         # absorbed nitrogen
         SNAB = max(x$NAB[EH]),
         SNAB_EF = max(x$NAB[EF]),
         SNAB_FM = max(x$NAB[FM]),
         SNAB_EM = max(x$NAB[EM]),
         SNAB_MH = max(x$NAB[MH]),
         
         # nitrogen nutrition index 
         SNNI = sum(1 - x$NNI[EH & x$NNI <1]),
         SNNI_EF = sum(1 - x$NNI[EF & x$NNI <1]),
         SNNI_FM = sum(1 - x$NNI[FM & x$NNI <1]),
         SNNI_MH = sum(1 - x$NNI[MH & x$NNI <1]),
         
         # nitrogen impact on phytosynthesis
         SFNRUE = sum(1 - x$FNRUE[EH]),
         SFNRUE_EF = sum(1 - x$FNRUE[EF]),
         SFNRUE_FM = sum(1 - x$FNRUE[FM]),
         SFNRUE_MH = sum(1 - x$FNRUE[MH]),
      
         # NNI at flowering
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


# Visualize timed output variables
#' @export display
display <- function(data, view="timed") {
  switch(
    view,
    timed = {
      data %>% 
        gather(variable, value, -time, factor_key=TRUE) %>% 
        ggplot(aes(x=time, y=value)) +
        geom_line() +
        facet_wrap(~ variable, scales="free")     
    }
  )
}

# Analysis ####

# compute metrics for goodness of fit [@Wallach2014]
# TODO : use data argument and non standard evaluation 
# TODO : add accuracy, precision, recall
#' @export evaluate_error
evaluate_error <- function(
    data, observed="observed", simulated="simulated", output="numeric") {
  
  metrics <- data %>% 
    select_(observed=observed, simulated=simulated) %>%
    drop_na() %>% 
    summarise(
      
      # general metrics
      n = n(),
      mean_observed = mean(observed),
      mean_simulated = mean(simulated),
      bias = mean(observed - simulated),
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
      p_pearson=ifelse(n > 2, cor.test(simulated, observed, method="pearson")$p.value, NA),
      r_kendall=cor(simulated, observed, method="kendall"),
      p_kendall=ifelse(n > 2, cor.test(simulated, observed, method="kendall")$p.value, NA),
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
evaluate_plot <- function(
    data, variable, color, scale = "free", size_label = 4, alpha = 0.5) 
{
  
  data |> ggplot() +
    geom_point(aes(color = {{color}}, x = simulated, y = observed), alpha = alpha) + 
    facet_wrap(variable, scales = "free") + 
    geom_abline(intercept = 0, slope = 1) +
    geom_text(
      data = data %>% 
        group_by(!!!variable) %>%
        do(evaluate_error(., output = "label")), 
      aes(x = Inf, y = -Inf, label = label), colour = "black", 
      hjust = 1.1, vjust = -1, size = size_label) + theme_bw() + 
    labs(x = "Simulated data", y = "Observed data")
  
}



# residuals evaluation graphs
#' @export evaluate_residuals
evaluate_residuals <- function(data, formula, color, scale="free", size_label=4, ...) {
  
  data %>%
    mutate(residuals = observed - simulated) %>%
    ggplot(aes(simulated, residuals)) +
    geom_point(aes_string(color = color), ...) + 
    facet_wrap(as.formula(formula), scales = scale) +
    geom_hline(yintercept = 0) +
    geom_text(
      data=data %>% group_by_(formula) %>% do(evaluate_error(., output="label")),
      aes(x=Inf, y=-Inf, label=label),
      colour="black", hjust=1.1, vjust=-1, size=size_label
    ) +
    theme_bw() + labs(x="Simulated data", y="Residuals")
}



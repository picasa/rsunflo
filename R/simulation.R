# Tools for simulation

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
			filename <- paste("data/meteo/",unique(x$NomFichierMeteo),".txt", sep="")
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
			filename <- paste("output/",output.prefix,"_",unique(o$Annee),".txt", sep="")
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
			filename <- paste("output/",output.prefix,"_",unique(o$Annee),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		},
		
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
			filename <- paste("output/",unique(x$site),".txt", sep="")
			write.table(o, file = filename, sep="\t", dec=".", row.names = FALSE)
			
			# Sortie
			return(data.frame(o))
		}
	)
}


## Mise en forme des données brutes de sortie
shape <- function(x, view) {

	x <- x[[1]]
	colnames(x) <- sub(".*\\.","", colnames(x))
  
	switch(view,
		
		timed = {
			# viewDynamic : utilisation noms de variables en
			colnames(x) <- c("time","RUE","LUE","LAI","TDM",
	                   "PhasePhenoPlante","TTA2","TM","NNI","NAB",
	                   "ETRETM","FTSW","FT","OC","GY","ETP","RR","GR","TN","TX")
	    },
	    
		end = {
			# viewStatic
			longnames <- c(
				"photo_TH_aFinMATURATION",
				"photo_RDT_aFinMATURATION")
			colnames(x)[match(longnames, colnames(x))] <- c("OC","GY")
		}
	)
	return(x)
}


## Fonction de synthèse des covariables (1 valeur par usm)
indicate <- function(x) {
  
  # Définition des périodes d'intégration
  # levée - récolte
  EH <- (x$PhasePhenoPlante > 1 & x$PhasePhenoPlante < 6)
  # levée - floraison
  # EF <- (x$PhasePhenoPlante == 2 | x$PhasePhenoPlante == 3)
  # initiation florale - début maturité
  # FIM <- (x$PhasePhenoPlante == 3 | x$PhasePhenoPlante == 4)
  # floraison - début maturité
  # FM <- x$PhasePhenoPlante == 4
  # début maturité - récolte
  # MH <- x$PhasePhenoPlante == 5
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
    OCS = max(x$OC)
  )
  return(o)
}

## Dynamique de FTSW sur la période de culture
indicate.ftsw <- function(x) {
  
  # Période de culture (levée - maturité)
  crop = (x$PhasePhenoPlante >1 & x$PhasePhenoPlante <6)
  
  # Variable dynamique
  o <- data.frame(
    t = 1:length(crop[crop==TRUE]),
    ftsw = x$FTSW[crop]
  )
  return(o)
}

## Simulation unitaire depuis une ligne d'un plan d'expérience
play <- function(model, design, unit, view) 
{
	# Simulation
	r <- results(
		run(
      model,
			begin								                = design[["begin"]][unit],
			duration					              		= design[["duration"]][unit],
			CONFIG_ClimatNomFichier.datas_file	= paste("series",design[["file"]][unit], sep="/"),
			CONFIG_Sol.profondeur              	= design[["depth"]][unit],
			CONFIG_Conduite.jsemis    		    	= design[["sow.date"]][unit],
			CONFIG_Conduite.jrecolte            = design[["hav.date"]][unit],
		  CONFIG_Conduite.densite        	    = design[["dens.val"]][unit],
			CONFIG_Conduite.date_ferti_1       	= design[["nit.date"]][unit],
			CONFIG_Conduite.apport_ferti_1     	= design[["nit.dose"]][unit],
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
	
	# Fonctions de traitement des sorties
	# return(list(
	#	indicators = indicate(shape(r, view)),
	#	dynamics = indicate.ftsw(shape(r, view))
	#))
  
  # Retour pour debug
  return(shape(r, view))
}


# Analyse ####
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

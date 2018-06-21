#' @import ggplot2
#' @import dplyr
#' @import tidyr


# Unit conversions and tools ####


# File management ####

#' @export yday_date
yday_date <- function(yday, year) {
  as.Date(yday - 1, origin = paste0(year,"-01-01"))  
}


#' @export modelmaker_management
modelmaker_management <- function(x) {
  
  # Nitrogen (2 modalities)
  s <- x[x$Fertilisation != 0,c("date","Fertilisation")]
  names(s) <- c("date","dose")
  n <- data.frame(
    nitrogen_date_1 = s$date[1],
    nitrogen_dose_1 = s$dose[1],
    nitrogen_date_2 = s$date[2],
    nitrogen_dose_2 = s$dose[2]
  )
  
  # Water (3 modalities)
  s <- x[x$Irrigation != 0,c("date","Irrigation")]
  names(s) <- c("date","dose")
  w <- data.frame(
    water_date_1 = s$date[1],
    water_dose_1 = s$dose[1],
    water_date_2 = s$date[2],
    water_dose_2 = s$dose[2],
    water_date_3 = s$date[3],
    water_dose_3 = s$dose[3]
  )
  
  # Output
  return(data.frame(n,w))
}


# Statistical indicators and function ####


# Calculer l'efficience du modèle
#' @export efficiency
efficiency <- function (obs, sim) {
  1 - (sum((na.omit(obs- sim))^2)/sum((na.omit(obs) - mean(obs, na.rm=TRUE))^2))
}

# Not in
#' @export '%ni%'
'%ni%' <- Negate('%in%')



# Graphical representations ####

# Biplot pour les objets produits par agricolae::AMMI
#' @export biplot_ammi
biplot_ammi <- function(m) {
  
  env <- m$biplot[m$biplot$type == "ENV",]
  env <- mutate(env, names = rownames(env))
  gen <- m$biplot[m$biplot$type == "GEN",] 
  gen <- mutate(gen, names = rownames(gen))
  
  ggplot() +
    geom_vline(x=0, colour="grey50") + 
    geom_hline(y=0, colour="grey50") + 
    geom_text(
      data=env,
      aes(x=PC1, y=PC2, label=names),
      angle=0, size=3, colour="grey50"
    ) + 
    geom_segment(
      data=env,
      aes(x=0, y=0, xend=PC1, yend=PC2),
      size=0.2, colour="grey70"
    ) + 
    geom_text(
      data=gen,
      aes(x=PC1, y=PC2, label=names),
      angle=0, size=3, vjust=1
    ) +
    labs(
      x=paste("PC 1 (",m$analysis$percent[1]," %)", sep=""),
      y=paste("PC 2 (",m$analysis$percent[2]," %)", sep="")
    ) +
    theme_bw()  
}

# Scatterplot matrix
# input should be a dataframe or data_table without key and in wide format
#' @export splom

splom <- function(data, plot_size_lims=c(0,1)) {
  
  # add id and normalize values
  data <- data %>% mutate_all(funs(rescale)) %>% mutate(id=1:n())
  
  # list selected variables (traits) 
  list_variables <- data %>% select(-id) %>% names(.)
  
  # compute possible variable combinations, use factors to keep order
  list_variables_design <- list_variables %>%
    combn(., m=2) %>% t() %>% data.frame() %>%
    mutate(panel=1:n()) %>%
    rename(x_lab=X1, y_lab=X2) %>%
    mutate(
      x_lab=factor(x_lab, levels=list_variables),
      y_lab=factor(y_lab, levels=list_variables)
    )
  
  # create labels for matrix diagonal
  data_labels <- data_frame(
    x_lab=list_variables,
    y_lab=list_variables,
    x=0.5, y=0.5
  ) %>%
    mutate(
      x_lab=factor(x_lab, levels=list_variables),
      y_lab=factor(y_lab, levels=list_variables)
    )
  
  # join design with actual dataset (input space)
  data_splom <- list_variables_design %>%
    left_join(data %>% gather(x_lab, x, -id, factor_key=TRUE)) %>%
    left_join(data %>% gather(y_lab, y, -id, factor_key=TRUE))
  
  # compute correlations between variables
  data_cor <- data_splom %>%
    group_by(x_lab, y_lab) %>%
    summarise(
      cor=cor(x, y, use="pairwise.complete.obs"),
      p=cor.test(x, y)$p.value,
      n=n()
    ) %>%
    mutate(test=ifelse(p < 0.05, TRUE, FALSE)) %>%
    rename(x_lab=y_lab, y_lab=x_lab)
  
  # plot performance of optimal solution in feasibility space  
  plot <- ggplot() +
    geom_point(data=data_splom, aes(x, y)) +
    geom_text(data=data_cor, aes(x=0.5, y=0.5, label=round(cor, digits=2), color=test), size=4) +
    geom_text(data=data_labels, aes(x, y, label=x_lab), size=4, alpha=0.5) +
    facet_grid(y_lab ~ x_lab, drop=FALSE) +
    xlim(plot_size_lims) + ylim(plot_size_lims) + 
    theme(
      panel.background = element_blank(),
      axis.ticks = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_blank(),
      axis.title.y = element_blank(),
      axis.title.x = element_blank(),
      strip.background = element_blank(),
      strip.text.x = element_blank(),
      strip.text.y = element_blank(),
      legend.position="none"
    )
  
  return(plot)
}



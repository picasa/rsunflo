# Unit conversions and tools ####

# Compute distance between two points: http://en.wikipedia.org/wiki/Haversine_formula
#' @export distance_haversine
distance_haversine <- function(lat1, lon1, lat2, lon2) {
  
  # Earth radius in km
  R <- 6371
  delta_lon <- (lon2*pi/180 - lon1*pi/180) # decimal degrees to radians
  delta_lat <- (lat2*pi/180 - lat1*pi/180) # decimal degrees to radians
  a <- sin(delta_lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta_lon/2)^2
  c <- 2 * asin(min(1,sqrt(a)))
  d = R * c * 1000 # distance in m
  return(d)
}


# File management ####

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

# Calculer r² entre observé et simulé
#' @export rsq
rsq <- function (sim, obs, digits=2) {
  round(cor(sim, obs, na.rm=TRUE)^2, digits=digits)
}

# Calculer un biais
#' @export biais
biais <- function (sim, obs, digits=2) {
  round(mean(na.omit(sim - obs)), digits=digits)
}

# Calculer RMSE
#' @export  rmse
rmse <- function(sim, obs, digits=2) {
	round(sqrt(mean(na.omit(sim - obs)^2)), digits=digits)
}

# Calculer l'Efficience du modèle
#' @export efficience
efficience <- function (sim, obs, digits=2) {
  round(1 - (sum((na.omit(sim - obs))^2)/sum((na.omit(obs) - mean(obs, na.rm=TRUE))^2)), digits=digits)
}

# Savoir combien de variété sont dans l'intervalle de confiance observé
#' @export wic
wic <- function (obs, sim, ic) {
  d=(sim <= obs + ic) & (sim >= obs - ic)
  o=length(d[d==T])/length(ic)
  return(round(o, 3)) 
}

# Last : dernière valeur non nulle d'un vecteur
# @export last
# last <- function(x) {tail(x[x != 0], n = 1)}

# Not in
#' @export '%ni%'
'%ni%' <- Negate('%in%')

# Correspondance partielle entre les noms de variétés fournis et une liste de référence
# max.distance = list(sub=3, del=6, ins=3)
match_fuzzy <- function(x, reference, index=1){
  agrep(pattern = x, x = reference, max.distance = 0.1, value=TRUE, ignore.case=TRUE)[index]
}




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

# Scatterplot pair matrix
# https://github.com/mike-lawrence/ez/blob/master/R/ezCor.R
#' @export ggpairs
ggpairs <- 
  function(
    data
    , r_size_lims = c(10,20)
    , point_alpha = .5
    , density_height = 1
    , density_adjust = 1
    , density_colour = 'lightgrey'
    , label_size = 10
    , label_colour = 'black'
    , label_alpha = .5
    , lm_colour = 'red'
    , ci_colour = 'green'
    , ci_alpha = .5
    , test_alpha = .05
    , test_correction = 'none'
  ){
    ntests = ((((ncol(data)-1)^2)-(ncol(data)-1))/2)
    if(test_correction[1]=='bonferroni'){
      test_alpha = test_alpha/ntests
    }else{
      if(test_correction[1]=='sidak'){
        test_alpha = 1-(1-test_alpha)^(1/ntests)
      }
    }
    for(i in 1:length(data)){
      data[,i]=(data[,i]-mean(data[,i],na.rm=T))/sd(data[,i],na.rm=T)
    }
    z=data.frame()
    z_cor = data.frame()
    i = 1
    j = i
    while(i<=length(data)){
      if(j>length(data)){
        i=i+1
        j=i
      }else{
        x = data[,i]
        y = data[,j]
        toss = is.na(x) | is.na(y)
        x = x[!toss]
        y = y[!toss]
        temp=as.data.frame(cbind(x,y))
        temp=cbind(temp,names(data)[i],names(data)[j])
        z=rbind(z,temp)
        this_cor = round(cor(x,y),2)
        this_cor.test = cor.test(x,y)
        this_col = ifelse(this_cor.test$p.value<test_alpha,'a','b')
        this_size = (this_cor)^2
        cor_text = ifelse(
          this_cor==0
          , '0'
          , ifelse(
            this_cor==1
            , '1'
            , ifelse(
              this_cor==-1
              , '-1'
              , ifelse(
                this_cor>0
                ,substr(format(c(this_cor,.123456789),digits=2)[1],2,4)
                ,paste('-',substr(format(c(this_cor,.123456789),digits=2)[1],3,5),sep='')
              )
            )
          )
        )
        b=as.data.frame(cor_text)
        b=cbind(b,this_col,this_size,names(data)[j],names(data)[i])
        z_cor=rbind(z_cor,b)
        j=j+1
      }
    }
    names(z)=c('x','y','x_lab','y_lab')
    z=z[z$x_lab!=z$y_lab,]
    names(z_cor)=c('cor','p','rsq','x_lab','y_lab')
    z_cor=z_cor[z_cor$x_lab!=z_cor$y_lab,]
    diag = melt(data,measure.vars=names(data))
    names(diag)[1] = 'x_lab'
    diag$y_lab = diag$x_lab
    dens = ddply(
      diag
      , .(x_lab,y_lab)
      , function(x){
        d = density(x$value[!is.na(x$value)],adjust=density_adjust)
        d = data.frame(x=d$x,y=d$y)
        d$ymax = d$y*(max(abs(c(z$x,z$y)))*2*density_height)/max(d$y) - max(abs(c(z$x,z$y)))*density_height
        d$ymin = - max(abs(c(z$x,z$y)))*density_height
        return(d)
      }
    )
    labels = ddply(
      diag
      , .(x_lab,y_lab)
      , function(x){
        to_return = data.frame(
          x = 0
          , y = 0
          , label = x$x_lab[1]
        )
        return(to_return)
      }
    )
    points_layer = layer(
      geom = 'point'
      , geom_par = list(
        alpha = point_alpha
      )
      , data = z
      , mapping = aes_string(
        x = 'x'
        , y = 'y'
      )
    )
    lm_line_layer = layer(
      geom = 'line'
      , geom_params = list(
        colour = lm_colour
      )
      , stat = 'smooth'
      , stat_params = list(method = 'lm')
      , data = z
      , mapping = aes_string(
        x = 'x'
        , y = 'y'
      )
    )
    lm_ribbon_layer = layer(
      geom = 'ribbon'
      , geom_params = list(
        fill = ci_colour
        , alpha = ci_alpha
      )
      , stat = 'smooth'
      , stat_params = list(method = 'lm')
      , data = z
      , mapping = aes_string(
        x = 'x'
        , y = 'y'
      )
    )
    cor_text_layer = layer(
      geom = 'text'
      , data = z_cor
      , mapping = aes_string(
        label = 'cor'
        , size = 'rsq'
        , colour = 'p'
      )
      , x = 0
      , y = 0
    )
    dens_layer = layer(
      geom = 'ribbon'
      , geom_par = list(
        colour = 'transparent'
        , fill = density_colour
      )
      , data = dens
      , mapping = aes_string(
        x = 'x'
        , ymax = 'ymax'
        , ymin = 'ymin'
      )
    )
    label_layer = layer(
      geom = 'text'
      , geom_par = list(
        colour = 'black'
        , size = label_size
        , alpha = .5
      )
      , data = labels
      , mapping = aes_string(
        x='x'
        , y='y'
        , label='label'
      )
    )
    y_lab = NULL
    x_lab = NULL
    f = facet_grid(y_lab~x_lab)
    packs = installed.packages()
    ggplot2_version_char = packs[dimnames(packs)[[1]]=='ggplot2',dimnames(packs)[[2]]=='Version']
    ggplot2_version_char = strsplit(ggplot2_version_char,'.',fixed=T)[[1]]
    if((ggplot2_version_char[1]>0)|(ggplot2_version_char[2]>9)|(ggplot2_version_char[3]>1)){
      o = theme(
        panel.grid.minor = element_blank()
        ,panel.grid.major = element_blank()
        ,axis.ticks = element_blank()
        ,axis.text.y = element_blank()
        ,axis.text.x = element_blank()
        ,axis.title.y = element_blank()
        ,axis.title.x = element_blank()
        ,legend.position='none'
        ,strip.background = element_blank()
        ,strip.text.x = element_blank()
        ,strip.text.y = element_blank()
        ,panel.background = element_rect(fill="transparent", colour=NA)
      )
    }else{
      o = opts(
        panel.grid.minor = theme_blank()
        ,panel.grid.major = theme_blank()
        ,axis.ticks = theme_blank()
        ,axis.text.y = theme_blank()
        ,axis.text.x = theme_blank()
        ,axis.title.y = theme_blank()
        ,axis.title.x = theme_blank()
        ,legend.position='none'
        ,strip.background = theme_blank()
        ,strip.text.x = theme_blank()
        ,strip.text.y = theme_blank()
      )
    }
    x_scale = scale_x_continuous(limits = c( -1*max(abs(dens$x)) , max(abs(dens$x)) ) )
    size_scale = scale_size(limits = c(0,1),range=r_size_lims)
    return(
      ggplot(z_cor)+
        points_layer+
        lm_ribbon_layer+
        lm_line_layer+
        dens_layer+
        label_layer+
        cor_text_layer+
        f+
        o+
        x_scale+
        size_scale
    )
  }


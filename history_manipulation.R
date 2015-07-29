

#### Draw smiles at day ###


require(dplyr)
require(tidyr)
require(ggplot2)


# +------------------------------------+
# | Prepare data
# +------------------------------------+
  
#   rts.data = read.csv('RTSI.txt') %>% select(c(3, 8)) %>% mutate(Dates = as.Date(as.character(X.DATE.), format='%Y%m%d')) %>% select(c(3, 2))
#   names(rts.data) = c('Dates', 'Close')
#   save(rts.data, file = 'rtsi.RData')

  load('rtsi.RData')
  
#   smile.data = read.csv(file = 'ri_smile.csv', sep = ';', header=T, dec=',') %>% select(c(-1)) 
#   smile.data$tms = as.Date(substr(as.character(smile.data$tms), 0, 10))
#   save(smile.data, file = 'smile.RData')

  load('smile.RData')

  dates.rng = c(min(smile.data$tms), max(smile.data$tms))
  

# +------------------------------------+
# | For each option series calc smile
# | External variables used: all.data
# +------------------------------------+

  CalcSmilesSeries = function(strikeRng = 0.2, 
                              smileDate = as.Date('2010-09-06') ){
  #  browser()
  ### Find coefs for intuted date
    vx.at.date = smile.data %>% filter(tms == smileDate)
    
  ### Make strikes range, include futures values
    rng = strikeRng  
    strikes = seq(min(vx.at.date$fut_price)*(1-rng), max(vx.at.date$fut_price)*(1+rng), length.out = 50 )
    strikes = sort(c(strikes, vx.at.date$fut_price))
    
  ### Calc smile for every exp.date, strike value
    smiles = lapply( c(1:nrow(vx.at.date)), function(x){
      x.row = x
      sapply(strikes, function(x){
        strike = x
        fut    = vx.at.date[x.row, 'fut_price', drop=T]
        tdays  = vx.at.date[x.row, 't', drop=T] * 250
        coef.vector = as.vector(vx.at.date[x.row, c('s', 'a', 'b', 'c', 'd', 'e')])
        vxSmile(strike, fut, tdays, coef.vector, method = 1)
      })
    })
  
  ### Arrange data for ggplot
    names(smiles) = as.vector(vx.at.date$small_name)
    smiles = gather(data = as.data.frame(c(list(strike = strikes), smiles)), key=strike )
    names(smiles) = c('Strike', 'BaseFutures', 'IV')
    smiles$BaseFutures = as.character(smiles$BaseFutures)
    fut.days = vx.at.date %>% select(small_name, t) %>% mutate(tdays = as.factor(round(t * 250, 0))) 
    fut.days$small_name = as.character(fut.days$small_name)
    #%>% 
    dplyr::left_join(smiles, fut.days, by = c('BaseFutures' = 'small_name'))
    
    return(smiles)
  }
    

  xtest = CalcSmilesSeries()
  xtest$BaseFutures = as.character(xtest$BaseFutures)
  str(xtest)



# +------------------------------------+
# | IV smile functions
# +------------------------------------+
vxSmile = function(strike, fut, tdays, coef.vector=NULL, method=2)
{
  
  s = try(as.numeric(coef.vector[['s']]), silent = T)
  a = try(as.numeric(coef.vector[['a']]), silent = T)
  b = try(as.numeric(coef.vector[['b']]), silent = T)
  c = try(as.numeric(coef.vector[['c']]), silent = T)
  d = try(as.numeric(coef.vector[['d']]), silent = T)
  e = try(as.numeric(coef.vector[['e']]), silent = T)
  f = try(as.numeric(coef.vector[['f']]), silent = T)
  g = try(as.numeric(coef.vector[['g']]), silent = T)
  
  
  try({ 
    if(method==1) 
      vxs=a + b*(1 - e ^ ( (-1)*c*( 1/(tdays/365)^0.5 * log(strike / fut)-s )^2 )) +  d * atan(e * (1 / (tdays / 365) ^ 0.5 * log(strike / fut) - s)) / e
    
    if(method==2)  
      vxs =  a + b*(1 - exp(-c * (1 / (tdays / 365) ^ 0.5 * log(strike / fut) - s) ^ 2)) + d * atan(e * (1 / (tdays / 365) ^ 0.5 * log(strike / fut) - s)) / e
    
    if(method==3)
      vxs = a + b*strike + c*strike^2 + d*strike^3 + e*strike^4 + f*strike^5 + g*strike^6
    
  }, silent=T)
  
  return(as.numeric(vxs))
  
}

  



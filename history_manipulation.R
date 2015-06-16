

#### Draw smiles at day ###
### test new commit

require(dplyr)
require(tidyr)
require(ggplot2)
source(file = 'C:\\Users\\arhipov\\Documents\\RBackup\\.Structure\\deriv_vxsmile.R')

# +------------------------------------+
# | Prepare data
# +------------------------------------+
  
  
  all.data = read.csv(file = 'c:\\1\\data\\ri_smile.csv', sep = ';', header=T, dec=',')
  all.data = all.data[-1]
  all.data$tms = as.Date(substr(as.character(all.data$tms), 0, 10))
  
  dates.rng = c(min(all.data$tms), max(all.data$tms))
  
  
# +------------------------------------+
# | For each option series calc smile
# | External variables used: all.data
# +------------------------------------+

  CalcSmilesSeries = function(strikeRng = 0.2, 
                              smileDate = as.Date('2010-09-06') ){
    
  ### Find coefs for intuted date
    vx.at.date = all.data %>% filter(tms == smileDate)
    
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
        tdays  = vx.at.date[1, 't', drop=T] * 250
        coef.vector = as.vector(vx.at.date[x.row, c('s', 'a', 'b', 'c', 'd', 'e')])
        vxSmile(strike, fut, tdays, coef.vector)
      })
    })
  
  ### Arrange data for ggplot
    names(smiles) = as.vector(vx.at.date$small_name)
    smiles = gather(data = as.data.frame(c(list(strike = strikes), smiles)), key=strike )
    names(smiles) = c('Strike', 'BaseFutures', 'IV')
    
    return(smiles)
  }
    







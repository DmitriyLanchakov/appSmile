

#### Draw smiles at day ###

require(dplyr)
require(ggplot2)
source(file = 'C:\\Users\\arhipov\\Documents\\RBackup\\.Structure\\deriv_vxsmile.R')

local( {
  
  all.data = read.csv(file = 'c:\\1\\data\\ri_smile.csv', sep = ';',header=T, dec=',')
  all.data = all.data[-1]
  all.data$tms = as.Date( substr( as.character(all.data$tms), 0, 10 ) )
  
  at.date = all.data %>% filter(tms==as.Date('2010-09-06'))
  
  sapply( c(1:nrow(at.date)), function(x){
    
    strike = at.date[x,'fut_price', drop=T]
    fut    = at.date[x,'fut_price', drop=T]
    tdays  = at.date[1,'t', drop=T]*250
    coef.vector=as.vector(at.date[x, c('s', 'a', 'b', 'c', 'd', 'e')])
    vxSmile(strike, fut, tdays, coef.vector)
    
    
  })
  
  View(all.data)
})

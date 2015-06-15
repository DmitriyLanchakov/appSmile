

#### Draw smiles at day ###
### test new commit

require(dplyr)
require(tidyr)
require(ggplot2)
source(file = 'C:\\Users\\arhipov\\Documents\\RBackup\\.Structure\\deriv_vxsmile.R')

local( {
  
  all.data = read.csv(file = 'c:\\1\\data\\ri_smile.csv', sep = ';',header=T, dec=',')
  all.data = all.data[-1]
  all.data$tms = as.Date( substr( as.character(all.data$tms), 0, 10 ) )
  
  vx.at.date = all.data %>% filter(tms==as.Date('2010-09-06'))
  
  smiles = lapply( c(1:nrow(at.date)), function(x){
    
    strikes = seq(120000, 170000, 5000)
    x.row = x
    sapply(strikes, function(x){
      
      strike = x
      fut    = at.date[x.row,'fut_price', drop=T]
      tdays  = at.date[1,'t', drop=T]*250
      coef.vector = as.vector(at.date[x.row, c('s', 'a', 'b', 'c', 'd', 'e')])
      vxSmile(strike, fut, tdays, coef.vector)
    
    })
  })
  
  names(smiles) = as.vector(vx.at.date$small_name)
  smiles = gather(data = as.data.frame( c(list(strike = strikes), smiles ) ), key=strike )
  names(smiles) = c('Strike', 'BaseFutures', 'IV')
  ggplot(data = smiles, aes(x = Strike, y = IV, color = BaseFutures)) + geom_point() + geom_line()
  
  View(all.data)
})

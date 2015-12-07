
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

source(file = 'history_manipulation.R')

library(shiny)

shinyServer(function(input, output, session) {

  values = reactiveValues()  
  values$actualDate = dates.rng[2]

<<<<<<< HEAD

# +------------------------------------+
# | Set correct date
# +------------------------------------+
  observe({
     
    input$dateSlider
    
    isolate({
      
      actDate = values$actualDate
      inpDate = input$dateSlider
      
      if(nrow(filter(smile.data, tms == inpDate)) == 0){
        
        if(inpDate > actDate){
          
          corDate = (smile.data %>% filter(tms >= inpDate) %>% filter(tms == min(tms)) %>% select(tms))[[1]]
        } else {
          
          corDate = (smile.data %>% filter(tms <= inpDate) %>% filter(tms == max(tms)) %>% select(tms))[[1]]
        }
      } else {
        
        corDate = inpDate
      }
      
    })

   
     values$actualDate = corDate

=======
  
# +--------------------------------------+
# | Update date slider at RTS chart click
# +--------------------------------------+
   observe({ 
     
     clickedRts = nearPoints(rts.data, (input$rts_click), xvar = 'Dates', yvar = 'Close')
     if(nrow(clickedRts) > 0)
       inpDate = clickedRts[1, c('Dates'), drop = T]

     updateDateInput(session, inputId = 'dateSlider', value = inpDate, min = dates.rng[1], max = dates.rng[2])
>>>>>>> origin/master
  })
  


# +------------------------------------+
<<<<<<< HEAD
# | Draw smile chart
# +------------------------------------+
  output$smileChart = renderPlot({ 
    
    try({
      
      the.date    = values$actualDate
      
      smiles.data = CalcSmilesSeries(strikeRng = input$strikeRngSlider, 
                                     smileDate = the.date, 
                                     nearest = input$nearestNum)
      
      rts.point   = rts.data %>% filter(Dates == the.date) %>% select(Close)
      
      iv.chart = ggplot(data = smiles.data, aes(x = Strike, y = IV, fill=tdays, alpha=tdays)) + geom_line(size = 1.5, color = 'blue') +
=======
# | Set correct date
# +------------------------------------+
  observe({
     
    input$dateSlider
    
    actDate = isolate(values$actualDate)
    inpDate = isolate(input$dateSlider)
    
    print(paste('actDate = ', actDate,', inpDate = ', inpDate,  sep=''))

    
    if(nrow(filter(smile.data, tms == inpDate)) == 0){

      if(inpDate > actDate){
        
        corDate = (smile.data %>% filter(tms >= inpDate) %>% filter(tms == min(tms)) %>% select(tms))[[1]]
      } else {
        
        corDate = (smile.data %>% filter(tms <= inpDate) %>% filter(tms == max(tms)) %>% select(tms))[[1]]
      }
    } else {
      
      corDate = inpDate
    }
   
     values$actualDate = corDate

  })
  


# +------------------------------------+
# | Draw smile chart
# +------------------------------------+
  output$smileChart = renderPlot({ 
    try({
      
      the.date    = values$actualDate
      smiles.data = CalcSmilesSeries(strikeRng = input$strikeRngSlider, smileDate = the.date, nearest = input$nearestNum)
      rts.point   = rts.data %>% filter(Dates == the.date) %>% select(Close)
      
      iv.chart = ggplot(data = smiles.data, aes(x = Strike, y = IV, fill = tdays, alpha = tdays)) + geom_line(size = 1.5, color = 'blue') +
>>>>>>> origin/master
        theme_bw(base_size = 16) + scale_alpha_discrete(name = "Days til exp") + theme(legend.position = 'bottom')
      
      if(input$checkLimit)
        iv.chart = iv.chart + scale_y_continuous(limit = c(input$yminNum, input$ymaxNum))
     
      iv.chart = iv.chart + geom_vline(xintercept = as.numeric(rts.point$Close[[1]]) * 100, color = 'red', linetype = 'dotted')
      
      iv.chart
    })
<<<<<<< HEAD
  }, width = 300, height = 300)
=======
  })
>>>>>>> origin/master
  


# +------------------------------------+
# | Draw RTS chart
# +------------------------------------+
  output$rtsChart = renderPlot({
<<<<<<< HEAD
    
    values$actualDate
    
=======
>>>>>>> origin/master
    try({
      
    chart.data = rts.data %>% filter(Dates >= dates.rng[1] & Dates <= dates.rng[2])
    
    ggplot(data = chart.data, aes(x = Dates, y = Close) ) + geom_line() + 
      geom_vline(xintercept = as.numeric(values$actualDate), color = 'red', linetype = 'dotted')
    
    })
<<<<<<< HEAD
  }, width = 500, height = 250)
  
  
  
# +--------------------------------------+
# | Update date slider at RTS chart click
# +--------------------------------------+
  observe({ 
    
    clickedRts = nearPoints(rts.data, input$rts_click, xvar = 'Dates', yvar = 'Close')
=======
  })
  


  output$rtsPlotText = renderPrint({
    
    #str(input$rts_click)
    
>>>>>>> origin/master
    
    if(nrow(clickedRts) > 0){
      
      inpDate = clickedRts[1, c('Dates'), drop = T]
      updateDateInput(session, inputId = 'dateSlider', value = inpDate, min = dates.rng[1], max = dates.rng[2])
    }
  })
  
})

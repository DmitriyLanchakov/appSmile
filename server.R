
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

source(file = 'history_manipulation.R')

library(shiny)

shinyServer(function(input, output) {

  values = reactiveValues()  
  values$actualDate = 0
  
  output$dateSlider = renderUI({
    
    if(values$actualDate > 0) 
      val = isolate(values$actualDate)
    else 
      val = dates.rng[2]
    
    dateInput('dateSlider', 'Date selector', val, dates.rng[1], dates.rng[2])
  })
  
  
  theDate = reactive({
    
    input$dateSlider
    
    actDate = isolate(values$actualDate)
    inpDate = isolate(input$dateSlider)
   
    corDate = inpDate
    
    if(nrow(filter(smile.data, tms == inpDate)) > 0){
         
      values$actualDate = actDate
    } else {
      
      if(inpDate > actDate){
        
        corDate = (smile.data %>% filter(tms >= inpDate) %>% filter(tms == min(tms)) %>% select(tms))[[1]]
        values$actualDate = corDate
      } else {
        
        corDate = (smile.data %>% filter(tms <= inpDate) %>% filter(tms == max(tms)) %>% select(tms))[[1]]
        values$actualDate = corDate
      }
    }
   
    corDate
  })
  
  
  output$smileChart = renderPlot({
    
    the.date = theDate()
    
    #print(the.date)
    
    smiles.data = CalcSmilesSeries(strikeRng = input$strikeRngSlider, smileDate = the.date, nearest = input$nearestNum)
    
    rts.point  = rts.data %>% filter(Dates == the.date) %>% select(Close)
    
    iv.chart = ggplot(data = smiles.data,   aes(x = Strike, y = IV, fill = tdays, alpha = tdays) ) + geom_line(size = 1.5, color = 'blue') 
    
    if(input$checkLimit)
      iv.chart = iv.chart + scale_y_continuous(limit = c(input$yminNum, input$ymaxNum))
   
    iv.chart = iv.chart + geom_vline(xintercept = as.numeric(rts.point$Close[[1]]) * 100, color = 'red', linetype = 'dotted')
    
    iv.chart
  })
  
  output$rtsChart = renderPlot({
    
    chart.data = rts.data %>% filter(Dates >= dates.rng[1] & Dates <= dates.rng[2])
    #the.point  = rts.data %>% filter(Dates == input$dateSlider)
    ggplot(data = chart.data, aes(x = Dates, y = Close) ) + geom_line() + 
      geom_vline(xintercept = as.numeric(theDate()), color = 'red', linetype = 'dotted')
    
  })
  
})


# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

source(file = 'history_manipulation.R')

library(shiny)

shinyServer(function(input, output) {

  output$dateSlider = renderUI({
    
    dateInput('dateSlider', 'Date selector', dates.rng[2], dates.rng[1], dates.rng[2])
  })
  
  output$smileChart = renderPlot({
    
    smiles.data = CalcSmilesSeries(strikeRng = input$strikeRngSlider, smileDate = input$dateSlider)
    
    ggplot(data = smiles.data,   aes(x = Strike, y = IV, fill = tdays, alpha = 1/t) ) + geom_line(size = 1.5, color = 'blue') 
  })
  
  output$rtsChart = renderPlot({
    
    chart.data = rts.data %>% filter(Dates >= dates.rng[1] & Dates <= dates.rng[2])
    #the.point  = rts.data %>% filter(Dates == input$dateSlider)
    ggplot(data = chart.data, aes(x = Dates, y = Close) ) + geom_line() + 
      geom_vline(xintercept = as.numeric(input$dateSlider), color = 'red', linetype = 'dotted')
    
  })
  
})

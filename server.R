
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
    ggplot() + geom_line(data = smiles.data, aes(x = Strike, y = IV, color = BaseFutures)) 
  })
  
})

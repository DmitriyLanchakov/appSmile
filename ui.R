
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  titlePanel("Volatility smile history"),
  
  fluidRow(
    column(width = 4,
           
           uiOutput('dateSlider')
           ),
    
    column(width = 4, 
           
            sliderInput('strikeRngSlider', 'Strikes range', 0.05, 0.5, 0.2)
           )
    ), 
  
  fluidRow(
    column(width = 8,
      
      plotOutput('smileChart')
      )
    )
  
))

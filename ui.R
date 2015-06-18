
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
           
           uiOutput('dateSlider'), 
           numericInput('nearestNum', label = 'Nearest expirations', value = 3, min = 0, step = 1)
           ),
    
    column(width = 4, 
           
             sliderInput('strikeRngSlider', 'Strikes range', 0.05, 0.5, 0.2),
           
             fluidRow(
               column(width = 4, checkboxInput('checkLimit', label = 'Limit Y', value = F)),
               column(width = 4, numericInput('yminNum', label = 'Y min', value = 20, min = 0, step = 1)),
               column(width = 4, numericInput('ymaxNum', label = 'Y max', value = 40, min = 0, step = 1))
               )
           )
    ), 
  
  fluidRow(
    column(width = 8,
      
      plotOutput('smileChart'),
      plotOutput('rtsChart')
      )
    )
  
))

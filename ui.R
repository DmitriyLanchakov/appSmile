
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  titlePanel("Volatility smile history"),
  
  p("The application shows RTS Index options' implied volatility curves. To calculate the curves, we used Moskow Stock Exchange 
    estimation algorithm (", a('http://fs.moex.com/files/2639/'), ") and historical values of the model parameteres (", 
    a('http://ftp.moex.ru/pub/FORTS/volat_coeff/'), ")."),
  p("The options' base assets are futures, so the x-axis labels of ", code("Smile chart"), " are 100 times more, than the index value. 
    Current index level is the vertical line on ", code("Smile chart"), " . 
    In the same way the selected date is highlighted on ", code("RTS Index chart"), ". "),
  p("Click ", code("RTS Index chart"), " to see the volatility structure in the selected date."),
  
  fluidRow(
    column(width = 4,
           
<<<<<<< HEAD
=======
           #uiOutput('dateSlider'), 
>>>>>>> origin/master
           dateInput('dateSlider', 'Input date', value = dates.rng[2], min = dates.rng[1], max = dates.rng[2]),
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
<<<<<<< HEAD
    column(width = 4,
       
       h3('Volatility smile'),
       plotOutput('smileChart')
    ),
    
    column(width = 7,
       h3('RTS Index'),
       plotOutput('rtsChart', click = 'rts_click') 
       #verbatimTextOutput('rtsPlotText')
=======
    column(width = 8,
      
      plotOutput('smileChart'),
#      plotOutput('rtsChart')
       plotOutput('rtsChart', click = 'rts_click'), 
       verbatimTextOutput('rtsPlotText')
>>>>>>> origin/master
      )
    )
  
))

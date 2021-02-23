# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)

shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })  
})
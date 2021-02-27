# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)

shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    
    dat <- read.csv("ccc.csv",header=T,fileEncoding = "UTF-8-BOM")
    
    result <- lm(formula = V3 ~ V1 + V2 + V1 * V2 + I(V1^2) + I(V2^2), data = dat)
    
    V1 = seq(-1,1,by = 0.1)
    V2 = seq(-1,1,by = 0.1)
    datf <- expand.grid(xvar = V1, yvar = V2)
    colnames(datf) <- c("V1","V2")
    f <- function(V1,V2){predict(result,datf)}
    V <- outer(V1, V2, f)
    filled.contour(V1,V2,V, xlab="GFL", ylab = "Blade Speed", col=rainbow(30))
    
  })  
})
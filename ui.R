# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)

shinyUI(navbarPage("Navbar",
                   tabPanel("page1",sidebarLayout(
                     sidebarPanel(
                       sliderInput("bins",
                                   "Number of bins:",
                                   min = 1,
                                   max = 50,
                                   value = 30)
                     ),
                     mainPanel(
                       plotOutput("distPlot")
                     )
                   )),
                   tabPanel("page2",
                            h2("example")),
                   navbarMenu("example",
                              tabPanel("name",
                                       h2("ee")
                              ),
                              tabPanel("dd",h2("ff")),
                              
                   checkboxGroupInput("variable", "Model:",
                                                 c("XX" = "mXX",
                                                   "YY" = "mYY",
                                                   "X" = "mX",
                                                   "Y" = "mY",
                                                   "XY" = "mXY")),
                      tableOutput("data")            
                   )
))
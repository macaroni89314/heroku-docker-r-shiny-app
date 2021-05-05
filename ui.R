# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)
library(DT)
library(rsm)


shinyUI(navbarPage("Navbar",
                   tabPanel("page1",sidebarLayout(
                     sidebarPanel( fluidRow(
                       column(4,
                              textInput("text1", label = h6("X1 parameter name"), value = "X1"),
                              textInput("text2", label = h6("X2 parameter name"), value = "X2"),
                       ),
                       column(4,
                              numericInput("center1", label=h6("X1 center value"), value = 10),
                              numericInput("center2", label = h6("X2 center value"), value = 10),
                       ),
                       column(4,
                              numericInput("distance1", label = h6("X1 1 distance"), value = 10),
                              numericInput("distance2", label = h6("X2 1 distance"), value = 10),
                       )),
                       h3("Plan"),
                      checkboxGroupInput("variable", "Select Model:",
                                          c("XX" = "I(x1^2)",
                                            "YY" = "I(x2^2)",
                                            "X" = "x1",
                                            "Y" = "x2",
                                            "XY" = "x1*x2")
                      
                                        
                     ),
                     
   
                     ),
                     mainPanel(
                       DTOutput("table"),
                       verbatimTextOutput("DOE"),
                       verbatimTextOutput("Summary"),
                       plotOutput("distPlot"),
                       textOutput("selected")
                     )
                   )),
                   tabPanel("page2",
                            h2("example")),
                   navbarMenu("example",
                              tabPanel("name",
                                       h2("ee")
                              ),
                              tabPanel("dd",h2("ff")),
                      tableOutput("data")            
                   )
))
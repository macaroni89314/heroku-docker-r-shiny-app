# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)
library(DT)
library(rsm)


shinyUI(navbarPage("Navbar",
                   tabPanel("page1",sidebarLayout(
                     sidebarPanel( 
                       textInput("text1", label = h3("X1 parameter name"), value = "X1"),
                       textInput("text2", label = h3("X2 parameter name"), value = "X2"),
                       
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
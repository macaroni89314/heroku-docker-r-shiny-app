# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)



shinyUI(navbarPage("Navbar",
                   tabPanel("page1",sidebarLayout(
                     sidebarPanel( h2("Plan"),
                      checkboxGroupInput("variable", "Select Model:",
                                          c("XX" = "mXX",
                                            "YY" = "mYY",
                                            "X" = "mX",
                                            "Y" = "mY",
                                            "XY" = "mXY")
                       
                     )),
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
                      tableOutput("data")            
                   )
))
# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)
library(DT)
library(rsm)
library(shinythemes)


shinyUI(navbarPage("",theme = shinytheme("flatly"),
                   tabPanel("Main",headerPanel("Free DOE"),
                   verticalLayout(
                    sidebarLayout(
                     sidebarPanel(h2("PLAN"),
                       
                       fluidRow(
                         column(12,h3("Design of experiments")),
                         
                         column(6,
                         selectInput("model",label = h6("design alph"), choices = list("CCC", "CCF"))),
                         column(6,
                         uiOutput("img1")),
      
                         column(12,
                         numericInput("star", label=h6("number of center"), value = 1,max=10)),
                         
                         column(12,h3("Input actual experimental numerical value")),
                       column(4,
                              textInput("text1", label = h6("X1 parameter name"), value = "X1"),
                              textInput("text2", label = h6("X2 parameter name"), value = "X2"),
                       ),
                       column(4,
                              numericInput("center1", label=h6("X1 center value"), value = 0),
                              numericInput("center2", label = h6("X2 center value"), value = 0),
                       ),
                       column(4,
                              numericInput("distance1", label = h6("X1 range"), value = 0),
                              numericInput("distance2", label = h6("X2 range"), value = 0),
                       )),
                       
                     
   
                     ),
                     mainPanel(
                       h3("Table for input response"),
                       DTOutput("table"),
                       br(),
                       h3("DataFrame used for analyze"),
                       verbatimTextOutput("DOE"),
                       
                       
                       
                     )
                   ),
                   
                   sidebarLayout(
                     sidebarPanel(h2("ANALYZE"),
                                  fluidRow(
                                  column(12,h3("Model")),
                                  column(12,
                                  checkboxGroupInput("variable", h6("select formula"),
                                                     c("X1X1" = "I(x1^2)",
                                                       "X2X2" = "I(x2^2)",
                                                       "X1" = "x1",
                                                       "X2" = "x2",
                                                       "X1X2" = "x1*x2"))),
                                  br(),
                                  
                                  column(12,h3("Plot")),
                                  column(12,
                                  selectInput("Display",label = h6("select plot display"), 
                                              choices = list("Model", "Actual"))),
                                 
                                                     
                                                     
                                  )),
                       mainPanel(
                         h3("Results of plot"),
                         plotOutput("distPlot",height = "100%"),
                                 style = "height: calc(100vh  - 100px)",
                                 textOutput("selected"),
                         h3("Results of summary"),
                                 verbatimTextOutput("Summary")
                                 
                   
                   )))),
                   navbarMenu("",
                  tabPanel("",h2("")
                              ),
                  tabPanel("",h2(""))
                   )
))
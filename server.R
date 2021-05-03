# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)
library(DT)
library(rsm)
library(dplyr)

js <- c(
  "table.on('key', function(e, datatable, key, cell, originalEvent){",
  "  var targetName = originalEvent.target.localName;",
  "  if(key == 13 && targetName == 'body'){",
  "    $(cell.node()).trigger('dblclick.dt');",
  "  }",
  "});",
  "table.on('keydown', function(e){",
  "  var keys = [9,13,37,38,39,40];",
  "  if(e.target.localName == 'input' && keys.indexOf(e.keyCode) > -1){",
  "    $(e.target).trigger('blur');",
  "  }",
  "});",
  "table.on('key-focus', function(e, datatable, cell, originalEvent){",
  "  var targetName = originalEvent.target.localName;",
  "  var type = originalEvent.type;",
  "  if(type == 'keydown' && targetName == 'input'){",
  "    if([9,37,38,39,40].indexOf(originalEvent.keyCode) > -1){",
  "      $(cell.node()).trigger('dblclick.dt');",
  "    }",
  "  }",
  "});"
)

shinyServer(function(input, output) {

  #DOE design
  
  dsg <- cube(2,n0=3,randomize=FALSE)
  dsg <-djoin(dsg,star(alpha = "spherical",randomize= FALSE,n0=0))
  dsg$X1 <- 5*dsg$x1 +85
  dsg$X2 <- 5*dsg$x2 +175
  dsg["response"]<-NA
  dsg <- dsg[,c("x1","x2","X1","X2","response")]

  DataRename <- reactive({
    Data <- dsg
    DataNew1<-Data
    X1 <- input$text1
    X2 <- input$text2
    
    if (X1 == "") {
      colnames(DataNew1)[3]= "X1"
    }else{
      colnames(DataNew1)[3]= X1
    }
    
    if (X2 == "") {
      colnames(DataNew1)[4]= "X2"
    }else{
      colnames(DataNew1)[4]= X2
    }
    return(DataNew1)
  })   
  
  output[["table"]] <- renderDT({
    datatable(
      DataRename(),
      selection = "none",
      editable = TRUE,
      callback = JS(js),
      extensions = "KeyTable",
      options = list(
        keys = TRUE,
        pageLength = 20
      )
    )
  })
 
  Data <- reactive({
    info <- rbind(input[["table_cells_filled"]], input[["table_cell_edit"]])
    if(!is.null(info)){
      info <- unique(info)
      info$value[info$value==""] <- NA
      dsg <<- editData(dsg, info, proxy = "dt")
    }
    dsg
  })
  
  
   
  output[["DOE"]] <- renderPrint({Data()})
  
               
  
  formula <- reactive({
    for (i in 1: sum(table(input$variable)))
      if(i==0){
        formula <- "Non"
      }
      else if(i==1){
        formula <- paste("response ~",input$variable[i])
      }else{
        formula =paste(formula,"+",input$variable[i])
      }
    return(formula)
  })
  
  
  output$distPlot <- renderPlot({
    
    dat <- Data()
    
    result <- lm(formula = formula() , data = dat)
    
    x1 = seq(-1,1,by = 0.1)
    x2 = seq(-1,1,by = 0.1)
    datf <- expand.grid(xvar = x1, yvar = x2)
    colnames(datf) <- c("x1","x2")
    f <- function(x1,x2){predict(result,datf)}
    V <- outer(x1, x2, f)
    filled.contour(x1,x2,V, xlab= list(input$text1), ylab = list(input$text2), 
                   color.palette=colorRampPalette(c("blue","yellow","red")),nlevels=200)
  
  Summary <- reactive(summary(result))    
  output[["Summary"]]<- renderPrint({Summary()})
  
  output$selected <- renderText({
  formula()
  })


    
  })  
})
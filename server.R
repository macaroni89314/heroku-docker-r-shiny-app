# example from https://www.randpy.tokyo/entry/shiny_8

library(shiny)
library(DT)
library(rsm)
library(ggplot2)

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

callback <- c(
  "var tbl = $(table.table().node());",
  "var id = tbl.closest('.datatables').attr('id');",
  "table.on('autoFill', function(e, datatable, cells){",
  "  var out = [];",
  "  for(var i = 0; i < cells.length; ++i){",
  "    var cells_i = cells[i];",
  "    for(var j = 0; j < cells_i.length; ++j){",
  "      var c = cells_i[j];",
  "      var value = c.set === null ? '' : c.set;", # null => problem in R
  "      out.push({",
  "        row: c.index.row + 1,",
  "        col: c.index.column,",
  "        value: value",
  "      });",
  # to color the autofilled cells, uncomment the two lines below  
  #  "      $(table.cell(c.index.row, c.index.column).node())",
  #  "        .css('background-color', 'yellow');",
  "    }",
  "  }",
  "  Shiny.setInputValue(id + '_cells_filled:DT.cellInfo', out);",
  "  table.rows().invalidate();", # this updates the column type
  "});"
)



shinyServer(function(input, output, session) {
  
  output$img1 <- renderUI({
    if(input$model == "CCC"){            
      img(height = 140, width = 140, src = "CCC.png")
    }                                        
    else if(input$model == "CCF"){
      img(height = 140, width = 140, src = "CCF.png")
    }
  })

  #DOE design
  dsgRecal <- reactive({ 
    if (input$model=="CCC"){
      Alpha <- 1.41}
    else{
      Alpha <- 1
    }
    Star <-input$star
    dsg <- cube(2,n0=Star,randomize=FALSE)
    dsg <- djoin(dsg,star(alpha = Alpha ,randomize= FALSE,n0=0))
    dsg["X1"]<-NA
    dsg["X2"] <-NA
    dsg["response"]<-NA
    dsg <-dsg[,c("x1","x2","X1","X2","response")]

        #actual parameter setting
    Cen1 <- input$center1
    Cen2 <- input$center2
    Dis1 <- input$distance1
    Dis2 <- input$distance2
    dsg$X1 <- Dis1*dsg$x1 +Cen1
    dsg$X2 <- Dis2*dsg$x2 +Cen2
    
    #exchange parameter name
    X1 <- input$text1
    X2 <- input$text2
    
    if (X1 == "") {
      colnames(dsg)[3]= "X1"
    }else{
      colnames(dsg)[3]= X1
    }
    
    if (X2 == "") {
      colnames(dsg)[4]= "X2"
    }else{
      colnames(dsg)[4]= X2
    }
    return(dsg)
  })
  


  output[["table"]] <- renderDT({
    datatable(
      dsgRecal(),
      selection = "none",
      editable = TRUE,
      callback = JS(js),
      extensions = "KeyTable",
      options = list(
        keys = TRUE,
        pageLength = 100,
        sDom  = '<"top">lrt<"bottom">ip',
        lengthChange = FALSE,
        dom = 't',
        columnDefs = list(list(className = "dt-right",targets= "_all"))
    ))
  })
  

  
  DF <- matrix(nrow=20,ncol=5)
  colnames(DF) <- c("x1","x2","X1","X2","response")
  DF <- data.frame(DF)

  Data <- reactive({    
    info <- rbind(input[["table_cells_filled"]], input[["table_cell_edit"]])
    if(!is.null(info)){
      info <- unique(info)
      info$value[info$value==""] <- NA
      DF <<- editData(DF, info)
    }
    return(DF)

  })
  

  
  Data2 <- reactive({
    Star <-input$star
    maxrow <- Star +8
    DF1<-cbind(dsgRecal()[1:maxrow,1:4],Data()[1:maxrow,"response"])
    names(DF1)[3]<- "X1"
    names(DF1)[4]<- "X2"
    names(DF1)[5]<-  "response"
    return(DF1)
    })
  
  
  output[["DOE"]] <- renderPrint({Data2()})
  
  
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
    
    if (input$Display == "Model"){
      formula =formula
    } else if(input$Display == "Actual"){
      formula <- gsub("x1","X1",formula)
      formula <- gsub("x2","X2",formula)
    }
    return(formula)
  })
  
  
  output$distPlot <- renderPlot({
    
    if (formula() == "Non"){
      result <- "Non"}
    else if (input$Display == "Model"){
    dat <-Data2()
    result <- lm(formula = formula() , data = dat)
    x1 = seq(-1,1,by = 0.1)
    x2 = seq(-1,1,by = 0.1)
    datf <- expand.grid(xvar = x1, yvar = x2)
    colnames(datf) <- c("x1","x2")
    f <- function(x1,x2){predict(result,datf)}
    V <- outer(x1, x2, f)
    filled.contour(x1,x2,V, xlab= list(input$text1), ylab = list(input$text2),
                   xlim =c(-1,1), ylim=c(-1,1),
                   color.palette=colorRampPalette(c("blue","green","yellow","orange","red")),
                   nlevels=100,
                   cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
    }
    else if (input$Display == "Actual"){
      dat <-Data2()
      result <- lm(formula = formula() , data = dat)
      X1 = seq(input$center1-input$distance1 ,input$center1+input$distance1 ,by = input$center1 /10)
      X2 = seq(input$center2-input$distance2 ,input$center2+input$distance2 ,by = input$center2 /10)
      datf <- expand.grid(xvar = X1, yvar = X2)
      colnames(datf) <- c("X1","X2")
      f <- function(X1,X2){predict(result,datf)}
      V <- outer(X1, X2, f)
      plot <- filled.contour(X1,X2,V, xlab= list(input$text1), ylab = list(input$text2),
                     xlim =c(input$center1-input$distance1 ,input$center1+input$distance1), 
                     ylim=c(input$center2-input$distance2 ,input$center2+input$distance2),
                     color.palette=colorRampPalette(c("blue","green","yellow","orange","red")),
                     nlevels=100,
                     cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
    return(plot)
      }
  
  Summary <- reactive({bindsummary <- summary(result)
  bindsummary$formula <- formula()
  return(bindsummary)})
  
  output[["Summary"]]<- renderPrint({Summary()[c(3,4,8,9,12)]})
  
 
  
    })

 
      

  
  
})
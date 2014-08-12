library(shiny)
library(ggplot2)

d <- read.csv("00270040-eng.csv",fileEncoding="latin1")
d$Value<-as.numeric(as.character(d$Value))
d<-d[which(d$Value>100),]

shinyServer(function(input, output) {
  
  
  dataset <- reactive(function() {
    #movies[sample(nrow(movies), input$sampleSize),]
    #movies[grep(input$text,movies$title),]
    if(length(input$citys)>0){
      d<-d[d$GEO %in% input$citys,]}  
    if(length(input$citys)==0){
      d<-d[!is.na(d$GEO),] }
    #d[d$GEO %in% input$citys,] 
    #d[!is.na(d$GEO),]
    minyear <- input$year[1]
    maxyear <- input$year[2]
    d[which(d$Ref_Date>=minyear & d$Ref_Date<=maxyear),]
      
  })
  
  output$sizeinfo <-  renderPrint({
    cat(nrow(dataset()))
    cat(" rows found with ")
    cat(ifelse(length(input$citys)>0,paste(as.character(length(input$citys))," cities",sep=""),"all cities"))
    cat(" selected.")
    cat("Data spanning a ")
    cat((input$year[2]-input$year[1])*12)
    cat(" month period.")
    
      
  })
  output$code <- renderUI({
    #cat("booya")
      HTML(rapply(as.list(input$citys),function(x) paste('<li><a href="http://maps.google.com/maps?daddr=',x,'">',x,'</a></li>',sep="")))
  })
  output$plot <- renderPlot(function() {
    d<-dataset()
    
    p <- ggplot(d, aes_string(x="Ref_Date", y="Value")) + geom_point()
    p <-p + xlab("Year") +ylab("Rent ($) per month")
    
    if (input$color != 'None')
      p <- p + aes_string(color=input$color)
    #facets <- paste("GEO", '~', input$facet_col)
    facets <- paste(input$facet_row, '~',ifelse(length(input$citys)>0,"GEO",".") )
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)
    
      p <- p + geom_jitter()
    if (input$smooth)
      p <- p + geom_smooth(method="loess",se=FALSE)
    
    
    print(p)
    
  }, height=600)
  
})
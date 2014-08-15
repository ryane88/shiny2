library(shiny)
library(ggplot2)
#read in data originally downloaded 2014-08-11 from data.gc.ca
d <- read.csv("00270040-eng.csv",fileEncoding="latin1")
d$Value<-as.numeric(as.character(d$Value))
#trim out rents lower thnan 100$
d<-d[which(d$Value>100),]
#remove cities with less than 50 datapoints
n<-as.data.frame(table(d$GEO))
m<-n[which(n$Freq>50),]
d<-merge(d,m, by.x = 'GEO', by.y='Var1')
d$GEO<-factor(d$GEO)

shinyServer(function(input, output) {
  
  
  dataset <- reactive( {
    #reactive function to subset data based on inputs in ui.r
    if(length(input$citys)>0){
      d<-d[d$GEO %in% input$citys,]}  
    if(length(input$citys)==0){
      d<-d[!is.na(d$GEO),] }
    
    minyear <- input$year[1]
    maxyear <- input$year[2]
    d[which(d$Ref_Date>=minyear & d$Ref_Date<=maxyear),]
    
      
  })
  
  mylm <- reactive( {
    #rerun lm when something changes
    mylm<-lm(Value~Ref_Date+UNIT,data=dataset())
    mylm
  
  })  
  output$table <- renderTable({
    
    #predict future rents   
    r<-data.frame(round(predict(mylm(),data.frame(Ref_Date=input$pyear,UNIT=levels(dataset()$UNIT)))))
    rownames(r)<-levels(dataset()$UNIT)
    colnames(r)<-c(paste(input$pyear," predicted rent per month ($)",sep="",collapse=""))
    r
  })
  output$sizeinfo <-  renderPrint({
    #print out basic dimension calculations
    cat(nrow(dataset()))
    cat(" rows found with ")
    cat(input$citys)
    cat(" selected.")
    cat("Data spanning a ")
    cat((input$year[2]-input$year[1])*12)
    cat(" month period.")
    
      
  })
  output$code <- renderUI({
      #link to google maps with chosen city    
      HTML(rapply(as.list(input$citys),function(x) paste('<li><a href="http://maps.google.com/maps?daddr=',x,'" target="_blank">',x,'</a></li>',sep="")))
  })
  output$plot <- renderPlot( {
    d<-dataset()
    #set options for ggplot
    p <- ggplot(d, aes_string(x="Ref_Date", y="Value")) + geom_point()
    p <-p + xlab("Year") +ylab("Rent ($) per month")
    p <- p + aes_string(color="UNIT")
    p <- p + ggtitle(paste("Rental costs: ",input$citys, " (", input$year[1],"-",input$year[2],")"))
    p <- p + geom_jitter()
    if (input$smooth)
      p <- p + geom_smooth(method="lm",se=FALSE)
    
    
    print(p)
    
  }, height=400)
  
})
library(shiny)
library(ggplot2)


#read in the data set. downloaded 2014-08-11 from data.gc.ca
d <- read.csv("00270040-eng.csv",fileEncoding="latin1")
d$Value<-as.numeric(as.character(d$Value))
#trim out suspect rents
d<-d[which(d$Value>100),]
#remove cities with less than 50 datapoints
n<-as.data.frame(table(d$GEO))
m<-n[which(n$Freq>50),]
d<-merge(d,m, by.x = 'GEO', by.y='Var1')
d$GEO<-factor(d$GEO)


shinyUI(
     
  pageWithSidebar(
  
 
  headerPanel(
    
    "Canadian Apartement Rental Analysis Tool",   
    
    
    ),

    
  
  sidebarPanel(
    tags$img(src="loueh.png",alt="LOU-EH?",width="100"),
    h5("*[loo-ey] a combination of the french term loue (to rent) and the canadian expression 'eh?'"),
    selectInput('citys', 'Choose City to explore rental costs:', levels(d$GEO), multiple=FALSE, selectize=TRUE),
    sliderInput("year", "Use data from years between:", 1987, 2013,value=c(1987,2013),step=1,format = "####"),
    tags$hr(),
    tags$h5("Link to Google Maps of chosen city:"),
    uiOutput("code"),
    tags$hr(),
    h5("Find this shiny app helpful? Share with popular social media services!"),
    #addthis buttons for social networking
    tags$script(type="text/javascript" ,src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-52003c0e1022f701"),
    HTML('<div class="addthis_sharing_toolbox" data-url="http://ryane88.shinyapps.io/shiny2/" data-title="LOU-EH?"></div>'),
    tags$hr(),
    "Or lets get ",
    tags$a(href="http://ca.linkedin.com/pub/ryan-eaton/8a/681/183/",target="_blank", "LinkedIN")
    
  ),
  
  mainPanel(
    tabsetPanel(type = "tabs", 
                tabPanel("Plot",
                         checkboxInput('smooth', 'Add Trend Lines?'),
                         verbatimTextOutput('sizeinfo'),
                         plotOutput('plot')
                         
                                   
                         ), 
                tabPanel("Predictions", 
                         sliderInput("pyear", "Predict rent for future year:",min=2014, max=2024,value=2014,step=1,format = "####"),
                         
                         tableOutput(outputId="table")
                         
                         ), 
                tabPanel("Help", 
                        "Simply choose a Canadian city, and a scatter plot
                         showing the rental costs by appartement type will be produced
                         in the 'Plot' tab. Trend lines can be added to the scatter plot, 
                        via options provided in the left side panel. To view predictions for 
                        future years choose the 'Predictions' tab. The year used for the
                        prediction can be modified using the slider control"
                        
                        ,tags$hr()
                        ,"Reference: Rental ",
                        tags$a(href="http://data.gc.ca/data/en/dataset/1146388b-a150-4e70-98ec-eb40cb9083c8", "Data"),
                        " from data.gc.ca"
                )
    )
    
  )
))
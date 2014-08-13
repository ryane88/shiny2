library(shiny)
library(ggplot2)
require(rpart)

d <- read.csv("00270040-eng.csv",fileEncoding="latin1")
d$Value<-as.numeric(as.character(d$Value))
d<-d[which(d$Value>100),]
n<-as.data.frame(table(d$GEO))
m<-n[which(n$Freq>50),]
d<-merge(d,m, by.x = 'GEO', by.y='Var1')
d$GEO<-factor(d$GEO)

shinyUI(
     
  pageWithSidebar(
  
 
  headerPanel(
    
    "Canadian Apartement Rental Comparisons",   
    
    
    ),

    
  
  sidebarPanel(
    tags$img(src="loueh.png",alt="LOU-EH?",width="100"),
    h5("*a combination of the french term loue (to rent) and the canadian expression 'eh?'"),
    selectInput('citys', 'Choose Cities to compare rental costs:', levels(d$GEO), multiple=TRUE, selectize=TRUE),
    selectInput('unit', 'Type of Unit:',selected='All', c('All','Bachelor units','One bedroom units','Two bedroom units','Three bedroom units')),
    checkboxInput('smooth', 'Add Trend Line'),
    selectInput('color', 'Color scatterplot by:', c('UNIT','None')),
    selectInput('facet_row', 'Vertical Split on:', c(None='.', 'UNIT')),
    sliderInput("year", "Data from years between:", 1987, 2013,value=c(1987,2013),step=1,format = "####"),
    tags$hr(),
    tags$a(href="http://maps.google.com/maps?daddr=HOME", "Links to Google Maps of chosen cities:"),
    uiOutput("code"),
    tags$hr(),
    "Reference: Rental ",
    tags$a(href="http://data.gc.ca/data/en/dataset/1146388b-a150-4e70-98ec-eb40cb9083c8", "Data"),
    " from data.gc.ca",
    tags$hr(),
    h5("Find this shiny app helpful? Share with popular social media services!"),
    tags$script(type="text/javascript" ,src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-52003c0e1022f701"),
    tags$div(class="addthis_sharing_toolbox"),
    tags$hr(),
    "Or let's get ",
    tags$a(href="http://ca.linkedin.com/pub/ryan-eaton/8a/681/183/", "LinkedIN")
    
  ),
  
  mainPanel(
    verbatimTextOutput('sizeinfo'),
    plotOutput('plot'),
    plotOutput('plot2')
  )
))
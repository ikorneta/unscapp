# server.R
# author: Iga Korneta
# version: 1.0
# created: June 1st, 2015
# UN General Assembly Voting Networks

# load the libraries
library(shiny)
library(ggplot2)
library(igraph)


#load the tables
net_all_5 <- read.csv('./data/002_net_all_0.5.csv')
net_all_7 <- read.csv('./data/002_net_all_0.7.csv')
net_hr_5 <- read.csv('./data/002_net_hr_0.5.csv')
net_hr_7 <- read.csv('./data/002_net_hr_0.7.csv')
net_col_5 <- read.csv('./data/002_net_col_0.5.csv')
net_col_7 <- read.csv('./data/002_net_col_0.7.csv')
net_ec_5 <- read.csv('./data/002_net_ec_0.5.csv')
net_ec_7 <- read.csv('./data/002_net_ec_0.7.csv')

countries <- read.csv('./data/001_countrydata.csv')
UNRGmap <- c("dark green", "red", "orange", "purple", "dark blue")
P5.G4.UfCcoremap <- c("blue", "orange", "grey", "red", "brown")
AU.EU.ASEANmap <- c("red", "dark green", "pink", "orange", "dark blue", "yellow", "grey", "purple")


# main function
shinyServer(
  function(input, output) {
    
    ###picking the right table
    net <- reactive({
      if (input$restype=='All' & input$abstvote=="0.5") {net_all_5}
      else if (input$restype=='All' & input$abstvote=="0.7") {net_all_7}
      else if (input$restype=='Human Rights (sess. 58-66)' & input$abstvote=="0.5") {net_hr_5}
      else if (input$restype=='Human Rights (sess. 58-66)' & input$abstvote=="0.7") {net_hr_7}
      else if (input$restype=='Colonialism (sess. 58-66)' & input$abstvote=="0.5") {net_col_5}
      else if (input$restype=='Colonialism (sess. 58-66)' & input$abstvote=="0.7") {net_col_7}
      else if (input$restype=='Economy (sess. 58-66)' & input$abstvote=="0.5") {net_ec_5}
      else if (input$restype=='Economy (sess. 58-66)' & input$abstvote=="0.7") {net_ec_5}
    })   
    
    
    ###creating the amended network
    new_weight <- reactive({ifelse(net()$sim > quantile(net()$sim, as.numeric(input$cutoff)), net()$sim, 0)})
    min_new_weight <- reactive({min(new_weight()[new_weight()>0])})
    max_new_weight <- reactive({max(new_weight()[new_weight()>0])})
    new_weight_2 <- reactive({ifelse(new_weight()==0, 0, (new_weight()+1-min_new_weight())/(max_new_weight()-min_new_weight()))})
    
    net_new <- reactive({data.frame(cbind(net()[,1:2], sim=new_weight_2()))})
    net_new2 <- reactive({net_new()[net_new()$sim!=0,]})
    
    
    ###creating the colormap
    color <- reactive({switch(input$color, 
                                  "UN Regional Groups"= countries$UNRG, 
                                  "P5/G4/UfC(core)/ACT"= countries$P5.G4.UfCcore,
                                  "AU/EU/ASEAN/CIS/UNASUR/CARICOM/GCC" = countries$AU.EU.ASEAN)})

    map <- reactive({switch(input$color, 
                                "UN Regional Groups"= UNRGmap, 
                                "P5/G4/UfC(core)/ACT"= P5.G4.UfCcoremap,
                                "AU/EU/ASEAN/CIS/UNASUR/CARICOM/GCC" = AU.EU.ASEANmap)})
    
    color2 <- reactive({map()[color()]})
    
    countries_new <- reactive({data.frame(cbind(countries, color=color2()))})

    
    #####visualising
    unscg <- reactive({graph.data.frame(net_new2(), vertices=countries_new(), directed=FALSE)})
    unscg_small <- reactive({induced.subgraph(unscg(), V(unscg())[degree(unscg())>0])})
  
    tempsize <- reactive({switch(input$small, "Yes"= unscg(), "No"= unscg_small())})
  
    
    unscg_p <- reactive({plot.igraph(tempsize(), layout=layout.fruchterman.reingold, vertex.size=4, vertex.color= V(tempsize())$color, vertex.label.cex=0.7, vertex.label.family='mono', vertex.label.dist=0.25, vertex.label.color=V(tempsize())$color, edge.width=E(tempsize())$sim, margin=-2)})    
    output$unscgPlot <- renderPlot({unscg_p()})
    
    
    ###calculating quant properties
    #####degree
    unscg_degree <- reactive({degree(unscg())})
    ord_unscg_degree <- reactive({order(unscg_degree(), decreasing=TRUE)})
    
    #####betweenness
    unscg_bet<- reactive({betweenness(unscg(), normalized=TRUE)})
    ord_unscg_bet <- reactive({order(unscg_bet(), decreasing=TRUE)})
    
    ####communities
    fc <- reactive({fastgreedy.community(unscg())})
    fc_siz <- reactive({sizes(fc())})
    
    ####assortativity
    ass_UNRG <- reactive({assortativity(unscg(), countries$UNRG)})
    ass_unions <- reactive({assortativity(unscg(), countries$AU.EU.ASEAN)})
    
    ###endresults
    output$unscgQuant0 <- renderText({switch(input$quantproperties,
                                    "Nodes with highest degree"="Nodes with highest degrees:", 
                                    "Nodes with highest betweenness"="Nodes with highest betweenness:", 
                                    "Communities"="Sizes of >1-member communities and some of the members of the largest community:", 
                                    "Assortativity"="Assortativity wrt UNRG (top) and different regional unions (bottom):"
                                    )
                             })
    
    
    output$unscgQuant1 <- renderPrint({switch(input$quantproperties,
                "Nodes with highest degree"=head(unscg_degree()[ord_unscg_degree()]), 
                "Nodes with highest betweenness"=head(unscg_bet()[ord_unscg_bet()]), 
                "Communities"=fc_siz()[fc_siz()>1], 
                "Assortativity"=ass_UNRG()
    )     
    }, width=30)
      
    
    output$unscgQuant2 <- renderPrint({switch(input$quantproperties,
               "Nodes with highest degree"=head(countries[ord_unscg_degree(),c(1,2)]), 
               "Nodes with highest betweenness"=head(countries[ord_unscg_bet(),c(1,2)]), 
               "Communities"=head(countries[membership(fc())==1, c(1,2)]), 
               "Assortativity"=ass_unions()
    )     
  })  

  
  }
)

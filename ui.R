# ui.R
# author: Iga Korneta
# version: 1.0
# created: June 1st, 2015
# UN General Assembly Voting Networks

library(shiny)

shinyUI(fluidPage(
  titlePanel("UN General Assembly Voting Networks (sessions 58-67 cumulative)"),  
  fluidRow(
    column(3,
           wellPanel(
             p(strong("Visualise the UNGA Voting Networks.")),
             br(),
             p(strong("Author: "), a(href="mailto:iga.korneta@gmail.com", "Iga Korneta")),
             p(strong("Date: "), "July 2015"),
             p(strong("Code: "), a(href="http://github.com/ikorneta/unscapp", "Github")),
             p(strong("Data source:"), a(href="https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/12379", "Erik Voeten Dataverse")),
             p("See the", strong("Help"), "tabs for the explanation of how I selected the data for the visualisation, as well as the various options.")
           )),
    
    column(9,
           tabsetPanel(
             tabPanel("Output",
                      column(8,
                             p(strong("Voting Networks Graph")),
                             plotOutput("unscgPlot"),
                             br()
                      ),
                      column(4,
                             p(strong("Network Properties")),
                             br(),
                             textOutput("unscgQuant0"),
                             verbatimTextOutput("unscgQuant1"),
                             verbatimTextOutput("unscgQuant2")
                      )             
             ),
             tabPanel("Help - data",
                      column(12, 
                             p(strong("Data")),
                             p("The visualised data come from the results of the non-unanimous UN GA votes collected in the", a(href="https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/12379", "Eric Voeten Dataverse"), ". Resolutions are classified as described in ", a(href="http://ssrn.com/abstract=2111149", "Voeten, E. (2012)"), ". For resolution subtypes, I chose to use only subtypes with the largest resolving power according to (Voeten, 2012)."),
                             p("I chose to use only data from after 2004 (inclusive), i.e. sessions 58-67."),
                             p("The networks are constructed as follows:"),
                             p("- for each agreement in votes, +1 point is given, for each vote in which one country had a Yes/No vote and the other abstained, either +0.5 or +0.7 points (this is the option ", strong("Abstention vote weight"), ") are given; absences not taken into calculation;"),
                             p("- edges in the quantiles below the cutoff (e.g. the lowest 95%) are dropped (this is the option ", strong("Edge quantile cutoff"), "). Basically, the larger this value, the more edges are dropped.")
                )), 
             tabPanel("Help - visualisation",
                      column(12,
                             p(strong("Visualisation options")),
                             p("You can hide lone nodes with the option ", strong("Show zero-degree nodes"), "."),
                             p("You can ", strong("colour"), " the countries by ", a(href="http://www.un.org/depts/DGACM/RegionalGroups.shtml", "UN Regional Groups"), ", by whether they are in the P5, G4, in the UfC core (as defined ", a(href="https://en.wikipedia.org/wiki/Uniting_for_Consensus", "here"),"), in ACT, or by membership in the various regional unions. Membership in UNASUR for some Central American countries is superceded by their earlier membership in CARICOM. Costa Rica is both a part of UfC and of ACT."),
                             br(),
                             p("A fun thing to do is to slide the cutoff from the very left to the very right. Remember to switch on/off the zero-degree nodes!")
                             
                             )                  
                      ),
             tabPanel("Help - properties",
                      column(12,
                             p(strong("Quantitative properties")),
                             p("Nodes with the ", strong("highest degree"), " have the most connections."),
                             p("Nodes with the ", strong("highest betweenness"), " are the most crucial to connecting different communities."),
                             p("Distinct ", strong("communities"), " are tightly-connected subnetworks of the main network."),
                             p("The ", strong("assortativity"), " coefficient is positive if similar vertices (based on some external property, in this case belonging to the same UN Regional Group or the same regional union) tend to connect to each other, and negative otherwise.")
                      )                  
             )             
             
             
             
             
           ))
  ),
  fluidRow(
    column(12,
           p(h4(strong('Pick the options:'))),
           column(3, 
                  radioButtons("restype", "Resolution type", choices=c("All", "Human Rights (sess. 58-66)", "Colonialism (sess. 58-66)", "Economy (sess. 58-66)"), selected="All")
           ),
           column(3,
                  radioButtons("abstvote", "Abstention vote weight", choices=c("0.5", "0.7"), selected="0.5", inline=TRUE),
                  br(),
                  sliderInput("cutoff", "Edge quantile cutoff", value=0.9, min=0.5, max=0.99, step=0.01)
           ),
           column(3,
                  radioButtons("small", "Show zero-degree nodes", choices=c("Yes", "No"), selected="Yes", inline=TRUE),
                  br(),
                  radioButtons("color", "Colour countries", choices=c("UN Regional Groups", "P5/G4/UfC(core)/ACT", "AU/EU/ASEAN/CIS/UNASUR/CARICOM/GCC"), selected="UN Regional Groups")
           ),
           column(3,
                  radioButtons("quantproperties", "Quantitative properties", choices=c("Nodes with highest degree", "Nodes with highest betweenness", "Communities", "Assortativity"), selected="Nodes with highest degree")
           )
    )
  )  
))
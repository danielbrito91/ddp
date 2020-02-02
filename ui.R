library(shiny)
# Define UI for dataset viewer app

shinyUI(fluidPage(
    #App title
    titlePanel("Water Quality in the State of Rio Grande do Sul"),
    
    #Sidebar layout with input definitions
    sidebarPanel(
        h1("Select a parameter"),
        # Input: Selector for choosing parameter
        selectInput(inputId = "variable",
                    label = "Parameter:",
                    choices = c("Biological Oxygen Demand (BOD)" = "dbo",
                                "Total Phosphorus (TP)" = "pt",
                                "Dissolved Oxygen (DO)" = "od")),
        helpText("Note: This app shows the water quality of the state
                         of Rio Grande do Sul, south of Brazil,
                         according to the data reported by the
                         National Water Agency of Brazil. The values reported
                         are the mean concentrations of the samples at each point",
        ),
        helpText("The red color represents a worse water quality (high levels for BOD, TP,
                         and low levels for DO), and the blue color represents better quality
                         (low levels for BOD and TP, high levels for DO)")
        
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
        h3(textOutput("caption")),
        p(textOutput("exp")),
        
        
        leafletOutput("mymap")
    )
    
    
    
))

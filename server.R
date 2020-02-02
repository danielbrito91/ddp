library(shiny)
library(leaflet)
library(tidyverse)

#serie historica
dbo <- read.csv("https://metadados.ana.gov.br/geonetwork/srv/en/resources.get?id=318&fname=dbo_stats.csv&access=private", sep = ";", dec = ",")
pt <- read.csv("https://metadados.ana.gov.br/geonetwork/srv/en/resources.get?id=318&fname=fosfototal_stats.csv&access=private", sep = ";", dec = ",")
od <- read.csv("https://metadados.ana.gov.br/geonetwork/srv/en/resources.get?id=318&fname=od_stats.csv&access=private", sep = ";", dec = ",")

# Filtra para o RS
dbo <- dbo %>% filter(uf == "RS") %>% rename("dbo" = media)
pt <- pt %>% filter(uf == "RS") %>% rename("pt" = media)
od <- od %>% filter(uf == "RS") %>% rename("od" = media)

# Merge data
qualidade <- merge(dbo, pt[, c("codigo", "pt")], by = "codigo")
qualidade <- merge(qualidade, od[, c("codigo", "od")], by = "codigo")
qualidade <- qualidade %>% select(codigo, lat, lon, dbo, pt, od)

shinyServer(function(input, output) {
    
    
    formulaText <- reactive({
        VarLab <- data.frame(var = c("dbo", "pt", "od"),
                             labels = c("Biological Oxygen Demand",
                                        "Total Phosphorus",
                                        "Dissolved Oxygen"))
        paste("You selected ", as.character(VarLab$labels[which(VarLab == input$variable)]))
    })
    
    explainText <- reactive({
        VarExp <- data.frame(labels= c("dbo", "pt", "od"),
                             exp = c("'Biochemical oxygen demand measures the amount of oxygen that microorganisms
consume while decomposing organic matter; it also measures the chemical oxidation of inorganic matter (i.e., the extraction of
oxygen from water via chemical reaction)'.\n

                                        USEPA: https://www.epa.gov/sites/production/files/2015-09/documents/2009_03_13_estuaries_monitor_chap9.pdf ",
                                        
                             "'Total Phosphorus is an essential nutrient for plants and animals. It is
naturally limited in most fresh water systems because it is not as abundant as carbon and nitrogen; introducing a small amount of
additional phosphorus into a waterway can have adverse effects. Sources of phosphorus include soil
and rocks, wastewater treatment plants, runoff from fertilized lawns and cropland, runoff from animal
manure storage areas, disturbed land areas, drained wetlands, water treatment, decomposition of organic
matter, and commercial cleaning preparations.'\n

                                        USEPA - https://www.epa.gov/sites/production/files/2015-09/documents/totalphosphorus.pdf",
                                        
                                        "'Dissolved oxygen concentrations indicate how well aerated the water is, and
vary according to a number of factors, including season, time of day, temperature,
and salinity.'\n

                             USEPA: https://www.epa.gov/sites/production/files/2015-09/documents/2009_03_13_estuaries_monitor_chap9.pdf"))
    
        paste(as.character(VarExp$exp[which(VarExp == input$variable)]))
        
        })
    
    filteredData <- reactive({
        qualidade[,c("codigo", "lat", "lon", input$variable)]
    })
    
    
    output$caption <- renderText({
        formulaText()
        
    })
    
    output$exp <- renderText({
        explainText()
    })
    
    output$mymap <- renderLeaflet({
        pal <- colorNumeric(
            palette = colorRamp(c("#91c5ff", "#ff0000"),
                                interpolate = "spline"), 
            domain = filteredData()[,4],
            reverse = input$variable == "od")     
        
        qualidade %>%
            leaflet() %>%
            addTiles() %>%
            addCircleMarkers(lat = ~lat, lng = ~lon, 
                             popup = ~paste0(as.character(round(filteredData()[,4], 2)), " mg/L"),
                             color = ~pal(filteredData()[,4]),
                             stroke = FALSE, fillOpacity = .7)
    })
    
    
})

library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(geojsonio)
library(aws.s3)
library(reshape2)
library(data.table)
library(highcharter)
library(leaflet.extras)

source("R/processing.R")

############# Census Map Postcode Data #############
####################################################
# map_polygons <- geojsonio::geojson_read("poa_simple.geojson", what = "sp")
# population <- fread("data/population_POA.csv", header = TRUE)
# religion <- fread("data/religions_POA.csv", header = TRUE)
# industry <- fread("data/industry_POA_2011.csv", header = TRUE)
# postcodes <- population$POA_CODE
####################################################


############# Census Map Suburb Data #############
####################################################
cat("Reading geoJSON\n")
map_polygons <- geojsonio::geojson_read("data/suburb_simple.geojson", what = "sp")
cat("Reading suburb blurbs")
suburb_blurbs <- fread("data/blurbs.csv")
cat("Reading populations\n")
population <- fread("data/suburb_data/ssc_population.csv", header = TRUE)
cat("Reading income\n")
income <- fread("data/suburb_data/ssc_income.csv", header = TRUE)
cat("Reading religion\n")
religion <- fread("data/suburb_data/ssc_religion.csv", header = TRUE)
cat("Reading countryOfBirth\n")
countryOfBirth <- fread("data/suburb_data/ssc_countryofbirth.csv", header = TRUE)
cat("Reading rentPayments\n")
rentPayments <- fread("data/suburb_data/ssc_rentPayments.csv", header = TRUE)
cat("Reading occupation\n")
occupation <- fread("data/suburb_data/ssc_occupation", header = TRUE)
cat("Reading Travel to Work\n")
travel <- fread("data/suburb_data/ssc_travelToWork.csv", header = TRUE)
cat("Reading Generating Suburbs\n")
suburbs <- unique(map_polygons$SSC_NAME)
####################################################

function(input, output, session) {
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(133.9892578125, -28.110748760633534, 5) %>%
      addProviderTiles(providers$CartoDB, options = providerTileOptions(minZoom = 5, maxZoom = 15))
  })
  
  observe({
      leafletProxy("map", data = map_polygons) %>%
      clearShapes() %>%
      clearControls() %>%
      addFullscreenControl(position = "bottomright", pseudoFullscreen = FALSE) %>%
      addPolygons(
        layerId = ~SSC_NAME,
        weight = 2,
        opacity = 1,
        color = "gray",
        dashArray = "3",
        fillOpacity = 0.1,
        label = ~paste0(SSC_NAME, ": ", round(map_polygons$SQKM,2), " SQKM"),
        highlight = highlightOptions(
          weight = 3,
          color = "black",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"))
    
    # Once Suburb is Selected
    observeEvent(input$map_shape_click$id, {
      layerid <- input$map_shape_click$id
      shinyjs::hide(id = "load_message", anim = FALSE)
      shinyjs::show(id = "fields", anim = FALSE)
      population_data <- data.frame(subset(population, select = c("population"), SSC == layerid))
      income_data <- data.frame(subset(income, select = c("variable", "value", "sortOrder"), SSC == layerid)) %>% arrange(sortOrder)
      religion_data <- data.frame(subset(religion, select = c("variable", "value"), SSC == layerid)) %>% arrange(variable)
      countryOfBirth_data <- data.frame(subset(countryOfBirth, select = c("variable", "value"), SSC == layerid)) %>% arrange(variable)
      rentPayments_data <- data.frame(subset(rentPayments, select = c("variable", "value", "sortOrder"), SSC == layerid)) %>% arrange(sortOrder)
      occupation_data <- data.frame(subset(occupation, select = c("variable", "value"), SSC == layerid)) %>% arrange(variable)
      travel_data <- data.frame(subset(travel, select = c("variable", "value"), SSC == layerid)) %>% arrange(variable)
      suburb_blurbs_data <- data.frame(subset(suburb_blurbs, select = "blurb", suburb == layerid))
      selectedPolygon <- subset(map_polygons, map_polygons$SSC_NAME == layerid)
      
      # hospital <- get_hospital(selectedPolygon@polygons[[1]]@labpt[2], selectedPolygon@polygons[[1]]@labpt[1])
      # bar <- get_bar(selectedPolygon@polygons[[1]]@labpt[2], selectedPolygon@polygons[[1]]@labpt[1])
      # police <- get_police(selectedPolygon@polygons[[1]]@labpt[2], selectedPolygon@polygons[[1]]@labpt[1])
      # dealerships <- get_dealership(selectedPolygon@polygons[[1]]@labpt[2], selectedPolygon@polygons[[1]]@labpt[1])
      
      leafletProxy("map", data = map_polygons) %>%
        clearGroup("highlighted_polygon") %>%
        clearMarkers() %>%
        # addAwesomeMarkers(hospital$lng, hospital$lat, label = hospital$name, icon = hospital_icon) %>%
        # addAwesomeMarkers(bar$lng, bar$lat, label = bar$name, icon = bar_icon) %>%
        # addAwesomeMarkers(police$lng, police$lat, label = police$name, icon = police_icon) %>%
        # addAwesomeMarkers(dealerships$lng, dealerships$lat, label = dealerships$name, icon = dealership_icon) %>%
        fitBounds(selectedPolygon@bbox[1], selectedPolygon@bbox[2], selectedPolygon@bbox[3], selectedPolygon@bbox[4]) %>%
        addPolygons(stroke = TRUE, weight = 2, color = "red", fillOpacity = 0.1, data = selectedPolygon, group = "highlighted_polygon")
      
      blank_data <- data.frame(x = 0, y = 0.01)
      blank_chart <- hchart(blank_data, type = "column", animation = FALSE, color = 'white') %>%
        hc_xAxis(title = list(enabled = FALSE)) %>%
        hc_yAxis(max = 10, min = 0, plotLines = list(
          list(label = list(text = "Insufficient Data", align = "center", style = list(fontSize = '20px', color = "gray")),
               color = "white",
               width = 5,
               value = 5)))
      
      
      output$suburb <- renderText(layerid)
      output$population <- renderText(prettyNum(population_data$population, big.mark = ","))
      # output$population_change <- renderText(paste0(round(as.numeric(population_data$Change), digits = 2), "%"))
      
      output$countryOfBirth_chart <- renderHighchart({
        tryCatch({
          hchart(countryOfBirth_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#4A90E2') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      output$rentPayments_chart <- renderHighchart({
        tryCatch({
          hchart(rentPayments_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#F2B95B') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      # output$industry_chart <- renderHighchart({
      #   hchart(industry_data, "column", hcaes(x = industry, y = count), animation = FALSE, color = '#4A90E2') %>%
      #     hc_xAxis(title = list(enabled = FALSE)) %>%
      #     hc_yAxis(title = list(enabled = FALSE))
      # })
      # 
      
      output$income_chart <- renderHighchart({
        tryCatch({
          hchart(income_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#FA475D') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      output$religion_chart <- renderHighchart({
        tryCatch({
          hchart(religion_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#B1D788') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      output$travel_chart <- renderHighchart({
        tryCatch({
          hchart(travel_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#B1D788') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      output$occupation_chart <- renderHighchart({
        tryCatch({
          hchart(occupation_data, "column", hcaes(x = variable, y = value), animation = FALSE, color = '#8C509B') %>%
            hc_xAxis(title = list(enabled = FALSE)) %>%
            hc_yAxis(title = list(enabled = FALSE))
        }, error = function(e){
          blank_chart
        })
      })
      
      output$blurb <- renderText({
          suburb_blurbs_data$blurb
      })
      
    })
    
    output$search <- renderUI({
      selectInput("search",
                  NULL,
                  choices = suburbs,
                  selected = NULL,
                  multiple = FALSE)
    })
    
    output$search_button <- renderUI({
      actionButton("submit", label = "Search")
    })
    
    
  })

}

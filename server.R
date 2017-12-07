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
map_polygons <- geojsonio::geojson_read("data/suburb_simple.geojson", what = "sp")
suburb_blurbs <- fread("data/blurbs.csv")
population <- fread("data/suburb_data/ssc_population.csv", header = TRUE)
# religion <- fread("data/religions_POA.csv", header = TRUE)
# industry <- fread("data/industry_POA_2011.csv", header = TRUE)
suburbs <- unique(map_polygons$SSC_NAME)
####################################################

function(input, output, session) {
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(133.9892578125, -28.110748760633534, 5) %>%
      addProviderTiles(providers$CartoDB, options = providerTileOptions(minZoom = 5, maxZoom = 13))
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
      shinyjs::show(id = "fields", anim = FALSE)
      layerid <- input$map_shape_click$id
      population_data <- data.frame(subset(population, select = c("population"), SSC == layerid))
      # religion_data <- data.frame(subset(religion, select = c("religion", "count"), POA_CODE == layerid)) %>% arrange(religion)
      # industry_data <- data.frame(subset(industry, select = c("industry", "count"), POA_CODE == layerid)) %>% arrange(industry)
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
      
      output$suburb <- renderText(layerid)
      output$population <- renderText(prettyNum(population_data$population, big.mark = ","))
      # output$population_change <- renderText(paste0(round(as.numeric(population_data$Change), digits = 2), "%"))
      
      # output$industry_chart <- renderHighchart({
      #   hchart(industry_data, "column", hcaes(x = industry, y = count), animation = FALSE, color = '#4A90E2') %>%
      #     hc_xAxis(title = list(enabled = FALSE)) %>%
      #     hc_yAxis(title = list(enabled = FALSE))
      # })
      # 
      # output$religion_chart <- renderHighchart({
      #   hchart(religion_data, "column", hcaes(x = religion, y = count), animation = FALSE, color = '#FA475D') %>% 
      #     hc_xAxis(title = list(enabled = FALSE)) %>%
      #     hc_yAxis(title = list(enabled = FALSE))
      # })
      
      output$blurb <- renderText({
          suburb_blurbs_data$blurb
      })
      
      output$load_message <- renderText({
        "Click a polygon to load stats..."
      })
      
      
    })
    
    # output$search <- renderUI({
    #   selectInput("search",
    #               "Search",
    #               choices = suburbs,
    #               multiple = FALSE)
    # })
    
  })

}

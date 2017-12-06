library(rgdal)
library(spdplyr)
library(geojsonio)
library(rmapshaper)
library(jsonlite)
library(raster)
library(leaflet)

# read data
shape <- shapefile("~/Downloads/1270055003_ssc_2011_aust_shape/SSC_2011_AUST.shp")

# Using the geojsonio package, convert shapefiles to geojson
suburb_json <- geojson_json(shape)

#simplify to reduce file size (will also reduce polygon accuracy when plotted on map) - use keep = 0.1 to play with simplification
suburb_json_simplified <- ms_simplify(suburb_json, keep = 0.02)

# Write to geojson file
geojson_write(suburb_json_simplified, file = "suburb_simple.geojson")

# Read in as you would in an app
ssc_geojson <- geojsonio::geojson_read("suburb_simple.geojson", what = "sp")

leaflet(ssc_geojson) %>%
  setView(133.9892578125, -28.110748760633534, 5) %>%
  addProviderTiles(providers$CartoDB, options = providerTileOptions(minZoom = 5, maxZoom = 15)) %>%
addPolygons(
  layerId = ~SSC_NAME,
  weight = 2,
  opacity = 1,
  color = "gray",
  dashArray = "3",
  fillOpacity = 0.1,
  label = ~paste0(SSC_NAME, ": ", round(ssc_geojson$SQKM,2), " SQKM"),
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

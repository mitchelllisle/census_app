library(leaflet)
library(highcharter)
library(shinycssloaders)
library(shinyjs)

useShinyjs()

navbarPage(windowTitle = "Mitchell Lisle | Compass", img(src = "logo.png", height = "20px"), id="nav", collapsible = TRUE,
           tabPanel("Census Map",
                    div(class="outer",
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")
                        ),

                        leafletOutput("map", width="65%", height="100%"),

                        absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                                      draggable = FALSE, top = 00, left = 0, right = 0, bottom = 0,
                                      width = "35%", height = "100%", overflow = "scroll",
                                      # uiOutput("search"),
                                      h1("Suburb"),
                                      h5(textOutput("suburb")),
                                      textOutput("blurb")
                                      # h2("Population"),
                                      # h5(textOutput("population")),
                                      # h2("Most Prevalent Industry of Employment"),
                                      # highchartOutput("industry_chart", height = "25%"),
                                      # h2("Most Prevalent Religions"),
                                      # highchartOutput("religion_chart", height = "25%")
                                      # h5(textOutput("population_change"))
                        )
                    )
           ),
           tabPanel("About"
             
           )
)

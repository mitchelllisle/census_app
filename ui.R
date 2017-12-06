library(leaflet)
library(highcharter)
library(shinycssloaders)
library(shinyjs)

navbarPage(windowTitle = "Mitchell Lisle | Compass", img(src = "logo.png", height = "20px"), id="nav", collapsible = TRUE,
           tabPanel("Census Map",
                    div(class="outer",
                        tags$head(
                          HTML(
                            "<!-- Global site tag (gtag.js) - Google Analytics -->
                            <script async src='https://www.googletagmanager.com/gtag/js?id=UA-110853728-1'></script>
                            <script>
                            window.dataLayer = window.dataLayer || [];
                            function gtag(){dataLayer.push(arguments);}
                            gtag('js', new Date());
                            
                            gtag('config', 'UA-110853728-1');
                            </script>
                            "
                          ),
                          includeCSS("styles.css")
                        ),

                        leafletOutput("map", width="65%", height="100%"),

                        
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                                        draggable = FALSE, top = 00, left = 0, right = 0, bottom = 0,
                                        width = "35%", height = "100%", overflow = "scroll",
                                        # uiOutput("search"),
                                shinyjs::hidden(div(id = "fields",
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
                        )
                    )
           ),
           tabPanel("About"
             
           ),
           
           useShinyjs()
)

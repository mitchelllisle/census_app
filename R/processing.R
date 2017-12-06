top_5_age <- function(age){
  age %>% 
    group_by(POA_CODE, State) %>% 
    tidyr::gather(age, count, 3:23, na.rm = TRUE, convert = TRUE) %>% 
    arrange(POA_CODE) %>% 
    top_n(5, count)  
}

top_5_religion <- function(religion){
  religion %>% 
    group_by(POA_CODE, State) %>% 
    tidyr::gather(religion , count, 3:9, na.rm = TRUE, convert = TRUE) %>% 
    arrange(POA_CODE) %>% 
    top_n(7, count)  
}

top_5_industry <- function(industry){
  industry %>% 
    group_by(POA_CODE, State) %>% 
    tidyr::gather(religion , count, 3:23, na.rm = TRUE, convert = TRUE) %>% 
    arrange(POA_CODE) %>% 
    top_n(5, count)  
}

google_places <- function(lat, lng, api_key, type){
  tryCatch({
    url <- paste0("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=", lat, ',', lng, "&radius=1000&type=", type,"&key=", api_key)
    
    request <- httr::GET(url)  
    
    hospital <- httr::content(request)
    
    all_data <- data.frame(name = NULL, lat = NULL, lng = NULL)
    
    for(i in 1:length(hospital$results)){
      current_name <- hospital$results[[i]]$name
      # current_rating <- restuarants$results[[i]]$rating
      current_lat <- hospital$results[[i]]$geometry$location$lat
      current_lng <- hospital$results[[i]]$geometry$location$lng
      
      current_data <- data.frame(name = current_name, 
                                 # rating = current_rating,
                                 lat = current_lat,
                                 lng = current_lng)
      
      all_data <- rbind(current_data, all_data)
    }
    
    return(all_data)
  }, error = function(e){
    all_data <- data.frame(name = "Agloe", lat = -41.628617, lng = 173.118618)
    return(all_data)
  })
}

hospital_icon <- awesomeIcons(icon = 'ambulance', library = 'fa', markerColor = "red")
bar_icon <- awesomeIcons(icon = 'glass', library = 'fa', markerColor = "green")
police_icon <- awesomeIcons(icon = 'cab', library = 'fa', markerColor = "blue")
dealership_icon <- awesomeIcons(icon = 'cab', library = 'fa', markerColor = "blue")

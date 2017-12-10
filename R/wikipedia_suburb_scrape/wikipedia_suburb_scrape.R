library(httr)
library(crayon)
library(jsonlite)

success <- green
fail <- red

cat(yellow("###################\n"))
cat(yellow("Import Suburbs...\n"))
cat(yellow("###################\n"))
suburbs <- read.csv("suburbs.csv")
all_paragraphs <- data.frame(suburb = NULL, state = NULL, blurb = NULL)
cat(yellow("\n"))
cat(yellow("###################\n"))
cat(yellow("Fetching Blurbs...\n"))
cat(yellow("###################\n"))

for(i in 1:nrow(suburbs)){
  url <- paste0("https://en.wikipedia.org/wiki/", URLencode(as.character(suburbs$suburb_name[i])), ",_", URLencode(as.character(suburbs$state_long[i])))
  
  args <- list(url = unbox(url), selectors = unbox("p"))
  
  body <- toJSON(list(args = args))
  
  tryCatch({
    request <- httr::POST("http://localhost:3000/r/termatico/web_scraper", body = body)
    
    data <- content(request)
    
    current_paragraph <- data.frame(suburb = suburbs$shape_name[i], state = suburbs$state_long[i], blurb = data$data$data[[1]]$data[1])
    all_paragraphs <- rbind(all_paragraphs, current_paragraph)
    cat(success(i, suburbs$suburb[i], paste0(round(i/nrow(suburbs)*100, 2), "%"), "\n"))
  }, error = function(e){
    current_paragraph <- data.frame(suburb = suburbs$shape_name[i], state = suburbs$state_long[i], blurb = "-")
    all_paragraphs <- rbind(all_paragraphs, current_paragraph)
    cat(fail(i, suburbs$suburb_name[i], suburbs$state_short[i], paste0(round(i/nrow(suburbs)*100, 2), "%"), "\n"))
  })
}

write.csv(all_paragraphs, "../../data/blurbs.csv")

cat(green("###################\n"))
cat(green("Done!\n"))
cat(green("###################\n"))
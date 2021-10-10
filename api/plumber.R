# plumber.R
library(dplyr)
library(tidyr)
library(stringr)
df <- readr::read_csv('data.csv') %>%
  mutate(
    x = str_extract(s, "\\w[0-9]*"),
    s_clean = ifelse(is.na(x), s, x)
  ) %>%
  select(id, s_clean, s, everything()) %>%
  select(-x)

#* Prints dataframe of serial numbers
#* @param serials 
#* @post /inspect
process_data <- function(serials = ""){
  if (length(serials) > 0){
    if(!(is.character(serials))){stop("Did not pass in string of form 's1|s2'")}
    df <- df %>% 
      filter(str_detect(s_clean, serials))
    if (nrow(df) == 0){
      return("ERROR: NO SERIALS WITH THAT SPECIFICATION.")
    }
  }
  
  out <- df %>%
    # filter(str_detect(s, paste(keep, collapse="|"))) %>%
    filter(!(s %in% (df %>% filter(p == "sub") %>% distinct(s) %>% pull()))) %>%
    group_by(s_clean) %>%
    mutate(keep_s = row_number() == 1) %>%
    group_by(s) %>%
    filter(max(keep_s) == TRUE) %>%
    select(s, s_clean, p, v) %>%
    pivot_wider(names_from=p, values_from=v)
}



#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg="") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function() {
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
  as.numeric(a) + as.numeric(b)
}

library(DBI)
# Create an ephemeral in-memory RSQLite database
# con <- dbConnect(RSQLite::SQLite(), ":memory:")
con <- dbConnect(RSQLite::SQLite(), db=here::here('data-raw/data.db'))

dbListTables(con)
df <- readr::read_csv(here::here("data-raw/data.csv"))
dbWriteTable(con, 'test', df, overwrite=T)
dbDisconnect(con)

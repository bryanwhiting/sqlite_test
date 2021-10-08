library(DBI)
con <- dbConnect(RSQLite::SQLite(), db=here::here('data-raw/data.db'))
dbListTables(con)

res <- dbSendQuery(con, "SELECT * FROM test")
dbFetch(res)

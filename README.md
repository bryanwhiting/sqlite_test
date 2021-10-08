
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Querying some data

Load data:

``` r
library(DBI)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
con <- dbConnect(RSQLite::SQLite(), db=here::here('data-raw/data.db'))
dbListTables(con)
```

    ## [1] "test"

``` r
res <- dbSendQuery(con, "SELECT * FROM test")
dbFetch(res)
```

    ##    id    s   p     v  t
    ## 1   1   s1 sub  s1.2  1
    ## 2   2   s1 sub  s1.1  2
    ## 3   3 s1.1   h  TRUE  3
    ## 4   4 s1.2   h  TRUE  4
    ## 5   5 s1.1   w FALSE  5
    ## 6   6   s1   a  TRUE  6
    ## 7   7   s2   h  TRUE  7
    ## 8   7   s2   a  TRUE  8
    ## 9   7   s2   w FALSE  9
    ## 10  8   s3   a  TRUE 10

# Dataset

``` sql
select *
from test 
```

<div class="knitsql-table">

|  id | s    | p   | v     |   t |
|----:|:-----|:----|:------|----:|
|   1 | s1   | sub | s1.2  |   1 |
|   2 | s1   | sub | s1.1  |   2 |
|   3 | s1.1 | h   | TRUE  |   3 |
|   4 | s1.2 | h   | TRUE  |   4 |
|   5 | s1.1 | w   | FALSE |   5 |
|   6 | s1   | a   | TRUE  |   6 |
|   7 | s2   | h   | TRUE  |   7 |
|   7 | s2   | a   | TRUE  |   8 |
|   7 | s2   | w   | FALSE |   9 |
|   8 | s3   | a   | TRUE  |  10 |

Displaying records 1 - 10

</div>

# SQL approach

``` sql
with t1 as (
  select *,
  case when p = "sub" or INSTR(s, ".") = 0 then s
      else substr(s, 1, INSTR(s, ".") - 1)
      end as s_clean,
    RANK() OVER(partition by 
      case when p = "sub" or INSTR(s, ".") = 0 then s
      else substr(s, 1, INSTR(s, ".") - 1)
      end
      order by t) as r
  from test
  where (s LIKE "s1%" OR s LIKE "s2%")
  AND s not in (
    select distinct s
    from test 
    where p = "sub"
  )
)
select s, s_clean,
  max(case when p = 'h' then v end) as h,
  max(case when p = 'w' then v end) as w,
  max(case when p = 'a' then v end) as a
from t1
where s in (select distinct(s) from t1 where r = 1)
group by 1, 2
```

<div class="knitsql-table">

| s    | s\_clean | h    | w     | a    |
|:-----|:---------|:-----|:------|:-----|
| s1.1 | s1       | TRUE | FALSE | NA   |
| s2   | s2       | TRUE | FALSE | TRUE |

2 records

</div>

# R

``` r
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
res <- dbSendQuery(con, "SELECT * FROM test")
df <- dbFetch(res) 

keep = c('s1', "s2")

df %>%
  filter(str_detect(s, paste(keep, collapse="|"))) %>%
  mutate(
    x = str_extract(s, "\\w[0-9]*"),
    serial_clean = ifelse(is.na(x), s, x)
   ) %>%
  filter(!(s %in% (df %>% filter(p == "sub") %>% distinct(s)))) %>%
  group_by(serial_clean) %>%
  mutate(keep_serial = row_number() == 1) %>%
  group_by(s) %>%
  filter(max(keep_serial) == TRUE) %>%
  select(s, serial_clean, p, v) %>%
  pivot_wider(names_from=p, values_from=v)
```

    ## # A tibble: 2 × 5
    ## # Groups:   s [2]
    ##   s     serial_clean h     w     a    
    ##   <chr> <chr>        <chr> <chr> <chr>
    ## 1 s1.1  s1           TRUE  FALSE <NA> 
    ## 2 s2    s2           TRUE  FALSE TRUE

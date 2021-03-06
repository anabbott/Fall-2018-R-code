library(RPostgres)
library(tidyverse)
library(dbplyr)
library(janitor)

# The folliwing url is provided by Heroku
url <- "postgres://viliygpvlizwel:5c26e3ddd0b2682b5c71a4230547677007d7f9fcfe1ed1c29ee45d6375a7475d@ec2-54-235-177-45.compute-1.amazonaws.com:5432/d47an5cjnv5mjb"

# To parse the url into usable sections use parse_url
pg <- httr::parse_url(url)

# predefine the queries we will need

q2 <- "select plan_annual_master_attribute.year,
  plan_annual_master_attribute.plan_id,
  plan_annual_master_attribute.attribute_value,
  plan.display_name,
  plan_master_attribute_names.name
  
  from                plan_annual_master_attribute
  inner join          plan
  on plan_annual_master_attribute.plan_id = plan.id
  inner join          plan_master_attribute_names
  on plan_annual_master_attribute.master_attribute_id = plan_master_attribute_names.id
   order by year, plan_annual_master_attribute.plan_id, plan_master_attribute_names.id"
# create a connection from the url using the parsed pieces
con <- dbConnect(RPostgres::Postgres(),
                          dbname = trimws(pg$path),
                          host = pg$hostname,
                          port = pg$port,
                          user = pg$username,
                          password = pg$password,
                          sslmode = "require"
                 )


# Run a SQL query 
res <- dbSendQuery(con,q2)
allData <- dbFetch(res)
dbClearResult(res)
dbDisconnect(con)
allWide <- allData %>% 
  filter(display_name == 'Texas Teacher Retirement System') 
allWide <- allWide %>% 
  select(year, plan_id, display_name, name, attribute_value) %>% 
  spread(name, attribute_value) 
clean <- allWide %>% 
  remove_empty('cols')



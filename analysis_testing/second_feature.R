library(tidyverse)
library(arrow)

# Rtsudio workaround to make sure path isn't hard-coded
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
base_path <- system('git rev-parse --show-toplevel', intern = T)

df <-
  read_parquet(paste0(
    base_path, 
    '/data/datasets/all_games_players_all_stats.parquet'),
   as_tibble = TRUE) %>% 
  rename_all(tolower)

# looks like most NAs are due to not counting stats over 30 + years ago
sapply(df, function(x) sum(is.na(x)))


statline_collector <- function (points,
                                assists = 0,
                                rebounds = 0,
                                steals = 0,
                                blocks = 0,
                                turnovers = 0,
                                fg_attempts = 0,
                                fg_makes = 0,
                                fg_percentage = 0,
                                fg3_attempts = 0,
                                fg3_makes = 0,
                                fg3_percentage = 0) {
  
  df %>% 
    # temporary fix to the NA problems
    select(-wl) %>% 
    replace(is.na(.), 0) %>% 
    
    filter(pts >= points,
           ast >= assists,
           reb >= rebounds,
           stl >= steals,
           blk >= blocks,
           tov >= turnovers,
           fga >= fg_attempts,
           fgm >= fg_makes,
           fg_pct >= fg_percentage,
           fg3a >= fg3_attempts,
           fg3m >= fg3_makes,
           fg3_pct >= fg3_percentage) %>% 
    group_by(name) %>% 
    summarise(count = n()) %>% 
    arrange(desc(count)) %>% 
    head(10)
}

statline_collector(points = 20,
                   assists = 10,
                   rebounds = 10,
                   fg_attempts = 10)







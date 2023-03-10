library(tidyverse)
library(arrow)

# Rtsudio workaround to make sure path isn't hard-coded
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
base_path <- system('git rev-parse --show-toplevel', intern = T)

df <-
  read_parquet(paste0(
    base_path, 
    '/data/datasets/all_games_players_all_stats.parquet'),
   as_tibble = TRUE)

# looks like most NAs are due to not counting stats over 30 + years ago
sapply(df %>%
         filter(SEASON_ID > 21990), function(x) sum(is.na(x)))


statline_collector <- function () {
  
}


df %>% 
  filter(PTS >= 10,
         AST >= 0) %>% 
  group_by(Player_ID) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

library(tidyverse)

# Rtsudio workaround to make sure path isn't hard-coded
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
base_path <- system('git rev-parse --show-toplevel', intern = T)

# load in massive csv
df <- 
  read.csv(paste0(base_path, '/data/datasets/all_games_players.csv')) %>% 
  mutate(season = substr(SEASON_ID, 2, 5)) %>% 
  select(season, PTS)



num_x_pts_scored <- function (df, pts, earliest_season) {
  
  df %>% 
    mutate(points_dummy = ifelse(PTS >= pts, 1, 0)) %>% 
    group_by(season) %>% 
    summarize(number = sum(points_dummy)) %>% 
    filter(season >= earliest_season) %>% 
    ggplot(aes(x = season, y = number)) +
    geom_bar(stat = 'identity') +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 80,
                                     hjust = 1))
  
}

num_x_pts_scored(df = df, 
                 pts = 50, 
                 earliest_season = 1990)



# df %>% 
#   mutate(points_dummy = ifelse(PTS >= 40, 1, 0)) %>% 
#   group_by(season) %>% 
#   summarize(number = sum(points_dummy)) %>% 
#   filter(season > 1980) %>% 
#   ggplot(aes(x = season, y = number)) +
#   geom_bar(stat = 'identity') +
#   theme_minimal() +
#   theme(axis.text.x = element_text(angle=80, hjust=1))

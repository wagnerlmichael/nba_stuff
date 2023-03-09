library(tidyverse)

# Rtsudio workaround to make sure path isn't hard-coded
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
base_path <- system('git rev-parse --show-toplevel', intern = T)

# load in massive csv
df <- read.csv(paste0(base_path, '/data/datasets/all_games_players.csv'))

# testing

df %>% distinct(SEASON_ID)

# nooooo missed the date parameter >:(
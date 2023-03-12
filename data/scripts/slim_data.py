import subprocess as sp
import pandas as pd

base_path = sp.getoutput('git rev-parse --show-toplevel')

df = pd.read_parquet(base_path + '/data/datasets/all_games_players_all_stats.parquet')

df = df[['SEASON_ID', 'Player_ID', 'FGM', 
    'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 
    'REB', 'AST', 'STL', 'BLK', 'TOV', 'PTS', 'name']]


df.to_parquet(base_path + '/data/datasets/all_games_players_all_slimmer.parquet')
import pandas as pd
import subprocess as sp
from nba_api.stats.static import players

base_path = sp.getoutput('git rev-parse --show-toplevel')

full_df  = pd.read_parquet(base_path + '/data/datasets/all_games_players_all_stats.parquet')

# create list of all NBA players in history to iterate through
player_dict = players.get_players()

ids = []
names = []

for i in range(len(player_dict)):
    ids.append(player_dict[i]['id'])
    names.append(player_dict[i]['full_name'])

join_df = pd.DataFrame({
    'Player_ID': ids,
    'name': names
})

merged_df = full_df.merge(join_df, on='Player_ID')
#merged_df.isna().sum()

merged_df.to_parquet(base_path + '/data/datasets/all_games_players_all_stats.parquet')
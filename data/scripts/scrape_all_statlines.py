"""
This script creates the all_games_players.csv in the /data/datasets/ path
"""
from nba_api.stats.static import players
from nba_api.stats.endpoints import playergamelog
from nba_api.stats.library.parameters import SeasonAll
import pandas as pd
import time
import subprocess as sp
import fastparquet

base_path = sp.getoutput('git rev-parse --show-toplevel')

# create list of all NBA players in history to iterate through
player_dict = players.get_players()
list_all_players = [player_dict[i]['id'] for i in range(len(player_dict))]

# create empty df
df_result = pd.DataFrame()

# fill empty df with every statline ever of every player
for count, i in enumerate(list_all_players):
    # delay in the loop so the API doesn't time out
    time.sleep(2.5)
    print(count, i)
    df_result = pd.concat([df_result, (playergamelog
                                        .PlayerGameLog(player_id=str(i),
                                                    season=SeasonAll.all)
                                        .get_data_frames()[0]
    )])


# write data to csv
# df_result.to_csv(base_path + '/data/datasets/all_games_players_all_stats.csv')
df_result.to_parquet(base_path + '/data/datasets/all_games_players_all_stats.parquet')
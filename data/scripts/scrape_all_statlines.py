"""
This script creates the all_games_players.csv in the /data/datasets/ path
"""
import argparse
from nba_api.stats.static import players
from nba_api.stats.endpoints import playergamelog
from nba_api.stats.library.parameters import SeasonAll
import pandas as pd
import time
import subprocess as sp
import fastparquet
import requests

def scrape_all_games(sleep_time, error_sleep_time):
    base_path = sp.getoutput('git rev-parse --show-toplevel')

    # create list of all NBA players in history to iterate through
    player_dict = players.get_players()
    list_all_players = [player_dict[i]['id'] for i in range(len(player_dict))]

    # create empty df
    df_result = pd.DataFrame()

    # fill empty df with every statline ever of every player
    for count, i in enumerate(list_all_players):
        while True:
            try:
                # delay in the loop so the API doesn't time out
                time.sleep(sleep_time)
                print(f'Iteration: {count}, Player ID: {i}')
                df_result = pd.concat([df_result, (playergamelog
                                                    .PlayerGameLog(player_id=str(i),
                                                                   season=SeasonAll.all)
                                                    .get_data_frames()[0]
                )])
                break  # if the request was successful, move on to the next player
            except requests.exceptions.ReadTimeout:
                # if the request read timed out, print a message and wait for the error sleep time before trying again
                print(f"Request read timed out for iteration {count} for player {i}. Waiting for {error_sleep_time} seconds before trying again.")
                time.sleep(error_sleep_time)

    df_result.to_parquet(base_path + '/data/datasets/all_games_players_all_stats.parquet')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Scrape all games from NBA API.')
    parser.add_argument('--sleep_time', type=float, default=2.5, help='Sleep time between players in seconds.')
    parser.add_argument('--error_sleep_time', type=float, default=120, help='Sleep time after a ReadTimeout error in seconds.')
    args = parser.parse_args()

    scrape_all_games(args.sleep_time, args.error_sleep_time)




"""
python3 -venv
pip install -r requirements.txt
deactivate

https://www.playingnumbers.com/2019/12/how-to-get-nba-data-using-the-nba_api-python-module-beginner/

hash-r
ipython
"""
from nba_api.stats.static import players
player_dict = players.get_players()
print(player_dict)

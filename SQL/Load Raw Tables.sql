\set ON_ERROR_STOP on

\copy raw.team FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/team.csv' WITH (FORMAT csv, HEADER true);
\copy raw.game FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/game.csv' WITH (FORMAT csv, HEADER true);
\copy raw.line_score FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/line_score.csv' WITH (FORMAT csv, HEADER true);
\copy raw.game_info FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/game_info.csv' WITH (FORMAT csv, HEADER true);
\copy raw.player FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/player.csv' WITH (FORMAT csv, HEADER true);
\copy raw.common_player_info FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/common_player_info.csv' WITH (FORMAT csv, HEADER true);
\copy raw.draft_history FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/draft_history.csv' WITH (FORMAT csv, HEADER true);
\copy raw.inactive_players FROM 'C:/Users/rgane/OneDrive/Desktop/Projects/SQL Project/Data/csv/inactive_players.csv' WITH (FORMAT csv, HEADER true);

-- Row-count check
SELECT 'raw.team' AS table_name, COUNT(*) AS row_count FROM raw.team
UNION ALL SELECT 'raw.game', COUNT(*) FROM raw.game
UNION ALL SELECT 'raw.line_score', COUNT(*) FROM raw.line_score
UNION ALL SELECT 'raw.game_info', COUNT(*) FROM raw.game_info
UNION ALL SELECT 'raw.player', COUNT(*) FROM raw.player
UNION ALL SELECT 'raw.common_player_info', COUNT(*) FROM raw.common_player_info
UNION ALL SELECT 'raw.draft_history', COUNT(*) FROM raw.draft_history
UNION ALL SELECT 'raw.inactive_players', COUNT(*) FROM raw.inactive_players
ORDER BY table_name;

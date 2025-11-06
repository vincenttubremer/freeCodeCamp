#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the first line
  if [[ $WINNER != 'winner' ]]; then

    # Adding winner team to teams table
    WINNER_ADDED=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    
    if [[ -z $WINNER_ADDED ]]; then
      WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      
      if [[ $WINNER_RESULT == "INSERT 0 1" ]]; then
        echo $WINNER added to DB
      fi

    fi

    # Adding opponent team to teams table
    OPPONENT_ADDED=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    
    if [[ -z $OPPONENT_ADDED ]]; then
      OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      if [[ $OPPONENT_RESULT == "INSERT 0 1" ]]; then
        echo $OPPONENT added to DB
      fi

    fi

    # Adding the game to games table
    if [[ $YEAR != year ]]; then
      
      # Get teams ids
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      OPPONENT_ID=$($PSQL "Select team_id FROM teams WHERE name='$OPPONENT'")
      
      if [ ! -z $WINNER_ID ] && [ ! -z $OPPONENT_ID ]; then

        GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                          VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        
        if [[ $GAME_RESULT == "INSERT 0 1" ]]; then
          echo $ROUND: $WINNER - $OPPONENT added
        fi

      fi

    fi

  fi
done

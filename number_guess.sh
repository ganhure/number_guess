#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
 
# generating random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1001 ))

echo -e "\nEnter your username:"
read USERNAME

# check if username has been used before
USERNAME_DB=$($PSQL "SELECT username FROM player_info WHERE username='$USERNAME'")

# if username variable is empty then username has not been used before and does not exist in our database - we should add it
if [[ -z $USERNAME_DB ]]
then
# add username to database
USERNAME_INSERT=$($PSQL "INSERT INTO player_info(username) VALUES('$USERNAME')")
# welcome statement for new users
echo "Welcome, $USERNAME! It looks like this is your first time here."
else
# get the games played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM player_info WHERE username='$USERNAME'")
# get the best game
BEST_GAME=$($PSQL "SELECT best_game FROM player_info WHERE username='$USERNAME'")
# welcome statement for returning players
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
# instantiating number of guesses variables, it starts at one since we read first guess above, and we increment it by 1 with each guess
NUMBER_OF_GUESSES=1
while [[ $SECRET_NUMBER -ne $GUESS ]]
do

if [[ ! $GUESS =~ ^[0-9]+[0-9]$ ]]
then
echo "That is not an integer, guess again:"
read GUESS
# adding 1 to number of guesses variable
NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
elif [[ $SECRET_NUMBER -lt $GUESS ]]
then
echo "It's lower than that, guess again:"
read GUESS
# adding 1 to number of guesses variable
NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
elif [[ $SECRET_NUMBER -gt $GUESS ]]
then
echo "It's higher than that, guess again:"
read GUESS
# adding 1 to number of guesses variable
NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

fi
done

# adding player info results after the game has finished

# updating the number of games played
GAMES_PLAYED_UPDATE=$($PSQL "UPDATE player_info SET games_played=games_played+1 WHERE username='$USERNAME'")

# get the best game
BEST_GAME=$($PSQL "SELECT best_game FROM player_info WHERE username='$USERNAME'")
# updating the best game using if statement
if [[ $BEST_GAME == 0 ]]
then
# add number of guesses as best game
BEST_GAME_UPDATE=$($PSQL "UPDATE player_info SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
elif [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
# add number of guesses as best game
BEST_GAME_UPDATE=$($PSQL "UPDATE player_info SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi

# when player wins
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"


#! /bin/bash

IFS=" "
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else

  SELECTED_ELEMENT=$1
  
  # check, if argument is a number
  if [[ $SELECTED_ELEMENT =~ ^[0-9]+$ ]]; then 
    ELEMENT_QUERY="Select atomic_number From elements Where atomic_number=$SELECTED_ELEMENT"
  
  # check, if string is no more than two character
  elif [[ ${#SELECTED_ELEMENT} -le 2 ]]; then
    ELEMENT_QUERY="Select atomic_number From elements Where symbol='$SELECTED_ELEMENT'"
  
  # use argument as name of element
  else
    ELEMENT_QUERY="Select atomic_number From elements Where name='$SELECTED_ELEMENT'"
  fi

  echo $($PSQL "$ELEMENT_QUERY") | while read ATOMIC_NUMBER; do
    
    if [[ ! -z $ATOMIC_NUMBER ]];then

      PROPERTY_QUERY="Select * From properties Inner Join types Using (type_id) Inner Join elements Using (atomic_number) Where atomic_number=$ATOMIC_NUMBER"
      echo $($PSQL "$PROPERTY_QUERY") | while IFS='|' read -a RECORD; do  
 
        ATOMIC_NUMBER=${RECORD[0]}
        TYPE_ID=${RECORD[1]}
        ATOMIC_MASS=${RECORD[2]}
        M_POINT=${RECORD[3]} 
        B_POINT=${RECORD[4]}
        TYPE=${RECORD[5]}
        ATOMIC_SYMBOL=${RECORD[6]}
        ATOMIC_NAME=${RECORD[7]}

        echo "The element with atomic number $ATOMIC_NUMBER is $ATOMIC_NAME ($ATOMIC_SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ATOMIC_NAME has a melting point of $M_POINT celsius and a boiling point of $B_POINT celsius."
      done
    
    # element was not found
    else
      echo "I could not find that element in the database."
    fi
  done
fi
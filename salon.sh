#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {

  if [[ ! -z $1 ]];then 
    echo -e "\n$1"
  else
    echo -e "\n~~~~~ MY SALON ~~~~~"
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  # Get services into an array
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]; then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done

  read SERVICE_ID_SELECTED

  # Only allow numbers for the input
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_ID=$($PSQL "Select service_id From services Where service_id = $SERVICE_ID_SELECTED")

  # If selected Service does not exist
  if [[ -z $SERVICE_ID ]]; then
    # Clear the input
    SERVICE_ID_SELECTED=""
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID" | sed -E 's/^ *| *$//g')

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "Select customer_id From customers Where phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_RESULT=$($PSQL "Insert Into customers(name, phone) Values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "Select customer_id From customers Where phone = '$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "Select name From customers Where phone = '$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')
    fi

    echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME
   
    APPOINTMENT_RESULT=$($PSQL "Insert Into appointments(customer_id, service_id, time)
                                Values ('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    if [[ $APPOINTMENT_RESULT == 'INSERT 0 1' ]]; then
      echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

    EXIT
    fi
  fi

} 

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
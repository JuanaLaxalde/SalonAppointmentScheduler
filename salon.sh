#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome To Juana's Salon ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi

  echo "Which service would you like to book in for?"
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]
    then
    echo "Sorry, we don't have any services available right now"
    else
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
      echo "$SERVICE_ID) $NAME"
      done

      read SERVICE_ID_SELECTED
      if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
        then
        MAIN_MENU "That is not a number"
        else
        SERV_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        if [[ -z $SERV_AVAIL ]]
          then
          MAIN_MENU "I could not find that service"
          else
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          if [[ -z $CUSTOMER_NAME ]]
            then
            echo -e "\nWhat's your name?"
            read CUSTOMER_NAME
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          fi
          echo -e "\When would you like your appointment to be?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          if [[ $SERVICE_TIME ]] 
            then
            INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
            if [[ $INSERT_SERV_RESULT ]]
              then
              echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
            fi
          fi
        fi
      fi

  fi
}

MAIN_MENU

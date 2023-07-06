#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# reset db
# $($PSQL "TRUNCATE appointments, customers")

echo -e "\n\n~~~~ Macho-Man Salon ~~~~\n"

echo -e "\nWelcome Brother."

MAIN_MENU()
{
  echo -e "\nWhat service might you require?"

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read ID BAR SERVICE_NAME
  do
    echo "$ID) $SERVICE_NAME"
  done
  echo "0) Exit"

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then 
    echo -e "\nBe well, brother. Until next we meet.\n"
    exit
  fi

  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU
  else
    MAKE_APPOINTMENT $SERVICE_ID_RESULT
  fi
}

MAKE_APPOINTMENT()
{
  SERVICE_ID=$1

  echo -e "\nExcellent. And what might be your contact number?"

  read CUSTOMER_PHONE

  CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID_RESULT ]]
  then
    echo -e "\nI see this is your inaugural visitation. What might be your esteemed name?"

    read CUSTOMER_NAME

    CREATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ $CREATE_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then echo -e "\nWe appreciate your benefaction."
    fi
  else 
    echo -e "\nWelcome back, brother."
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID_RESULT")
  fi

  echo -e "\nWhen would you require this service?"

  read SERVICE_TIME

  echo $SERVICE_TIME

  CREATE_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_RESULT, $SERVICE_ID, '$SERVICE_TIME')")
  
  if [[ $CREATE_APPT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
    SERVICE=$(echo $SERVICE_NAME | sed 's/^ *| *$//')
    TIME=$(echo $SERVICE_TIME | sed 's/^ *| *$//')
    NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//')
    echo -e "\n I have put you down for a $SERVICE at $TIME, $NAME."
  fi
}

MAIN_MENU
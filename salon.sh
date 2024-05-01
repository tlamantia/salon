#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
SERVICES_LIST_FORMATTED=$(echo "$SERVICES_LIST" | sed 's/ |/\)/')
echo -e "\n~~~~~ Salon ~~~~~\n"
echo "$SERVICES_LIST_FORMATTED"
echo -e "\nPlease select a service:"
read SERVICE_ID_SELECTED
# if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
# send to main menu
  then
  MAIN_MENU "Please select a number."
  else 
  # get service availability
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if not available
    if [[ -z $SERVICE_NAME ]]
  # send to main menu
    then
    MAIN_MENU "Please select a valid number."
    else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    #check for existing customer
    CUSTOMER_ID=$($PSQL "Select customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
    # add customer
    echo -e "\nPlease enter new customer's name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "Select customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
    # get customer's name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi
    echo -e "\nPlease enter a service time:"
    read SERVICE_TIME
    # enter appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." 
    
  fi
fi
}
if [[ -z $SERVICE_NAME ]]
then
MAIN_MENU
fi

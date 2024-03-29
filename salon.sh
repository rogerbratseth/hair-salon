#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointments ~~~~~\n"

MAIN_MENU() {
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi
	# display list of services
	SERVICE_LIST=$($PSQL "SELECT * FROM services")
	echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done
	# ask for which service
	echo -e "\nWhich service would you like to make a appointment for?"
	read SERVICE_ID_SELECTED
	# if input is not a number
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		# send to main menu
		MAIN_MENU "You must input a number."
	else
		# get service availability
		SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
		# if not available
		if [[ -z $SERVICE_NAME_SELECTED ]]
		then
		  # send to main menu
		  MAIN_MENU "That service is not available"
	  	else
		  # get customer info
		  echo -e "\nPlease enter your phone number"
		  read CUSTOMER_PHONE
		  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		  # if customer doesn't exist
		  if [[ -z $CUSTOMER_NAME ]]
		  then
		    # get new customer name
		    echo -e "\nWhat's your name?"
		    read CUSTOMER_NAME
		    # insert new customer
		    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
		  fi
		  # get customer id
		  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		  # get time for appointment
		  echo -e "\nAt what time do you want your appointment?"
		  read SERVICE_TIME
		  # insert appointment
		  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
		  # output confirmation
		  echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
		fi
	fi
}

MAIN_MENU

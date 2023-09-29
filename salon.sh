#!/bin/bash
PSQL="psql -X -U freecodecamp -d salon --tuples-only -c"
SERVICE_LIST=$($PSQL "select * from services")


BOOKING() {
  if $1:
  then
    echo -e "\n$1"
  fi
  echo "$SERVICE_LIST" | while IFS=" | " read SERVICE_ID SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
  echo -e "\nSelect service you want to book:"
  read SERVICE_ID_SELECTED
  SERVICE_SEL_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED ")
  if [[ -z $SERVICE_SEL_NAME ]]
  then
    BOOKING "This service doesn't exist!"
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      PHONE_NAME_INS_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      if [[ PHONE_NAME_INS_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted customer: $CUSTOMER_NAME ($CUSTOMER_PHONE)"
      fi
    fi
    echo -e "\nEnter desired time of appointment:"
    read SERVICE_TIME
    APPOINT_INS_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time)\
    values((select customer_id from customers where phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    if [[ $APPOINT_INS_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\n I have put you down for a$SERVICE_SEL_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

BOOKING
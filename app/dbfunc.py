import mysql.connector  # importing the mysql-connector module
from mysql.connector import errorcode  # importing errorcode from mysql-connector

# MYSQL CONFIG VARIABLES
hostname = "127.0.0.1"   # The hostname or IP address of your MySQL server
username = "root"        # The username to authenticate with
passwd = "12345678"      # The password to authenticate with
db = 'horizontravels'    # The name of the database you want to connect to

def getConnection():
    try:
        # Establishing a connection to the MySQL server using the configuration variables
        conn = mysql.connector.connect(host=hostname, user=username, password=passwd, database=db)
    except mysql.connector.Error as err:
        # Handling errors that can occur while connecting to the MySQL server
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print('User name or Password is not working')
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print('Database does not exist')
        else:
            print(err)  
    else:
        # If no error occurred while connecting, returning the connection object
        return conn

# Calling the getConnection() function to establish a connection with the MySQL server
getConnection()

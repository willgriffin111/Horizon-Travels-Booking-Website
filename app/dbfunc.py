import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv()  # load values from .env file

hostname = os.getenv("DB_HOST")
username = os.getenv("DB_USER")
passwd = os.getenv("DB_PASS")
db = os.getenv("DB_NAME")

def getConnection():
    try:
        conn = mysql.connector.connect(
            host=hostname,
            user=username,
            password=passwd,
            database=db
        )
        return conn
    except mysql.connector.Error as err:
        print("Database connection error:", err)
        return None

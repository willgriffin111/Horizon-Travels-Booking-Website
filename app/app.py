from flask import Flask, render_template, request, url_for, redirect,session,jsonify,flash
import dbfunc, mysql.connector,calendar, gc, datetime
from dbfunc import db
from passlib.hash import sha256_crypt
from datetime import date
from datetime import datetime
from functools import wraps
import numpy as np

app = Flask(__name__)
app.secret_key = 'HorizonTravelsSecretKey'

# DB_NAME = 'horizonTravels'
conn = dbfunc.getConnection()


# --------------------------------------WRAPPERS-------------------------------

# Wrapper for ensuring the user is logged in before accessing the page
# If user tries to access a page where they need to be logged in then they are redirect to the login page 
# and a message is flashed telling them that they need to be logged in.
def login_required(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if 'logged_in' in session:
            return f(*args, **kwargs)
        else:            
            flash('You need to login first', 'error')
            return redirect(url_for('login'))

    return wrap

# Wrapper for ensure the user type stored in the the session is admin before accessing the page
# If the user is not an admin then they are redirect to the index page 
def admin_required(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if ('logged_in' in session) and (session['usertype'] == 'admin'):
            return f(*args, **kwargs)
        else:            

            return redirect(url_for("index"))   
    return wrap


# --------------------------------------FUNCTIONS---------------------------------

# runStatement is a statement for running SQL querys either for:
#   - two way trips 
#   - single value SELECT statements
#   - standard single statements such as INSERT ,SELECT, MODIFY....
#   - number of results returned from SELECT statement 

def runStatement(departStatement, returnStatement, tripType):
    global departRoutes, returnRoutes, total, data, queryResults   # Declare global variables to be used later

 
    if conn != None:     # Check if a connection to the MySQL database has been established using dbfunc.py
        conn.reconnect()    # Reconnect to the database and create a cursor
        dbcursor = conn.cursor()
        dbcursor.execute('USE {};'.format(db))   # Use the specified database

        # If trip type is "twoway", execute both the departure and return statements
        if tripType == "twoway":
            dbcursor.execute(departStatement)  # execute departure statement
            departRoutes = dbcursor.fetchall()  # store the results of the departure statement in departRoutes
            dbcursor.execute(returnStatement)  # execute return statement
            returnRoutes = dbcursor.fetchall()  # store the results of the return statement in returnRoutes
        # If trip type is "fetchone", execute only the departure statement
        elif tripType == "fetchone":
            dbcursor.execute(departStatement)  # execute departure statement
            data = dbcursor.fetchone()  # store the single result of the departure statement in data
        # If trip type is anything else, execute only the departure statement
        else:
            dbcursor.execute(departStatement)  # execute departure statement
            queryResults = dbcursor.fetchall()  # store the results of the departure statement in queryResults

       
        total = dbcursor.rowcount  # Store the total number of rows affected by the statement
        conn.commit() # Commit the changes made to the database
       
        dbcursor.close()  # Close the cursor and the connection to the database
        conn.close()
        print('Statement run successfully')
    else:
        print('DB connection error')

        

# travelTypeAvailable is for validating whether the given travel type is avaiable on a given day 
# If the provided travel type is available on the provided date then True is returned 
# If the travel type is not available then False is returned 
def travelTypeAvailable(date, travelType):
    travelType += "Travel"     #The values returned from the HTML 
    airTravelAvailable = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    trainTravellAvailable = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    coachTravelAvailable = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Sunday"]
    
    date = date.replace("-"," ") #Replaces "-" with " " so it is in the same format as todays date called below
    day = datetime.strptime(date, '%Y  %m %d').weekday() #Calcualtes the day of the week number of a given date 
    departureDay = calendar.day_name[day] #Calcuates the day of travel in a string e.g. "Monday"
    
    if travelType == "airTravel" and departureDay in airTravelAvailable:
        return True  #If the depature day is in the list of available air travels days then return True
    if travelType == "trainTravel" and departureDay in trainTravellAvailable:
        return True  #If the depature day is in the list of available train travels days then return True
    if travelType == "coachTravel" and departureDay in coachTravelAvailable:
        return True  #If the depature day is in the list of available coach travels days then return True
    else:
        return False #If the travel type does not travel on the given day then return False
    
# totalPrice is for calculating the price given the travel class, quantity and date 
# The function does the following:
#   - price is multipled by the quantity purchased
#   - price is multipled by two if the class is business 
#   - depending on how far away the booking date is from todays date a discount is applied to the price 
def totalPrice(price, travelClass, quantity, travelDate):
    
    dateToday = date.today()# Setting today's date as a reference.
    travelDate = datetime.strptime(travelDate, "%Y-%m-%d").date()  # Converting the travel date string to a datetime object and extracting the date.
    
    price *= int(quantity) # Multiplying the base price by the number of tickets purchased.
    if travelClass == "business": # Doubling the price if the travel class is business.
        price *= 2
          
    delta =  travelDate - dateToday # Calculating the difference between the travel date and today's date.
    
    # Applying discounts based on the number of days left until the travel date.
    if 90 >= delta.days >= 80:
        price -= (price * 20 / 100) #If between 90 and 80 days a 20% discount is applied
        
    elif 79 >= delta.days >= 60:
        price -= (price * 10 / 100) #If between 79 and 60 days a 10% discount is applied
         
    elif 59 >= delta.days >= 45:
        price -= (price * 5 / 100) #If between 59 and 45 days a 5% discount is applied
          
    return price  # Returning the final price.


# seatsAvailable checks if seats are available for a given travel journey on a given date,
# based on the maximum amount of bookings allowed for the travel type and the given quantity.
def seatsAvailable(travelId,travelDate,quantity):
     # Retrieving the travel type for the given travel ID from the database.
    statement = "SELECT travelType FROM travel WHERE idtravel = %s;"%(travelId) 
    runStatement (statement,None,"fetchone")
    travelType = data[0] 

    # Retrieving the total quantity of bookings for the given travel ID and date from the database.
    statement = "SELECT quantity FROM booking WHERE travel_idtravel = %s AND bookingDate ='%s';"%(travelId,travelDate) 
    numOfBookings = 0
    runStatement(statement,None,None)
    for i in range(int(total)):
        x = str(queryResults[i]).strip("(),") 
        numOfBookings += int(x)
  
    
    if travelType =="air": #For air, if the number of bookings minus the maximum number of seats (120) is bigger than the given quantity, return True
        if (120 - numOfBookings) >= int(quantity):
            return True
        else: #If the given quantity is bigger than the the amount of seat still available, return False
            return False
        
    if travelType =="coach": #For coach, if the number of bookings minus the maximum number of seats (50) is bigger than the given quantity, return True
        if (50 - numOfBookings) >= int(quantity):
            return True
        else: #If the given quantity is bigger than the the amount of seat still available, return False
            return False
    if travelType =="train":  #For train, if the number of bookings minus the maximum number of seats (300) is bigger than the given quantity, return True
        if (300 - numOfBookings) >= int(quantity):
            return True
        else: #If the given quantity is bigger than the the amount of seat still available, return False
            return False
       
    
# --------------------------------------MAIN-------------------------------

# Index is the home page and the first page the user sees when opening the website 
# Index does not have a login_required wrapper so must allows users who are not logged in access 
# Index dynamically loads depature desinations into a select box for user selection
@app.route('/')
def index():
    runStatement("SELECT DISTINCT departureLocation FROM travel;",None,None) #DISTINCT departure locations are selected from the database
    cities = []
    for city in queryResults:
        city = str(city).strip("(") # SQL results are returned as ('bristol'),('london'). It is stripped of the ()',
        city = str(city).strip(")")
        city = str(city).strip(",")
        city = str(city).strip("'")
        cities.append(city) # after each city is stipped it is added to the list citites 
    if 'logged_in' in session: # if user is logged in 
         #render template (index.html) where session (usertype) is passed to the site and the cities list is passed too 
        return render_template("index.html",departurelist=cities,usertype=session['usertype'])
    else:
        return render_template("index.html",departurelist=cities) #If not logged in render index.html and pass cities list only 

# returnCity is a AJAX function for returning the desinations of the selected depature location
@app.route('/returncity/', methods=['POST', 'GET'])
def returnCity():
    if request.method == 'GET': 
        deptcity = request.args.get('q') # get the selected departure city from the request arguments
        # retrieve the distinct arrival locations for the given departure location
        statement = "SELECT DISTINCT arrivalLocation FROM travel WHERE departureLocation = '%s';"%(deptcity)
        runStatement(statement,None,None)
        return jsonify(returncities=queryResults, size=total)  # return a JSON object that contains the results of the query and the total number of rows returned
    else:
        return jsonify(returncities='DB Connection Error')  # if the request method is not GET, return a JSON object with an error message
    
# results processess the data the user inputed from the index page and outputs the results 
@app.route('/results', methods = ['POST', 'GET'])
def results():
    if request.method == "POST":
        # Retrieve the departure location, arrival location, travel type, departure date, and trip type from the request form
        global departureDate
        departLocation = request.form["departureLocation"]
        arrivalLocation = request.form["arrivalLocation"]
        travelType = request.form["traveltype"]
        departureDate = request.form["departureDate"]
        tripType = request.form["triptype"]  
        
        # Check if the trip type is oneway
        if tripType == "oneway":
            # Check if the travel type is available for the given departure date
            if travelTypeAvailable(departureDate,travelType) == True:
                # Construct a SQL SELECT statement to retrieve travel routes from the database
                SELECT_statement = 'SELECT * FROM travel WHERE departureLocation = "%s" AND arrivalLocation = "%s" AND TravelType="%s";'%(departLocation, arrivalLocation, travelType)
                # Execute the SQL statement and store the result in the global variable departRoutes
                runStatement(SELECT_statement,None,"twoway")
                print("departAvailable")
                # Check if the user is logged in and render the results page with available routes and user information
                if 'logged_in' in session:
                    return render_template("results.html",departAvailable=True, departRoutes=departRoutes, departLocation=departLocation, \
                    arrivalLocation=arrivalLocation, tripType=tripType,usertype=session['usertype'])
                # If the user is not logged in, render the results page with available routes
                else:
                    return render_template("results.html",departAvailable=True, departRoutes=departRoutes, departLocation=departLocation, \
                    arrivalLocation=arrivalLocation, tripType=tripType)
                
            # If the travel type is not available for the given departure date, render the results page with no results 
            else:
                 # Check if the user is logged in and render the results page with available routes and user information
                print("departUnavailable")
                if 'logged_in' in session:
                    return render_template("results.html",departAvailable=False, departRoutes=0, departureDate=departureDate, departLocation=departLocation,\
                    arrivalLocation=arrivalLocation, tripType=tripType,usertype=session['usertype'])
                else:
                    return render_template("results.html",departAvailable=False, departRoutes=0, departureDate=departureDate, departLocation=departLocation,\
                    arrivalLocation=arrivalLocation, tripType=tripType)
        
        # Check if the trip type is twoway        
        if tripType == "twoway":
            global returnDate
            # Retrieve the returnDate from the request form
            returnDate = request.form["returnDate"] 
            # Two select statements for out going and returning. The arrival location and the departure location has been swapped on the return statement
            departStatement = 'SELECT * FROM travel WHERE departureLocation = "%s" AND arrivalLocation = "%s" AND TravelType="%s";'%(departLocation, arrivalLocation, travelType)
            returnStatement = 'SELECT * FROM travel WHERE departureLocation = "%s" AND arrivalLocation = "%s" AND TravelType="%s";'%( arrivalLocation,departLocation, travelType)
            
            runStatement(departStatement,returnStatement,"twoway") #Using runStatment function to run the two statements
                
            # Using travelTypeAvailable functions to process whether the travel type is available on the given day 
            # If travel type is available for depature and return, return "results.html" with the results from the select statements
            if travelTypeAvailable(departureDate,travelType) == True  and travelTypeAvailable(returnDate,travelType) == True:
                print("depart = True, return = True")
                if 'logged_in' in session: #If user logged in return "results.html" with user data 
                    return render_template("results.html", departAvailable=True,returnAvailable=True,departRoutes=departRoutes, returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,usertype=session['usertype'])
                else: #If user not logged in return "results.html" without user data 
                     return render_template("results.html", departAvailable=True,returnAvailable=True,departRoutes=departRoutes, returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation)
                     
            # If travel type is not available for depature but is available for return, return "results.html" with the results from the select statements
            if travelTypeAvailable(departureDate,travelType) == False  and travelTypeAvailable(returnDate,travelType) == True:
                print("depart = false, return = True")
                if 'logged_in' in session:
                    return render_template("results.html", departAvailable=False,returnAvailable=True, departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,departureDate=departureDate,usertype=session['usertype'])
                else:
                    return render_template("results.html", departAvailable=False,returnAvailable=True, departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,departureDate=departureDate)
            
            # If travel type is available for depature but is not available for return, return "results.html" with the results from the select statements
            if travelTypeAvailable(departureDate,travelType) == True  and travelTypeAvailable(returnDate,travelType) == False:
                print("depart = True, return = False")
                if 'logged_in' in session:
                    return render_template("results.html", departAvailable=True,returnAvailable=False,  departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,arrivalDate=returnDate,usertype=session['usertype'])
                else:
                    return render_template("results.html", departAvailable=True,returnAvailable=False,  departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,arrivalDate=returnDate)
                    
            # If travel type is not available for depature or return then "results.html" with no data
            if travelTypeAvailable(departureDate,travelType) == False  and travelTypeAvailable(returnDate,travelType) == False:
                print("depart = false, return = false")
                if 'logged_in' in session:
                    return render_template("results.html", departAvailable=False,returnAvailable=False, departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,departureDate=departureDate,arrivalDate=returnDate,usertype=session['usertype'])
                else:
                    return render_template("results.html", departAvailable=False,returnAvailable=False, departRoutes=departRoutes,returnRoutes=returnRoutes,\
                    departLocation=departLocation, arrivalLocation=arrivalLocation,departureDate=departureDate,arrivalDate=returnDate)
    else:
        print('DB connection Error')
        return redirect(url_for('index'))
    
# This function is responsible for rendering the booking success page after a user successfully books a flight.
@app.route("/bookingSuccess", methods=['POST', 'GET'])
@login_required # This decorator ensures that the user must be logged in to access this page.
def bookingSuccess():

    # Initializing variables for messages and default prices.
    depatureMessage = ''
    arrivalMessage = ''
    defaultDeparturePrice = 0
    defaultArrivalPrice = 0

    # Checking if the request method is POST.
    if request.method == "POST":

        # Retrieving data from the form.
        departureId = request.form["departureChoice"]
        departureQuantity = request.form["departureQuantity"]
        departureTravelClass = request.form["departureTravelClass"]

        # Trying to retrieve the return data from the form.
        try:
            returnId = request.form["returnChoice"]
            arrivalQuantity = request.form["arrivalQuantity"]
            arrivalTravelClass = request.form["arrivalTravelClass"]
            Return = True  
        except:
            Return = False  #If this errors then booking is only a oneway 

        # -------------------------- DEPARTURE INSERT --------------------------

        # Retrieving the original price of the departure travel.
        statement = "SELECT price FROM travel WHERE idtravel = %s;"%(departureId)
        runStatement(statement,None,"fetchone")
        originalDeparturePrice = data[0]

        # Calculating the total price of the departure travel, e.g. applying discount, multiplying by quantity and multiplying two is business class.
        departureTotalPrice = totalPrice(originalDeparturePrice,departureTravelClass,departureQuantity,departureDate)

         # Calculating departure saving.
        if departureTravelClass =="business":
            defaultDeparturePrice = originalDeparturePrice * 2

        defaultDeparturePrice = defaultDeparturePrice * int(departureQuantity) 
        departureSaving =  defaultDeparturePrice - departureTotalPrice
        
        # Checking if seats are available for the departure journey.
        if seatsAvailable(departureId,departureDate,departureQuantity) == True:
            print("Departure available, making booking")
            statement = 'INSERT INTO booking (accountHolder_idAccountHolder,travel_idtravel,bookingDate,travelClass,quantity,totalPrice) VALUES \
            ((SELECT idAccountHolder FROM accountHolder WHERE email="%s"),%s,"%s","%s",%s,%s);'%(session['email'],departureId,departureDate,departureTravelClass,\
                departureQuantity,departureTotalPrice)
            runStatement(statement,None,None) # Inserting the booking data into the database.
        else:
            depatureMessage = "No seats available on departure"
            departureSaving = 0

       

        # -------------------------- RETURN INSERT --------------------------
        if Return == True:
            # Retrieving the original price of the return travel.
            statement = "SELECT price FROM travel WHERE idtravel = %s;"%(returnId)
            runStatement(statement,None,"fetchone")
            originalArrivalPrice = data[0]

            # Calculating the total price of the return travel.
            arrivalTotalPrice = totalPrice(originalArrivalPrice,arrivalTravelClass,arrivalQuantity,returnDate)    
             # Calculating the return saving.
            if arrivalTravelClass == "business":
                defaultArrivalPrice = originalArrivalPrice * 2
            defaultArrivalPrice = defaultArrivalPrice * int(arrivalQuantity)
            arrivalSaving =  defaultArrivalPrice - arrivalTotalPrice


            # Checking if seats are available for the return travel.
            if seatsAvailable(returnId,returnDate,arrivalQuantity) == True:
                print("Return available, making booking")
                # Inserting the booking data into the database.
                statement = 'INSERT INTO booking (accountHolder_idAccountHolder,travel_idtravel,bookingDate,travelClass,quantity,totalPrice) VALUES \
                ((SELECT idAccountHolder FROM accountHolder WHERE email="%s"),%s,"%s","%s",%s,%s);'%(session['email'],returnId,returnDate,arrivalTravelClass,\
                    arrivalQuantity,arrivalTotalPrice)
                runStatement(statement,None,None) # Inserting the booking data into the database.
            else:
                arrivalMessage = "No seats available on arrival"
                arrivalSaving = 0

           
        # -------------------------- DISPLAY --------------------------
        # Retrieving the departure travel information for display.
        depatureDisplayStatement = 'SELECT travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime FROM travel WHERE idtravel=%s;'%(departureId)

        # Calculating the total saving.
        totalSaving = departureSaving

        # Checking if the booking is a twoway journey
        if Return == True:
            
            # Calculating the total saving.
            totalSaving =totalSaving + arrivalSaving

            # Retrieving the return travel information for display.
            returnDisplayStatement  = 'SELECT travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime FROM travel WHERE idtravel=%s;'%(returnId)

            # Checking if seats are available for both departure and return travels.
            if seatsAvailable(departureId,departureDate,departureQuantity) == True and seatsAvailable(returnId,returnDate,arrivalQuantity) == True:
                print("departSeats = True, returnSeats = True")
                runStatement(depatureDisplayStatement,returnDisplayStatement,"twoway") # Running the display statement for both travels.

                # Rendering the booking success page with all the information.
                return render_template("bookingSuccess.html",usertype=session['usertype'],departRoutes=departRoutes,returnRoutes=returnRoutes,\
                departureTravelClass=departureTravelClass,departureTotalPrice=departureTotalPrice,departureQuantity=departureQuantity,departureDate=departureDate,\
                arrivalTravelClass=arrivalTravelClass,arrivalTotalPrice=arrivalTotalPrice,arrivalQuantity=arrivalQuantity,returnDate=returnDate,\
                depatureMessage=depatureMessage,arrivalMessage=arrivalMessage,totalSaving=totalSaving)

            # Checking if only seats for the return travel are available.
            if seatsAvailable(departureId,departureDate,departureQuantity) == False and seatsAvailable(returnId,returnDate,arrivalQuantity) == True:
                print("departSeats = False, returnSeats = True")
                runStatement(returnDisplayStatement,None,"twoway")  # Running the display statement for the return travel only.

                # Rendering the booking success page with the return travel information only.
                return render_template("bookingSuccess.html",usertype=session['usertype'],departRoutes=departRoutes,\
                departureTravelClass=arrivalTravelClass,departureTotalPrice=arrivalTotalPrice,departureQuantity=arrivalQuantity,departureDate=returnDate,\
                depatureMessage=depatureMessage,arrivalMessage=arrivalMessage,totalSaving=totalSaving)

            # Checking if only seats for the departure travel are available.
            if seatsAvailable(departureId,departureDate,departureQuantity) == True and seatsAvailable(returnId,returnDate,arrivalQuantity) == False:
                print("departSeats = True, returnSeats = False")
                runStatement(depatureDisplayStatement,None,"twoway") # Running the display statement for the departure travel only.

                # Rendering the booking success page with the departure travel information only.
                return render_template("bookingSuccess.html",usertype=session['usertype'],departRoutes=departRoutes,\
                departureTravelClass=arrivalTravelClass,departureTotalPrice=arrivalTotalPrice,departureQuantity=arrivalQuantity,departureDate=returnDate,\
                depatureMessage=depatureMessage,arrivalMessage=arrivalMessage,totalSaving=totalSaving)
                
            # Checking if seats for both departure and return travels are not available.
            if seatsAvailable(departureId,departureDate,departureQuantity) == False and seatsAvailable(returnId,returnDate,arrivalQuantity) == False:
                print("departSeats = False, returnSeats = False")
                # Setting messages to display on the booking success page.
                depatureMessage = "No seats available on departure"
                arrivalMessage = "No seats available on return"

                # Rendering the booking success page with the messages.
                return render_template("bookingSuccess.html",usertype=session['usertype'],depatureMessage=depatureMessage,arrivalMessage=arrivalMessage,totalSaving=totalSaving)

        # Checking if only the departure travel data is available (oneway booking).
        if Return == False:
            # Checking if seats are available for the departure travel.
            if seatsAvailable(departureId,departureDate,departureQuantity) == True:
                runStatement(depatureDisplayStatement,None,"twoway") # Running the display statement for the departure travel only.

                # Rendering the booking success page with the departure travel information.
                return render_template("bookingSuccess.html",usertype=session['usertype'],departRoutes=departRoutes, \
                    departureTravelClass=departureTravelClass,departureTotalPrice=departureTotalPrice,departureQuantity=departureQuantity,departureDate=departureDate,\
                    depatureMessage=depatureMessage,totalSaving=totalSaving)

            else:
                # Rendering the booking success page with the message if the seats are not available for the departure travel.
                return render_template("bookingSuccess.html",usertype=session['usertype'],depatureMessage=depatureMessage,totalSaving=totalSaving)
    else:
        # If the request method is not POST (i.e. the form has not been submitted), display the plain booking success page
        return render_template("bookingSuccess.html",usertype=session['usertype'],totalSaving=totalSaving)

       
   
# ------------------------------ LOGIN/SIGNUP ----------------------------------------------
# signup is where the user can make accounts 
@app.route('/signup',methods = ['POST', 'GET'])
def signup():
    error = '' # Initialize the error message to be empty
    try:
        if request.method == "POST": # If the request method is POST (i.e. form has been submitted)
            # Retrieve the values from the form
            fName = request.form["fname"]
            lName = request.form["lname"]
            dob = request.form["dob"]
            email = request.form["email"]
            password = request.form["password"]
            
            # Check if required fields are not empty
            if fName != None and lName != None and lName != None and dob !=None and password !=None: 
                # Hash the password for security
                password = sha256_crypt.hash((str(password)))  
                # si
                statement = "SELECT * FROM accountHolder WHERE email = '%s';"%(email)
                runStatement(statement,None,None)
                if total > 0:   #this means there is a user with same email
                    print('username already taken, please choose another')
                    error = "User name already taken, please choose another"
                    return render_template("register.html", error=error) 
                else:
                    # Check if the user is over 18 years old
                    birthdate = datetime.strptime(dob, "%Y-%m-%d").date()
                    today = date.today()
                    age = today.year - birthdate.year - ((today.month, today.day) < (birthdate.month, birthdate.day))
                    if age < 18:
                         error="You must be 18 you create an account"
                    else:
                        # If all checks pass, insert the user into the database
                        insert = "INSERT INTO accountHolder (firstName,lastName,dob,email,passwrd) VALUES('%s','%s','%s','%s','%s');"\
                            %(fName,lName,dob,email,password)
                        runStatement(insert,None,None)
                        error='User registered successfully'
                    return render_template("register.html",error=error)          
            else:
                # If any required fields are empty, display an error message
                print('empty parameters')
                error = "Kindly ensure that all the requisite fields have been populated"
                return render_template("register.html", error=error)
        else:
            # If the request method is not POST (i.e. the form has not been submitted), display the registration form
            return render_template("register.html", error=error)
    except Exception as e:  
        # If any other exceptions occur, display a generic error message
        print("Error: ", e)
        error = "An error has occurred and it is recommended that you contact an administrator for further assistance." 
        return render_template("register.html", error=error) 

# login page is where the user can log in to their account 
@app.route('/login', methods=['POST', 'GET'])
def login():
    error = ''
    try:
        if request.method == "POST":  # If the request method is POST (i.e. form has been submitted)
            # Retrieve the values from the form
            email = request.form["email"]
            password = request.form["password"]

            if email != None and password != None: #If email input and password input is not blank
                # Fetch the password and account type for the given email
                statement = "SELECT passwrd, accountHolderType FROM accountHolder WHERE email = '%s';" % (email)
                runStatement(statement, None, "fetchone")  # Execute the query

                # Check if any row was returned
                if total < 1:  # This means no user exists
                    error = "User / password does not exist, login again"
                    # Return a rendered template with the error message
                    return render_template("login.html", error=error)
                else:
                    # Verify the entered password with the stored password using the sha256_crypt library
                    if sha256_crypt.verify(password, str(data[0])):
                        # If the password is correct, set session variables and redirect to index page
                        session['logged_in'] = True
                        session['email'] = request.form['email']
                        session['usertype'] = str(data[1])
                        return redirect(url_for('index'))
                    else:
                        # If the password is incorrect, return a rendered template with an error message
                        error = "Invalid credentials username/password, try again."
                        return render_template("login.html", error=error)
            # Collect the garbage to free up memory
            gc.collect()
            # Return a rendered template with the error message
            return render_template("login.html", error=error)
    except Exception as e:
        print("Error: ", e)
        # If an exception occurs, return a rendered template with an error message
        error = "An error has occurred and it is recommended that you contact an administrator for further assistance."
        return render_template("login.html", error=error)

    # If the request method is GET or there was no form data submitted, simply return the login page
    return render_template("login.html")


# ------------------------------ TERMS AND CONDITIONS ----------------------------------------------
# termsAndConditions is a simple page where the user can view the legalities of the site 
@app.route('/termsAndConditions')
def termsAndConditions():
    if 'logged_in' in session:
        return render_template("termsAndConditions.html",usertype=session['usertype'])
    else:
        return render_template("termsAndConditions.html")

# ------------------------------ ACCOUNT ----------------------------------------------

# Account is where the user view their account details and can change their password 
@app.route("/account", methods=['POST', 'GET'])
@login_required
def account():
    # Initialize an empty message variable
    message = ''

    # Handle POST requests (i.e. form submissions)
    if request.method == "POST":
        # Get the user's input for the current password, new password, and confirmation password
        currentPassword = request.form["currentPassword"] 
        newPassword = request.form["newPassword"]
        confirmPassword = request.form["confirmPassword"]
        
        # Check if the new password and confirmation password match
        if newPassword == confirmPassword:
            # Hash the new password using sha256_crypt
            password = sha256_crypt.hash((str(newPassword)))  
            # Fetch the user's current password from the database
            statement = "SELECT passwrd FROM accountHolder WHERE email = '%s';"%(session['email'])
            runStatement(statement, None, "fetchone")
            # Verify that the current password matches the user's input
            if sha256_crypt.verify(currentPassword, str(data[0])):
                # Update the user's password in the database with the hashed version of the new password
                statement = "UPDATE accountHolder SET passwrd = '%s' WHERE email = '%s'"%(password,session['email'])
                runStatement(statement, None, None)
                # Set the message to indicate that the password has been changed
                message = "Password changed"
            else:
                # Set the message to indicate that the current password is incorrect
                message = "Incorrect password"
        else:
            # Set the message to indicate that the new password and confirmation password do not match
            message = "Passwords do not match"
             
    # Fetch the user's account information from the database
    statement = "SELECT * FROM accountHolder WHERE email='%s';"%(session['email'])
    runStatement(statement, None, "fetchone")
    
    # Pass the user's account information and the message to the account.html template for rendering
    return render_template("account.html", usertype=session['usertype'], fName=data[1], lName=data[2], dob=data[3], email=data[4], accountType=data[6], message=message)

    
# ------------------------------ BOOKINGS ----------------------------------------------
# Booking page is where users can see their bookings and modify them
@app.route("/bookings",methods = ['POST', 'GET'])
@login_required
def bookings():
    message = '' # Initialize the message variable
    dateToday = date.today() # Get today's date

    # Check if the request method is POST
    if request.method =="POST":
        bookingId = request.form["departureChoice"] # Get the booking ID from the form
        deleteModify = request.form["deleteModify"] # Get the action (delete/modify) from the form
        
        # If the action is 'modify'
        if deleteModify == "modify":
            # Select the travel ID from the booking table using the booking ID and user's email
            statement = 'SELECT travel_idtravel FROM booking WHERE idbooking = %s AND \
                    accountHolder_idAccountHolder = (SELECT accountHolder_idAccountHolder FROM accountHolder WHERE email="%s");'%(bookingId,session['email'])
            runStatement(statement,None,"fetchone")
            travelId = data[0] # Get the travel ID
            
            # Get the booking date, travel class, and quantity from the form
            bookingDate = request.form["bookingDate"]
            travelClass = request.form["class"]
            quantity = request.form["quantity"]
            
            # Select the travel type from the travel table using the booking ID
            statement = "SELECT travelType FROM travel WHERE idtravel=(SELECT travel_idtravel FROM booking WHERE idbooking=%s);"%(bookingId)
            runStatement(statement,None,"fetchone")
            travelType = data[0] # Get the travel type
            
            # Check if the selected travel type is available on the selected booking date
            if travelTypeAvailable(bookingDate,travelType):
                # Check if the required number of seats are available on the selected travel
                if seatsAvailable(travelId,bookingDate,quantity):
                    # Select the price of the booking from the travel table using the booking ID
                    statement = "SELECT price FROM travel WHERE idtravel = (SELECT travel_idtravel FROM booking WHERE idbooking = %s);"%(bookingId)
                    runStatement(statement,None,"fetchone")
                    price = int(data[0]) # Get the price and convert it to integer
                    
                    # Calculate the total price of the booking
                    price = totalPrice(price,travelClass,quantity,bookingDate)
                    
                    # Update the booking with the new details
                    statement = 'UPDATE booking SET bookingDate = "%s", travelClass = "%s", quantity = %s, totalPrice = %s WHERE idbooking = %s;'%(bookingDate,travelClass,quantity,price,bookingId)
                    runStatement(statement,None,None)
                    
                    message = "Booking updated" # Set the success message
                else:
                    message = "No seats available" # Set the error message
            else:
                message = (travelType+" travel not available on "+bookingDate) # Set the error message
            
        # If the action is 'delete'
        if deleteModify =="delete":
            # Select the booking date from the booking table using the booking ID
            statement = "SELECT bookingDate FROM booking WHERE idbooking = %s"%(bookingId)
            runStatement(statement,None,"fetchone")
            bookingDate = data[0] # Get the booking date
        
            # Calculate the difference between the booking date and today's date
            delta = bookingDate - dateToday
        
            # Check the cancellation policy based on the number of days between the booking date and today's date
            if delta.days >=60:
                message ="Fully refunded" # If the booking was made more than 60 days ago, refund the entire amount
            if delta.days >= 30 and delta.days <=60:
                message = "As your booking is between 30 and 60 days you have been charged a 50% fee" # If the booking was made between 30 and 60 days ago, charge a 50% cancellation fee
            if delta.days < 30:
                message = "You are not eligible for a refund as you booking is within 30 days" # If the booking was made less than 30 days ago, no refund is allowed
            
            # Delete the booking from the booking table
            statement = "DELETE FROM booking WHERE idbooking = %s;"%(bookingId)
            runStatement(statement,None,None)

    # Select the relevant details of the user's bookings from the booking and travel tables
    statement = 'SELECT idbooking,bookingDate,travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime,travelClass,totalPrice,quantity,totalPrice FROM booking \
        INNER JOIN travel WHERE accountHolder_idAccountHolder=(SELECT idAccountHolder FROM accountHolder WHERE email="%s")AND travel_idtravel=idtravel AND bookingCreated >=  "%s";'%(session['email'],dateToday)
    runStatement(statement,None,None)

    return render_template("bookings.html",queryResults=queryResults,usertype=session['usertype'],message=message) # Render the bookings page with the relevant details and the success/error message


# ------------------------------ ADMIN ----------------------------------------------
# admin accounts is where admin users can modify users account details
@app.route("/adminAccounts", methods=['POST', 'GET'])  
@login_required  # Decorator to check if the user is logged in
@admin_required  # Decorator to check if the user is an admin
def adminAccounts():
    message = ''  # Initialize message variable to an empty string

    if request.method == "POST":  # Check if the form has been submitted
        # Get the account ID and new password from the form
        accountId = request.form["accountChoice"]
        newPassword = request.form["newPassword"]

        try:
            promoteDemote = request.form["promoteDemoteBox"]  # Try to get the promote/demote value from the form
        except:
            promoteDemote = None  # If it's not there, set it to None

        if newPassword != "":  # If the user has submitted a new password
            password = sha256_crypt.hash((str(newPassword)))  # Hash the new password
            # Update the password in the database
            statement = "UPDATE accountHolder SET passwrd = '%s' WHERE idAccountHolder = '%s';" % (password, accountId)
            runStatement(statement, None, None)  # Execute the SQL statement
            message = "Password changed"  # Set the message to indicate that the password has been changed

        if promoteDemote != None:  # If the user has submitted a promote/demote request
            # Get the ID of the currently logged-in user from the session data
            statement = "SELECT idAccountHolder FROM accountHolder WHERE email='%s';" % (session['email'])
            runStatement(statement, None, "fetchone")
            curruntAccountId = data[0]

            if int(curruntAccountId) != int(accountId):  # Check if the user is trying to edit their own account
                if promoteDemote == "Promote":  # If the user is promoting the account
                    # Update the account type to admin
                    statement = "UPDATE accountHolder SET accountHolderType='admin' WHERE idAccountHolder='%s';" % (accountId)
                    message = "Account promoted"  # Set the message to indicate that the account has been promoted
                if promoteDemote == "Demote":  # If the user is demoting the account
                    # Update the account type to standard
                    statement = "UPDATE accountHolder SET accountHolderType='standard' WHERE idAccountHolder='%s';" % (accountId)
                    message = "Account demoted"  # Set the message to indicate that the account has been demoted
                runStatement(statement, None, None)  # Execute the SQL statement
            else:
                message = "Error: Can not edit your own account"  # Set the message to indicate an error

    statement = "SELECT * FROM accountHolder"  # Select all data from the accountHolder table
    runStatement(statement, None, None)  # Execute the SQL statement
    # Render the adminAccounts.html template with the queryResults, usertype, and message variables
    return render_template("adminAccounts.html", queryResults=queryResults, usertype=session['usertype'], message=message)

# adminBookings is an admin page where the admin user can see all the bookings and cancel 
@app.route("/adminBookings", methods=['POST', 'GET'])
@login_required  # Decorator to check if the user is logged in
@admin_required  # Decorator to check if the user is an admin
def adminBookings():
    message = ''
    if request.method =="POST":
        selected = request.form["selected"] #Selecting the select booking to cancel 
        
        # Delete booking
        statement = "DELETE FROM booking WHERE idbooking = %s;"%(selected)
        runStatement(statement,None,None)
        
        message = "Booking cancelled"
        
    # This SQL statement joins the booking, travel, and accountHolder tables to get information about bookings.
    statement = "SELECT idbooking,firstName,lastName,email,travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime, travelClass,quantity,totalPrice,bookingCreated,bookingModified \
                FROM booking INNER JOIN travel ON travel_idtravel=idtravel INNER JOIN accountHolder ON accountHolder_idaccountHolder = idaccountHolder;"
    
    # This function call executes the SQL statement and returns the results.
    runStatement(statement,None,None)
    
    # This returns a template that displays the results of the SQL query in a table.
    # It also passes the usertype of the current session to the template.
    return render_template("adminBookings.html",queryResults=queryResults,usertype=session['usertype'],message=message)

@app.route("/adminJourneys", methods=['POST', 'GET'])
@login_required  # Decorator to check if the user is logged in
@admin_required  # Decorator to check if the user is an admin
def adminJourneys():
    # Check if the request method is POST
    if request.method == "POST":
        # Get the value of modifyType from the form data
        modifyType = request.form["modifyType"]
   
        # If modifyType is not "delete"
        if modifyType != "delete":
            # Get the rest of the form data
            travelType = request.form["travelType"]
            departLocation = request.form["departLocation"]
            departTime = datetime.strptime(request.form["departTime"], '%H:%M:%S')
            arrivalLocation = request.form["arrivalLocation"]
            arrivalTime = datetime.strptime(request.form["arrivalTime"], '%H:%M:%S')
            price = request.form["price"]
            
            # If modifyType is "insert"
            if modifyType == "insert":
                # Calculate the travel time based on the departure and arrival times
                travelTime = arrivalTime - departTime
                # Build the SQL statement to insert a new record into the travel table
                statement = 'INSERT INTO travel (TravelType, departureLocation, departureTime, arrivalLocation, arrivalTime, travelTime, price) \
                             VALUES("%s","%s","%s","%s","%s","%s",%s);' % (travelType, departLocation, departTime, arrivalLocation, travelTime, arrivalTime, price)
                
            # If modifyType is "modify"
            if modifyType == "modify":
                # Get the value of travelId from the form data
                travelId = request.form["travelId"]
                # Build the SQL statement to update an existing record in the travel table
                statement = 'UPDATE travel SET travelType = "%s", departureLocation = "%s", departureTime = "%s", \
                             arrivalLocation = "%s", arrivalTime = "%s", price = "%s" \
                             WHERE idtravel = %s;' % (travelType, departLocation, departTime, arrivalLocation, arrivalTime, price, travelId)
                
        # If modifyType is "delete"
        else:
            # Get the value of travelId from the form data
            travelId = request.form["travelId"]
            # Build the SQL statement to delete a record from the travel table
            statement = "DELETE FROM travel WHERE idtravel = %s;" % (travelId) 
        
        # Execute the SQL statement against the database
        runStatement(statement, None, None)
    
    # Build the SQL statement to select all records from the travel table
    statement = "SELECT * FROM travel"
    # Execute the SQL statement against the database
    runStatement(statement, None, None)
    # Render the adminJourneys.html template, passing the query results and user type information to the template
    return render_template("adminJourneys.html", queryResults=queryResults, usertype=session['usertype'])

# adminSales returns the top four customer in order of totalBookingPrice
@app.route("/adminSales")
@login_required  # Decorator to check if the user is logged in
@admin_required  # Decorator to check if the user is an admin
def adminSales():
    statement = "SELECT accountHolder.idAccountHolder, accountHolder.firstName, accountHolder.lastName,accountHolder.email, COALESCE(SUM(booking.totalPrice), 0) AS totalBookingPrice\
                FROM accountHolder LEFT JOIN booking ON accountHolder.idAccountHolder = booking.accountHolder_idAccountHolder \
                GROUP BY accountHolder.idAccountHolder, accountHolder.firstName, accountHolder.lastName ORDER BY totalBookingPrice DESC LIMIT 4;"
    runStatement(statement,None,None) 
    return render_template("adminSales.html",usertype=session['usertype'],queryResults=queryResults) #Returns "adminSales.html" with results 

# salesPerJourney called from an AJAX function to returns the data for the number of sales per journey for each travel type
@app.route('/salesPerJourney',methods = ['POST', 'GET'])
def salesPerJourney():
    # If the request method is GET, extract the values for the month and travel type from the request arguments
    if request.method =="GET":
        month = request.args.get('month')
        travel_type = request.args.get('travelType')
        
        # Query the database to get the total number of journeys of the given travel type
        statement = "SELECT  COUNT(*) AS journeyCount FROM travel WHERE travelType = '%s';"%(travel_type)
        runStatement(statement,None,"fetchone")
        RANGE = data[0] # The total number of journeys of the given travel type
        
        sales = [] # Initialize an empty list to hold the sales data
        travelId = [] # Initialize an empty list to hold the travel IDs
        for i in range(1,RANGE+1):
            travelId.append(i) # Append the travel ID to the travelId list
            # Query the database to get the number of bookings for the current travel ID and month
            statement = "SELECT COUNT(*) FROM booking INNER JOIN travel ON booking.travel_idtravel = travel.idtravel \
                WHERE travel.idtravel = %s AND DATE_FORMAT(booking.bookingDate, '%%Y-%%m') = '%s';"%(i,month)
            runStatement(statement,None,"fetchone")
            sales.append(int(data[0])) # Append the sales data to the sales list
        print(sales)
        # Create a 2D numpy array to hold the sales and travel ID data
        array = np.empty([2, RANGE]) 
        array[0] = sales # Set the first row of the array to the sales data
        array[1] = travelId # Set the second row of the array to the travel IDs
        # Return the data as a JSON object
        return jsonify(array.tolist()) 


# salesPerYear called from an AJAX function to return the data of total sales per given year
@app.route('/salesPerYear',methods = ['POST', 'GET'])
def salesPerYear():
    # Check if the request method is GET and retrieve the 'year' parameter from the URL query string.
    if request.method =="GET":
        year = request.args.get('year')
    
        RANGE = 12 # Set the range of months to be queried as 12.
        
        # Create empty lists for sales and month numbers.
        sales = []
        monthNum = []
        
        # Loop through each month, executing a SQL query to retrieve the count of bookings for that month.
        # Append the sales count to the sales list and the month number to the monthNum list.
        for i in range(1,RANGE+1):
            monthNum.append(i)
            if len(str(i)) == 1:
                statement = "SELECT COUNT(*) AS bookingCount FROM booking WHERE DATE_FORMAT(bookingDate, '%%Y/%%m') = '%s/0%s';"%(year,i)
            if len(str(i)) == 2:
                statement = "SELECT COUNT(*) AS bookingCount FROM booking WHERE DATE_FORMAT(bookingDate, '%%Y/%%m') = '%s/%s';"%(year,i)
            runStatement(statement,None,"fetchone")
            sales.append(int(data[0]))
        print(sales)
        
        # Create a 2D NumPy array with 2 rows and 12 columns.
        array = np.empty([2, RANGE]) 
         
        # Set the first row to be the sales list and the second row to be the monthNum list.
        array[0] = sales 
        array[1] = monthNum
        
        # Convert the array to a list and return it as a JSON response.
        return jsonify(array.tolist())


# ------------------------------ LOGOUT ----------------------------------------------
# This route is used to log out the user
@app.route("/logout")
@login_required # Decorator to check if the user is logged in
def logout():
    session.clear() # This clears the session data for the user
    print("You have been logged out!")
    gc.collect()  # This line explicitly triggers garbage collection to free up any memory used by the application
    return redirect(url_for('index')) # This redirects the user to the homepage after they have been logged out


# ------------------------------ RUN ----------------------------------------------
if __name__ == '__main__':
    for i in range(13000, 18000): #Searches for an available port from 13000 to 18000
        try:
            app.run(port = i, debug=True) #Starts app
            break
        except OSError as e:
            print("Port {} not available".format(i))

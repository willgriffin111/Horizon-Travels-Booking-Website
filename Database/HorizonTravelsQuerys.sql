USE HorizonTravels;

DELETE FROM booking;

-- Used in seatsAvailable function for retrieving the travel type for the given travel ID.
SELECT travelType FROM travel WHERE idtravel = 1; 

-- Used in seatsAvailable function for retrieving the total quantity of bookings for the given travel ID and date.
SELECT quantity FROM booking WHERE travel_idtravel = 1 AND bookingDate ='27/04/2023';

-- Used in index to retrieve all departure locations for select box  
SELECT DISTINCT departureLocation FROM travel;

-- Used in the the function returnCity to dynamically load arrival locations for given departure location
SELECT DISTINCT arrivalLocation FROM travel WHERE departureLocation = 'Bristol';

-- Used in results to retrieve travel routes for oneway travel
SELECT * FROM travel WHERE departureLocation = "bristol" AND arrivalLocation = "london" AND TravelType="air";

-- Used in results to retrieve travel routes for twoway travel
SELECT * FROM travel WHERE departureLocation = "bristol" AND arrivalLocation = "london" AND TravelType="air";
SELECT * FROM travel WHERE departureLocation = "bristol" AND arrivalLocation = "london" AND TravelType="air";

-- Used in bookingSuccess to retrieving the original price of the departure travel
SELECT price FROM travel WHERE idtravel = 1;

-- Used in bookingSuccess to make booking of outgoing journey
INSERT INTO booking (accountHolder_idAccountHolder,travel_idtravel,bookingDate,travelClass,quantity,totalPrice) VALUES 
            ((SELECT idAccountHolder FROM accountHolder WHERE email="admin@admin.com"),1,"27/04/2023","Business",1,160);

-- Used in bookingSuccess for retrieving the original price of the return travel
SELECT price FROM travel WHERE idtravel = 2;

-- Used in bookingSuccess to make booking of return journey
INSERT INTO booking (accountHolder_idAccountHolder,travel_idtravel,bookingDate,travelClass,quantity,totalPrice) VALUES 
                ((SELECT idAccountHolder FROM accountHolder WHERE email="admin@admin.com"),2,"27/04/2023","Business",1,160);

-- Used in bookingSuccess for retrieving the departure travel information for display.
SELECT travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime FROM travel WHERE idtravel=1;

-- Used in bookingSuccess for retrieving the return travel information for display.
SELECT travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime FROM travel WHERE idtravel=2;

-- Used in signup to check if the email address already exists in the database
SELECT * FROM accountHolder WHERE email = 'admin@admin.com';

-- Used in signup to insert the user into the database
INSERT INTO accountHolder (firstName,lastName,dob,email,passwrd) VALUES('will','griffin','02/06/2003','admin@admin.com','123');

-- Used in login to fetch the password and account type for the email
SELECT passwrd, accountHolderType FROM accountHolder WHERE email = 'admin@admin.com';

-- Used in account to fetch the user's current password from the database
SELECT passwrd FROM accountHolder WHERE email = 'admin@admin.com';

-- Used in account to change the user password
UPDATE accountHolder SET passwrd = '1234' WHERE email = 'admin@admin.com'

-- Used in account to fetch all the users data 
SELECT * FROM accountHolder WHERE email='admin@admin.com';

-- Used in booking to select the travel ID from the booking table using the booking ID and user's email
SELECT travel_idtravel FROM booking WHERE idbooking = 1 AND 
                    accountHolder_idAccountHolder = (SELECT accountHolder_idAccountHolder FROM accountHolder WHERE email="admin@admin.com");

-- Used in bookings to select the travel type from the travel table using the booking ID
SELECT travelType FROM travel WHERE idtravel=(SELECT travel_idtravel FROM booking WHERE idbooking=1);

-- Used in bookings to select the price of the booking from the travel table using the booking ID
SELECT price FROM travel WHERE idtravel = (SELECT travel_idtravel FROM booking WHERE idbooking = 1);

-- Used in booking to update booking date, travel class, quantity and total price
UPDATE booking SET bookingDate = "27/04/2023", travelClass = "Business", quantity = 1, totalPrice = 160 WHERE idbooking = 1;

-- Used in booking to select the booking date from the booking table using the booking ID
SELECT bookingDate FROM booking WHERE idbooking = 1;

-- Used in booking to deleted a booking
DELETE FROM booking WHERE idbooking = 1;

-- Used in admin account to update passwords
UPDATE accountHolder SET passwrd = '1234' WHERE idAccountHolder = 1;

-- Used in adminAccounts to get the ID of the currently logged-in user
SELECT idAccountHolder FROM accountHolder WHERE email='admin@admin.com';


-- Used in adminAccounts to promote user
UPDATE accountHolder SET accountHolderType='admin' WHERE idAccountHolder='1';

-- Used in adminAccounts to demote user
UPDATE accountHolder SET accountHolderType='standard' WHERE idAccountHolder='1';

-- Used in adminAccount to select all data from the accountHolder table
SELECT * FROM accountHolder;

-- Used in adminBooking for retrieving data from three tables: "booking," "travel," and "accountHolder". To show booking details for each user 
SELECT idbooking,firstName,lastName,email,travelType,departureLocation,departureTime, arrivalLocation,arrivalTime,travelTime, travelClass,quantity,totalPrice,bookingCreated,bookingModified 
                FROM booking INNER JOIN travel ON travel_idtravel=idtravel INNER JOIN accountHolder ON accountHolder_idaccountHolder = idaccountHolder;

-- Used in adminSales to show the top four customer in order of total sales
SELECT accountHolder.idAccountHolder, accountHolder.firstName, accountHolder.lastName,accountHolder.email, COALESCE(SUM(booking.totalPrice), 0) AS totalBookingPrice
                FROM accountHolder LEFT JOIN booking ON accountHolder.idAccountHolder = booking.accountHolder_idAccountHolder 
                GROUP BY accountHolder.idAccountHolder, accountHolder.firstName, accountHolder.lastName ORDER BY totalBookingPrice DESC LIMIT 4;

-- Used in salesPerJourney to count how many of the journeys are from each travel type
SELECT  COUNT(*) AS journeyCount FROM travel WHERE travelType = 'air';

-- Used in salesPerJourney to count how may bookings each travel type has each month 
SELECT COUNT(*) FROM booking INNER JOIN travel ON booking.travel_idtravel = travel.idtravel 
                WHERE travel.idtravel = 1 AND DATE_FORMAT(booking.bookingDate, '%%Y-%%m') = '1';

-- Used in salesPerYear to count how many bookings each month has (months 0-9)
SELECT COUNT(*) AS bookingCount FROM booking WHERE DATE_FORMAT(bookingDate, '%%Y/%%m') = '2023/04';

-- Used in salesPerYear to count how many bookings each month has (months 10-12)
SELECT COUNT(*) AS bookingCount FROM booking WHERE DATE_FORMAT(bookingDate, '%%Y/%%m') = '2023/11';


-- INSERT travel journeys
INSERT INTO travel (idtravel, TravelType, departureLocation, departureTime, arrivalLocation, arrivalTime, travelTime, price) 
VALUES 
(1, 'air', 'Newcastle', '16:45:00', 'Bristol', '18:00:00', '1:15:00', 80),
(2, 'air', 'Bristol', '8:00:00', 'Newcastle', '9:15:00', '1:15:00', 80),
(3, 'air', 'Cardiff', '6:00:00', 'Edinburgh', '7:30:00', '1:30:00', 80),
(4, 'air', 'Bristol', '11:30:00', 'Manchester', '12:30:00', '1:00:00', 60),
(5, 'air', 'Manchester', '12:20:00', 'Bristol', '13:20:00', '1:00:00', 60),
(6, 'air', 'Bristol', '7:40:00', 'London', '8:20:00', '0:40:00', 60),
(7, 'air', 'London', '11:00:00', 'Manchester', '12:20:00', '1:20:00', 75),
(8, 'air', 'Manchester', '12:20:00', 'Glasgow', '13:30:00', '1:10:00', 75),
(9, 'air', 'Bristol', '7:40:00', 'Glasgow', '8:45:00', '1:05:00', 90),
(10, 'air', 'Glasgow', '14:30:00', 'Newcastle', '15:45:00', '1:15:00', 75),
(11, 'air', 'Newcastle', '16:15:00', 'Manchester', '17:05:00', '0:50:00', 75),
(12, 'air', 'Manchester', '18:25:00', 'Bristol', '19:30:00', '1:05:00', 60),
(13, 'air', 'Bristol', '6:20:00', 'Manchester', '7:20:00', '1:00:00', 60),
(14, 'air', 'Portsmouth', '12:00:00', 'Dundee', '14:00:00', '2:00:00', 100),
(15, 'air', 'Dundee', '10:00:00', 'Portsmouth', '12:00:00', '2:00:00', 100),
(16, 'air', 'Edinburgh', '18:30:00', 'Cardiff', '20:00:00', '1:30:00', 80),
(17, 'air', 'Southampton', '12:00:00', 'Manchester', '13:30:00', '1:30:00', 70),
(18, 'air', 'Manchester', '19:00:00', 'Southampton', '20:30:00', '1:30:00', 70),
(19, 'air', 'Birmingham', '16:00:00', 'Newcastle', '17:30:00', '1:30:00', 75),
(20, 'air', 'Newcastle', '6:00:00', 'Birmingham', '7:30:00', '1:30:00', 75),
(21, 'air', 'Aberdeen', '7:00:00', 'Portsmouth', '9:00:00', '2:00:00', 75),
(22, 'coach', 'Newcastle', '16:45:00', 'Bristol', '4:00:00', '11:15:00', 27),
(23, 'coach', 'Bristol', '8:00:00', 'Newcastle', '19:15:00', '11:15:00', 27),
(24, 'coach', 'Cardiff', '6:00:00', 'Edinburgh', '19:30:00', '13:30:00', 27),
(25, 'coach', 'Bristol', '11:30:00', 'Manchester', '20:30:00', '9:00:00', 20),
(26, 'coach', 'Manchester', '12:20:00', 'Bristol', '21:20:00', '9:00:00', 20),
(27, 'coach', 'Bristol', '7:40:00', 'London', '13:40:00', '6:00:00', 20),
(28, 'coach', 'London', '11:00:00', 'Manchester', '23:00:00', '12:00:00', 25),
(29, 'coach', 'Manchester', '12:20:00', 'Glasgow', '22:50:00', '10:30:00', 25),
(30, 'coach', 'Bristol', '7:40:00', 'Glasgow', '17:25:00', '9:45:00', 30),
(31, 'coach', 'Glasgow', '14:30:00', 'Newcastle', '1:45:00', '11:15:00', 25),
(32, 'coach', 'Newcastle', '16:15:00', 'Manchester', '23:45:00', '7:30:00', 25),
(33, 'coach', 'Manchester', '18:25:00', 'Bristol', '4:10:00', '9:45:00', 20),
(34, 'coach', 'Bristol', '6:20:00', 'Manchester', '15:20:00', '9:00:00', 20),
(35, 'coach', 'Edinburgh', '18:30:00', 'Cardiff', '8:00:00', '13:30:00', 27),
(36, 'coach', 'Southampton', '12:00:00', 'Manchester', '1:30:00', '13:30:00', 23),
(37, 'coach', 'Manchester', '19:00:00', 'Southampton', '8:30:00', '13:30:00', 23),
(38, 'coach', 'Birmingham', '16:00:00', 'Newcastle', '5:30:00', '13:30:00', 25),
(39, 'coach', 'Newcastle', '6:00:00', 'Birmingham', '19:30:00', '13:30:00', 25),
(40, 'train', 'Newcastle', '16:45:00', 'Bristol', '21:45:00', '5:00:00', 200),
(41, 'train', 'Bristol', '8:00:00', 'Newcastle', '13:00:00', '5:00:00', 200),
(42, 'train', 'Cardiff', '6:00:00', 'Edinburgh', '12:00:00', '6:00:00', 200),
(43, 'train', 'Bristol', '11:30:00', 'Manchester', '15:30:00', '4:00:00', 150),
(44, 'train', 'Manchester', '12:20:00', 'Bristol', '16:20:00', '4:00:00', 150),
(45, 'train', 'Bristol', '7:40:00', 'London', '10:20:00', '2:40:00', 150),
(46, 'train', 'London', '11:00:00', 'Manchester', '16:20:00', '5:20:00', 188),
(47, 'train', 'Manchester', '12:20:00', 'Glasgow', '17:00:00', '4:40:00', 188),
(48, 'train', 'Bristol', '7:40:00', 'Glasgow', '12:00:00', '4:20:00', 225),
(49, 'train', 'Glasgow', '14:30:00', 'Newcastle', '19:30:00', '5:00:00', 188),
(50, 'train', 'Newcastle', '16:15:00', 'Manchester', '19:35:00', '3:20:00', 188),
(51, 'train', 'Manchester', '18:25:00', 'Bristol', '22:45:00', '4:20:00', 150),
(52, 'train', 'Bristol', '6:20:00', 'Manchester', '10:20:00', '4:00:00', 150),
(53, 'train', 'Edinburgh', '18:30:00', 'Cardiff', '0:30:00', '6:00:00', 200),
(54, 'train', 'Southampton', '12:00:00', 'Manchester', '18:00:00', '6:00:00', 175),
(55, 'train', 'Manchester', '19:00:00', 'Southampton', '1:00:00', '6:00:00', 175),
(56, 'train', 'Birmingham', '16:00:00', 'Newcastle', '22:00:00', '6:00:00', 188),
(57, 'train', 'Newcastle', '6:00:00', 'Birmingham', '12:00:00', '6:00:00', 188);


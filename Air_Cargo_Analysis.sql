/*1. Create an ER diagram for the given airlines database.
SQL code:*/

DESCRIBE customer;
DESCRIBE routes;
DESCRIBE passengers_on_flights;
DESCRIBE ticket_details;
ALTER TABLE customer
ADD primary key (customer_id);
ALTER TABLE passengers_on_flights ADD primary key (seat_num);
ALTER TABLE passengers_on_flights MODIFY seat_num VARCHAR(20);
ALTER TABLE ticket_details
ADD primary key (p_date, class_id);
ALTER TABLE ticket_details MODIFY p_date VARCHAR(10), MODIFY class_id VARCHAR(50);
ALTER TABLE passengers_on_flights MODIFY travel_dateVARCHAR(10), MODIFY class_id VARCHAR(50);
ALTER TABLE passengers_on_flights ADD FOREIGN KEY(customer_id) REFERENCES customer(customer_id);
ALTER TABLE passengers_on_flights ADD FOREIGN KEY (route_id)
REFERENCES routes(route_id);
ALTER TABLE ticket_details
ADD FOREIGN KEY(customer_id) REFERENCES customer(customer_id);
ALTER TABLE passengers_on_flights
ADD FOREIGN KEY(travel_date, class_id) REFERENCES ticket_details(p_date, class_id);

/*2. Write a query to create route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. Implement the check constraint for the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0.
SQL code:*/


DESCRIBE routes;
-- route_id should be a primary key in order to be Unique and cannot contain Null values ALTER TABLE routes
MODIFY flight_num int NOT NULL;
ALTER TABLE routes
ADD primary key (route_id);
ALTER TABLE routes
ADD CHECK (flight_num > 1),
ADD CHECk (distance_miles > 0);
SELECT *
FROM routes
WHERE distance_miles > 0;


/*3. Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data from the passengers_on_flights table.
SQL code:*/

SELECT c.customer_id, c.first_name, c.last_name, p.route_id, p.travel_date
FROM customer as c
INNER JOIN passengers_on_flights as p
ON c.customer_id=p.customer_id WHERE p.route_id BETWEEN 01 AND 25;



/*4. Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.
SQL code:*/


SELECT SUM(no_of_tickets) AS num_passenger_in_business_class, SUM(Price_per_ticket * No_of_tickets) AS total_revenue_of_business_class FROM ticket_details
WHERE class_id = 'Bussiness';



/* 6. Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.
SQL code:*/


SELECT c.*
FROM customer c
JOIN ticket_details td ON c.customer_id = td.customer_id;


/*7. Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.
SQL code:*/


SELECT c.first_name, c.last_name
FROM customer c
JOIN ticket_details td ON c.customer_id = td.customer_id WHERE td.brand = 'Emirates';


/* 8. Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table.
SQL code:*/


SELECT customer_id
FROM passengers_on_flights WHERE class_id = 'Economy Plus' GROUP BY customer_id
HAVING COUNT(*) > 0;


/*9. Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.
SQL code:*/


SELECT IF(SUM(price_per_ticket * no_of_tickets) > 10000, 'Revenue has crossed 10000', 'Revenue has not crossed 10000') AS revenue_status
FROM ticket_details;


/* 10. Write a query to create and grant access to a new user to perform operations on a database.
SQL code:*/


CREATE USER 'new_user'@'localhost' IDENTIFIED BY '123'; GRANT ALL PRIVILEGES ON airlines.* TO 'new_user'@'localhost';


/* 11. Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.
SQL code:*/


SELECT class_id, MAX(price_per_ticket) OVER (PARTITION BY class_id) AS max_ticket_price FROM ticket_details;




/* 12. Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.
SQL code:*/

SELECT *
FROM passengers_on_flights WHERE route_id = 4;




/* 13. For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.
SQL code:*/

CREATE VIEW execution_plan AS SELECT *
FROM passengers_on_flights WHERE route_id = 4;



/* 14. Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.
SQL code:*/

SELECT customer_id, aircraft_id, SUM(Price_per_ticket) AS total_price FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP;


/* 15. Write a query to create a view with only business class customers along with the brand of airlines.
SQL code:*/


CREATE VIEW business_class_customers AS
SELECT c.customer_id, c.first_name, c.last_name, c.date_of_birth, c.gender, td.brand FROM Customer c
JOIN ticket_details td ON c.customer_id = td.customer_id
WHERE td.class_id = 'Business';



/*16. Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. Also, return an error message if the table doesn't exist.
SQL code:*/

DELIMITER $$
CREATE PROCEDURE get_flight_route_range (IN flight_route_id1 INT, IN flight_route_id2 INT) BEGIN
DECLARE passengers_table_exists INT; DECLARE customer_table_exists INT;
SELECT COUNT(*) INTO passengers_table_exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'passengers_on_flights'; SELECT COUNT(*) INTO customer_table_exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'customer';
-- Return an error message if either of the tables does not exist
IF passengers_table_exists = 0 OR customer_table_exists = 0 THEN
SELECT 'Error: One or more of the required tables are not exist. ' AS Message;
ELSE
-- Check the number of rows that would be returned by the query
SET @num_rows = (
SELECT COUNT(*)
FROM passengers_on_flights AS p
WHERE p.route_id BETWEEN flight_route_id1 AND flight_route_id2
);
-- Return an error message if there is no matching rows
IF @num_rows = 0 THEN
SELECT 'Error: No data found for the specified flight route range. Table Doesnt Exist' AS Message;
ELSE
-- Fetching passenger and customer details between the specified routes
SELECT p.route_id,
p.depart,
p.arrival,
p.seat_num,
c.*
FROM passengers_on_flights AS p
INNER JOIN customer AS c ON p.customer_id = c.customer_id
WHERE p.route_id BETWEEN flight_route_id1 AND flight_route_id2
ORDER BY p.route_id; END IF;
END IF;
END $$
DELIMITER ;
CALL get_flight_route_range('1','30'); -- CALL get_flight_route_range('2','3');


/* 17. Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.
SQL code:*/


CREATE PROCEDURE get_routes_with_distance() BEGIN
SELECT *
FROM routes
WHERE distance_miles > 2000;
END &&
DELIMITER ;
CALL get_routes_with_distance();


/*18. Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long- distance travel (LDT) for >6500.
SQL code:*/


DELIMITER &&
CREATE PROCEDURE group_distance_travel() BEGIN
SELECT flight_num, CASE
WHEN distance_miles >= 0 AND distance_miles <= 2000 THEN 'SDT' WHEN distance_miles > 2000 AND distance_miles <= 6500 THEN 'IDT' WHEN distance_miles > 6500 THEN 'LDT'
END AS distance_category FROM routes;
END &&
DELIMITER ;
CALL group_distance_travel();




/* 19. Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table.
SQL code:*/


DELIMITER &&
CREATE PROCEDURE get_ticket_details() BEGIN
SELECT p_date, customer_id, class_id, CASE
WHEN class_id = 1 THEN 'Yes'
ELSE 'No'
END AS complimentary_service
FROM ticket_details
WHERE
class_id IS NOT NULL;
END &&
DELIMITER ;
CALL get_ticket_details();





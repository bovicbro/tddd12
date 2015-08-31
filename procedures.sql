DROP PROCEDURE IF EXISTS add_credit_card;
DROP PROCEDURE IF EXISTS reserve_ticket;
DROP PROCEDURE IF EXISTS pay_ticket;
DROP PROCEDURE IF EXISTS add_passanger;
DROP PROCEDURE IF EXISTS get_available_flights;
DROP PROCEDURE IF EXISTS add_person;
DROP FUNCTION IF EXISTS get_price;
DROP FUNCTION IF EXISTS get_seats_left;

delimiter //

CREATE PROCEDURE add_credit_card 
(IN 
    month_year varchar(7), 
    f_name varchar(20), 
    l_name varchar(20), 
    card_no varchar(16), 
    csv int)
BEGIN
    INSERT INTO credit_card 
    VALUES(
    card_no, 
    f_name, 
    l_name, 
    month_year, 
    csv);
END;

//

/*When we recieve a batch of reservations with a specific contat, we assume
that the first person we recive is the contact for that batch.*/
CREATE PROCEDURE reserve_ticket
(IN 
    v_p_no varchar(10), 
    v_f_name varchar(20), 
    v_l_name varchar(20), 
    v_flight_no int, 
    v_contact varchar(10)
    ) 
BEGIN
CALL add_person(v_f_name,v_l_name,v_p_no);
INSERT INTO tickets(passenger, contact, flight_no) 
VALUES (
    v_p_no, 
    v_contact, 
    v_flight_no);
END;

//

CREATE PROCEDURE add_person
(IN
	f_name varchar(20),
	l_name varchar(20),
	p_no varchar(10)
)

BEGIN
INSERT IGNORE INTO people VALUES
(
	f_name,
	l_name,
	p_no
);
END;

//

CREATE PROCEDURE pay_ticket 
(IN 
    p_no varchar(10), 
    f_name varchar(20), 
    l_name varchar(20), 
    card_no_in varchar(16), 
    month_year varchar(7), 
    csv int
    )

BEGIN

DECLARE v_flight_no INT;
DECLARE no_req_seats INT;

SELECT flight_no, COUNT(*) 
    INTO 
	v_flight_no, 
	no_req_seats
    FROM 
	tickets
    WHERE 
	contact = p_no 
    GROUP BY 
	contact
;

IF (get_seats_left(v_flight_no, no_req_seats)) THEN
	UPDATE flight 
	SET tickets_left = tickets_left - no_req_seats 
	WHERE flight_no 
	LIKE v_flight_no;
ELSE
	DELETE * FROM tickets 
	WHERE contact = p_no and flight_no 
	LIKE v_flight_no;
END IF;

CALL add_credit_card(month_year, f_name, l_name, card_no_in, csv);
END;

//

DELIMITER |
CREATE TRIGGER update_ticket AFTER UPDATE ON flight FOR EACH ROW
BEGIN
	SELECT CONCAT(
	SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
        SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1)
    ) as uniqe_ticket_no;

	SELECT flight_no FROM tickets WHERE price = NEW.price

	UPDATE tickets SET 
	price = get_price(flight_no), 
	status = 1,
	
	pay_date = CURDATE()
	WHERE (id = ticket OR reservation_no = ticket);
END: |
DELIMITER //

//

CREATE FUNCTION get_seats_left(this_flight INT, no_req_seats INT)
RETURNS TINYINT(1)
BEGIN
DECLARE seats_left TINYINT(1);
IF (
    SELECT tickets_left 
	FROM flight 
	WHERE flight_no=this_flight) > no_req_seats 
	THEN
		SET seats_left = 1;
    ELSE
	SET seats_left = 0;
END IF;
	RETURN(seats_left);
END;

//

CREATE FUNCTION get_price(flight INT)
RETURNS INT
BEGIN
DECLARE route_price INT;
DECLARE weekday_factor DOUBLE;
DECLARE seats_left INT;
DECLARE passanger_factor DOUBLE;
DECLARE flight_date DATE;
DECLARE flight_schedule_id INT;
DECLARE route INT;	 

SELECT tickets_left, dep_date, schedule_id  
FROM flight 
WHERE flight_no = flight 
INTO seats_left, flight_date, flight_schedule_id;

SET weekday_factor = (
    SELECT price_factor 
    FROM weekday_factor 
    WHERE weekday = DAYNAME(flight_date) 
    AND year = YEAR(flight_date));

SET passanger_factor = (
    SELECT price_factor 
    FROM passanger_factor 
    WHERE year = YEAR(flight_date));

SET route = (
    SELECT route_id 
    FROM flight_schedule 
    WHERE id = flight_schedule_id);

SET route_price = (
    SELECT price 
    FROM route_price 
    WHERE year = YEAR(flight_date) 
    AND route_id = route);

RETURN(route_price*weekday_factor*((61-seats_left)/60)*passanger_factor);
END;  

//

CREATE PROCEDURE add_passanger 
(IN 
    reservation_no int, 
    v_f_name varchar(20), 
    v_l_name varchar(20), 
    v_p_no varchar(10))

BEGIN

DECLARE flight INT;
DECLARE contact_person varchar(20);
DECLARE credit_card varchar(16);

SELECT card_no, flight_no, contact 
INTO credit_card, flight, contact_person 
FROM tickets 
WHERE id = reservation_no;  

INSERT INTO people 
VALUES(v_f_name, v_l_name, v_p_no);

INSERT INTO tickets(status, price, pay_date, card_no, passenger, contact, flight_no, reservation_no) 
VALUES(1, price(flight), NULL, credit_card, v_p_no, contact_person, flight, reservation_no);

END; 

//

CREATE PROCEDURE add_passanger (IN v_f_name, v_l_name, v_p_no, v_p_no, )

//

CREATE PROCEDURE get_available_flights(v_dep_city varchar(14), v_arr_city varchar(14), no_people int, travle_date DATE)
BEGIN

DECLARE wanted_route INT;
DECLARE wanted_flight INT;
DECLARE wanted_schedule INT; 

SET wanted_route = (
    SELECT route_id 
    FROM route 
    WHERE
	dep_city  = (SELECT id FROM city WHERE name LIKE v_dep_city) AND
	arr_city  = (SELECT id FROM city WHERE name LIKE v_arr_city));

SELECT wanted_route;

SELECT f.flight_no, f.dep_date, f_s.dep_time, f_s.arr_time 
FROM 
flight f,
flight_schedule f_s
WHERE
f_s.route_id = wanted_route AND
f.schedule_id = f_s.id AND
f.dep_date = travle_date AND
f.tickets_left >= no_people;


SELECT id 
INTO wanted_flight 
FROM flight_schedule 
WHERE route_id = wanted_route;

SELECT schedule_id 
INTO wanted_flight 
FROM flight 
WHERE dep_date = travle_date AND tickets_left >= no_people;

SELECT weekday, dep_time, arr_time 
FROM flight_schedule 
WHERE route_id = wanted_route AND id = wanted_flight;

SELECT f_s.id, dep_city, f_s.dep_time, arr_city, f_s.arr_time, travle_date, f.tickets_left, get_price(f_s.id) 
FROM flight_schedule f_s, flight f, city c, route r 
WHERE (
    c.name = dep_city AND 
    c.name = arr_city AND 
    r.dep_city = c.id AND 
    r.arr_city = c.id AND 
    f_s.route_id = r.route_id AND 
    f.schedule_id = f_s.id
    ) AND
    f.dep_date = travle_date AND 
    f.tickets_left >= no_people;

END;

//

delimiter ;

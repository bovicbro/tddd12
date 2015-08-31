
delimiter ;

DROP TABLE IF EXISTS valid_for CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS credit_card CASCADE;
DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS route_price CASCADE;
DROP TABLE IF EXISTS flight CASCADE;
DROP TABLE IF EXISTS flight_schedule CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS weekday_factor CASCADE;
DROP TABLE IF EXISTS passanger_factor CASCADE;

CREATE TABLE credit_card
(
	card_no varchar(16),
	f_name varchar(20),
	l_name varchar(20),
	month_year varchar(7),
	csv int(3) NOT NULL,
	CONSTRAINT
	PRIMARY KEY (card_no)
);

CREATE TABLE people
(
	f_name varchar(20),
	l_name varchar(20),
	p_no varchar(10),
	CONSTRAINT
	PRIMARY KEY (p_no)
);

CREATE TABLE tickets
(
	id int NOT NULL AUTO_INCREMENT,
	purchase_id int DEFAULT NULL,
	status int DEFAULT 0,
	price int DEFAULT NULL,
	pay_date date DEFAULT NULL,
	card_no varchar(16) DEFAULT NULL,
	passenger varchar(10),
	contact varchar(10),
	flight_no int,
	CONSTRAINT
	PRIMARY KEY (id),
	FOREIGN KEY (passenger) REFERENCES people(p_no),
	FOREIGN KEY (card_no) REFERENCES credit_card(card_no),
	FOREIGN KEY (contact) REFERENCES people(p_no)
);


CREATE TABLE city
(
	id int NOT NULL AUTO_INCREMENT,
	name varchar(14),
	CONSTRAINT
	PRIMARY KEY (id)
);

CREATE TABLE weekday_factor
(
	weekday varchar(8) NOT NULL,
	year int,
	price_factor float(6),
	CONSTRAINT
	PRIMARY KEY (year, weekday)
);

CREATE TABLE passanger_factor 
(
	year int,
	price_factor float(6),
	CONSTRAINT
	PRIMARY KEY (year)
);

CREATE TABLE route
(
	route_id int(10) NOT NULL AUTO_INCREMENT,
	dep_city int NOT NULL,
	arr_city int NOT NULL,
	CONSTRAINT
	PRIMARY KEY (route_id),
	FOREIGN KEY (dep_city) REFERENCES city(id),
	FOREIGN KEY (arr_city) REFERENCES city(id)
);

CREATE TABLE flight_schedule
(
	weekday varchar(10),
	dep_time TIME,
	arr_time TIME,
	year int(4),
	id int NOT NULL AUTO_INCREMENT,
	route_id int,
	CONSTRAINT
	PRIMARY KEY	(id),
	FOREIGN KEY (route_id) REFERENCES route(route_id)
);

CREATE TABLE flight 
(
	schedule_id int,
	flight_no int NOT NULL AUTO_INCREMENT, 
	dep_date date,
	aircraft varchar(7),
	tickets_left int(10),
	CONSTRAINT
	PRIMARY KEY (flight_no),
	FOREIGN KEY (schedule_id) REFERENCES flight_schedule(id)
);

CREATE TABLE route_price
(
	year int(4),
	price int(6),
	route_id int(10) NOT NULL,
	CONSTRAINT
	PRIMARY KEY (year, route_id),
	FOREIGN KEY (route_id) REFERENCES route(route_id)
);

ALTER TABLE tickets ADD CONSTRAINT fk_flight_no FOREIGN KEY (flight_no) REFERENCES flight(flight_no);

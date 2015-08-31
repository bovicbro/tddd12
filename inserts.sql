
INSERT INTO credit_card 
VALUES (
    '4552966878562242',
    'Jens',
    'Johansson',
    2016-06, 123
    );

INSERT INTO people 
VALUES (
    'Victor',
    'Broman',
    '9212052212'),
    (
    'Jens',
    'Johansson',
    '0101010101'
    );

INSERT INTO city(name) VALUES
('Stockholm'),
('Hanoi'),
('Macao');

INSERT INTO route(arr_city, dep_city) VALUES
(2,1),
(1,1);

INSERT INTO route_price(year, price, route_id) VALUES
(2014,100,1),
(2014,77,2),
(2015,66,1),
(2015,55,2);

INSERT INTO flight_schedule(weekday, dep_time, arr_time, year, route_id) VALUES
('Sunday','08:00:00','13:35:00','2014',1),
('Monday','15:00:00','23:17:00','2014',2);


INSERT INTO	flight (schedule_id,dep_date,aircraft,tickets_left) VALUES
(1,'2014-05-18',0000000,1),
(2,'2014-05-18',0000001,1);

INSERT INTO tickets (status,price,pay_date,card_no,passenger,contact, flight_no) VALUES
(1,2000,2014-01-01,'4552966878562242','9212052212','0101010101', 2);
/*(1,3500,2014-01-01,'4552966878562242','8909047535','0101010101', 2, 1),
(1,2120,2014-01-01,'4552966878562242','0101010101','0101010101', 1, NULL);
*/
INSERT INTO weekday_factor(weekday, year, price_factor) VALUES
('Monday', 2014, 1),
('Thuesday',2014, 2),
('Wednesday',2014, 3),
('Thursday',2014, 4),
('Friday',2014, 4.7),
('Saturday',2014, 2),
('Sunday',2014, 4.7);

INSERT INTO passanger_factor VALUES
(2014, 2.4),
(2015, 2.5);

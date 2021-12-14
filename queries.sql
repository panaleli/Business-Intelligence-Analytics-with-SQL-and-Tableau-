--Part B: Provide the latitude and longitude for each id_request.

SELECT id_request, latitude, longitude
from request;


--Part B: How many requests per day happened during week 11, 2018 and during previous week?

SELECT
strftime('%d/%m/%Y',created_at) created_at, 
strftime('%W',created_at) AS week_of_year,
COUNT(id_request)
FROM request
where  week_of_year = '11' --Year week =11
or week_of_year = '10'  --previous Year week =10
GROUP   BY  DATE(created_at)
order by created_at asc;


--Part B: Provide a list of active passengers sorted descending by volume of rides. 
--Active passengers: Passengers who have at least 1 ​completed ​ride.

SELECT fare_snapshot.id_passenger,
count(ride.id_request) as volume_rides
FROM fare_snapshot, ride, payment_mean_history
where fare_snapshot.id_request =
ride.id_request
and fare_snapshot.id_passenger =
payment_mean_history.id_passenger
and ride.actual_revenue >'0'
GROUP BY fare_snapshot.id_passenger
order by volume_rides desc;


--Part B: What was the request to ride ratio per weekday and per hour?
--SQL Query Part 1:

CREATE VIEW rush_hours_days AS 
SELECT 
strftime('%w',created_at) AS week_day,
strftime('%d/%m/%Y',created_at) created_at_date, 
strftime('%H:%M:%S',created_at) created_at_hours, 
strftime('%H',created_at) AS hours,
COUNT(id_request) AS total_count_request
FROM ride
GROUP BY created_at_date, hours
order by week_day,hours asc;

--SQL Query Part 2:

SELECT
  rush_hours_days.week_day AS week_day,
  rush_hours_days.hours AS rush_hour,
  rush_hours_days.total_count_request AS total_count
-- get the max count for every day
FROM (
      SELECT
        week_day,          -- the day 
        max(total_count_request) as total_count_request -- the count
      FROM rush_hours_days
      GROUP BY week_day
     ) AS max_count
-- find the actual hour(s) with the max count for every day:
INNER JOIN rush_hours_days ON rush_hours_days.total_count_request = max_count.total_count_request
                AND rush_hours_days.week_day = max_count.week_day;




--Part B: How many rides per day were ​completed ​using cash and how many using a credit card?

SELECT 
strftime('%d/%m/%Y',ride.created_at) ride_created_day,
IIF 
(payment_mean_history.created_at <= ride.created_at 
AND
ride.created_at < payment_mean_history.deleted_at, 'credit_card', 'cash') as payment_method,
count(ride.id_request) as completed_rides
FROM fare_snapshot, ride, payment_mean_history
where fare_snapshot.id_passenger = payment_mean_history.id_passenger
and fare_snapshot.id_request = ride.id_request
and ride.actual_revenue >'0'
group by
payment_method,
ride_created_day
order by ride_created_day asc;
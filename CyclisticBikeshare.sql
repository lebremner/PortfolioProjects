--View Data, drop unneccesary column1 
--Chicago
SELECT TOP 1000 * 
FROM Q1_21

SELECT TOP 1000 *
FROM Q2_21

ALTER TABLE Q2_21
DROP COLUMN column1

SELECT TOP 1000 *
FROM Q3_21

ALTER TABLE Q3_21
DROP COLUMN column1

SELECT TOP 1000 *
FROM Q4_21

ALTER TABLE Q4_21
DROP COLUMN column1

--Bay Area
SELECT TOP 1000 * 
FROM bay_Q121

ALTER TABLE bay_Q121
DROP COLUMN column1

SELECT TOP 1000 *
FROM bay_Q221

ALTER TABLE bay_Q221
DROP COLUMN column1

SELECT TOP 1000 *
FROM bay_Q321

ALTER TABLE bay_Q321
DROP COLUMN column1

SELECT TOP 1000 *
FROM bay_Q421

ALTER TABLE bay_Q421
DROP COLUMN column1


----------------------------------------------------------------------------------------------------------
--Create Temp Tables
--Chicago
--Create temp table
CREATE TABLE #Chicago_Bike_21 (
started_at nvarchar(MAX)
, ended_at nvarchar(MAX)
, start_station_name nvarchar(max)
, end_station_name nvarchar(max)
, start_lat float
, start_lng float
, end_lat float
, end_lng float
, member_casual nvarchar(max))

INSERT INTO #Chicago_Bike_21
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM Q1_21
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM Q2_21
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM Q3_21
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM Q4_21

SELECT TOP 1000 *
FROM #Chicago_Bike_21
ORDER BY started_at

--Bay Area
CREATE TABLE #SF_Bike_21 (
started_at nvarchar(MAX)
, ended_at nvarchar(MAX)
, start_station_name nvarchar(max)
, end_station_name nvarchar(max)
, start_lat float
, start_lng float
, end_lat float
, end_lng float
, member_casual nvarchar(max))

INSERT INTO #SF_Bike_21
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM bay_Q121
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM bay_Q221
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM bay_Q321
UNION
SELECT started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual
FROM bay_Q421

SELECT TOP 1000 *
FROM #SF_Bike_21
ORDER BY started_at

---------------------------------------------------------------------------------------------------------------
--Count individual stations

--Chicago
SELECT count(distinct start_station_name)
FROM #Chicago_Bike_21
WHERE start_station_name NOT LIKE 'NA'

--Bay Area
SELECT count(distinct start_station_name)
FROM #SF_Bike_21
WHERE start_station_name NOT LIKE 'NA'

--Count membership type

--Chicago
SELECT count(member_casual), member_casual
FROM #Chicago_Bike_21
GROUP BY member_casual

--Bay Area
SELECT count(member_casual), member_casual
FROM #SF_Bike_21
GROUP BY member_casual

-----------------------------------------------------------------------------------------------------------------------
--Calcluate trip duration, add to table

--Chicago
Select started_at, ended_at, DATEDIFF(MINUTE, started_at, ended_at) as trip_duration
From #Chicago_Bike_21

ALTER TABLE #Chicago_Bike_21
Add trip_duration int;

Update #Chicago_Bike_21
SET trip_duration =  DATEDIFF(MINUTE, started_at, ended_at);


--Bay Area
Select started_at, ended_at, DATEDIFF(MINUTE, started_at, ended_at) as trip_duration
From #SF_Bike_21;

ALTER TABLE #SF_Bike_21
Add trip_duration int;

Update #SF_Bike_21
SET trip_duration =  DATEDIFF(MINUTE, started_at, ended_at);

SELECT TOP 1000 *
FROM #SF_Bike_21


---------------------------------------------------------------------------------------------------------------------
--Add day of the week column

--Chicago
SELECT started_at, DATENAME(weekday, started_at) as day_of_week
FROM #Chicago_Bike_21;

ALTER TABLE #Chicago_Bike_21
Add day_of_week nvarchar(50);

UPDATE #Chicago_Bike_21
SET day_of_week =  DATENAME(weekday, started_at)

Select TOP 1000 *
From #Chicago_Bike_21


--Bay Area
SELECT started_at, DATENAME(weekday, started_at) as day_of_week
FROM #SF_Bike_21;

ALTER TABLE #SF_Bike_21
Add day_of_week nvarchar(50);

UPDATE #SF_Bike_21
SET day_of_week =  DATENAME(weekday, started_at)

SELECT TOP 1000 *
FROM #SF_Bike_21

-----------------------------------------------------------------------------------------------
--splitting out start date from start time

--Chicago
Select started_at, CONVERT (Date, started_at) as start_date
From #Chicago_Bike_21

ALTER TABLE #Chicago_Bike_21
Add start_date date;

UPDATE #Chicago_Bike_21
SET start_date =   CONVERT (Date, started_at)

Select TOP 1000 *
From #Chicago_Bike_21


--Bay Area
Select started_at, CONVERT (Date, started_at) as start_date
From #SF_Bike_21

ALTER TABLE #SF_Bike_21
Add start_date date;

UPDATE #SF_Bike_21
SET start_date =   CONVERT (Date, started_at)

SELECT TOP 1000 *
FROM #SF_Bike_21

-------------------------------------------------------------------------------------------------------
--Daily Ride Count and Average trip duration grouped by membership type

--Chicago
SELECT start_date, member_casual, count(start_date) as daily_ride_count, AVG(trip_duration) as avg_trip_duration
FROM #Chicago_Bike_21
WHERE trip_duration < 1440
GROUP BY start_date, member_casual
ORDER BY start_date

--Bay Area
SELECT start_date, member_casual, count(start_date) as daily_ride_count, AVG(trip_duration) as avg_trip_duration
FROM #SF_Bike_21
WHERE trip_duration < 1440
GROUP BY start_date, member_casual
ORDER BY start_date

----------------------------------------------------------------------------------------------------------
--Day of the week count my membership type

--Chicago
SELECT day_of_week, member_casual, COUNT(day_of_week) as weekday_count
FROM #Chicago_Bike_21
GROUP BY day_of_week, member_casual
ORDER BY day_of_week

--Bay Area
SELECT day_of_week, member_casual, COUNT(day_of_week) as weekday_count
FROM #SF_Bike_21
GROUP BY day_of_week, member_casual
ORDER BY day_of_week


---------------------------------------------------------------------------------------------------------
--Top 20 Stations by Membership Type, Latitude and longitude smoothed for visualization 

--Chicago
SELECT TOP 20 start_station_name, member_casual, 
COUNT(start_station_name) as popular_stations,
AVG (start_lat) as start_lat_avg,
AVG(start_lng) as start_lng_avg
FROM #Chicago_Bike_21
WHERE start_station_name NOT LIKE 'NA' AND member_casual LIKE 'member'
GROUP BY start_station_name, member_casual
ORDER BY popular_stations DESC

SELECT TOP 20 start_station_name, member_casual, 
COUNT(start_station_name) as popular_stations,
AVG (start_lat) as start_lat_avg,
AVG(start_lng) as start_lng_avg
FROM #Chicago_Bike_21
WHERE start_station_name NOT LIKE 'NA' AND member_casual LIKE 'casual'
GROUP BY start_station_name, member_casual
ORDER BY popular_stations DESC

--Bay Area
SELECT TOP 20 start_station_name, member_casual, 
COUNT(start_station_name) as popular_stations,
AVG (start_lat) as start_lat_avg,
AVG(start_lng) as start_lng_avg
FROM #SF_Bike_21
WHERE start_station_name NOT LIKE 'NA' AND member_casual LIKE 'member'
GROUP BY start_station_name, member_casual
ORDER BY popular_stations DESC

SELECT TOP 20 start_station_name, member_casual, 
COUNT(start_station_name) as popular_stations,
AVG (start_lat) as start_lat_avg,
AVG(start_lng) as start_lng_avg
FROM #SF_Bike_21
WHERE start_station_name NOT LIKE 'NA' AND member_casual LIKE 'casual'
GROUP BY start_station_name, member_casual
ORDER BY popular_stations DESC



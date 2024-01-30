-- Question #3
SELECT 
	COUNT(index) AS total_trips
FROM green_taxi_data 
WHERE 
	lpep_pickup_datetime >= '2019-09-18 00:00:00' AND lpep_pickup_datetime <= '2019-09-18 23:59:59'
	AND lpep_dropoff_datetime >= '2019-09-18 00:00:00' AND lpep_pickup_datetime <= '2019-09-18 23:59:59'
;


-- Question # 4
SELECT *
FROM green_taxi_data
WHERE 
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-16' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-18' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-21' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-26'
ORDER BY trip_distance DESC
LIMIT 1;


-- Question # 5
SELECT 
	z."Borough" AS Borough,
	SUM(g."total_amount") AS sum_total_amount
FROM
	green_taxi_data g
INNER JOIN
	zones z ON g."PULocationID" = z."LocationID"
WHERE 
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-18'
	AND
	z."Borough" != 'Unknown'
GROUP BY
	Borough
LIMIT 3;


-- Question # 6
SELECT
	g.index,
	g.lpep_pickup_datetime,
	g.lpep_dropoff_datetime,
	zpu."Zone" AS "pu_zone",
	zdo."Zone" AS "do_zone",
	g."tip_amount"
FROM 
	green_taxi_data g 
INNER JOIN 
	zones zpu ON g."PULocationID" = zpu."LocationID"
INNER JOIN
	zones zdo ON g."DOLocationID" = zdo."LocationID"
WHERE 
	CAST(g.lpep_pickup_datetime AS DATE) >= '2019-09-01' AND CAST(g.lpep_dropoff_datetime AS DATE) <= '2019-09-30'
	AND
	zpu."Zone" = 'Astoria'
	AND
	zdo."Zone" is NOT NULL
ORDER by g."tip_amount" DESC
LIMIT 10;
;
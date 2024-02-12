-- SET UP
-- CREATE EXTERNAL TABLE
CREATE OR REPLACE EXTERNAL TABLE `lyrical-compass-412311.ny_taxi.green_taxi_external`
OPTIONS(
  format = "PARQUET",
  uris = ['gs://stb-de-zoomcamp-mage/yellow_taxi_data/2022/green/green_tripdata_2022-*.parquet']
);
-- CREATE STORED TABLE
CREATE OR REPLACE TABLE `lyrical-compass-412311.ny_taxi.green_taxi_2022` AS 
SELECT * FROM `lyrical-compass-412311.ny_taxi.green_taxi_external`;


-- QUESTION 1
-- COUNT RECORDS
SELECT COUNT(VendorID) FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022`;


-- QUESTION 2
-- DISTINCT PULocationsIDs: EXTERNAL
SELECT COUNT(DISTINCT PULocationID) FROM `lyrical-compass-412311.ny_taxi.green_taxi_external`;
-- DISTINCT PULocationsIDs: STORED
SELECT COUNT(DISTINCT PULocationID) FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022`;


-- QUESTION 3
-- fare_amount of 0
SELECT COUNT(fare_amount) FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022` WHERE fare_amount = 0;


-- QUESTION 4
-- Optimized query: Order results by PULocation and filter based on lpep_pickup_time
CREATE OR REPLACE TABLE `lyrical-compass-412311.ny_taxi.green_taxi_2022_partitioned_clustered`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT * FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022`;


-- QUESTION 5
-- Retrieve PULocationID beteween lpel_pickup_datetime 06/01/2022 and 06/30/2022 from materialized table.
SELECT DISTINCT PUlocationID FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022` WHERE lpep_pickup_datetime BETWEEN '2022-06-01' AND '2022-06-30';
-- Retrieve PULocationID beteween lpel_pickup_datetime 06/01/2022 and 06/30/2022 from partitioned table.
SELECT DISTINCT PUlocationID FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022_partitioned_clustered` WHERE lpep_pickup_datetime BETWEEN '2022-06-01' AND '2022-06-30';


-- QUESTION 8
-- Materialized table
SELECT COUNT(*) FROM `lyrical-compass-412311.ny_taxi.green_taxi_2022`;
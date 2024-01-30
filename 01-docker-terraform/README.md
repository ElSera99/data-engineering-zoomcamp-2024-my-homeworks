# **Question 1. Knowing docker tags**

Run the command to get information on Docker

*docker --help*

Now run the command to get help on the "docker build" command:

*docker build --help*

Do the same for "docker run".

Which tag has the following text? - *Automatically remove the container when it exits*

- -delete
- -rc
- -rmc
- `-rm`

# **Question 2. Understanding docker first run**

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash. Now check the python modules that are installed ( use *pip list* ).

What is version of the package *wheel* ?

- `0.42.0`
- 1.0.0
- 23.0.1
- 58.1.0

> **Using a Python:3.9 container with *--entrypoint=bash* and using *pip list*, we can found the answer**

# **Question 3. Count records**

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that *lpep_pickup_datetime* and *lpep_dropoff_datetime* columns are in the format timestamp (date and hour+min+sec) and not in date.

- `15767`
- 15612
- 15859
- 89009

Used data:

- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz
- https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv **- Previously uploaded**

> **First, we need to upload data to the database, for that a jupyter notebook was created:**
> 

```python
import pandas as pd
from sqlalchemy import create_engine

df = pd.read_csv("csv/green_tripdata_2019-09.csv", low_memory=False)
df["lpep_pickup_datetime"] = pd.to_datetime(df["lpep_pickup_datetime"])
df["lpep_dropoff_datetime"] = pd.to_datetime(df["lpep_dropoff_datetime"])

user = "root"
password = "root"
url = "localhost"
port = 5432
dbname = "ny_taxi"
table_name = "green_taxi_data"

engine = create_engine(f"postgresql://{user}:{password}@{url}:{port}/{dbname}")

table_schema = pd.io.sql.get_schema(df, name=table_name, con=engine)

df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')
df.to_sql(name=table_name, con=engine, if_exists='append')
```

> **To count the travels from that day**
> 

```sql
SELECT 
	COUNT(index) AS total_trips
FROM green_taxi_data 
WHERE 
	lpep_pickup_datetime >= '2019-09-18 00:00:00' AND lpep_pickup_datetime <= '2019-09-18 23:59:59'
	AND lpep_dropoff_datetime >= '2019-09-18 00:00:00' AND lpep_pickup_datetime <= '2019-09-18 23:59:59'
;
```

# **Question 4. Largest trip for each day**

Which was the pick up day with the largest trip distance Use the pick up time for your calculations.

- 2019-09-18 - Largest trip distance: 70.28
- 2019-09-16 - Largest trip distance: 114.3
- `2019-09-26  - Largest trip distance: 341.64`
- 2019-09-21 - Largest trip distance: 135.53

> **First, need to describe the columns on the table, then select the dates to filter the days:**
> 

```sql
SELECT 
  column_name, 
  data_type, 
  character_maximum_length, 
  is_nullable, 
  column_default 
FROM 
  information_schema.columns 
WHERE 
  table_name = 'green_taxi_data';
```

> **Select Trips from the desired dates, and order by trip distance**
> 

```sql
SELECT *
FROM green_taxi_data
WHERE 
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-16' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-18' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-21' OR
	CAST(lpep_pickup_datetime AS DATE) = '2019-09-26'
ORDER BY trip_distance DESC
LIMIT 10;
```

# **Question 5. Three biggest pick up Boroughs**

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

- "Brooklyn" "Manhattan" "Queens"
- `"Bronx" "Brooklyn" "Manhattan"`
- "Bronx" "Manhattan" "Queens"
- "Brooklyn" "Queens" "Staten Island"

> **In order to achieve this, a INNER JOIN must be created to relate *zones* table and *green_taxi_data* table**
> 

```sql
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
```

# **Question 6. Largest tip**

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? We want the name of the zone, not the id.

Note: it's not a typo, it's *tip* , not *trip*

- Central Park
- Jamaica
- `JFK Airport`
- Long Island City/Queens Plaza

> **For this, is necessary to first make a double inner join in order to obtain the name of the PU and DO Zones, after that, filter by month and the desired zone. Finally order by the biggest tip received.**
> 

```sql
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
```
